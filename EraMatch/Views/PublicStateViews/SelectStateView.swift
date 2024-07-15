import SwiftUI

struct SelectStateView: View {
    var body: some View {
        ZStack {
            BackgroundView() // Arka planı ayarlıyoruz
            
            VStack {
                Spacer()
                
                Image("travellers")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.75)
                    .padding(.bottom, 40)
                    .padding(.top, 40)
                
                NavigationLink(destination: UserSignUpView(userType: "traveller")) {
                    Text("I’M JUST LOOKING FOR TRAVEL")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                }
                .onTapGesture {
                    UserDefaults.standard.set("traveller", forKey: "UserRole")
                }

                Spacer()

                Image("ngos")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.80)
                
                NavigationLink(destination: NgoSignUpView(userType: "ngo")) {
                    Text("I’M MEMBER OF A NGO")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                }
                .onTapGesture {
                    UserDefaults.standard.set("ngo", forKey: "UserRole")
                }

                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(false)
    }
}

struct SelectStateView_Previews: PreviewProvider {
    static var previews: some View {
        SelectStateView()
    }
}
