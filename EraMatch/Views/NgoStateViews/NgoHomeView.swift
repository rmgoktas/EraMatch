//
//  AdminHomeView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 4.07.2024.
//

import SwiftUI

struct NgoHomeView: View {
    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 30) {
                // My Events Header
                Text("My Events")
                    .font(.title)
                    .bold()
                    .padding(.horizontal, 90)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(30)
                    .shadow(radius: 4)

                // Event Card
                EventCardView(
                    title: "Hidden Geniuses",
                    subtitle: "Training Course on “Digital Skills”",
                    location: "Madrid, SPAIN",
                    dateRange: "14 Apr 2024 - 21 Apr 2024",
                    onDetailTap: {
                        // Navigate to event details
                    }
                )

                Spacer()

                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // Add new event action
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(30)
                        }
                        .padding()
                    }
                }

                // NGO Nav Bar
                NgoNavBarView()
                    .padding(.top, 10)
            }
        }
    }
}

struct NgoHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NgoHomeView()
    }
}



