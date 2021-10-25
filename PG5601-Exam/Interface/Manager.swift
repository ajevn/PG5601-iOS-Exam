//
//  Manager.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 25/10/2021.
//

import Foundation

class Manager {
    //Add variables for specific delegates here thus making them accessible to child classes of Manager
    var personManagerDelegate: PersonManagerDelegate?
    
    func fetchData(with url: URLRequest) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.personManagerDelegate?.didFailWithError(error: error!)
            }
            if let safeData = data {
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
            //delegate?.didFailWithError(error: error)
            print(jsonError)
            return nil
        }
    }

}
