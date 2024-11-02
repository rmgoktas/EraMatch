import SwiftUI
import Firebase

class LoginViewModel: ObservableObject {
    
    @Published var currentUser: Firebase.User? = Auth.auth().currentUser
    @Published var email = ""
    @Published var password = ""
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    
    @Published var navigateToTravellerHome = false
    @Published var navigateToNGOHome = false
    @Published var isLoggedIn: Bool = true
    
    init() {
        if let savedEmail = UserDefaults.standard.string(forKey: "userEmail") {
            self.email = savedEmail
        }
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
        }
    }
    
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
            
            UserDefaults.standard.set(self.email, forKey: "userEmail")
            UserDefaults.standard.set(true, forKey: "isLoggedIn")

            let db = Firestore.firestore()
            
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
            navigateToTravellerHome = false
            navigateToNGOHome = false
            UserDefaults.standard.removeObject(forKey: "userEmail")
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            self.isLoggedIn = false 
        } catch let signOutError as NSError {
            alertMessage = "Error signing out: \(signOutError.localizedDescription)"
            showingAlert = true
            print("Sign out error: \(signOutError.localizedDescription)") 
            
        }
    }
}

