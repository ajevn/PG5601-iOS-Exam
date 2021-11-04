//
//  Constants.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 21/10/2021.
//

import Foundation

struct K {
    //Storing globally used constants to minimize errors resulting from typos in commonly used variable names
    static let personListCellIdentifier = "PersonReusableCell"
    static let personListCellName = "PersonCell"
    static let personApiSeedKey = "PersonApiSeedKey"
    static let personApiBaseUrl = "https://randomuser.me/api/"
    static let personApiURLExcludedFields = "exc=login&exc=registered"
    static let personApiURLNationality = "nat=no"
    static let personApiURLStandardSeed = "seed=ios"
    static let personMapAnnotationKey = "PersonAnnotationKey"
}

