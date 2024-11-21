//
//  Event.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 21.11.2024.
//


import Foundation
import FirebaseFirestoreSwift

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var country: String
    var type: String
    var topic: String
    var startDate: Date
    var endDate: Date
    var included: [String]
    var lookingFor: [Participant]
    var countries: [CountryNGO]
    var reimbursementLimit: Double
    var eventInfoPackURL: String?
    var eventPhotoURL: String?
    var formLink: String
    var creatorId: String 
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case country
        case type
        case topic
        case startDate
        case endDate
        case included
        case lookingFor
        case countries
        case reimbursementLimit
        case eventInfoPackURL
        case eventPhotoURL
        case formLink
        case creatorId
    }
}

struct Participant: Codable {
    var count: Int
    var nationality: String
}

struct CountryNGO: Codable {
    var country: String
    var ngoName: String
}
