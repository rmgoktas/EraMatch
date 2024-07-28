//
//  NgoProfileView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 25.07.2024.
//

import SwiftUI

struct NgoProfileView: View {
    @EnvironmentObject var signUpViewModel: NgoSignUpViewModel

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                VStack {
                    // Üst çubuk
                    HStack {
                        Button(action: {
                            // Menu action
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Text("Profile")
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

                    GeometryReader { geometry in
                        ScrollView {
                            VStack {
                                VStack(spacing: 20) {
                                    // Profile Picture and Name
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                        Text(signUpViewModel.ngoName.isEmpty ? "STKAdi" : signUpViewModel.ngoName)
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
                                            TextField("Country", text: $signUpViewModel.ngoCountry)
                                                .padding()
                                                .background(Color(.systemGray6))
                                                .cornerRadius(8)
                                        }
                                        VStack(alignment: .leading) {
                                            Text("OID Number")
                                                .font(.headline)
                                            TextField("OID Number", text: $signUpViewModel.oidNumber)
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
                                        TextField("email@provider.com", text: $signUpViewModel.ngoEmail)
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
                                            TextField("Instagram Profile", text: $signUpViewModel.instagram)
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
                                            TextField("Facebook Profile", text: $signUpViewModel.facebook)
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
                                }
                                .padding(.all, 20)
                                .background(Color.white)
                                .cornerRadius(8)
                                .padding(.horizontal)
                                .padding(.top, geometry.safeAreaInsets.top + 40)
                            }
                        }
                    }
                }

                // NGO Nav Bar
                VStack {
                    Spacer()
                    NgoNavBarView()
                        .padding(.horizontal)
                        .padding(.top, 10)
                }

                // Floating Action Button
                VStack {
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct NgoProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NgoProfileView()
            .environmentObject(NgoSignUpViewModel())
    }
}




