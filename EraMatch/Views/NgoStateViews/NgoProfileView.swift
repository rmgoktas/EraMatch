//
//  NgoProfileView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 25.07.2024.
//

import SwiftUI

struct NgoProfileView: View {
    @ObservedObject var homeViewModel: NgoHomeViewModel
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Picture and Name
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                    Text(homeViewModel.ngoName)
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    Button(action: {
                        // Share action
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                .padding()
                
                // Country and OID Number
                HStack {
                    VStack(alignment: .leading) {
                        Text("Country")
                            .font(.headline)
                        TextField("Country", text: $homeViewModel.country)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    VStack(alignment: .leading) {
                        Text("OID Number")
                            .font(.headline)
                        TextField("OID Number", text: $homeViewModel.oidNumber)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                // Email
                VStack(alignment: .leading) {
                    Text("E-Mail")
                        .font(.headline)
                    TextField("email@provider.com", text: $homeViewModel.email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Social Profiles
                VStack(alignment: .leading) {
                    HStack {
                        Text("Instagram Profile")
                            .font(.headline)
                        TextField("Instagram Profile", text: $homeViewModel.instagram)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                Image(systemName: "link")
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8),
                                alignment: .trailing
                            )
                    }
                    HStack {
                        Text("Facebook Profile")
                            .font(.headline)
                        TextField("Facebook Profile", text: $homeViewModel.facebook)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                Image(systemName: "link")
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8),
                                alignment: .trailing
                            )
                    }
                }
                .padding(.horizontal)

                // Download PIF Button
                Button(action: {
                    // Download PIF action
                }) {
                    Text("DOWNLOAD PIF")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Sign Out Button
                Button(action: {
                    loginViewModel.logoutUser()
                }) {
                    Text("SIGN OUT")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .padding(.all, 20)
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }
}

struct NgoProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NgoProfileView(homeViewModel: NgoHomeViewModel())
            .environmentObject(LoginViewModel()) 
    }
}






