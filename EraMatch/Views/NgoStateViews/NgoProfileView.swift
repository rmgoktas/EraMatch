//
//  NgoProfileView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 25.07.2024.
//

import SwiftUI

struct NgoProfileView: View {
    @State private var bio: String = "Write about your STK..."
    @State private var country: String = "Türkiye"
    @State private var oidNumber: String = "9999999999"
    @State private var email: String = "email@provider.com"
    @State private var instagramProfile: String = ""
    @State private var facebookProfile: String = ""

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 20) {
                // Profile Picture and Name
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                    Text("STKAdi")
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

                // Bio
                VStack(alignment: .leading) {
                    Text("Bio")
                        .font(.headline)
                    TextField("Write about your STK...", text: $bio)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Country and OID Number
                HStack {
                    VStack(alignment: .leading) {
                        Text("Country")
                            .font(.headline)
                        TextField("Country", text: $country)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    VStack(alignment: .leading) {
                        Text("OID Number")
                            .font(.headline)
                        TextField("OID Number", text: $oidNumber)
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
                    TextField("email@provider.com", text: $email)
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
                        TextField("Instagram Profile", text: $instagramProfile)
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
                        TextField("Facebook Profile", text: $facebookProfile)
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

                // Change Password
                HStack {
                    Spacer()
                    Button(action: {
                        // Change password action
                    }) {
                        Text("Change Password")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)

                // Download PIF Button
                Button(action: {
                    // Download PIF action
                }) {
                    Text("DOWNLOAD PIF")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                Spacer()

                // NGO Nav Bar
                NgoNavBarView()
                    .padding(.top, 10)
            }
        }
    }
}

struct NgoProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NgoProfileView()
    }
}



