//
//  NgoHomeViewModel.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 10.10.2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class NgoHomeViewModel: ObservableObject {
    @Published var ngoName: String = ""
    @Published var oidNumber: String = ""
    @Published var country: String = ""
    @Published var email: String = ""
    @Published var logoUrl: URL?
    @Published var pifUrl: URL?
    @Published var instagram: String = ""
    @Published var facebook: String = ""
    @Published var pdfData: Data?
    @Published var isLoading: Bool = false
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    @Published private var editingFields: [String: Bool] = [
        "country": false,
        "oidNumber": false,
        "email": false,
        "instagram": false,
        "facebook": false,
        "pifUrl": false,
        "logoUrl": false
    ]
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        loadNgoData()
    }
    
    func loadNgoData() {
        guard let userId = userId else {
            print("User not logged in.")
            return
        }
        
        db.collection("ngos").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self?.ngoName = data["ngoName"] as? String ?? ""
                    self?.oidNumber = data["oidNumber"] as? String ?? ""
                    self?.email = data["email"] as? String ?? ""
                    self?.country = data["country"] as? String ?? ""
                    self?.instagram = data["instagram"] as? String ?? ""
                    self?.facebook = data["facebook"] as? String ?? ""
                    
                    if let pifUrlString = data["pifUrl"] as? String {
                        self?.pifUrl = URL(string: pifUrlString)
                    }
                    
                    if let logoUrlString = data["logoUrl"] as? String {
                        self?.logoUrl = URL(string: logoUrlString)
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func loadPDFData() {
        guard let pifUrl = pifUrl else { return }
        
        isLoading = true
        let task = URLSession.shared.dataTask(with: pifUrl) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let data = data, error == nil {
                    self?.pdfData = data
                } else {
                    print("Error loading PDF: \(String(describing: error))")
                }
            }
        }
        task.resume()
    }
    func uploadPDF(url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            print("Dosyaya erişim sağlanamadı.")
            return
        }
        
        isLoading = true
        handleFileUpload(fileUrl: url, isPIF: true) { [weak self] uploadedUrl, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let uploadedUrl = uploadedUrl {
                    self?.pifUrl = uploadedUrl
                    self?.updateField("pifUrl", value: uploadedUrl.absoluteString)
                } else {
                    print("Yükleme başarısız.")
                }
                url.stopAccessingSecurityScopedResource()
            }
        }
    }
    func uploadLogo(url: URL) {
        isLoading = true
        handleFileUpload(fileUrl: url, isPIF: false) { [weak self] uploadedUrl, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let uploadedUrl = uploadedUrl {
                    self?.logoUrl = uploadedUrl
                    self?.updateField("logoUrl", value: uploadedUrl.absoluteString)
                }
            }
        }
    }
    
    func handleImageUpload(image: UIImage, fileExtension: String, completion: @escaping (URL?, String?) -> Void) {
        let storageRef = Storage.storage().reference()
        let fileName = UUID().uuidString + "." + fileExtension
        let fileRef = storageRef.child("logos/\(fileName)")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Image data conversion failed")
            completion(nil, "Image data conversion failed")
            return
        }
        
        fileRef.putData(imageData, metadata: nil) { metadata, error in
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
                completion(url, nil) 
            }
        }
    }

    
    func handleFileUpload(fileUrl: URL, isPIF: Bool, completion: @escaping (URL?, String) -> Void) {
        let storageRef = Storage.storage().reference()
        let fileName = UUID().uuidString
        let fileRef = isPIF ? storageRef.child("pifs/\(fileName).pdf") : storageRef.child("logos/\(fileName).png")
        
        guard fileUrl.startAccessingSecurityScopedResource() else {
            print("Couldn't access security-scoped resource")
            completion(nil, "Couldn't access file")
            return
        }
        
        guard FileManager.default.fileExists(atPath: fileUrl.path) else {
            print("File does not exist at path: \(fileUrl.path)")
            fileUrl.stopAccessingSecurityScopedResource()
            completion(nil, "File not found")
            return
        }
        
        do {
            let fileData = try Data(contentsOf: fileUrl)
            fileRef.putData(fileData, metadata: nil) { metadata, error in
                fileUrl.stopAccessingSecurityScopedResource()
                
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
            fileUrl.stopAccessingSecurityScopedResource()
            print("Error reading file data: \(error.localizedDescription)")
            completion(nil, error.localizedDescription)
        }
    }
    
    func updateField(_ key: String, value: String) {
        guard let userId = userId else { return }
        db.collection("ngos").document(userId).updateData([key: value]) { error in
            if let error = error {
                print("Error updating \(key): \(error.localizedDescription)")
            } else {
                print("\(key) updated successfully")
            }
        }
    }
    
    func toggleEditing(for key: String, fieldText: String) {
        DispatchQueue.main.async {
            self.editingFields[key]?.toggle()
            
            // Eğer editing mode'dan çıkıyorsak, değeri güncelle
            if !(self.editingFields[key] ?? false) {
                self.updateField(key, value: fieldText)
            }
        }
        
        // Debug için
        print("Toggle editing for \(key): \(self.editingFields[key] ?? false)")
    }
    
    func isEditingField(_ key: String) -> Bool {
        return editingFields[key] ?? false
    }
    
    func openPif() {
        guard let pifUrl = pifUrl else {
            print("Invalid PIF URL")
            return
        }
        UIApplication.shared.open(pifUrl)
    }
}
