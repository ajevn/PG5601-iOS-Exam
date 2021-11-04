//
//  PersonManager.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 22/10/2021.
//

import Foundation
import Logging

protocol NetworkManagerDelegate {
    func didFetchPersons(personArray: PersonDataResults)
    func didFailWithError(error: Error)
}

class NetworkManager{
    var networkManagerDelegate: NetworkManagerDelegate?
    let logger = Logger(label: "PersonManager")
    
    init() {
        
    }
    
    func fetchData(withBaseURL baseURL: String,withURLSeed urlSeed: String,withURLNationality urlNationality: String,withURLExcludedFields urlExcludedFields: String,withResultCount resultCount: String) {
        var url = URLRequest(url: URL(string: "\(baseURL)?results=\(resultCount)&\(urlNationality)&\(urlExcludedFields)&seed=\(urlSeed)")!)
        url.setValue("Content-Type", forHTTPHeaderField: "application/json")
        logger.info("Attempting to fetch data from API using seed: \(urlSeed)")


        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.networkManagerDelegate?.didFailWithError(error: error!)
                
                NotificationCenter.default.post(name: .didFailWithError, object: nil)
            }
            if let safeData = data {
                self.logger.info("Successfully fetched data from API")
                let personArrayParsed = self.parseJSON(from: safeData)!
                self.networkManagerDelegate?.didFetchPersons(personArray: personArrayParsed)
                
                NotificationCenter.default.post(name: .didFetchPersons, object: nil)
            }
        }
        task.resume()
    }
    
    func parseJSON(from data: Data) -> PersonDataResults? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(PersonDataResults.self, from: data)
            return decodedData
        } catch let jsonError as NSError {
            self.networkManagerDelegate?.didFailWithError(error: jsonError)
            return nil
        }
    }
}

