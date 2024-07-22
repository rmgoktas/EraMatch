//
//  UserNavBarView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 21.07.2024.
//

import SwiftUI

struct UserNavBarView: View {
    @Binding var selectedTab: String
    
    var body: some View {
        HStack {
            Button(action: {
                selectedTab = "Home"
            }) {
                VStack {
                    Image(systemName: "house")
                        .font(.title)
                    Text("Home")
                        .font(.caption)
                }
                .foregroundColor(selectedTab == "Home" ? .purple : .gray)
            }
            
            Spacer()
            
            Button(action: {
                selectedTab = "Events"
            }) {
                VStack {
                    Image(systemName: "calendar")
                        .font(.title)
                    Text("Events")
                        .font(.caption)
                }
                .foregroundColor(selectedTab == "Events" ? .purple : .gray)
            }
            
            Spacer()
            
            Button(action: {
                selectedTab = "Submissions"
            }) {
                VStack {
                    Image(systemName: "paperplane")
                        .font(.title)
                    Text("Submissions")
                        .font(.caption)
                }
                .foregroundColor(selectedTab == "Submissions" ? .purple : .gray)
            }
            
            Spacer()
            
            Button(action: {
                selectedTab = "Profile"
            }) {
                VStack {
                    Image(systemName: "person")
                        .font(.title)
                    Text("Profile")
                        .font(.caption)
                }
                .foregroundColor(selectedTab == "Profile" ? .purple : .gray)
            }
        }
        .padding(.horizontal) // Adjust horizontal padding for spacing
        .padding(.vertical, 10) // Vertical padding for top and bottom
        .background(Color.white)
        .cornerRadius(15) // Border radius added
        .shadow(radius: 5) // Optional shadow for better visual effect
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.black, lineWidth: 1) // Border with corner radius
        )
        .frame(maxWidth: .infinity) // Expand to fit the width of the screen
    }
}

struct UserNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        UserNavBarView(selectedTab: .constant("Home"))
            .previewLayout(.sizeThatFits)
            .padding() // Padding to preview
    }
}





