//
//  NotificationsView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 18.12.2024.
//

import SwiftUI

struct NotificationView: View {
    @Binding var shouldDismiss: Bool

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "bell.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .opacity(0.5)
                Text("You have no notifications yet. Check back later!")
                    .font(.headline)
                    .foregroundColor(.gray) 
            }
            .navigationBarTitle("Notifications", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                shouldDismiss = false
            })
        }
    }
}
