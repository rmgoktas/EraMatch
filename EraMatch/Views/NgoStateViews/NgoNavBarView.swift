//
//  NgoNavBarView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 26.07.2024.
//

import SwiftUI

struct NgoNavBarView: View {
    var body: some View {
        HStack {
            navBarButton(imageName: "calendar", title: "My Events", destination: Text("My Events View")) // Replace with actual view
            Spacer()
            navBarButton(imageName: "checkmark.circle", title: "Submissions", destination: Text("Submissions View")) // Replace with actual view
            Spacer()
            navBarButton(imageName: "person", title: "Profile", destination: Text("Profile View")) // Replace with actual view
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

struct NGONavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NgoNavBarView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

