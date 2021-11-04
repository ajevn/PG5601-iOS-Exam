//
//  PersonInfoViewController.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 25/10/2021.
//

import UIKit
import Kingfisher
import CoreData

class PersonInfoViewController: UIViewController {
    
    //selectedPerson object set to AnyObject to faciliate being set to both PersonEntity and EditedPersonEntity
    //this allows PersonEditInfoViewController to delete PersonEntity and create a new EditedPersonEntity after editing is done and replace selectedPerson with the new EditedPersonEntity object
    var selectedPerson: AnyObject?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var postalCodeLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBAction func didTapDelete(_ sender: Any) {
        deletePerson()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initData()
    }
    
    func initData() {
        //selectedPerson data being updated in PersonEditInfoViewController before popping back to this view.
        
        if let url = selectedPerson?.pictureLargeUrl {
            personImage.kf.indicatorType = .activity
            personImage.kf.setImage(with: URL(string: url!), placeholder: .none,
                                    options: [.processor(RoundCornerImageProcessor(cornerRadius: 20)),
                                              .transition(.fade(0.25)),])
        }
        if let firstName = selectedPerson?.firstName {
            firstNameLabel.text = firstName
        }
        if let lastName = selectedPerson?.lastName {
            lastNameLabel.text = lastName
        }
        if let age = selectedPerson?.age{
            ageLabel.text = String(age)
        }
        if let birthDate = selectedPerson?.dob {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            birthDateLabel.text = dateFormatter.string(from: birthDate!)
        }
        if let email = selectedPerson?.email {
            emailLabel.text = email
        }
        if let city = selectedPerson?.city {
            cityLabel.text = city
        }
        if let county = selectedPerson?.county {
            countyLabel.text = county
        }
        if let postalCode = selectedPerson?.postCode {
            postalCodeLabel.text = postalCode
        }
        if let phoneNumber = selectedPerson?.phoneNumber {
            phoneNumberLabel.text = phoneNumber
        }
    }
    
    func deletePerson() {
        let personRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
        let editedPersonRequest: NSFetchRequest<EditedPersonEntity> = EditedPersonEntity.fetchRequest()
        
        let predicate = NSPredicate(format: "id == %@", String((selectedPerson?.id)!))
        personRequest.predicate = predicate
        editedPersonRequest.predicate = predicate
                
        do {
            //Typesaving selectedPerson as it can be both PersonEntity and EditedPersonEntity
            let fetchedPerson: AnyObject
            if(selectedPerson is PersonEntity){
                fetchedPerson = try context.fetch(personRequest).first!
            } else {
                fetchedPerson = try context.fetch(editedPersonRequest).first!
            }
            
            let newDeletedPerson = DeletedPersonEntity(context: context)
            
            newDeletedPerson.firstName = fetchedPerson.firstName
            newDeletedPerson.lastName = fetchedPerson.lastName
            newDeletedPerson.age = fetchedPerson.age
            newDeletedPerson.dob = fetchedPerson.dob
            newDeletedPerson.city = fetchedPerson.city
            newDeletedPerson.phoneNumber = fetchedPerson.phoneNumber
            newDeletedPerson.email = fetchedPerson.email
            newDeletedPerson.coordinatesLat = fetchedPerson.coordinatesLat
            newDeletedPerson.coordinatesLon = fetchedPerson.coordinatesLon
            newDeletedPerson.county = fetchedPerson.county
            newDeletedPerson.gender = fetchedPerson.gender
            newDeletedPerson.id = fetchedPerson.id
            newDeletedPerson.postCode = fetchedPerson.postCode
            newDeletedPerson.nationality = fetchedPerson.nationality
            newDeletedPerson.pictureLargeUrl = fetchedPerson.pictureLargeUrl
            newDeletedPerson.pictureSmallUrl = fetchedPerson.pictureSmallUrl
            newDeletedPerson.pictureThumbnailUrl = fetchedPerson.pictureThumbnailUrl
            newDeletedPerson.pictureData = fetchedPerson.pictureData
            
            
            context.delete(fetchedPerson as! NSManagedObject)
            sharedPersistenceManager.saveContext(withContext: context)
            self.navigationController?.popViewController(animated: true)
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PersonEditInfoViewController {
            destinationViewController.selectedPerson = selectedPerson
        }
    }
}
