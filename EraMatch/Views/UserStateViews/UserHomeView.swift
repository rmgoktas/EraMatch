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
    @State private var selectedTab: String = "Home"
    @State private var isSearching = false
    @State private var searchText = ""

    var body: some View {
        ZStack {
            BackgroundView()

            VStack {
                headerView
                VStack(spacing: 20) {
                    switch selectedTab {
                    case "Home":
                        homeTabView
                    case "Profile":
                        UserProfileView(homeViewModel: homeViewModel)
                    case "Events":
                        UserEventsView()
                    case "Submissions":
                        UserSubmissionsView()
                    default:
                        Text("Unknown Tab")
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                UserNavBarView(selectedTab: $selectedTab)
                    .padding(.horizontal)
                    .padding(.top)
            }

            if isMenuOpen {
                overlayMenu
            }
        }
        .onAppear {
            homeViewModel.fetchUsername()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var headerView: some View {
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
            
            if isSearching {
                HStack {
                    TextField("Search...", text: $searchText)
                        .padding(.leading, 10)
                    Button(action: {
                        withAnimation {
                            isSearching = false
                            searchText = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)
                .transition(.move(edge: .trailing))
            } else {
                Text(selectedTab)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    isSearching.toggle()
                }
            }) {
                Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 30)
        .padding(.horizontal)
    }
    
    private var homeTabView: some View {
        VStack {
            Text("Hi, \(homeViewModel.userName)!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 40)

            VStack {
                VStack {
                    HStack {
                        Text("What to Do ?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        Spacer()
                    }

                    HStack {
                        Image(systemName: "airplane")
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text("Search Free Travels")
                                .font(.headline)
                                .foregroundColor(.black)
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
                }
                .padding()
                .background(Color.white)
                .cornerRadius(25)

                // New Section for Topics
                VStack(alignment: .leading) {
                    Text("   Search by Topics")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(homeViewModel.topics, id: \.self) { topic in
                            Button(action: {
                                print("Selected topic: \(topic)")
                            }) {
                                HStack {
                                    Text(topic)
                                        .padding(10)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.black)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(radius: 2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(25)
            .shadow(radius: 10)
            .padding(.top, 60) 
        }
    }

    
    private var overlayMenu: some View {
        ZStack(alignment: .leading) {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
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

    private var sliderMenu: some View {
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
            .environmentObject(UserHomeViewModel())
    }
}

