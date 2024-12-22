import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

@MainActor
class EventCardViewModel: ObservableObject {
    static let shared = EventCardViewModel()
    
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userNationality: String = ""
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    private var db = Firestore.firestore()
    private var cache: [String: [Event]] = [:]
    private var cachedEvents: [Event] = []
    private var lastFetchTime: Date?
    private let cacheValidityDuration: TimeInterval = 300
    private var isFetching = false
    private let imageCache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func fetchEvents(for creatorId: String) {
        if let cachedEvents = cache[creatorId] {
            print("Data loaded from cache")
            self.events = cachedEvents
            return
        }
        
        print("Data not in cache, fetching from Firebase...")
        isLoading = true
        db.collection("events").whereField("creatorId", isEqualTo: creatorId).getDocuments { [weak self] (querySnapshot, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found in the 'events' collection")
                    return
                }
                
                let fetchedEvents = documents.compactMap { queryDocumentSnapshot -> Event? in
                    var event = try? queryDocumentSnapshot.data(as: Event.self)
                    if event?.id == nil {
                        event?.id = queryDocumentSnapshot.documentID
                    }
                    return event
                }
                
                print("Data fetched successfully. Event count: \(fetchedEvents.count)")
                self?.events = fetchedEvents
                self?.cache[creatorId] = fetchedEvents
            }
        }
    }
    
    func refreshEvents(for creatorId: String) async {
        print("Refreshing data...")
        isLoading = true
        cache[creatorId] = nil
        
        do {
            let querySnapshot = try await db.collection("events").whereField("creatorId", isEqualTo: creatorId).getDocuments()
            
            let fetchedEvents = querySnapshot.documents.compactMap { queryDocumentSnapshot -> Event? in
                var event = try? queryDocumentSnapshot.data(as: Event.self)
                if event?.id == nil {
                    event?.id = queryDocumentSnapshot.documentID
                }
                return event
            }
            
            print("Data refreshed successfully. Event count: \(fetchedEvents.count)")
            self.events = fetchedEvents
            self.cache[creatorId] = fetchedEvents
        } catch {
            print("Error refreshing events: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func startListening(for creatorId: String) {
        db.collection("events").whereField("creatorId", isEqualTo: creatorId).addSnapshotListener { [weak self] querySnapshot, error in
            if let error = error {
                print("Snapshot listening error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found in snapshot")
                return
            }
            
            let updatedEvents = documents.compactMap { try? $0.data(as: Event.self) }
            DispatchQueue.main.async {
                self?.events = updatedEvents
                self?.cache[creatorId] = updatedEvents
            }
        }
    }
    
    func fetchUserNationality() async {
            guard let userId = Auth.auth().currentUser?.uid else {
                self.errorMessage = "User not logged in"
                return
            }
            
            do {
                let document = try await db.collection("travellers").document(userId).getDocument()
                if let country = document.data()?["country"] as? String {
                    self.userNationality = country
                    print("User nationality fetched: \(country)")
                } else {
                    self.errorMessage = "User country not found"
                }
            } catch {
                self.errorMessage = "Error fetching user country: \(error.localizedDescription)"
                print("Error fetching user country: \(error.localizedDescription)")
            }
        }
        
        func fetchEventsForUser() async {
            print("fetchEventsForUser called")
            print("Cache status: events count: \(cachedEvents.count), last fetch time: \(lastFetchTime?.description ?? "nil")")
            
            // Eğer zaten bir fetch işlemi devam ediyorsa, yeni fetch işlemini engelle
            guard !isFetching else {
                print("Fetch already in progress, skipping...")
                return
            }
            
            // Cache kontrolü
            if !cachedEvents.isEmpty, let lastFetch = lastFetchTime {
                let timeSinceLastFetch = Date().timeIntervalSince(lastFetch)
                print("Time since last fetch: \(timeSinceLastFetch) seconds")
                
                if timeSinceLastFetch < cacheValidityDuration {
                    print("Loading data from cache...")
                    await MainActor.run {
                        self.events = self.cachedEvents
                        self.isLoading = false
                    }
                    return
                } else {
                    print("Cache expired, reloading...")
                }
            } else {
                print("Cache empty, loading for the first time...")
            }
            
            isFetching = true
            defer { isFetching = false }
            
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }
            
            await fetchUserNationality()
            
            guard !userNationality.isEmpty else {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "User nationality not found"
                }
                return
            }
            
            do {
                let querySnapshot = try await db.collection("events").getDocuments()
                
                let fetchedEvents = querySnapshot.documents.compactMap { queryDocumentSnapshot -> Event? in
                    guard var event = try? queryDocumentSnapshot.data(as: Event.self) else { return nil }
                    if event.id == nil {
                        event.id = queryDocumentSnapshot.documentID
                    }
                    return event
                }.filter { event in
                    event.lookingFor.contains { $0.nationality.lowercased() == userNationality.lowercased() }
                }
                
                await MainActor.run {
                    self.events = fetchedEvents
                    self.cachedEvents = fetchedEvents
                    self.lastFetchTime = Date()
                    self.isLoading = false
                    print("Data loaded successfully and cached")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    
    @MainActor
    func clearCache() {
        cachedEvents = []
        lastFetchTime = nil
        cache.removeAll()
        events = []
    }
    
    // Cache'i manuel olarak yenilemek için
    func forceRefresh() async {
        clearCache()
        await fetchEventsForUser()
    }
    
    func loadImage(from urlString: String) async -> UIImage? {
        // cache kontrol
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            print("Image loaded from cache: \(urlString)")
            return cachedImage
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid image URL: \(urlString)")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                // caching done
                imageCache.object(forKey: urlString as NSString)
                print("Image cached: \(urlString)")
                return image
            }
        } catch {
            print("Error loading image: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func clearImageCache() {
        imageCache.removeAllObjects()
        print("Image cache cleared")
    }
    
    func deleteEvent(eventId: String) async throws {
        let db = Firestore.firestore()
        try await db.collection("events").document(eventId).delete()
        
        if let index = events.firstIndex(where: { $0.id == eventId }) {
            events.remove(at: index)
        }
        
        if let index = cachedEvents.firstIndex(where: { $0.id == eventId }) {
            cachedEvents.remove(at: index)
        }
        
        cache.removeValue(forKey: eventId)
    }
    
    func fetchEventsByTopic(for userCountry: String, topic: String) async {
        print("Fetching events for country: \(userCountry) and topic: \(topic)...")
        isLoading = true
        
        do {
            let querySnapshot = try await db.collection("events")
                .whereField("topic", isEqualTo: topic)
                .getDocuments()
            
            let fetchedEvents = querySnapshot.documents.compactMap { queryDocumentSnapshot -> Event? in
                var event = try? queryDocumentSnapshot.data(as: Event.self)
                if event?.id == nil {
                    event?.id = queryDocumentSnapshot.documentID
                }
                return event
            }.filter { event in
                event.lookingFor.contains { $0.nationality.lowercased() == userCountry.lowercased() }
            }
            
            print("Fetched events: \(fetchedEvents)")
            
            if fetchedEvents.isEmpty {
                print("No events found for the specified criteria.")
                self.alertMessage = "No events found for the specified criteria."
                self.showAlert = true
            } else {
                print("Data fetched successfully. Event count: \(fetchedEvents.count)")
            }
            
            self.events = fetchedEvents
        } catch {
            print("Error fetching events: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}



