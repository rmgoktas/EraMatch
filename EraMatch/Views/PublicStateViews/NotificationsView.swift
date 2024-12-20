//
//  NotificationsView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 18.12.2024.
//

import SwiftUI

struct NotificationView: View {
    @Binding var shouldDismiss: Bool // Dismiss için binding

    var body: some View {
        NavigationView {
            VStack {
            }
            .navigationBarTitle("Notifications", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                shouldDismiss = false 
            })
        }
    }
}
