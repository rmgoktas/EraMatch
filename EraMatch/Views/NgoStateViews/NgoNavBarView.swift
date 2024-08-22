//
//  NgoNavBarView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 26.07.2024.
//

import SwiftUI

struct NgoNavBarView: View {
    @Binding var selectedTab: String

    var body: some View {
        HStack {
            navBarButton(imageName: "calendar", title: "My Events", selectedTab: $selectedTab)
            Spacer()
            navBarButton(imageName: "checkmark.circle", title: "Submissions", selectedTab: $selectedTab)
            Spacer()
            navBarButton(imageName: "person", title: "Profile", selectedTab: $selectedTab)
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

    private func navBarButton(imageName: String, title: String, selectedTab: Binding<String>) -> some View {
        Button(action: {
            selectedTab.wrappedValue = title
        }) {
            VStack {
                Image(systemName: imageName)
                    .font(.title)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(selectedTab.wrappedValue == title ? .purple : .gray)
        }
    }
}

struct NGONavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NgoNavBarView(selectedTab: .constant("My Events"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}



