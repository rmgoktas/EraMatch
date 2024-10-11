//
//  NgoHomeViewModel.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 10.10.2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class NgoHomeViewModel: ObservableObject {
    @Published var ngoName: String = ""
    @Published var oidNumber: String = ""
    @Published var country: String = ""
    @Published var email: String = ""
    @Published var logoUrl: String = ""
    @Published var pifUrl: String = ""
    @Published var instagram: String = ""
    @Published var facebook: String = ""

    private var db = Firestore.firestore()

    private var userId: String {
        // Firebase Auth ile giriş yapmış NGO'nun ID'sini alıyoruz
        return Auth.auth().currentUser?.uid ?? ""
    }

    init() {
        loadNgoData()
    }

    func loadNgoData() {
        guard !userId.isEmpty else {
            print("User ID is empty")
            return
        }

        db.collection("ngos").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error)")
                return
            }
            
            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }
            
            let data = document.data()
            DispatchQueue.main.async {
                self.ngoName = data?["ngoName"] as? String ?? ""
                self.oidNumber = data?["oidNumber"] as? String ?? ""
                self.country = data?["country"] as? String ?? ""
                self.email = data?["email"] as? String ?? ""
                self.logoUrl = data?["logoUrl"] as? String ?? ""
                self.pifUrl = data?["pifUrl"] as? String ?? ""
                self.instagram = data?["instagram"] as? String ?? ""
                self.facebook = data?["facebook"] as? String ?? ""
            }
        }
    }

    func updateNgoField(field: String, value: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("ngos").document(userId).updateData([field: value]) { error in
            if let error = error {
                print("Error updating NGO \(field): \(error)")
            } else {
                print("\(field) updated successfully")
            }
        }
    }
}
