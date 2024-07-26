//
//  EventCard.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 26.07.2024.
//

import SwiftUI

struct EventCardView: View {
    var title: String
    var subtitle: String
    var location: String
    var dateRange: String
    var onDetailTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
            Text(location)
                .font(.footnote)
            HStack {
                Image(systemName: "calendar")
                Text(dateRange)
                    .font(.footnote)
            }
            HStack {
                Spacer()
                Button(action: onDetailTap) {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.yellow)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
    }
}

struct EventCardView_Previews: PreviewProvider {
    static var previews: some View {
        EventCardView(
            title: "Hidden Geniuses",
            subtitle: "Training Course on “Digital Skills”",
            location: "Madrid, SPAIN",
            dateRange: "14 Apr 2024 - 21 Apr 2024",
            onDetailTap: {}
        )
    }
}
