import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class CreateEventViewModel: ObservableObject {
    @Published var event: Event
    @Published var selectedInfoPack: URL?
    @Published var selectedPhoto: URL?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init() {
        // Event'i oluştururken creatorId'yi boş bir string olarak başlatıyoruz
        self.event = Event(title: "", country: "", type: "", topic: "", startDate: Date(), endDate: Date(), included: [], lookingFor: [], countries: [], reimbursementLimit: 0, formLink: "", creatorId: "")
    }
    
    func createEvent(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // Mevcut kullanıcının ID'sini al
        guard let currentUser = Auth.auth().currentUser else {
            self.errorMessage = "No authenticated user found"
            self.isLoading = false
            completion(false)
            return
        }
        
        // Event'in creatorId'sini ayarla
        self.event.creatorId = currentUser.uid
        
        uploadInfoPack { infoPackURL in
            self.uploadPhoto { photoURL in
                self.event.eventInfoPackURL = infoPackURL
                self.event.eventPhotoURL = photoURL
                
                do {
                    let docRef = try self.db.collection("events").addDocument(from: self.event)
                    print("Event created successfully with ID: \(docRef.documentID)")
                    self.isLoading = false
                    completion(true)
                } catch {
                    print("Error creating event: \(error.localizedDescription)")
                    self.errorMessage = "Failed to create event: \(error.localizedDescription)"
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
    
    private func uploadInfoPack(completion: @escaping (String?) -> Void) {
        guard let infoPack = selectedInfoPack else {
            completion(nil)
            return
        }
        
        let storageRef = storage.reference().child("infopacks/\(UUID().uuidString).pdf")
        storageRef.putFile(from: infoPack, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading info pack: \(error.localizedDescription)")
                self.errorMessage = "Failed to upload info pack: \(error.localizedDescription)"
                completion(nil)
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting info pack download URL: \(error.localizedDescription)")
                        self.errorMessage = "Failed to get info pack download URL: \(error.localizedDescription)"
                        completion(nil)
                    } else {
                        completion(url?.absoluteString)
                    }
                }
            }
        }
    }
    
    private func uploadPhoto(completion: @escaping (String?) -> Void) {
        guard let photo = selectedPhoto else {
            completion(nil)
            return
        }
        
        let storageRef = storage.reference().child("eventphotos/\(UUID().uuidString).jpg")
        storageRef.putFile(from: photo, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading photo: \(error.localizedDescription)")
                self.errorMessage = "Failed to upload photo: \(error.localizedDescription)"
                completion(nil)
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting photo download URL: \(error.localizedDescription)")
                        self.errorMessage = "Failed to get photo download URL: \(error.localizedDescription)"
                        completion(nil)
                    } else {
                        completion(url?.absoluteString)
                    }
                }
            }
        }
    }
}

