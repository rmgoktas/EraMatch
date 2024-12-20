import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class CreateEventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var event = Event(
        id: nil,
        title: "",
        country: "",
        type: "",
        topic: "",
        startDate: Date(),
        endDate: Date(),
        includedItems: IncludedItems(),
        lookingFor: [],
        countries: [],
        reimbursementLimit: 0,
        eventInfoPackURL: nil,
        eventPhotoURL: nil,
        formLink: "",
        creatorId: "",
        otherTopic: ""
    )
    
    @Published var selectedInfoPack: URL?
    @Published var selectedPhoto: URL?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var oidNumberInput: String = ""
    @Published var isLoadingNGO = false
    @Published var ngoError: String?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func createEvent(completion: @escaping (Bool) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not logged in."
            completion(false)
            return
        }
        
        isLoading = true
        self.event.creatorId = currentUserId
        
        uploadInfoPack { [weak self] infoPackURL in
            guard let self = self else { return }
            
            if infoPackURL == nil {
                self.errorMessage = "Failed to upload info pack"
                self.isLoading = false
                completion(false)
                return
            }
            
            self.uploadPhoto { photoURL in
                if photoURL == nil {
                    self.errorMessage = "Failed to upload photo"
                    self.isLoading = false
                    completion(false)
                    return
                }
                
                self.event.eventInfoPackURL = infoPackURL
                self.event.eventPhotoURL = photoURL
                
                do {
                    let docRef = try self.db.collection("events").addDocument(from: self.event)
                    print("Event created successfully with ID: \(docRef.documentID)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completion(true)
                    }
                } catch {
                    print("Error creating event: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completion(false)
                    }
                }
            }
        }
    }
    
    private func uploadInfoPack(completion: @escaping (String?) -> Void) {
        guard let infoPack = selectedInfoPack,
              let infoPackData = try? Data(contentsOf: infoPack) else {
            print("Info pack data could not be read")
            completion(nil)
            return
        }
        
        let fileName = "infopack_\(UUID().uuidString).pdf"
        let storageRef = storage.reference().child("infopacks/\(fileName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "application/pdf"
        
        storageRef.putData(infoPackData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading info pack: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString)
            }
        }
    }
    
    private func uploadPhoto(completion: @escaping (String?) -> Void) {
        guard let photo = selectedPhoto,
              let imageData = try? Data(contentsOf: photo) else {
            print("Photo data could not be read")
            completion(nil)
            return
        }
        
        let fileName = "eventphoto_\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child("eventphotos/\(fileName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading photo: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString)
            }
        }
    }
    
    func fetchNGODetails(oidNumber: String, completion: @escaping (Bool) -> Void) {
        isLoadingNGO = true
        ngoError = nil
        
        db.collection("ngos")
            .whereField("oidNumber", isEqualTo: oidNumber)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoadingNGO = false
                    
                    if let error = error {
                        self.ngoError = "Error: \(error.localizedDescription)"
                        completion(false)
                        return
                    }
                    
                    guard let document = snapshot?.documents.first else {
                        self.ngoError = "No NGO found with this OID number"
                        completion(false)
                        return
                    }
                    
                    do {
                        let ngo = try document.data(as: NGO.self)
                        
                        let countryNGO = CountryNGO(country: ngo.country, ngoName: ngo.ngoName)
                        
                        // kontrol
                        if self.event.countries.contains(where: { $0.country == countryNGO.country }) {
                            self.ngoError = "An NGO from this country is already added"
                            completion(false)
                            return
                        }
                        
                        // diziye ekle
                        self.event.countries.append(countryNGO)
                        completion(true)
                    } catch {
                        self.ngoError = "Error parsing NGO data"
                        completion(false)
                    }
                }
            }
    }
    func isValidOIDFormat(_ oid: String) -> Bool {
        let pattern = "^E[0-9]{8}$"
        return oid.range(of: pattern, options: .regularExpression) != nil
    }
    
    func refreshEvents(for creatorId: String) async {
        print("Refreshing data...")
        isLoading = true
        
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
        } catch {
            print("Error refreshing events: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
