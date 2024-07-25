//
//  UserHomeViewModel.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 20.07.2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class UserHomeViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var topics = ["Improve Yourself", "Climate Change", "Artistic Skills", "Equality Rights", "Digital Skills (STEM)", "Health Care"]
    
    @Published var username = ""
    @Published var bio = ""
    @Published var country = ""
    @Published var email = ""
    @Published var instagram = ""
    @Published var facebook = ""

    private var db = Firestore.firestore()
    
    private var userId: String {
        // Firebase Auth ile giriş yapmış kullanıcının ID'sini alıyoruz
        return Auth.auth().currentUser?.uid ?? ""
    }

    init() {
        fetchUsername()
        loadUserData()
    }

    func fetchUsername() {
        guard let user = Auth.auth().currentUser else {
            return
        }

        // Kullanıcı ID'sine göre Firestore'dan veri çekme
        let userId = user.uid
        db.collection("travellers").document(userId).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                self?.userName = document.data()?["userName"] as? String ?? "Unknown"
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func updateUserField(field: String, value: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("travellers").document(userId).updateData([field: value]) { error in
            if let error = error {
                print("Error updating user \(field): \(error)")
            } else {
                print("\(field) updated successfully")
            }
        }
    }
    
    func loadUserData() {
        guard !userId.isEmpty else {
            print("User ID is empty")
            return
        }

        db.collection("travellers").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self.username = data?["username"] as? String ?? ""
                    self.bio = data?["bio"] as? String ?? ""
                    self.country = data?["country"] as? String ?? ""
                    self.email = data?["email"] as? String ?? ""
                    self.instagram = data?["instagram"] as? String ?? ""
                    self.facebook = data?["facebook"] as? String ?? ""
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}



