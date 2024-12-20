//
//  UserSubmissionViewModel.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 17.12.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class UserSubmissionViewModel: ObservableObject {
    private let db = Firestore.firestore()
    @Published var submissions: [Submission] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func saveSubmission(for event: Event) {
        guard let userId = Auth.auth().currentUser?.uid,
              let eventId = event.id else { return }
        
        // Kullanıcının daha önce bu etkinliğe başvurup başvurmadığını kontrol et
        db.collection("submissions")
            .whereField("userId", isEqualTo: userId)
            .whereField("eventId", isEqualTo: eventId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.error = error.localizedDescription
                    print("Error checking submissions: \(error.localizedDescription)")
                    return
                }
                
                if let existingSubmission = snapshot?.documents.first {
                    // Eğer başvuru zaten varsa, güncelle
                    self?.db.collection("submissions").document(existingSubmission.documentID).updateData([
                        "date": Timestamp(date: Date()),
                        "eventTitle": event.title,
                        "eventCountry": event.country
                    ]) { error in
                        if let error = error {
                            self?.error = error.localizedDescription
                            print("Error updating submission: \(error.localizedDescription)")
                        } else {
                            print("Submission successfully updated")
                        }
                    }
                } else {
                    // Eğer başvuru yoksa, yeni bir başvuru kaydet
                    let submission = [
                        "userId": userId,
                        "eventId": eventId,
                        "date": Timestamp(date: Date()),
                        "eventTitle": event.title,
                        "eventCountry": event.country
                    ] as [String : Any]
                    
                    self?.db.collection("submissions").addDocument(data: submission) { error in
                        if let error = error {
                            self?.error = error.localizedDescription
                            print("Error saving submission: \(error.localizedDescription)")
                        } else {
                            print("Submission successfully saved")
                        }
                    }
                }
            }
    }
    
    func fetchUserSubmissions() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        db.collection("submissions")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                self?.submissions = snapshot?.documents.compactMap { document in
                    try? document.data(as: Submission.self)
                } ?? []
            }
    }
    
    func resetApplicationStatus() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        UserDefaults.standard.removeObject(forKey: "applied_\(userId)")
    }
}

// Submissions
struct Submission: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let eventId: String
    let date: Date
    let eventTitle: String
    let eventCountry: String
}
