//
//  NGO.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 14.12.2024.
//


struct NGO: Codable, Identifiable {
    var id: String // Firebase uid
    var type: String
    var ngoName: String
    var email: String
    var oidNumber: String
    var country: String
    var logoUrl: String?
    var pifUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "uid"
        case type
        case ngoName
        case email
        case oidNumber
        case country
        case logoUrl
        case pifUrl
    }
}
