//
//  PersistenceController.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 31/10/2021.
//

import Foundation
import CoreData

class PersistenceController {
    
    func saveContext(withContext context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Successfully saved context.")
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func deleteAllPersons(withContext context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PersonEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            print("Successfully deleted context.")
        } catch let error as NSError {
            print("Error deleting context: \(error)")
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
            print("Successfully loaded context.")
            return personArray
        } catch let error as NSError {
            print("Error loading context: \(error)")
        }
        return nil
    }
    
}
