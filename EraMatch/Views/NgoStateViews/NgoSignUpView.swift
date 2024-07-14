import SwiftUI
import Firebase

struct NgoSignUpView: View {
    @StateObject private var viewModel = NgoSignUpViewModel()
    
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
                            .onChange(of: viewModel.ngoEmail) { newValue in
                                if !newValue.contains("@") {
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
                    
                    // Logo
                    VStack(alignment: .leading) {
                        Text("Upload Your Logo")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                        Button(action: {
                            // Logo yükleme işlemi burada olacak
                        }) {
                            HStack {
                                Text("Upload Logo")
                                    .foregroundColor(.white)
                                    .padding()
                                Spacer()
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            }
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.top)
                    
                    // PIF Upload
                    VStack(alignment: .leading) {
                        Text("Upload Your PIF")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                        Button(action: {
                            // PIF yükleme işlemi burada olacak
                        }) {
                            HStack {
                                Text("Upload PIF")
                                    .foregroundColor(.white)
                                    .padding()
                                Spacer()
                                Image(systemName: "doc")
                                    .foregroundColor(.white)
                            }
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.top)
                    
                    // DONE Button
                    Button(action: {
                        if viewModel.validatePasswords() && viewModel.isFormValid() {
                            viewModel.signUpNgo(userType: userType)
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
                        NavigationLink(destination: NgoHomeView(), isActive: $viewModel.navigateToHome) {
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

struct NgoSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NgoSignUpView(userType: "ngo") // NGO türünü burada belirle
    }
}
