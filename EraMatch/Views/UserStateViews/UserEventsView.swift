import SwiftUI

struct UserEventsView: View {
    @StateObject private var viewModel = EventCardViewModel.shared
    @State private var currentIndex = 0
    @State private var selectedEvent: Event?
    @State private var showEventDetails = false
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading events...")
                    .foregroundColor(.white)
                    .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                    .scaleEffect(1.5)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.events.isEmpty {
                Text("No events found for your country.")
                    .foregroundColor(.white)
                    .padding()
            } else {
                GeometryReader { geometry in
                    ZStack {
                        ForEach(Array(viewModel.events.enumerated().reversed()), id: \.element.id) { index, event in
                            UserEventCardView(event: event) {
                                selectedEvent = event
                                showEventDetails = true
                            }
                            .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.65)
                            .offset(x: calculateXOffset(for: index, geometry: geometry),
                                    y: calculateYOffset(for: index) - geometry.size.height * 0.15)
                            .scaleEffect(calculateScale(for: index))
                            .zIndex(Double(viewModel.events.count - index))
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: dragOffset)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation.width
                            }
                            .onEnded { value in
                                let threshold = geometry.size.width / 4
                                if value.translation.width < -threshold && currentIndex < viewModel.events.count - 1 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        currentIndex += 1
                                    }
                                }
                                if value.translation.width > threshold && currentIndex > 0 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        currentIndex -= 1
                                    }
                                }
                            }
                    )
                }
                .padding(.top, 150)
            }
        }
        .task {
            if viewModel.events.isEmpty {
                await viewModel.fetchEventsForUser()
            }
        }
        .refreshable {
            await viewModel.forceRefresh()
        }
        .sheet(isPresented: $showEventDetails) {
            if let event = selectedEvent {
                UserEventDetailsView(event: event)
            }
        }
    }
    
    private func calculateXOffset(for index: Int, geometry: GeometryProxy) -> CGFloat {
        if index < currentIndex {
            return -geometry.size.width
        } else if index > currentIndex {
            let offset = CGFloat(index - currentIndex) * 20
            return offset
        }
        return dragOffset
    }
    
    private func calculateYOffset(for index: Int) -> CGFloat {
        if index <= currentIndex {
            return 0
        }
        return CGFloat(index - currentIndex) * 15
    }
    
    private func calculateScale(for index: Int) -> CGFloat {
        if index <= currentIndex {
            return 1.0
        }
        return 1.0 - CGFloat(index - currentIndex) * 0.05
    }
}
