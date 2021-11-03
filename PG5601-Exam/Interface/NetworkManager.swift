//
//  Manager.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 25/10/2021.
//

import Foundation
import Logging


class NetworkManager {
    //Add variables for specific delegates here thus making them accessible to child classes of Manager
    var personManagerDelegate: PersonManagerDelegate?
    let logger = Logger(label: "NetworkManager")
    
    func fetchData(with url: URLRequest) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.personManagerDelegate?.didFailWithError(error: error!)
            }
            if let safeData = data {
                self.logger.info("Successfully fetched data from API")
                self.personManagerDelegate?.didFetchPersons(personArray: self.parseJSON(from: safeData)!)
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
            self.personManagerDelegate?.didFailWithError(error: jsonError)
            return nil
        }
    }

}
