import SwiftUI
import Firebase

struct UserSignUpView: View {
    @ObservedObject var viewModel = UserSignUpViewModel()
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    // User Type
    var userType: String

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
                        TextField("", text: $viewModel.userName)
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
                        TextField("", text: $viewModel.userEmail)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .onSubmit {
                                if !viewModel.userEmail.contains("@") {
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
                        SecureField("", text: $viewModel.userPassword)
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
                        SecureField("", text: $viewModel.userConfirmedPassword)
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
                                Text(viewModel.userCountry.isEmpty ? "Select Country" : viewModel.userCountry)
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
                                        viewModel.userCountry = country
                                    }
                                } + [.cancel()]
                            )
                        }
                    }
                    .padding(.top)
                    
                    // DONE Button
                    Button(action: {
                        if viewModel.validatePasswords() && viewModel.isFormValid() {
                            viewModel.signUpUser(userType: userType)
                        } else {
                            viewModel.alertMessage = "Please fill out all fields and ensure passwords match."
                            viewModel.showingAlert = true
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
                    .alert(isPresented: $viewModel.showingAlert) {
                        Alert(
                            title: Text("Form Incomplete"),
                            message: Text(viewModel.alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    .background(
                        NavigationLink(destination: UserHomeView(), isActive: $viewModel.navigateToHome) {
                            EmptyView()
                        }
                        .hidden()
                    )
                    
                    Spacer()
                }
                .padding()
            }
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
            }
        }
    }
}

struct UserSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        UserSignUpView(userType: "user") 
    }
}
