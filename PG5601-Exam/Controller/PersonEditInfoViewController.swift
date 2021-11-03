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
    
    var selectedPerson: PersonEntity?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let persistenceController = PersistenceManager()

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
        
        if let url = selectedPerson?.pictureLargeUrl {
            personImage.kf.indicatorType = .activity
            personImage.kf.setImage(with: URL(string: url), placeholder: .none,
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
            dobDatePicker.date = birthDate
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
        let request : NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", String((selectedPerson?.id)!))
        request.predicate = predicate
                
        do {
            let fetchedPerson: PersonEntity = try context.fetch(request).first!
            fetchedPerson.firstName = firstNameTextField.text
            fetchedPerson.lastName = lastNameTextField.text
            
            //Calculate Age based on updated birthdate from picker
            let now = Date()
            let birthDate = dobDatePicker.date
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
            fetchedPerson.age = Int16(ageComponents.year!)
            
            fetchedPerson.dob = dobDatePicker.date
            fetchedPerson.email = emailTextField.text
            fetchedPerson.city = cityTextField.text
            fetchedPerson.phoneNumber = phoneNumberTextField.text
            fetchedPerson.isEdited = true
            
            persistenceController.saveContext(withContext: context)
            self.navigationController?.popViewController(animated: true)
        } catch {
            print(error)
        }
    }
}

extension PersonEditInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        savePersonChanges()
        return true
    }
}
