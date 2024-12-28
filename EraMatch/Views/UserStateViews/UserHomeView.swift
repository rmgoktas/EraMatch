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
    @State private var isGuideSheetPresented = false
    @State private var isNotificationsSheetPresented = false
    @State private var guideContent: GuideContent = .whatIsEraMatch

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
        .sheet(isPresented: $isNotificationsSheetPresented) {
            NotificationView(shouldDismiss: $isNotificationsSheetPresented)
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 16) {
            // Tab Title - Left aligned
            Text(selectedTab)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            Spacer()
            
            // Right side buttons
            HStack(spacing: 20) {
                // Help Menu
                Menu {
                    Button("What is EraMatch?") {
                        isGuideSheetPresented = true
                        guideContent = .whatIsEraMatch
                    }
                    Button("How Do I Participate?") {
                        isGuideSheetPresented = true
                        guideContent = .howDoIParticipate
                    }
                    Button("Do I Have to Pay?") {
                        isGuideSheetPresented = true
                        guideContent = .doIHaveToPay
                    }
                    Button("What Can I Do on EraMatch?") {
                        isGuideSheetPresented = true
                        guideContent = .whatCanIDo
                    }
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .sheet(isPresented: $isGuideSheetPresented) {
                    GuideScreenView(content: guideContent)
                }
                
                // Notifications Button
                Button(action: {
                    isNotificationsSheetPresented.toggle()
                }) {
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .sheet(isPresented: $isNotificationsSheetPresented) {
                    NotificationView(shouldDismiss: $isNotificationsSheetPresented)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, getSafeAreaTop())
        .padding(.bottom, 10)
    }

    private func getSafeAreaTop() -> CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.top
        }
        return 0
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

                    Button(action: {
                        Task {
                            await EventCardViewModel.shared.fetchEventsForUser()
                        }
                        selectedTab = "Events"
                    }) {
                        HStack {
                            Image(systemName: "airplane")
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Search All Free Travels")
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

                    VStack(alignment: .leading) {
                        Text("   Search by Topics")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 20)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(homeViewModel.topics, id: \.self) { topic in
                                Button(action: {
                                    print("Selected topic: \(topic)")
                                    Task {
                                        let userCountry = homeViewModel.country 
                                        await EventCardViewModel.shared.fetchEventsByTopic(for: userCountry, topic: topic) // load for topics and country
                                        selectedTab = "Events"
                                    }
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
                .frame(width: 300)
                .offset(x: isMenuOpen ? 0 : -300)
                .animation(.easeInOut, value: isMenuOpen)
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

