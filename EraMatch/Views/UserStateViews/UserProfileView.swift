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
    @State private var selectedTab: String = "Profile"
    
    @State private var isEditingBio = false
    @State private var isEditingCountry = false
    @State private var isEditingEmail = false
    @State private var isEditingInstagram = false
    @State private var isEditingFacebook = false

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(homeViewModel.userName)
                                .font(.title)
                                .fontWeight(.bold)
                            Button(action: {
                                // TODO pp update
                            }) {
                                Text("Update profile picture")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.trailing)
                    }
                    .padding(.horizontal)

                    profileField(title: "Bio", text: $homeViewModel.bio, isEditing: $isEditingBio, field: "bio", isBio: true)
                    profileField(title: "Country", text: $homeViewModel.country, isEditing: $isEditingCountry, field: "country")
                    profileField(title: "E-Mail", text: $homeViewModel.email, isEditing: $isEditingEmail, field: "email")
                    profileField(title: "Instagram Profile", text: $homeViewModel.instagram, isEditing: $isEditingInstagram, field: "instagram")
                    profileField(title: "Facebook Profile", text: $homeViewModel.facebook, isEditing: $isEditingFacebook, field: "facebook")
                    
                    Button(action: {
                        loginViewModel.logoutUser()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                    }
                    .padding(.top, 20)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(25)
                .padding(.top, 50)
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
        .onAppear {
            homeViewModel.loadUserData()
        }
        .navigationBarBackButtonHidden(true)
    }

    private func profileField(title: String, text: Binding<String>, isEditing: Binding<Bool>, field: String, isBio: Bool = false) -> some View {
        VStack {
            HStack {
                Text(title)
                    .font(.headline)
                    .padding(.top, 8)
                
                Spacer()
                
                if isEditing.wrappedValue {
                    Button(action: {
                        homeViewModel.updateUserField(field: field, value: text.wrappedValue)
                        isEditing.wrappedValue = false
                    }) {
                        Text("Done")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                } else {
                    Button(action: {
                        isEditing.wrappedValue = true
                    }) {
                        Text("Edit")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if isBio {
                TextEditor(text: text)
                    .frame(height: 150) 
                    .padding()
                    .background(Color(.white))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .disabled(!isEditing.wrappedValue)
            } else {
                TextField(title, text: text)
                    .padding()
                    .background(Color(.white))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .disabled(!isEditing.wrappedValue)
            }
        }
    }
}






