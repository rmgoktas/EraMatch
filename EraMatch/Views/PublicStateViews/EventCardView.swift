//
//  EventCard.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 26.07.2024.
//

import SwiftUI
import FirebaseStorage

struct NGOEventCardView: View {
    let event: Event
    let onTap: () -> Void
    @StateObject private var imageLoader = ImageLoader()
    @State private var showEventDetails = false
    @State private var showDeleteAlert = false
    @StateObject private var eventViewModel = EventCardViewModel.shared
    
    var body: some View {
        VStack(spacing: 0) {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    )
            }
            
            HStack(spacing: 12) {
                if event.includedItems.accommodation {
                    IconView(systemName: "bed.double.fill")
                }
                if event.includedItems.transportation {
                    IconView(systemName: "airplane")
                }
                if event.includedItems.food {
                    IconView(systemName: "fork.knife")
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\"\(event.type)\" on \"\(event.topic)\"")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(event.country)
                    .font(.subheadline)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.black)
                    Text(dateRangeString)
                        .font(.subheadline)
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        print("Button tapped: \(event.title)") // Debugging için
                        showEventDetails = true
                        onTap()
                    }) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black)
                            )
                    }
                }
                .padding(.top, 8)
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
        .padding(.horizontal)
        .onAppear(perform: loadEventImage)
        .contentShape(Rectangle())
        .onTapGesture {
            print("Event tapped: \(event.title)")
            onTap()
        }
        .sheet(isPresented: $showEventDetails) {
            NgoEventDetailsView(event: event)
        }
        .alert("Delete Event", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteEvent()
            }
        } message: {
            Text("Are you sure you want to delete this event? This action cannot be undone.")
        }
    }
    
    private var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let startString = formatter.string(from: event.startDate)
        let endString = formatter.string(from: event.endDate)
        return "\(startString) - \(endString)"
    }
    
    private func loadEventImage() {
        if let imageUrl = event.eventPhotoURL {
            imageLoader.loadImage(from: imageUrl)
        }
    }
    
    private func deleteEvent() {
        guard let eventId = event.id else { return }
        
        Task {
            do {
                try await eventViewModel.deleteEvent(eventId: eventId)
                print("Event successfully deleted")
            } catch {
                print("Error deleting event: \(error.localizedDescription)")
            }
        }
    }
}

struct IconView: View {
    let systemName: String
    
    var body: some View {
        Image(systemName: systemName)
            .foregroundColor(.white)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black)
            )
    }
}


struct UserEventCardView: View {
    let event: Event
    var onDetailTap: () -> Void
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let imageUrl = event.eventPhotoURL {
                Group {
                    if let loadedImage = imageLoader.image {
                        Image(uiImage: loadedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.65)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    } else {
                        Color.gray.opacity(0.3)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            )
                    }
                }
            }
            
            VStack(spacing: 16) {
                Spacer()
                
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                        
                        Text("Type: \(event.type)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Text("Topic: \(event.topic)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Text("Country: \(event.country)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Text(dateRangeString)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 12) {
                        if event.includedItems.transportation {
                            Image(systemName: "airplane")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        if event.includedItems.food {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        if event.includedItems.accommodation {
                            Image(systemName: "bed.double.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                
                Button(action: onDetailTap) {
                    Text("View Details")
                        .font(.headline)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(Color.white.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 16)
                .padding(.horizontal, 20)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.8),
                        Color.black.opacity(0.6),
                        Color.black.opacity(0.4),
                        Color.black.opacity(0.2),
                        Color.clear
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.65)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.white.opacity(0.4), radius: 10, x: 0, y: 5)
        .onAppear {
            if let imageUrl = event.eventPhotoURL {
                imageLoader.loadImage(from: imageUrl)
            }
        }
        .onDisappear {
            imageLoader.cancel()
        }
    }
    
    private var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let startString = formatter.string(from: event.startDate)
        let endString = formatter.string(from: event.endDate)
        return "\(startString) - \(endString)"
    }
}

