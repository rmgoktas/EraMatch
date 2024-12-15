//
//  NgoNavBarView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 26.07.2024.
//

import SwiftUI

struct NgoNavBarView: View {
    @Binding var selectedTab: String
    @Binding var isCreateEventViewPresented: Bool

    var body: some View {
        HStack(spacing: 20) {
            Spacer()
            navBarButton(imageName: "calendar", title: "My Events", selectedTab: $selectedTab)
            Spacer()
            
            ZStack {
                Button(action: {
                    isCreateEventViewPresented = true
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black, Color.black.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(selectedTab == "Create" ? 45 : 0))
                            .animation(.spring(response: 0.3), value: selectedTab == "Create")
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 56, height: 56)
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .center) 
            .offset(y: -0)
            
            Spacer()
            navBarButton(imageName: "person", title: "Profile", selectedTab: $selectedTab)
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
            .foregroundColor(selectedTab.wrappedValue == title ? .black : .gray)
        }
    }
}

