//
//  HomeView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 3.07.2024.
//

import SwiftUI

struct UserHomeView: View {
    @StateObject private var homeViewModel = UserHomeViewModel()
    @State private var isMenuOpen = false
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var selectedTab: String = "Home" // Selected tab state

    var body: some View {
        ZStack {
            VStack {
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
                    
                    Text("Home")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "magnifyingglass")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .padding()
                
                // Ana içerik
                ScrollView {
                    VStack {
                        Text("Hi, \(homeViewModel.userName)!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 25)
                            .padding(.trailing, 100)
                        
                        VStack {
                            Text("What to Do ?")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top, 20)
                            
                            HStack {
                                Image(systemName: "airplane")
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("Search Free Travels")
                                        .font(.headline)
                                    Text("Find and filter travel events")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            
                            // Event by Topics
                            VStack(alignment: .leading) {
                                Text("Events by Topics")
                                    .font(.title3)
                                    .padding(.top, 10)
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                    ForEach(homeViewModel.topics, id: \.self) { topic in
                                        Text(topic)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(15)
                                            .shadow(radius: 5)
                                    }
                                }
                            }
                            .padding(.top, 30)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                        .padding(.top, 50)
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    
                }
            }
            .background(BackgroundView())
            
            VStack {
                Spacer()
                UserNavBarView(selectedTab: $selectedTab)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity)
                    
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
        }
        .onAppear {
            homeViewModel.fetchUsername()
        }
        .navigationBarBackButtonHidden(true)
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

struct UserHomeView_Previews: PreviewProvider {
    static var previews: some View {
        UserHomeView()
            .environmentObject(LoginViewModel())
    }
}




