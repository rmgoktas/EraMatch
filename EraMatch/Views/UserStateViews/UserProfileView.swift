//
//  UserProfileView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 22.07.2024.
//

import SwiftUI

struct UserProfileView: View {
    @StateObject private var viewModel = UserHomeViewModel()
    @State private var selectedTab: String = "Profile" // Selected tab state

    var body: some View {
        VStack {
            UserNavBarView(selectedTab: $selectedTab)
                .padding(.bottom, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(viewModel.username)
                                .font(.title)
                                .fontWeight(.bold)
                            Button(action: {
                                // Profile picture update action
                            }) {
                                Text("Update profile picture")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.trailing)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio")
                            .font(.headline)
                        TextField("Write about yourself...", text: $viewModel.bio)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                        Text("Country")
                            .font(.headline)
                        TextField("Country", text: $viewModel.country)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                        Text("E-Mail")
                            .font(.headline)
                        TextField("email@provider.com", text: $viewModel.email)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                        Text("Instagram Profile")
                            .font(.headline)
                        TextField("Instagram Profile", text: $viewModel.instagram)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                        Text("Facebook Profile")
                            .font(.headline)
                        TextField("Facebook Profile", text: $viewModel.facebook)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                        Button(action: {
                            // Change password action
                        }) {
                            Text("Change Password")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                }
            }
            .background(BackgroundView())
        }
        .onAppear {
            viewModel.loadUserData()
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
