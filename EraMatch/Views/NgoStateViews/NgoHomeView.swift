//
//  NgoHomeView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 4.07.2024.
//

import SwiftUI

struct NgoHomeView: View {
    @ObservedObject var homeViewModel: NgoHomeViewModel
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var isCreateEventViewPresented = false
    @State private var isNotificationPresented = false
    
    var body: some View {
        TabView {
            NavigationStack {
                NgoMyEventsView()
                    .environmentObject(loginViewModel)
                    .navigationBarTitleDisplayMode(.large)
                    .navigationTitle("My Events")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack(spacing: 20) {
                                Button(action: {
                                    isNotificationPresented.toggle()
                                }) {
                                    Image(systemName: "bell")
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
            }
            .tabItem {
                Label("My Events", systemImage: "calendar")
            }
            
            NavigationStack {
                NgoProfileView(homeViewModel: homeViewModel)
                    .environmentObject(loginViewModel)
                    .navigationBarTitleDisplayMode(.large)
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
        .onAppear {
            homeViewModel.loadNgoData()
        }
        .overlay(alignment: .bottom) {
            Button(action: {
                isCreateEventViewPresented = true
            }) {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.black)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.bottom, 64)
        }
        .fullScreenCover(isPresented: $isCreateEventViewPresented) {
            CreateEventView(shouldDismiss: $isCreateEventViewPresented, creatorId: loginViewModel.userId ?? "")
        }
        .sheet(isPresented: $isNotificationPresented) {
            NotificationView(shouldDismiss: $isNotificationPresented)
        }
    }
}

struct NgoHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NgoHomeView(homeViewModel: NgoHomeViewModel())
            .environmentObject(LoginViewModel())
    }
}

