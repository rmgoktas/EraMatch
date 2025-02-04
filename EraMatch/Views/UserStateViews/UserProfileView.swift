//
//  UserProfileView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 22.07.2024.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @ObservedObject var homeViewModel: UserHomeViewModel
    
    @State private var isEditingBio = false
    @State private var isEditingCountry = false
    @State private var isEditingEmail = false
    @State private var isEditingInstagram = false
    @State private var isEditingFacebook = false

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Profile Header
                    HStack(spacing: 20) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                        
                        Text(homeViewModel.userName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, getSafeAreaTop())

                    // Profile Fields
                    VStack(spacing: 24) {
                        profileField(title: "Bio", text: $homeViewModel.bio, isEditing: $isEditingBio, field: "bio", isBio: true)
                        profileField(title: "Country", text: $homeViewModel.country, isEditing: $isEditingCountry, field: "country")
                        profileField(title: "E-Mail", text: $homeViewModel.email, isEditing: $isEditingEmail, field: "email")
                        profileField(title: "Instagram Profile", text: $homeViewModel.instagram, isEditing: $isEditingInstagram, field: "instagram")
                        profileField(title: "Facebook Profile", text: $homeViewModel.facebook, isEditing: $isEditingFacebook, field: "facebook")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Sign Out Button
                    Button(action: {
                        loginViewModel.logoutUser()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
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
        .onAppear {
            homeViewModel.loadUserData()
        }
    }

    private func profileField(title: String, text: Binding<String>, isEditing: Binding<Bool>, field: String, isBio: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    if isEditing.wrappedValue {
                        homeViewModel.updateUserField(field: field, value: text.wrappedValue)
                    }
                    isEditing.wrappedValue.toggle()
                }) {
                    Text(isEditing.wrappedValue ? "Done" : "Edit")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
            }
            
            if isBio {
                TextEditor(text: text)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .disabled(!isEditing.wrappedValue)
            } else {
                TextField(title, text: text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!isEditing.wrappedValue)
            }
        }
    }
    
    private func getSafeAreaTop() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else { return 47 }
        return window.safeAreaInsets.top
    }
}
