//
//  GuideScreenView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 21.07.2024.
//

import SwiftUI

enum GuideContent {
    case whatIsEraMatch
    case howDoIParticipate
    case doIHaveToPay
    case whatCanIDo
}

struct GuideScreenView: View {
    var content: GuideContent
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(title(for: content))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text(description(for: content))
                    .font(.body)
                    .padding(.top, 10)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Guide")
    }
    
    private func title(for content: GuideContent) -> String {
        switch content {
        case .whatIsEraMatch:
            return "What is EraMatch ?"
        case .howDoIParticipate:
            return "How Do I Participate ?"
        case .doIHaveToPay:
            return "Do I Have to Pay ?"
        case .whatCanIDo:
            return "What Can I Do on EraMatch ?"
        }
    }
    
    private func description(for content: GuideContent) -> String {
        switch content {
        case .whatIsEraMatch:
            return "EraMatch is a digital platform that supports the dissemination of free travel experiences, jobs, trainings and volunteering opportunities in Europe and the whole world. We have catalogued the main offers of free travel events, volunteering and jobs in: private events, youth exchanges, jobs, internships, training courses, seminars, volunteering opportunities."
        case .howDoIParticipate:
            return "You have to apply and be selected by the organizers of the travel opportunities you apply for. In order to apply for these events you don't need anything in particular, usually the only thing that is required is the ability to speak English and to have great positive energy! Reimbursement budgets and additional details are usually specified on the infopacks which are informative documents for each event. You can browse and apply for as many as you like!"
        case .doIHaveToPay:
            return "It depends on the type of the event. You can check covered expenses in the events' details page before applying. Most events, like Youth Exchanges, often cover everything. Accommodation and food are often offered by the event organizers. Reimbursements are offered (with fair budget caps) for the entire trip that will be emitted in last instance by the organizers of the given event. You'll only need to pay in advance the money for your travel."
        case .whatCanIDo:
            return "EraMatch is an impressive tool that is useful to people interested in applying for free mobility events according to their interests and needs... but it's also useful to the events' organizers. Here's a list of the features for: Travellers: browse as many events or jobs as you want for free; receive notifications to know when events that match your interests have been uploaded; manage and sync across your devices all your tickets, budgets, packing lists, documents and more; customize your search by using filters by your country, events' host country, start date, end date, topic, type."
        }
    }
}

struct GuideScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GuideScreenView(content: .whatIsEraMatch)
        }
    }
}

