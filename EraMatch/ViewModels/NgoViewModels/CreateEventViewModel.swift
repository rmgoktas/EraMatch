import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class CreateEventViewModel: ObservableObject {
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
        
        uploadInfoPack { infoPackURL in
            self.uploadPhoto { photoURL in
                self.event.eventInfoPackURL = infoPackURL
                self.event.eventPhotoURL = photoURL
                
                do {
                    let _ = try self.db.collection("events").addDocument(from: self.event)
                    print("Event created successfully")
                    self.isLoading = false
                    completion(true)
                } catch {
                    print("Error creating event: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
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
                completion(nil)
            } else {
                storageRef.downloadURL { url, error in
                    completion(url?.absoluteString)
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
                completion(nil)
            } else {
                storageRef.downloadURL { url, error in
                    completion(url?.absoluteString)
                }
            }
        }
    }
}
