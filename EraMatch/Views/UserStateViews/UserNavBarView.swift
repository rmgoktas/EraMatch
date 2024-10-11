//
//  UserNavBarView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 21.07.2024.
//

import SwiftUI

struct UserNavBarView: View {
    @Binding var selectedTab: String // Seçili sekmeyi tutacak binding değişkeni

    var body: some View {
        HStack {
            navBarButton(imageName: "house", title: "Home", selectedTab: $selectedTab, tabName: "Home")
            Spacer()
            navBarButton(imageName: "calendar", title: "My Events", selectedTab: $selectedTab, tabName: "Events")
            Spacer()
            navBarButton(imageName: "paperplane", title: "Submissions", selectedTab: $selectedTab, tabName: "Submissions")
            Spacer()
            navBarButton(imageName: "person", title: "Profile", selectedTab: $selectedTab, tabName: "Profile")
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
    
    private func navBarButton(imageName: String, title: String, selectedTab: Binding<String>, tabName: String) -> some View {
        Button(action: {
            selectedTab.wrappedValue = tabName // Seçili sekmeyi güncelle
        }) {
            VStack {
                Image(systemName: imageName)
                    .font(.title)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(selectedTab.wrappedValue == tabName ? .purple : .gray) 
        }
    }
}

struct UserNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        // Seçili sekme için bir örnek Binding oluştur
        StateWrapper()
            .environmentObject(LoginViewModel())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

// StateWrapper, selectedTab'ı Binding olarak sağlamak için kullanılabilir
struct StateWrapper: View {
    @State private var selectedTab: String = "Home"
    
    var body: some View {
        UserNavBarView(selectedTab: $selectedTab)
    }
}


