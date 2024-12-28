import SwiftUI
import Firebase

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var ngoHomeViewModel = NgoHomeViewModel()
    @StateObject private var userHomeViewModel = UserHomeViewModel()
    @State private var showSignUpOptions = false

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                VStack(alignment: .leading) {
                    HStack {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(.top, 70)
                            .padding(.bottom, 20)

                        Text("EraMatch")
                            .font(.custom("Futura", size: 50))
                            .foregroundColor(.white)
                            .padding(.top, 30)
                    }
                    .frame(maxWidth: .infinity)

                    Text("Welcome!")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 45)

                    TextField("E-mail", text: $viewModel.email)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(30)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .foregroundColor(.white)
                        .padding(.top, 10)

                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(30)
                        .foregroundColor(.white)
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
                                .cornerRadius(30)
                        }
                    }
                    .padding(.top, 50)

                    Spacer()

                    HStack {
                        Text("Are you new here?")
                            .foregroundColor(.white)
                        NavigationLink(destination: SelectStateView()
                            .environmentObject(viewModel)) {
                            Text("Sign Up")
                                .fontWeight(.bold)
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
                    destination: UserHomeView()
                        .environmentObject(viewModel),
                    isActive: $viewModel.navigateToTravellerHome
                ) {
                    EmptyView()
                }
                .hidden()
            )
            .background(
                NavigationLink(
                    destination: NgoHomeView(homeViewModel: ngoHomeViewModel)
                        .environmentObject(viewModel), 
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


