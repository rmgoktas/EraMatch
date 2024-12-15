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

    var body: some View {
        ZStack {
            BackgroundView()
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
                            .accessibilityLabel("Open Menu")
                    }

                    Spacer()

                    Text(selectedTab)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "magnifyingglass")
                        .font(.title)
                        .foregroundColor(.white)
                        .accessibilityLabel("Search")
                }
                .padding(.top, 30)
                .padding(.horizontal)
                .background(Color.black.opacity(0))

                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case "My Events":
                            NgoMyEventsView()
                        case "Profile":
                            NgoProfileView(homeViewModel: homeViewModel)
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
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $isCreateEventViewPresented) {
            CreateEventView(shouldDismiss: $isCreateEventViewPresented)
        }
    }
}

