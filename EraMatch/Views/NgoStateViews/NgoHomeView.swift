//
//  NgoHomeView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 4.07.2024.
//

import SwiftUI

struct NgoHomeView: View {
    @State private var isMenuOpen = false
    @State private var selectedTab: String = "My Events"
    @ObservedObject var homeViewModel: NgoHomeViewModel
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var isCreateEventViewPresented = false
    @State private var isNotificationPresented = false

    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                HStack {
                    Text(selectedTab)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        isNotificationPresented.toggle()
                    }) {
                        Image(systemName: "bell")
                            .font(.title3)
                            .foregroundColor(.white)
                            .accessibilityLabel("Notifications")
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal)
                .background(Color.black.opacity(0))

                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case "My Events":
                            NgoMyEventsView()
                                .environmentObject(loginViewModel)
                        case "Profile":
                            NgoProfileView(homeViewModel: homeViewModel)
                                .environmentObject(loginViewModel)
                        default:
                            Text("Unknown Tab")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    .background(Color.clear)
                }

                NgoNavBarView(selectedTab: $selectedTab, isCreateEventViewPresented: $isCreateEventViewPresented)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }
        }
        .onAppear {
            homeViewModel.loadNgoData()
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $isCreateEventViewPresented) {
            CreateEventView(shouldDismiss: $isCreateEventViewPresented, creatorId: loginViewModel.userId ?? "")
        }
        .sheet(isPresented: $isNotificationPresented) {
            NotificationView(shouldDismiss: $isNotificationPresented)
        }
    }
}

