import SwiftUI
import Firebase

struct NgoSignUpView: View {
    
    @State private var oidNumber = "E00000000"
    @State private var ngoEmail = ""
    @State private var ngoPassword = ""
    @State private var ngoConfirmedPassword = ""
    @State private var ngoCountry = ""
    @State private var ngoName = ""
    
    @State private var showingCountryPicker = false
    @State private var showLogoPicker = false
    @State private var showPifPicker = false
    @State private var logoUrl: URL?
    @State private var pifUrl: URL?
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var navigateToHome = false
    
    var userType: String

    var body: some View {
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
                        TextField("", text: $ngoName)
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
                        
                        TextField("Enter 8 digits", text: $oidNumber)
                            .keyboardType(.numberPad)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .onChange(of: oidNumber) { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered.count > 8 {
                                    oidNumber = "E" + String(filtered.prefix(8))
                                } else {
                                    oidNumber = "E" + filtered
                                }
                            }
                            .onAppear {
                                if !oidNumber.hasPrefix("E") {
                                    oidNumber = "E00000000"
                                }
                            }
                    }
                    .padding(.top)
                    
                    // Email
                    VStack(alignment: .leading) {
                        Text("E-mail")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                        TextField("", text: $ngoEmail)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .onChange(of: ngoEmail) { newValue in
                                if !newValue.contains("@") {
                                    alertMessage = "Email must contain '@'."
                                    showingAlert = true
                                }
                            }
                    }
                    .padding(.top)
                    
                    // Password
                    VStack(alignment: .leading) {
                        Text("Password")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                        SecureField("", text: $ngoPassword)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                    }
                    .padding(.top)
                    
                    // Confirm Password
                    VStack(alignment: .leading) {
                        Text("Confirm Password")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                        SecureField("", text: $ngoConfirmedPassword)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                    }
                    .padding(.top)
                    
                    // Country Picker
                    VStack(alignment: .leading) {
                        Text("Select Nationality")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                        Button(action: {
                            showingCountryPicker.toggle()
                        }) {
                            HStack {
                                Text(ngoCountry.isEmpty ? "Select Nationality" : ngoCountry)
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
                        .actionSheet(isPresented: $showingCountryPicker) {
                            ActionSheet(
                                title: Text("Select a Country"),
                                buttons: countries.map { country in
                                    .default(Text(country)) {
                                        ngoCountry = country
                                    }
                                } + [.cancel()]
                            )
                        }
                    }
                    .padding(.top)
                    
                    // Logo Picker
                    Button(action: {
                        showLogoPicker = true
                    }) {
                        Text("UPLOAD YOUR LOGO")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                    }
                    .padding(.top, 25)
                    .fileImporter(isPresented: $showLogoPicker, allowedContentTypes: [.image], onCompletion: { result in
                        switch result {
                        case .success(let url):
                            logoUrl = url
                            print("Logo selected: \(url.lastPathComponent)")
                        case .failure(let error):
                            print("Failed to select logo: \(error.localizedDescription)")
                        }
                    })
                    
                    // PIF Picker
                    Button(action: {
                        showPifPicker = true
                    }) {
                        Text("UPLOAD YOUR PIF")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                    }
                    .padding(.top)
                    .fileImporter(isPresented: $showPifPicker, allowedContentTypes: [.pdf], onCompletion: { result in
                        switch result {
                        case .success(let url):
                            pifUrl = url
                            print("PIF selected: \(url.lastPathComponent)")
                        case .failure(let error):
                            print("Failed to select PIF: \(error.localizedDescription)")
                        }
                    })
                    
                    // DONE Button
                    Button(action: {
                        if validatePasswords() && isFormValid() {
                            signUpNgo()
                        } else {
                            alertMessage = "Please fill out all fields, ensure passwords match, and check email format."
                            showingAlert = true
                        }
                    }) {
                        Text("DONE")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white.opacity(1))
                            .cornerRadius(15)
                    }
                    .padding(.top, 40)
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("Form Incomplete"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    .background(
                        NavigationLink(destination: NgoHomeView(), isActive: $navigateToHome) {
                            EmptyView()
                        }
                        .hidden()
                    )
                    
                    Spacer()
                }
                .padding()
            }
        }
    }

    // MARK: - Form Validation
    private func isFormValid() -> Bool {
        let isOidNumberValid = oidNumber.count == 9 && oidNumber.first == "E"
        return !ngoName.isEmpty &&
               isOidNumberValid &&
               !ngoEmail.isEmpty &&
               !ngoPassword.isEmpty &&
               ngoPassword == ngoConfirmedPassword &&
               !ngoCountry.isEmpty
    }
    
    // MARK: - Password Validation
    private func validatePasswords() -> Bool {
        return ngoPassword == ngoConfirmedPassword
    }
    
    private func signUpNgo() {
        isLoading = true
        Auth.auth().createUser(withEmail: ngoEmail, password: ngoPassword) { authResult, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showingAlert = true
                isLoading = false
                return
            }
            guard let uid = authResult?.user.uid else { return }
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData([
                "uid": uid,
                "type": "NGO",
                "ngoName": ngoName,
                "oidNumber": oidNumber,
                "email": ngoEmail,
                "country": ngoCountry,
                "logoUrl": logoUrl?.absoluteString ?? "",
                "pifUrl": pifUrl?.absoluteString ?? ""
            ]) { error in
                isLoading = false
                if let error = error {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                } else {
                    navigateToHome = true
                }
            }
        }
    }
}
struct NgoSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NgoSignUpView(userType: "ngo")
    }
}
