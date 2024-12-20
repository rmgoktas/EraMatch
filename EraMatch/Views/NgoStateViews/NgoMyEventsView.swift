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
    @StateObject private var viewModel = EventCardViewModel.shared
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading events...")
            } else if viewModel.events.isEmpty {
                Text("Event not found.")
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.events) { event in
                        NGOEventCardView(event: event) {
                            print("Etkinliğe tıklandı: \(event.title)")
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .onAppear {
            Task {
                await viewModel.refreshEvents(for: loginViewModel.userId ?? "")
            }
        }
        .refreshable {
            Task {
                await viewModel.refreshEvents(for: loginViewModel.userId ?? "")
            }
        }
    }
}
