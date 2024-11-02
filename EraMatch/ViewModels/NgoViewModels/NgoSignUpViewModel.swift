import SwiftUI
import Firebase
import FirebaseStorage

class NgoSignUpViewModel: ObservableObject {
    @Published var ngoName = ""
    @Published var oidNumber = ""
    @Published var ngoEmail = ""
    @Published var ngoPassword = ""
    @Published var ngoConfirmedPassword = ""
    @Published var ngoCountry = ""
    @Published var showingCountryPicker = false
    @Published var instagram = ""
    @Published var facebook = ""
    
    @Published var showingAlert = false
    @Published var alertMessage = ""
    
    @Published var navigateToHome = false
    
    @Published var isLoading = false
    
    @Published var pifUrl: URL?
    @Published var logoUrl: URL?
    
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
            db.collection("ngos").document(uid).setData([
                "uid": uid,
                "type": userType,
                "ngoName": self.ngoName,
                "email": self.ngoEmail,
                "oidNumber": self.oidNumber,
                "country": self.ngoCountry,
                "logoUrl": self.logoUrl?.absoluteString ?? "",
                "pifUrl": self.pifUrl?.absoluteString ?? ""
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
    
    func handleFileUpload(fileUrl: URL, isPIF: Bool, completion: @escaping (URL?, String) -> Void) {
        let storageRef = Storage.storage().reference()
        let fileName = UUID().uuidString
        let fileRef = isPIF ? storageRef.child("pifs/\(fileName).pdf") : storageRef.child("logos/\(fileName).png")
        
        let shouldStopAccessing = fileUrl.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                fileUrl.stopAccessingSecurityScopedResource()
            }
        }
        
        guard FileManager.default.fileExists(atPath: fileUrl.path) else {
            print("File does not exist at path: \(fileUrl.path)")
            completion(nil, "File not found")
            return
        }
        
        do {
            let fileData = try Data(contentsOf: fileUrl)
            fileRef.putData(fileData, metadata: nil) { metadata, error in
                if let error = error {
                    print("File upload error: \(error.localizedDescription)")
                    completion(nil, error.localizedDescription)
                    return
                }
                
                fileRef.downloadURL { url, error in
                    if let error = error {
                        print("Failed to retrieve download URL: \(error.localizedDescription)")
                        completion(nil, error.localizedDescription)
                        return
                    }
                    completion(url, fileUrl.lastPathComponent)
                }
            }
        } catch {
            print("Error reading file data: \(error.localizedDescription)")
            completion(nil, error.localizedDescription)
        }
    }

    func saveImageToDocuments(image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 1) else { return nil }
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString + ".jpg"
        let fileUrl = documents.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileUrl)
            return fileUrl
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return nil
        }
    }
}
