//
//  UserEventsView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 12.10.2024.
//

import SwiftUI

struct UserEventsView: View {
    @State private var selectedTab: String = "Events"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                EventCardView(
                    title: "Hidden Geniuses",
                    subtitle: "Training Course on “Digital Skills”",
                    location: "Madrid, SPAIN",
                    dateRange: "14 Apr 2024 - 21 Apr 2024", onDetailTap: { /* TODO Navigate to event details */ }
                )
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                
                EventCardView(
                    title: "Youth Exchange",
                    subtitle: "Exploring Cultural Diversity",
                    location: "Berlin, GERMANY",
                    dateRange: "10 Jun 2024 - 20 Jun 2024", onDetailTap: { /* TODO Navigate to event details */ }
                )
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                
                EventCardView(
                    title: "Environmental Summit",
                    subtitle: "Actions for a Sustainable Future",
                    location: "Oslo, NORWAY",
                    dateRange: "5 Jul 2024 - 12 Jul 2024", onDetailTap: { /* TODO Navigate to event details */ }
                )
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}

struct UserEventsView_Previews: PreviewProvider {
    static var previews: some View {
        UserEventsView()
    }
}
