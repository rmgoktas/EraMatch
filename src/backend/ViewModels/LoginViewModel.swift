import SwiftUI
import FirebaseAuth

class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    @Published var isLoggedIn: Bool = false
    
    init() {
        // Uygulama açıldığında kullanıcı bilgilerini kontrol et
        if let savedEmail = UserDefaults.standard.string(forKey: "userEmail") {
            self.email = savedEmail
            self.isLoggedIn = true
            
            // Şifreyi Keychain'den yükle
            if let savedPasswordData = KeychainHelper.load(key: "userPassword"),
               let savedPassword = String(data: savedPasswordData, encoding: .utf8) {
                self.password = savedPassword
                self.loginUser() // Otomatik giriş yap
            }
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
            
            UserDefaults.standard.set(self.email, forKey: "userEmail")
            KeychainHelper.save(key: "userPassword", data: self.password.data(using: .utf8)!) // Şifreyi kaydet
            self.isLoggedIn = true
        }
    }
    
    func logoutUser() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "userEmail")
            KeychainHelper.delete(key: "userPassword") // Şifreyi sil
            self.isLoggedIn = false
        } catch let signOutError as NSError {
            alertMessage = "Error signing out: \(signOutError.localizedDescription)"
            showingAlert = true
        }
    }
} 