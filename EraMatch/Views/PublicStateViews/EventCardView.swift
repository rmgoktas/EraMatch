//
//  EventCard.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 26.07.2024.
//

import SwiftUI
import FirebaseStorage

struct EventCardView: View {
    let event: Event
    var onDetailTap: () -> Void
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        VStack(spacing: 0) {
            // Event image
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
            
            // Top section with included items icons
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
                // Country flag
                if let countryCode = getCountryCode(from: event.country) {
                    Text(countryFlag(from: countryCode))
                        .font(.system(size: 30))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Event details
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Training Course on \"\(event.topic)\"")
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
                
                // Detail button
                HStack {
                    Spacer()
                    Button(action: onDetailTap) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.yellow)
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
    }
    
    private var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let startString = formatter.string(from: event.startDate)
        let endString = formatter.string(from: event.endDate)
        return "\(startString) - \(endString)"
    }
    
    private func getCountryCode(from country: String) -> String? {
        // Extract country code from country string (e.g., "Madrid, SPAIN" -> "ES")
        let components = country.components(separatedBy: ", ")
        guard let countryName = components.last else { return nil }
        
        // Simple mapping for demo - expand as needed
        let countryCodes = ["SPAIN": "ES"]
        return countryCodes[countryName]
    }
    
    private func countryFlag(from countryCode: String) -> String {
        // Convert country code to flag emoji
        let base: UInt32 = 127397
        var flag = ""
        for scalar in countryCode.unicodeScalars {
            flag.append(String(UnicodeScalar(base + scalar.value)!))
        }
        return flag
    }
    
    private func loadEventImage() {
        if let imageUrl = event.eventPhotoURL {
            imageLoader.loadImage(from: imageUrl)
        }
    }
}

struct IconView: View {
    let systemName: String
    
    var body: some View {
        Image(systemName: systemName)
            .foregroundColor(.yellow)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black)
            )
    }
}
