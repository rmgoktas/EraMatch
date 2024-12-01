//
//  NgoMyEventsView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 11.10.2024.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct NgoMyEventsView: View {
    @StateObject private var viewModel = EventCardViewModel()
    @State private var isUserLoggedIn = false
    @State private var userId: String = ""

    var body: some View {
        Group {
            if isUserLoggedIn {
                eventListView
            } else {
                Text("Lütfen oturum açın")
            }
        }
        .onAppear(perform: checkUserAuthenticationStatus)
    }

    private var eventListView: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Etkinlikler yükleniyor...")
            } else if !viewModel.events.isEmpty {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.events) { event in
                        EventCardView(event: event) {
                            print("Etkinliğe tıklandı: \(event.title)")
                        }
                    }
                }
                .padding(.vertical)
            } else {
                Text("Hiç etkinlik bulunamadı")
            }
        }
    }

    private func checkUserAuthenticationStatus() {
        if let user = Auth.auth().currentUser {
            isUserLoggedIn = true
            userId = user.uid
            print("Oturum açmış kullanıcı ID'si: \(userId)")
            viewModel.fetchEvents(for: userId)
        } else {
            isUserLoggedIn = false
            print("Kullanıcı oturum açmamış")
        }
    }
}
