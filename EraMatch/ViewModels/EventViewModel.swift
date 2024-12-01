import Foundation
import Firebase
import FirebaseFirestore

class EventCardViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    func fetchEvents(for creatorId: String) {
        print("Attempting to fetch events for creator ID: \(creatorId)")
        db.collection("events").whereField("creatorId", isEqualTo: creatorId).getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found in the 'events' collection")
                return
            }
            
            print("Found \(documents.count) documents")
            
            self?.events = documents.compactMap { queryDocumentSnapshot in
                do {
                    let event = try queryDocumentSnapshot.data(as: Event.self)
                    print("Successfully decoded event: \(event.title)")
                    return event
                } catch {
                    print("Error decoding event: \(error.localizedDescription)")
                    return nil
                }
            }
            
            print("Successfully decoded \(self?.events.count ?? 0) events")
        }
    }
}
