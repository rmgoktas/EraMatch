//
//  NgoMyEventsView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 11.10.2024.
//

import SwiftUI

struct NgoMyEventsView: View {
    var body: some View {
        VStack {
            EventCardView(
                title: "Hidden Geniuses",
                subtitle: "Training Course on “Digital Skills”",
                location: "Madrid, SPAIN",
                dateRange: "14 Apr 2024 - 21 Apr 2024", onDetailTap: { /* Navigate to event details */ }
            )
            .cornerRadius(10)

            EventCardView(
                title: "Youth Exchange",
                subtitle: "Exploring Cultural Diversity",
                location: "Berlin, GERMANY",
                dateRange: "10 Jun 2024 - 20 Jun 2024", onDetailTap: { /* Navigate to event details */ }
            )
            .cornerRadius(10)

            EventCardView(
                title: "Environmental Summit",
                subtitle: "Actions for a Sustainable Future",
                location: "Oslo, NORWAY",
                dateRange: "5 Jul 2024 - 12 Jul 2024", onDetailTap: { /* Navigate to event details */ }
            )
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct NgoMyEventsView_Previews: PreviewProvider {
    static var previews: some View {
        NgoMyEventsView()
    }
}

