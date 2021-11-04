//
//  PersistenceController.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 31/10/2021.
//

import Foundation
import CoreData
import Logging

class PersistenceManager {
    let logger = Logger(label: "PersistenceManager")
    
    func saveContext(withContext context: NSManagedObjectContext) {
        do {
            try context.save()
            logger.info("Successfully saved context")
        } catch {
            logger.error("Error saving context: \(error)")
        }
    }
    
    func deleteAllPersons(withContext context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PersonEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            logger.info("Successfully deleted context")
        } catch let error as NSError {
            logger.error("Error deleting context: \(error)")
        }
    }
    
    func deletePerson(personEntity: PersonEntity,withContext context: NSManagedObjectContext) {
        context.delete(personEntity)
        saveContext(withContext: context)
    }
    
    func loadPersons(withContext context: NSManagedObjectContext) -> [PersonEntity]? {
        let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
        do {
            let personArray = try context.fetch(fetchRequest)
            logger.info("Successfully loaded persons from context")
            return personArray
        } catch let error as NSError {
            logger.error("Error loading context: \(error)")
        }
        return nil
    }
    func loadEditedPersons(withContext context: NSManagedObjectContext) -> [EditedPersonEntity]? {
        let fetchRequest: NSFetchRequest<EditedPersonEntity> = EditedPersonEntity.fetchRequest()
        do {
            let personArray = try context.fetch(fetchRequest)
            logger.info("Successfully loaded edited persons from context")
            return personArray
        } catch let error as NSError {
            logger.error("Error loading context: \(error)")
        }
        return nil
    }
    func loadEditedPersonIds(withContext context: NSManagedObjectContext) -> [String]? {
        let fetchRequest: NSFetchRequest<EditedPersonEntity> = EditedPersonEntity.fetchRequest()
        do {
            let personArray = try context.fetch(fetchRequest)
            var personIdsArray: [String] = []
            
            for person in personArray {
                if let safeId = person.id {
                    personIdsArray.append(safeId)
                }
            }
            
            logger.info("Successfully loaded edited person ids")
            return personIdsArray
        } catch let error as NSError {
            logger.error("Error loading edited person ids: \(error)")
        }
        return nil
    }
    func loadDeletedPersonIds(withContext context: NSManagedObjectContext) -> [String]? {
        let fetchRequest: NSFetchRequest<DeletedPersonEntity> = DeletedPersonEntity.fetchRequest()
        do {
            let personArray = try context.fetch(fetchRequest)
            var personIdsArray: [String] = []
            
            for person in personArray {
                if let safeId = person.id {
                    personIdsArray.append(safeId)
                }
            }
            
            logger.info("Successfully loaded deleted person ids")
            return personIdsArray
        } catch let error as NSError {
            logger.error("Error loading deleted person ids: \(error)")
        }
        return nil
    }
    
}
