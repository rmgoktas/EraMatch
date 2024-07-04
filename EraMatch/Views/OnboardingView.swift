import SwiftUI

struct OnboardingView: View {
    @Binding var isFirstLaunch: Bool
    @State private var currentTab = 0

    var body: some View {
        ZStack {
            BackgroundView()  // Arka planı ayarlıyoruz

            TabView(selection: $currentTab) {
                VStack {
                    Spacer()
                    Image("travellers")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.75) // Ekran genişliğine göre ayarlıyoruz
                        .padding(.bottom, 75)
                    Text("FOR TRAVELLERS")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top)
                    Text("Choose events about your interests, apply them and travel for free.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
                .tag(0)
                .tabItem {
                    Text("Travellers")
                }

                VStack {
                    Spacer()
                    Image("ngos")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.75) // Ekran genişliğine göre ayarlıyoruz
                        .padding(.bottom)
                    Text("FOR NGO'S")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.bottom, 50)
                    Text("Find participants for your exchange events and classify them easy and fast.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.bottom, 100)
                    Spacer()
                }
                .tag(1)
                .tabItem {
                    Text("NGOs")
                }

                VStack {
                    Spacer()
                    VStack(spacing: 8) {
                        VStack {
                            Image("travellers")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.75)
                            Button(action: {
                                // Action for "I'M JUST LOOKING FOR FREE TRAVEL"
                            }) {
                                Text("I’M JUST LOOKING FOR FREE TRAVEL")
                                    .font(.headline)
                                    .foregroundColor(.black) // Buton yazısını mavi yapıyoruz
                                    .padding()
                                    .background(Color.white) // Buton arka planını beyaz yapıyoruz
                                    .cornerRadius(15)
                            }
                        }
                        VStack {
                            Image("ngos")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.75)
                            Button(action: {
                                // Action for "I’M MEMBER OF A NGO"
                            }) {
                                Text("I’M MEMBER OF A NGO")
                                    .font(.headline)
                                    .foregroundColor(.black) // Buton yazısını mavi yapıyoruz
                                    .padding()
                                    .background(Color.white) // Buton arka planını beyaz yapıyoruz
                                    .cornerRadius(15)
                            }
                        }
                    }
                    Spacer()
                }
                .tag(2)
                .tabItem {
                    Text("Choices")
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .overlay(
                VStack {
                    Spacer()
                    if currentTab < 2 {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    currentTab += 1
                                }
                            }) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 75)
                    }
                },
                alignment: .bottom
            )
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    @State static var isFirstLaunch = true

    static var previews: some View {
        OnboardingView(isFirstLaunch: $isFirstLaunch)
    }
}
