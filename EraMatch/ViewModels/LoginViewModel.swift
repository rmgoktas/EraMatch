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
                self.alertMessage = "Error: \(error.localizedDescription)"
                self.showingAlert = true
                self.isLoading = false
                return
            }
            
            guard let uid = authResult?.user.uid else {
                self.alertMessage = "User ID not found."
                self.showingAlert = true
                self.isLoading = false
                return
            }
            
            let db = Firestore.firestore()
            
            // Check in 'ngos' collection
            db.collection("ngos").document(uid).getDocument { document, error in
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
                    self.isLoading = false
                } else {
                    // Check in 'travellers' collection if not found in 'users'
                    db.collection("travellers").document(uid).getDocument { document, error in
                        if let document = document, document.exists {
                            self.navigateToTravellerHome = true
                        } else {
                            self.alertMessage = "User data not found."
                            self.showingAlert = true
                        }
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    func logoutUser() {
        do {
            try Auth.auth().signOut()
            // Reset navigation flags or navigate back to login screen
            navigateToTravellerHome = false
            navigateToNGOHome = false
        } catch let signOutError as NSError {
            self.alertMessage = "Error signing out: \(signOutError.localizedDescription)"
            self.showingAlert = true
        }
    }
}


