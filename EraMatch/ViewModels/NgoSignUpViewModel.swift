//
//  NgoSignUpViewModel.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 15.07.2024.
//

import SwiftUI
import Firebase

class NgoSignUpViewModel: ObservableObject {
    @Published var ngoName = ""
    @Published var oidNumber = ""
    @Published var ngoEmail = ""
    @Published var ngoPassword = ""
    @Published var ngoConfirmedPassword = ""
    @Published var ngoCountry = ""
    @Published var showingCountryPicker = false
    
    @Published var showingAlert = false
    @Published var alertMessage = ""
    
    @Published var navigateToHome = false
    
    @Published var isLoading = false
    
    let countries = CountryList.countries // CountryList.swift dosyasından gelen ülkeler dizisi
    
    // MARK: - Form Validation
    func isFormValid() -> Bool {
        return !ngoName.isEmpty &&
               !oidNumber.isEmpty &&
               !ngoEmail.isEmpty &&
               !ngoPassword.isEmpty &&
               ngoPassword == ngoConfirmedPassword &&
               !ngoCountry.isEmpty
    }
    
    // MARK: - Password Validation
    func validatePasswords() -> Bool {
        return ngoPassword == ngoConfirmedPassword
    }
    
    func signUpNgo(userType: String) {
        isLoading = true
        Auth.auth().createUser(withEmail: ngoEmail, password: ngoPassword) { authResult, error in
            if let error = error {
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
                self.isLoading = false
                return
            }
            guard let uid = authResult?.user.uid else { return }
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData([
                "uid": uid,
                "type": userType, // Burada userType değişkenini kullanarak type alanını ayarlıyoruz
                "ngoName": self.ngoName,
                "email": self.ngoEmail,
                "oidNumber": self.oidNumber,
                "country": self.ngoCountry
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

