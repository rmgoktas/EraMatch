import SwiftUI
import Firebase

struct UserSignUpView: View {
    @State private var userName = ""
    @State private var userEmail = ""
    @State private var userPassword = ""
    @State private var userConfirmedPassword = ""
    @State private var userCountry = ""
    @State private var showingCountryPicker = false
    
    // Alert
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Navigation
    @State private var navigateToHome = false
    
    // Loading state
    @State private var isLoading = false
    
    // User Type
    var userType: String // "user" olarak ayarlanacak

    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                VStack {
                    Text("Sign up as \(userType)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 25)
                        .padding(.trailing, 50)
                    
                    // Name - Surname
                    VStack(alignment: .leading) {
                        Text("Name - Surname")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                        TextField("", text: $userName)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                    }
                    .padding(.top)
                    
                    // Email
                    VStack(alignment: .leading) {
                        Text("E-mail")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                        TextField("", text: $userEmail)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .onChange(of: userEmail) { newValue in
                                if !newValue.contains("@") {
                                    alertMessage = "Email must contain '@'."
                                    showingAlert = true
                                }
                            }
                    }
                    
                    // Password
                    VStack(alignment: .leading) {
                        Text("Password")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                        SecureField("", text: $userPassword)
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
                        SecureField("", text: $userConfirmedPassword)
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
                            showingCountryPicker.toggle()
                        }) {
                            HStack {
                                Text(userCountry.isEmpty ? "Select Country" : userCountry)
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
                                buttons: CountryList.countries.map { country in
                                    .default(Text(country)) {
                                        userCountry = country
                                    }
                                } + [.cancel()]
                            )
                        }
                    }
                    .padding(.top)
                    
                    // DONE Button
                    Button(action: {
                        if validatePasswords() && isFormValid() {
                            signUpUser()
                        } else {
                            alertMessage = "Please fill out all fields and ensure passwords match."
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
                        NavigationLink(destination: UserHomeView(), isActive: $navigateToHome) {
                            EmptyView()
                        }
                        .hidden()
                    )
                    
                    Spacer()
                }
                .padding()
            }
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
            }
        }
    }

    // MARK: - Form Validation
    private func isFormValid() -> Bool {
        return !userName.isEmpty &&
               !userEmail.isEmpty &&
               !userPassword.isEmpty &&
               userPassword == userConfirmedPassword &&
               !userCountry.isEmpty
    }
    
    // MARK: - Password Validation
    private func validatePasswords() -> Bool {
        return userPassword == userConfirmedPassword
    }
    
    private func signUpUser() {
        isLoading = true
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
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
                "type": userType, // Burada userType değişkenini kullanarak type alanını ayarlıyoruz
                "userName": userName,
                "email": userEmail,
                "country": userCountry
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

struct UserSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        UserSignUpView(userType: "user") // User türünü burada belirle
    }
}
