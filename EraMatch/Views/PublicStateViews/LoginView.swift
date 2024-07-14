import SwiftUI

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            BackgroundView() // Arka planı ayarlıyoruz
            
            VStack(alignment: .leading) {
                Text("EraMatch")
                    .font(.custom("", size: 50))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                Text("Welcome!")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 10)

                TextField("E-mail", text: $email)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .foregroundColor(.white)
                    .padding(.top, 20)

                SecureField("Password", text: $password)
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
                        // Giriş işlemi
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
        }
        .navigationBarHidden(false)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
