//
//  UserNavBarView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 21.07.2024.
//

import SwiftUI

struct UserNavBarView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        HStack {
            navBarButton(imageName: "house", title: "Home", destination: UserHomeView())
            Spacer()
            navBarButton(imageName: "calendar", title: "Events", destination: Text("Events View")) // Replace with actual view
            Spacer()
            navBarButton(imageName: "paperplane", title: "Submissions", destination: Text("Submissions View")) // Replace with actual view
            Spacer()
            navBarButton(imageName: "person", title: "Profile", destination: UserProfileView())
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.black, lineWidth: 0.5)
        )
        .frame(maxWidth: .infinity)
    }

    private func navBarButton<Destination: View>(imageName: String, title: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            VStack {
                Image(systemName: imageName)
                    .font(.title)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(.purple)
        }
    }
}

struct UserNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        UserNavBarView()
            .environmentObject(LoginViewModel())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

