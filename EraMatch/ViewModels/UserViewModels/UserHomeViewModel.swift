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
    private var db = Firestore.firestore()

    init() {
        fetchUsername()
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
}

