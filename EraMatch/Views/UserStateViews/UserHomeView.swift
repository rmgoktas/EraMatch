//
//  HomeView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 3.07.2024.
//

import SwiftUI

struct UserHomeView: View {
    @StateObject private var homeViewModel = UserHomeViewModel()
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var isGuideSheetPresented = false
    @State private var isNotificationsSheetPresented = false
    @State private var guideContent: GuideContent = .whatIsEraMatch
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                ZStack(alignment: .top) {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Welcome Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Hi,")
                                    .font(.title)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                Text(homeViewModel.userName)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, getSafeAreaTop())
                            
                            // Quick Actions Section
                            VStack(spacing: 20) {
                                HStack {
                                    Text("Quick Actions")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                .padding(.horizontal)

                                Button(action: {
                                    Task {
                                        await EventCardViewModel.shared.fetchEventsForUser()
                                        selectedTab = 1
                                    }
                                }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "airplane")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 40)
                                            .background(Color.blue)
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading) {
                                            Text("Search All Free Travels")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text("Find and filter travel events")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Topics Section
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Search by Topics")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(homeViewModel.topics, id: \.self) { topic in
                                        Button(action: {
                                            Task {
                                                let userCountry = homeViewModel.country 
                                                await EventCardViewModel.shared.fetchEventsByTopic(for: userCountry, topic: topic)
                                                selectedTab = 1
                                            }
                                        }) {
                                            Text(topic)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                                .padding(.vertical, 12)
                                                .frame(maxWidth: .infinity)
                                                .background(Color(.systemBackground))
                                                .cornerRadius(12)
                                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                    
                    // Blur overlay for top safe area
                    Rectangle()
                        .fill(Color(.systemGroupedBackground))
                        .frame(height: getSafeAreaTop())
                        .frame(maxWidth: .infinity)
                        .blur(radius: 20)
                        .overlay(
                            Rectangle()
                                .fill(Color(.systemGroupedBackground).opacity(0.8))
                        )
                        .ignoresSafeArea()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 20) {
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
                                    .foregroundColor(.primary)
                            }
                            
                            Button(action: {
                                isNotificationsSheetPresented.toggle()
                            }) {
                                Image(systemName: "bell")
                                    .font(.system(size: 20))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .tag(0)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                
                UserEventsView()
                    .tag(1)
                    .tabItem {
                        Label("Events", systemImage: "calendar")
                    }
                
                UserProfileView(homeViewModel: homeViewModel)
                    .tag(2)
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            homeViewModel.fetchUsername()
        }
        .sheet(isPresented: $isGuideSheetPresented) {
            GuideScreenView(content: guideContent)
        }
        .sheet(isPresented: $isNotificationsSheetPresented) {
            NotificationView(shouldDismiss: $isNotificationsSheetPresented)
        }
    }
    
    private func getSafeAreaTop() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else { return 47 }
        return window.safeAreaInsets.top
    }
}

struct UserHomeView_Previews: PreviewProvider {
    static var previews: some View {
        UserHomeView()
            .environmentObject(LoginViewModel())
            .environmentObject(UserHomeViewModel())
    }
}

