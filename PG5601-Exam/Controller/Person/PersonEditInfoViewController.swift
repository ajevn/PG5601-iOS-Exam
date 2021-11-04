//
//  PersonEditInfoViewController.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 31/10/2021.
//

import UIKit
import Kingfisher
import CoreData

class PersonEditInfoViewController: UIViewController {
    
    var selectedPerson: AnyObject?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var dobDatePicker: UIDatePicker!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBAction func didClickSave(_ sender: Any) {
        savePersonChanges()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        cityTextField.delegate = self
        phoneNumberTextField.delegate = self
        
        if let url = selectedPerson?.pictureLargeUrl {
            personImage.kf.indicatorType = .activity
            personImage.kf.setImage(with: URL(string: url!), placeholder: .none,
                                    options: [.processor(RoundCornerImageProcessor(cornerRadius: 20)),
                                              .transition(.fade(0.25)),])
        }
        if let firstName = selectedPerson?.firstName {
            firstNameTextField.text = firstName
            firstNameTextField.delegate = self
        }
        if let lastName = selectedPerson?.lastName {
            lastNameTextField.text = lastName
            lastNameTextField.delegate = self
        }
        if let age = selectedPerson?.age {
            ageLabel.text = String(age)
        }
        if let birthDate = selectedPerson?.dob {
            dobDatePicker.date = birthDate!
        }
        if let email = selectedPerson?.email {
            emailTextField.text = email
            emailTextField.delegate = self
        }
        if let city = selectedPerson?.city {
            cityTextField.text = city
            cityTextField.delegate = self
        }
        if let phoneNumber = selectedPerson?.phoneNumber {
            phoneNumberTextField.text = phoneNumber
            phoneNumberTextField.delegate = self
        }
    }
    
    
    
    func savePersonChanges() {
        let personRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
        let editedPersonRequest: NSFetchRequest<EditedPersonEntity> = EditedPersonEntity.fetchRequest()
        
        let predicate = NSPredicate(format: "id == %@", String((selectedPerson?.id)!))
        personRequest.predicate = predicate
        editedPersonRequest.predicate = predicate
                
        do {
            let fetchedPerson: AnyObject
            if(selectedPerson is PersonEntity){
                fetchedPerson = try context.fetch(personRequest).first!
            } else {
                fetchedPerson = try context.fetch(editedPersonRequest).first!
            }
            let newEditedPerson = EditedPersonEntity(context: context)
            
            //New data from editable textfields
            newEditedPerson.firstName = firstNameTextField.text
            newEditedPerson.lastName = lastNameTextField.text
            //Calculate Age based on updated birthdate from picker
            let now = Date()
            let birthDate = dobDatePicker.date
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
            newEditedPerson.age = Int16(ageComponents.year!)

            newEditedPerson.dob = dobDatePicker.date
            newEditedPerson.email = emailTextField.text
            newEditedPerson.city = cityTextField.text
            newEditedPerson.phoneNumber = phoneNumberTextField.text
        
            //Data from personEntity fetched from database
            newEditedPerson.email = fetchedPerson.email
            newEditedPerson.coordinatesLat = fetchedPerson.coordinatesLat
            newEditedPerson.coordinatesLon = fetchedPerson.coordinatesLon
            newEditedPerson.county = fetchedPerson.county
            newEditedPerson.gender = fetchedPerson.gender
            newEditedPerson.id = fetchedPerson.id
            newEditedPerson.postCode = fetchedPerson.postCode
            newEditedPerson.pictureLargeUrl = fetchedPerson.pictureLargeUrl
            newEditedPerson.pictureSmallUrl = fetchedPerson.pictureSmallUrl
            newEditedPerson.pictureThumbnailUrl = fetchedPerson.pictureThumbnailUrl
            newEditedPerson.nationality = fetchedPerson.nationality
            newEditedPerson.pictureData = fetchedPerson.pictureData
            
            //Deletes person from PersonEntity or Edited PErson entity, saving it in EditedPersonEntity as either a brand ned entity or a replacement to EditedPersonEntity if person was already edited
            context.delete(fetchedPerson as! NSManagedObject)
            sharedPersistenceManager.saveContext(withContext: context)
            
            //Sets selectedPerson object in PersonInfoViewController to the newly created EditedPersonEntity object since the PersonEntity object was deleted.
            let vcDestinationOnPop = self.navigationController?.viewControllers.first(where: { $0 is PersonInfoViewController }) as! PersonInfoViewController
            vcDestinationOnPop.selectedPerson = newEditedPerson
            self.navigationController?.popViewController(animated: true)
        } catch {
            print(error)
        }
    }
}

extension PersonEditInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
