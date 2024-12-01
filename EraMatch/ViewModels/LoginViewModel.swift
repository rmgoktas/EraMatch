import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class LoginViewModel: ObservableObject {
    
    @Published var currentUser: User? = Auth.auth().currentUser
    @Published var email = ""
    @Published var password = ""
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    
    @Published var navigateToTravellerHome = false
    @Published var navigateToNGOHome = false
    @Published var isLoggedIn: Bool = false
    
    init() {
        if let savedEmail = UserDefaults.standard.string(forKey: "userEmail") {
            self.email = savedEmail
        }
        
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isLoggedIn = user != nil
        }
    }
    
    func loginUser() {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
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

            self.checkUserType(uid: uid)
        }
    }
    
    private func checkUserType(uid: String) {
        let db = Firestore.firestore()
        
        db.collection("ngos").document(uid).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
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
                self.checkTravellerUser(uid: uid)
            }
        }
    }
    
    private func checkTravellerUser(uid: String) {
        let db = Firestore.firestore()
        
        db.collection("travellers").document(uid).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                self.navigateToTravellerHome = true
            } else {
                self.alertMessage = "User data not found."
                self.showingAlert = true
            }
            self.isLoading = false
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
