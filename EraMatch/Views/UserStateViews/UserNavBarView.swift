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
        HStack(spacing: 30) {
            Spacer()
            navBarButton(imageName: "house", title: "Home", selectedTab: $selectedTab, tabName: "Home")
            Spacer()
            navBarButton(imageName: "calendar", title: "Events", selectedTab: $selectedTab, tabName: "Events")
            Spacer()
            navBarButton(imageName: "person", title: "Profile", selectedTab: $selectedTab, tabName: "Profile")
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white.opacity(1))
        .cornerRadius(15)
        .shadow(radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.black, lineWidth: 0.5)
        )
        .frame(maxWidth: .infinity)
    }
    
    private func navBarButton(imageName: String, title: String, selectedTab: Binding<String>, tabName: String) -> some View {
        Button(action: {
            selectedTab.wrappedValue = tabName
        }) {
            VStack {
                Image(systemName: imageName)
                    .font(.title)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(selectedTab.wrappedValue == tabName ? .black : .gray)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab = "Home"
        
        var body: some View {
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    UserNavBarView(
                        selectedTab: $selectedTab
                    )
                }
            }
        }
    }
    
    return PreviewWrapper()
}



