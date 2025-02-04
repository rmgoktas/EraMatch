import SwiftUI

struct UserEventsView: View {
    @StateObject private var viewModel = EventCardViewModel.shared
    @State private var selectedEvent: Event?
    @State private var showEventDetails = false
    @State private var searchText = ""
    
    private var filteredEvents: [Event] {
        if searchText.isEmpty {
            return viewModel.events
        }
        return viewModel.events.filter { event in
            event.title.localizedCaseInsensitiveContains(searchText) ||
            event.country.localizedCaseInsensitiveContains(searchText) ||
            event.topic.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search events...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, getSafeAreaTop())
                    
                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Loading events...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            Text("Please try again later")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else if filteredEvents.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text(searchText.isEmpty ? "No events found" : "No matching events")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(searchText.isEmpty ? "Check back later for new events" : "Try different search terms")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        ForEach(filteredEvents) { event in
                            EventCard(event: event) {
                                selectedEvent = event
                                showEventDetails = true
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 16)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            
            // Blur overlay for top safe area
            Rectangle()
                .fill(Color(.systemGroupedBackground))
                .frame(height: getSafeAreaTop())
                .frame(maxWidth: .infinity)
                .blur(radius: 20)
                .overlay(
                    Rectangle()
                        .fill(Color(.systemGroupedBackground).opacity(0.8))
                )
                .ignoresSafeArea()
        }
        .refreshable {
            await viewModel.forceRefresh()
        }
        .task {
            if viewModel.events.isEmpty {
                await viewModel.fetchEventsForUser()
            }
        }
        .sheet(isPresented: $showEventDetails) {
            if let event = selectedEvent {
                NavigationStack {
                    UserEventDetailsView(event: event)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showEventDetails = false
                                }
                            }
                        }
                }
            }
        }
    }
    
    private func getSafeAreaTop() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else { return 47 }
        return window.safeAreaInsets.top
    }
}

struct EventCard: View {
    let event: Event
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Event Image
                if let photoURL = event.eventPhotoURL,
                   let url = URL(string: photoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                                    .tint(.gray)
                            )
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Title and Location
                    Text(event.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        Text(event.country)
                            .foregroundColor(.secondary)
                    }
                    
                    // Tags
                    HStack {
                        EventTag(text: event.type, color: .blue)
                        EventTag(text: event.topic, color: .purple)
                    }
                    
                    // Included Items
                    HStack(spacing: 12) {
                        if event.includedItems.accommodation {
                            Label("Accommodation", systemImage: "house.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if event.includedItems.food {
                            Label("Food", systemImage: "fork.knife")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if event.includedItems.transportation {
                            Label("Transport", systemImage: "airplane")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
}

struct EventTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }
}
