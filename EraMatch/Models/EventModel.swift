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
    var otherTopic: String

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
    }

    init(id: String? = nil, title: String, country: String, type: String, topic: String, startDate: Date, endDate: Date, includedItems: IncludedItems, lookingFor: [Participant], countries: [CountryNGO], reimbursementLimit: Double, eventInfoPackURL: String?, eventPhotoURL: String?, formLink: String, creatorId: String, otherTopic: String) {
        self.id = id
        self.title = title
        self.country = country
        self.type = type
        self.topic = topic
        self.startDate = startDate
        self.endDate = endDate
        self.includedItems = includedItems
        self.lookingFor = lookingFor
        self.countries = countries
        self.reimbursementLimit = reimbursementLimit
        self.eventInfoPackURL = eventInfoPackURL
        self.eventPhotoURL = eventPhotoURL
        self.formLink = formLink
        self.creatorId = creatorId
        self.otherTopic = otherTopic
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        country = try container.decode(String.self, forKey: .country)
        type = try container.decode(String.self, forKey: .type)
        topic = try container.decode(String.self, forKey: .topic)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        includedItems = try container.decode(IncludedItems.self, forKey: .includedItems)
        lookingFor = try container.decode([Participant].self, forKey: .lookingFor)
        countries = try container.decode([CountryNGO].self, forKey: .countries)
        reimbursementLimit = try container.decode(Double.self, forKey: .reimbursementLimit)
        eventInfoPackURL = try container.decodeIfPresent(String.self, forKey: .eventInfoPackURL)
        eventPhotoURL = try container.decodeIfPresent(String.self, forKey: .eventPhotoURL)
        formLink = try container.decode(String.self, forKey: .formLink)
        creatorId = try container.decode(String.self, forKey: .creatorId)
        otherTopic = try container.decodeIfPresent(String.self, forKey: .otherTopic) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(country, forKey: .country)
        try container.encode(type, forKey: .type)
        try container.encode(topic, forKey: .topic)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(includedItems, forKey: .includedItems)
        try container.encode(lookingFor, forKey: .lookingFor)
        try container.encode(countries, forKey: .countries)
        try container.encode(reimbursementLimit, forKey: .reimbursementLimit)
        try container.encodeIfPresent(eventInfoPackURL, forKey: .eventInfoPackURL)
        try container.encodeIfPresent(eventPhotoURL, forKey: .eventPhotoURL)
        try container.encode(formLink, forKey: .formLink)
        try container.encode(creatorId, forKey: .creatorId)
        try container.encode(otherTopic, forKey: .otherTopic)
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
