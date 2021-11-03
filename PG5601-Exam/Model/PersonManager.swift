//
//  PersonManager.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 22/10/2021.
//

import Foundation

protocol PersonManagerDelegate {
    func didFetchPersons(personArray: PersonDataResults)
    func didFailWithError(error: Error)
}

class PersonManager: NetworkManager {


    override init() {
        super.init()
    }
    
    func fetchData(withBaseURL baseURL: String,withURLSeed urlSeed: String,withURLNationality urlNationality: String,withURLExcludedFields urlExcludedFields: String,withResultCount resultCount: String) {
        var request = URLRequest(url: URL(string: "\(baseURL)?results=\(resultCount)&\(urlNationality)&\(urlExcludedFields)&\(urlSeed)")!)
        request.setValue("Content-Type", forHTTPHeaderField: "application/json")
        print("Attempting to fetch data from API using seed: \(urlSeed)")

        fetchData(with: request)
    }
}

