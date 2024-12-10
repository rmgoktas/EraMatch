import SwiftUI
import Firebase

struct UserEventsView: View {
    @StateObject private var viewModel = EventCardViewModel()
    @State private var currentIndex = 0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        VStack {
            Text("")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            if viewModel.isLoading {
                ProgressView("Loading events...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.events.isEmpty {
                Text("No events found for your nationality.")
                    .foregroundColor(.secondary)
            } else {
                GeometryReader { geometry in
                    let cardWidth = geometry.size.width * 0.8
                    let cardSpacing: CGFloat = 20
                    
                    ZStack {
                        ForEach(Array(viewModel.events.enumerated().reversed()), id: \.element.id) { index, event in
                            EventCard(event: event)
                                .frame(width: cardWidth)
                                .offset(x: CGFloat(index - currentIndex) * (cardWidth + cardSpacing) + offset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            offset = value.translation.width
                                        }
                                        .onEnded { value in
                                            let threshold = cardWidth / 3
                                            if value.translation.width > threshold && currentIndex > 0 {
                                                currentIndex -= 1
                                            } else if value.translation.width < -threshold && currentIndex < viewModel.events.count - 1 {
                                                currentIndex += 1
                                            }
                                            withAnimation(.spring()) {
                                                offset = 0
                                            }
                                        }
                                )
                        }
                    }
                    .frame(height: geometry.size.height)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchEventsForUser()
            }
        }
    }
}

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: URL(string: event.eventPhotoURL ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(height: 200)
            .clipped()
            
            Text(event.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(event.country)
                .font(.subheadline)
            
            Text("Type: \(event.type)")
                .font(.subheadline)
            
            Text("Topic: \(event.topic)")
                .font(.subheadline)
            
            Text("Date: \(formattedDateRange(start: event.startDate, end: event.endDate))")
                .font(.subheadline)
            
            Spacer()
            
            Button("Apply") {
                // Handle apply action
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    private func formattedDateRange(start: Date, end: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return "\(dateFormatter.string(from: start)) - \(dateFormatter.string(from: end))"
    }
}

