//
//  NgoHomeView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 4.07.2024.
//

import SwiftUI

struct NgoHomeView: View {
    @State private var isMenuOpen = false
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()

                VStack {
                    // Üst çubuk
                    HStack {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Text("My Events")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)

                        Spacer()

                        Image(systemName: "magnifyingglass")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 30)
                    .padding(.horizontal)
                    .background(Color.black.opacity(0))

                    GeometryReader { geometry in
                        ScrollView {
                            VStack(spacing: 30) {
                                // Event Cards
                                EventCardView(
                                    title: "Hidden Geniuses",
                                    subtitle: "Training Course on “Digital Skills”",
                                    location: "Madrid, SPAIN",
                                    dateRange: "14 Apr 2024 - 21 Apr 2024",
                                    onDetailTap: {
                                        // Navigate to event details
                                    }
                                )

                                EventCardView(
                                    title: "Youth Exchange",
                                    subtitle: "Exploring Cultural Diversity",
                                    location: "Berlin, GERMANY",
                                    dateRange: "10 Jun 2024 - 20 Jun 2024",
                                    onDetailTap: {
                                        // Navigate to event details
                                    }
                                )

                                EventCardView(
                                    title: "Environmental Summit",
                                    subtitle: "Actions for a Sustainable Future",
                                    location: "Oslo, NORWAY",
                                    dateRange: "5 Jul 2024 - 12 Jul 2024",
                                    onDetailTap: {
                                        // Navigate to event details
                                    }
                                )

                                Spacer(minLength: 90) // Floating Action Button için altta yer bırakmak amacıyla spacer ekledim
                            }
                            .padding(.top, geometry.safeAreaInsets.top + 60)
                        }
                    }
                }

                // NGO Nav Bar
                VStack {
                    Spacer()
                    NgoNavBarView()
                        .padding(.horizontal)
                        .padding(.top, 10)
                }

                if isMenuOpen {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation {
                                isMenuOpen = false
                            }
                        }

                    sliderMenu
                        .transition(.move(edge: .leading))
                        .animation(.easeInOut(duration: 0.3))
                }

                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // Add new event action
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color.purple)
                                .cornerRadius(40)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 90)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // Slider menü bileşeni
    var sliderMenu: some View {
        ZStack(alignment: .leading) {
            BackgroundView()

            VStack(alignment: .leading) {
                HStack {
                    Text("EraMatch")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isMenuOpen = false
                        }
                    }) {
                        Image(systemName: "arrow.backward")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }
                .padding()

                List {
                    NavigationLink(destination: GuideScreenView(content: .whatIsEraMatch)) {
                        Text("What is EraMatch ?")
                    }
                    NavigationLink(destination: GuideScreenView(content: .howDoIParticipate)) {
                        Text("How Do I Participate ?")
                    }
                    NavigationLink(destination: GuideScreenView(content: .doIHaveToPay)) {
                        Text("Do I Have to Pay ?")
                    }
                    NavigationLink(destination: GuideScreenView(content: .whatCanIDo)) {
                        Text("What Can I Do on EraMatch ?")
                    }
                }

                Spacer()

                Button(action: {
                    loginViewModel.logoutUser()
                    withAnimation {
                        isMenuOpen = false
                    }
                }) {
                    HStack {
                        Text("Sign Out")
                        Image(systemName: "arrow.right.circle")
                    }
                    .padding(.bottom, 50)
                    .padding(.leading, 180)
                }
            }
            .frame(width: 300)
            .background(Color.white)
            .offset(x: isMenuOpen ? 0 : -300, y: 50)
            .edgesIgnoringSafeArea(.top)
        }
    }
}

struct NgoHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NgoHomeView()
            .environmentObject(LoginViewModel())
    }
}









