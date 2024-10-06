import SwiftUI
import Firebase

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                VStack(alignment: .leading) {
                    Text("EraMatch")
                        .font(.custom("", size: 50))
                        .foregroundColor(.white)
                        .padding(.top, 60)
                    Text("Welcome!")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 75)
                    
                    TextField("E-mail", text: $viewModel.email)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    HStack {
                        Spacer()
                        Button("I forgot my password") {
                            // Şifre unutma işlemi
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.top, 10)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.loginUser()
                        }) {
                            Text("Sign In")
                                .bold()
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    HStack {
                        Text("Are you new here?")
                            .foregroundColor(.white)
                        NavigationLink(destination: SelectStateView()) {
                            Text("Sign Up")
                                .bold()
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 20)
                    Spacer()
                }
                .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                }
            }
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(
                    title: Text("Login Error"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            // Kullanıcı türüne göre yönlendirme
            .background(
                NavigationLink(
                    destination: UserHomeView(),
                    isActive: $viewModel.navigateToTravellerHome
                ) {
                    EmptyView()
                }
                .hidden()
            )
            .background(
                NavigationLink(
                    destination: NgoHomeView(),
                    isActive: $viewModel.navigateToNGOHome
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
