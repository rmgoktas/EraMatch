//
//  Event.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 21.11.2024.
//

import Foundation
import FirebaseFirestore

struct IncludedItems: Codable {
    var transportation: Bool = false
    var accommodation: Bool = false
    var food: Bool = false
}

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var country: String
    var type: String
    var topic: String
    var startDate: Date
    var endDate: Date
    var includedItems: IncludedItems
    var lookingFor: [Participant]
    var countries: [CountryNGO]
    var reimbursementLimit: Double
    var eventInfoPackURL: String?
    var eventPhotoURL: String?
    var formLink: String
    var creatorId: String
    var otherTopic: String = ""
    var imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case country
        case type
        case topic
        case startDate
        case endDate
        case includedItems
        case lookingFor
        case countries
        case reimbursementLimit
        case eventInfoPackURL
        case eventPhotoURL
        case formLink
        case creatorId
        case otherTopic
        case imageURL
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
