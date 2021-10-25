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

class PersonManager: Manager {
    
    let baseURL = "https://randomuser.me/api/"
    let urlSeed = "seed=403f97561700da74"
    let urlNationality = "nat=no"
    let urlExcludedFields = "exc=login&exc=registered"
    let resultCount = "100"


    override init() {
        super.init()
        var request = URLRequest(url: URL(string: "\(baseURL)?results=\(resultCount)&\(urlNationality)&\(urlExcludedFields)&\(urlSeed)")!)
        request.setValue("Content-Type", forHTTPHeaderField: "application/json")
        
        fetchData(with: request)
    }
}

