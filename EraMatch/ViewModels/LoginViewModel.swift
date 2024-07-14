//
//  LoginViewModel.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 15.07.2024.
//

import SwiftUI
import Firebase

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    
    @Published var navigateToTravellerHome = false
    @Published var navigateToNGOHome = false
    
    func loginUser() {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
                self.isLoading = false
                return
            }
            
            guard let uid = authResult?.user.uid else { return }
            let db = Firestore.firestore()
            db.collection("users").document(uid).getDocument { document, error in
                self.isLoading = false
                if let document = document, document.exists {
                    let userData = document.data()
                    let userType = userData?["type"] as? String ?? ""
                    
                    if userType == "traveller" {
                        self.navigateToTravellerHome = true
                    } else if userType == "ngo" {
                        self.navigateToNGOHome = true
                    } else {
                        self.alertMessage = "Unknown user type."
                        self.showingAlert = true
                    }
                } else {
                    self.alertMessage = "User data not found."
                    self.showingAlert = true
                }
            }
        }
    }
}
