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
                }
                .padding(.top, 30)
                .padding(.horizontal)
                .background(Color.black.opacity(0))

                ScrollView {
                    VStack(spacing: 20) {
                        if selectedTab == "My Events" {
                            NgoMyEventsView()
                        } else if selectedTab == "Submissions" {
                            NgoSubmissionsView()
                        } else if selectedTab == "Profile" {
                            NgoProfileView(homeViewModel: homeViewModel)
                               
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    .background(Color.clear)
                }

                NgoNavBarView(selectedTab: $selectedTab)
                    .padding(.horizontal)
                    .padding(.top, 10)
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
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Color.purple)
                            .cornerRadius(40)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 90)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}



