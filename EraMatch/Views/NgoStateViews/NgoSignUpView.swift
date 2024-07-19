import SwiftUI
import Firebase
import PhotosUI

struct NgoSignUpView: View {
    @StateObject private var viewModel = NgoSignUpViewModel()
    @State private var showingPIFPicker = false
    @State private var showingLogoPicker = false
    
    @State private var logoFileName = ""
    @State private var pifFileName = ""

    var userType: String

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                ScrollView {
                    VStack {
                        Text("Sign Up as NGO")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 25)
                            .padding(.trailing, 100)
                        
                        // NGO NAME
                        VStack(alignment: .leading) {
                            Text("NGO Name")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.leading, 5)
                            TextField("", text: $viewModel.ngoName)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(15)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        // OID Number
                        VStack(alignment: .leading) {
                            Text("Your NGO's OID Number")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.leading, 5)
                            
                            TextField("Enter 8 digits", text: $viewModel.oidNumber)
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(15)
                                .onChange(of: viewModel.oidNumber) { newValue in
                                    let filtered = newValue.filter { $0.isNumber }
                                    if filtered.count > 8 {
                                        viewModel.oidNumber = "E" + String(filtered.prefix(8))
                                    } else {
                                        viewModel.oidNumber = "E" + filtered
                                    }
                                }
                                .onAppear {
                                    if !viewModel.oidNumber.hasPrefix("E") {
                                        viewModel.oidNumber = "E"
                                    }
                                }
                        }
                        
                        // Email
                        VStack(alignment: .leading) {
                            Text("E-mail")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.leading, 5)
                            TextField("", text: $viewModel.ngoEmail)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(15)
                                .onSubmit {
                                    if !viewModel.ngoEmail.contains("@") {
                                        viewModel.alertMessage = "Email must contain '@'."
                                        viewModel.showingAlert = true
                                    }
                                }
                        }
                        
                        // Password
                        VStack(alignment: .leading) {
                            Text("Password")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.leading, 5)
                            SecureField("", text: $viewModel.ngoPassword)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(15)
                        }
                        
                        // Confirm Password
                        VStack(alignment: .leading) {
                            Text("Confirm Password")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.leading, 5)
                            SecureField("", text: $viewModel.ngoConfirmedPassword)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(15)
                        }
                        
                        // Country Picker
                        VStack(alignment: .leading) {
                            Text("Select Country")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.leading, 5)
                            Button(action: {
                                viewModel.showingCountryPicker.toggle()
                            }) {
                                HStack {
                                    Text(viewModel.ngoCountry.isEmpty ? "Select Country" : viewModel.ngoCountry)
                                        .foregroundColor(.white)
                                        .padding()
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.white)
                                }
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(15)
                            }
                            .padding(.top, 5)
                            .actionSheet(isPresented: $viewModel.showingCountryPicker) {
                                ActionSheet(
                                    title: Text("Select a Country"),
                                    buttons: viewModel.countries.map { country in
                                        .default(Text(country)) {
                                            viewModel.ngoCountry = country
                                        }
                                    } + [.cancel()]
                                )
                            }
                        }
                        .padding(.top)
                        
                        // Logo Picker
                        VStack(alignment: .leading) {
                            Text("Upload Your Logo")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.leading, 5)
                            Button(action: {
                                self.showingLogoPicker = true
                            }) {
                                HStack {
                                    Text(logoFileName.isEmpty ? "Upload Logo" : logoFileName)
                                        .foregroundColor(.white)
                                        .padding()
                                    Spacer()
                                    Image(systemName: "photo")
                                        .foregroundColor(.white)
                                }
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(15)
                            }
                            .padding(.top, 5)

                            if !logoFileName.isEmpty {
                                Button(action: {
                                    self.logoFileName = ""
                                    self.viewModel.logoUrl = nil
                                }) {
                                    Text("Remove Logo")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.top)
                        .sheet(isPresented: $showingLogoPicker) {
                            ImagePickerView(sourceType: .photoLibrary) { image in
                                if let image = image {
                                    if let fileUrl = saveImageToDocuments(image: image) {
                                        viewModel.handleFileUpload(fileUrl: fileUrl, isPIF: false) { url, fileName in
                                            DispatchQueue.main.async {
                                                if let url = url {
                                                    viewModel.logoUrl = url
                                                    logoFileName = fileName
                                                } else {
                                                    // Handle URL is nil case
                                                    viewModel.alertMessage = "Logo upload failed."
                                                    viewModel.showingAlert = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // PIF Upload
                        VStack(alignment: .leading) {
                            Text("Upload Your PIF")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.leading, 5)
                            Button(action: {
                                self.showingPIFPicker = true
                            }) {
                                HStack {
                                    Text(pifFileName.isEmpty ? "Upload PIF" : pifFileName)
                                        .foregroundColor(.white)
                                        .padding()
                                    Spacer()
                                    Image(systemName: "doc")
                                        .foregroundColor(.white)
                                }
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(15)
                            }
                            .padding(.top, 5)

                            if !pifFileName.isEmpty {
                                Button(action: {
                                    self.pifFileName = ""
                                    self.viewModel.pifUrl = nil
                                }) {
                                    Text("Remove PIF")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.top)
                        .fileImporter(isPresented: $showingPIFPicker, allowedContentTypes: [.pdf]) { result in
                            switch result {
                            case .success(let url):
                                viewModel.handleFileUpload(fileUrl: url, isPIF: true) { url, fileName in
                                    DispatchQueue.main.async {
                                        if let url = url {
                                            viewModel.pifUrl = url
                                            pifFileName = fileName
                                        } else {
                                            // Handle URL is nil case
                                            viewModel.alertMessage = "PIF upload failed."
                                            viewModel.showingAlert = true
                                        }
                                    }
                                }
                            case .failure(let error):
                                print("Failed to pick PIF file: \(error.localizedDescription)")
                            }
                        }

                        // Sign Up Button
                        Button(action: {
                            guard viewModel.isFormValid() else {
                                viewModel.alertMessage = "Please fill in all fields and ensure passwords match."
                                viewModel.showingAlert = true
                                return
                            }
                            
                            viewModel.signUpNgo(userType: userType)
                        }) {
                            Text("Sign Up")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        .padding(.top)
                        
                        Spacer()

                        // NavigationLink for navigation
                        NavigationLink(
                            destination: NgoHomeView(),
                            isActive: $viewModel.navigateToHome,
                            label: {
                                EmptyView()
                            }
                        )
                    }
                    .padding()
                    .alert(isPresented: $viewModel.showingAlert) {
                        Alert(
                            title: Text("Incomplete"),
                            message: Text(viewModel.alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
        }
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

struct ImagePickerView: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var completionHandler: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self, completionHandler: completionHandler)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePickerView
        var completionHandler: (UIImage?) -> Void

        init(_ parent: ImagePickerView, completionHandler: @escaping (UIImage?) -> Void) {
            self.parent = parent
            self.completionHandler = completionHandler
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                if let fileUrl = saveImageToDocuments(image: image) {
                    parent.handleFileUpload(fileUrl: fileUrl, isPIF: false, completionHandler: completionHandler)
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completionHandler(nil)
            picker.dismiss(animated: true, completion: nil)
        }

        func saveImageToDocuments(image: UIImage) -> URL? {
            let fileManager = FileManager.default
            guard let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
            let fileUrl = documentsUrl.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")

            if let imageData = image.pngData() {
                try? imageData.write(to: fileUrl)
                return fileUrl
            }
            return nil
        }
    }

    func handleFileUpload(fileUrl: URL, isPIF: Bool, completionHandler: @escaping (UIImage?) -> Void) {
        let viewModel = NgoSignUpViewModel() // ViewModel örneği oluşturulması
        viewModel.handleFileUpload(fileUrl: fileUrl, isPIF: isPIF) { url, fileName in
            DispatchQueue.main.async {
                if let url = url {
                    viewModel.logoUrl = url
                    completionHandler(UIImage(contentsOfFile: fileUrl.path))
                } else {
                    viewModel.alertMessage = "Logo upload failed."
                    viewModel.showingAlert = true
                }
            }
        }
    }
}
