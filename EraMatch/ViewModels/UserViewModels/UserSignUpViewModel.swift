//
//  UserSignUpViewModel.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 15.07.2024.
//

import SwiftUI
import Firebase

class UserSignUpViewModel: ObservableObject {
    @Published var userName = ""
    @Published var userEmail = ""
    @Published var userPassword = ""
    @Published var userConfirmedPassword = ""
    @Published var userCountry = ""
    @Published var showingCountryPicker = false
    
    @Published var showingAlert = false
    @Published var alertMessage = ""
    
    @Published var navigateToHome = false
    
    @Published var isLoading = false
    
    let countries = CountryList.countries // CountryList.swift dosyasından gelen ülkeler dizisi
    
    // MARK: - Form Validation
    func isFormValid() -> Bool {
        return !userName.isEmpty &&
               !userEmail.isEmpty &&
               !userPassword.isEmpty &&
               userPassword == userConfirmedPassword &&
               !userCountry.isEmpty
    }
    
    // MARK: - Password Validation
    func validatePasswords() -> Bool {
        return userPassword == userConfirmedPassword
    }
    
    func signUpUser(userType: String) {
        isLoading = true
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
            if let error = error {
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
                self.isLoading = false
                return
            }
            guard let uid = authResult?.user.uid else { return }
            let db = Firestore.firestore()
            db.collection("travellers").document(uid).setData([
                "uid": uid,
                "type": userType, // Burada userType değişkenini kullanarak type alanını ayarlıyoruz
                "userName": self.userName,
                "email": self.userEmail,
                "country": self.userCountry
            ]) { error in
                self.isLoading = false
                if let error = error {
                    self.alertMessage = error.localizedDescription
                    self.showingAlert = true
                } else {
                    self.navigateToHome = true
                }
            }
        }
    }
}

