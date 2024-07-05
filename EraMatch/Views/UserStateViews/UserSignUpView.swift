import SwiftUI

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

    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                VStack {
                    Text("Sign up as Traveller")
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
                                buttons: countries.map { country in
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
                            // Handle done action
                            print("Form is valid, proceed with sign up")
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
                    
                    Spacer()
                }
                .padding()
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
}

#Preview {
    UserSignUpView()
}
