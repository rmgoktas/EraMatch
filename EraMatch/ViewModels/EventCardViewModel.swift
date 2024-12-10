import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

@MainActor
class EventCardViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userNationality: String = ""
    
    private var db = Firestore.firestore()
    private var cache: [String: [Event]] = [:]
    
    func fetchEvents(for creatorId: String) {
        if let cachedEvents = cache[creatorId] {
            print("Veriler önbellekten yüklendi.")
            self.events = cachedEvents
            return
        }
        
        print("Veriler önbellekte yok, Firebase'den çekiliyor...")
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
                
                print("Veriler başarıyla çekildi. Olay sayısı: \(fetchedEvents.count)")
                self?.events = fetchedEvents
                self?.cache[creatorId] = fetchedEvents // Veriyi önbelleğe kaydet
            }
        }
    }
    
    func refreshEvents(for creatorId: String) async {
        print("Veriler yenileniyor...")
        isLoading = true
        cache[creatorId] = nil // Önbelleği temizle
        
        do {
            let querySnapshot = try await db.collection("events").whereField("creatorId", isEqualTo: creatorId).getDocuments()
            
            let fetchedEvents = querySnapshot.documents.compactMap { queryDocumentSnapshot -> Event? in
                var event = try? queryDocumentSnapshot.data(as: Event.self)
                if event?.id == nil {
                    event?.id = queryDocumentSnapshot.documentID
                }
                return event
            }
            
            print("Veriler başarıyla yenilendi. Olay sayısı: \(fetchedEvents.count)")
            self.events = fetchedEvents
            self.cache[creatorId] = fetchedEvents // Veriyi önbelleğe kaydet
        } catch {
            print("Error refreshing events: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func startListening(for creatorId: String) {
        db.collection("events").whereField("creatorId", isEqualTo: creatorId).addSnapshotListener { [weak self] querySnapshot, error in
            if let error = error {
                print("Snapshot dinleme hatası: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("Snapshot'ta döküman bulunamadı")
                return
            }
            
            let updatedEvents = documents.compactMap { try? $0.data(as: Event.self) }
            DispatchQueue.main.async {
                self?.events = updatedEvents
                self?.cache[creatorId] = updatedEvents // Önbelleği güncelle
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
            isLoading = true
            
            await fetchUserNationality()
            
            guard !userNationality.isEmpty else {
                isLoading = false
                return
            }
            
            print("Fetching events for user with nationality: \(userNationality)")
            
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
                
                print("Events fetched successfully. Event count: \(fetchedEvents.count)")
                self.events = fetchedEvents
            } catch {
                print("Error fetching events: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }



