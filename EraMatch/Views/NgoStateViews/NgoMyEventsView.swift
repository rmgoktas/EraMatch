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
    @State private var viewAppeared = false

    var body: some View {
        Group {
            if isUserLoggedIn {
                eventListView
            } else {
                Text("Lütfen oturum açın")
            }
        }
        .onAppear {
            checkUserAuthenticationStatus()
            viewAppeared = true
        }
        .onChange(of: viewAppeared) { _ in
            if isUserLoggedIn {
                Task {
                    await viewModel.refreshEvents(for: userId)
                }
            }
        }
    }

    private var eventListView: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading events...")
            } else if viewModel.events.isEmpty {
                Text("Etkinlik bulunamadı.")
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.events) { event in
                        EventCardView(event: event) {
                            print("Etkinliğe tıklandı: \(event.title)")
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .refreshable {
            await viewModel.refreshEvents(for: userId)
        }
        .navigationBarItems(trailing: refreshButton)
        .onAppear {
            if !viewModel.events.isEmpty {
                Task {
                    await viewModel.refreshEvents(for: userId)
                }
            }
        }
    }

    private var refreshButton: some View {
        Button(action: {
            Task {
                await viewModel.refreshEvents(for: userId)
            }
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.title2)
        }
    }

    private func checkUserAuthenticationStatus() {
        if let user = Auth.auth().currentUser {
            isUserLoggedIn = true
            userId = user.uid
            print("Oturum açmış kullanıcı ID'si: \(userId)")
            viewModel.fetchEvents(for: userId)
            viewModel.startListening(for: userId)
        } else {
            isUserLoggedIn = false
            print("Kullanıcı oturum açmamış")
        }
    }
}

