//
//  PersonData.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 21/10/2021.
//

import Foundation

struct PersonDataResults: Codable {
    var results: [PersonData]
    var info: ResultInfo
}

struct PersonData: Codable {
    var gender: String
    var name: PersonName
    var location: PersonLocation
    var email: String
    var dob: PersonDateOfBirth
    var phone: String
    var cell: String
    var id: PersonId
    var picture: PersonPicture
    var nat: String
}

struct ResultInfo: Codable {
    var seed: String
    var results: Int
    var page: Int
    var version: String
}

struct PersonName: Codable {
    var title: String
    var first: String
    var last: String
}

struct PersonLocation: Codable {
    var street: PersonLocationStreet
    var city: String
    var state: String
    var country: String
    var postcode: String
    var coordinates: PersonLocationCoordinate
    var timezone: PersonLocationTimezone
}

struct PersonLocationStreet: Codable {
    var number: Int
    var name: String
}

struct PersonLocationCoordinate: Codable {
    var latitude: String
    var longitude: String
}

struct PersonLocationTimezone: Codable {
    var offset: String
    var description: String
}

struct PersonDateOfBirth: Codable {
    var date: String
    var age: Int
}

struct PersonId: Codable {
    var name: String?
    var value: String
}

struct PersonPicture: Codable {
    var large: String
    var medium: String
    var thumbnail: String
}
