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
    
    var selectedPerson: PersonEntity?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let persistenceController = PersistenceManager()
    
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
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initData()
    }
    
    func initData() {
        let request : NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", String((selectedPerson?.id)!))
        request.predicate = predicate
                
        do {
            let fetchedPerson: PersonEntity = try context.fetch(request).first!
            
            if let url = fetchedPerson.pictureLargeUrl {
                personImage.kf.indicatorType = .activity
                personImage.kf.setImage(with: URL(string: url), placeholder: .none,
                                        options: [.processor(RoundCornerImageProcessor(cornerRadius: 20)),
                                                  .transition(.fade(0.25)),])
            }
            if let firstName = fetchedPerson.firstName {
                firstNameLabel.text = firstName
            }
            if let lastName = fetchedPerson.lastName {
                lastNameLabel.text = lastName
            }
            ageLabel.text = String(fetchedPerson.age)
            if let birthDate = fetchedPerson.dob {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                birthDateLabel.text = dateFormatter.string(from: birthDate)
            }
            if let email = fetchedPerson.email {
                emailLabel.text = email
            }
            if let city = fetchedPerson.city {
                cityLabel.text = city
            }
            if let county = fetchedPerson.county {
                countyLabel.text = county
            }
            if let postalCode = fetchedPerson.postCode {
                postalCodeLabel.text = postalCode
            }
            if let phoneNumber = fetchedPerson.phoneNumber {
                phoneNumberLabel.text = phoneNumber
            }
        } catch {
            print(error)
        }
        
        
    }
    
    func deletePerson() {
        let request : NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", String((selectedPerson?.id)!))
        request.predicate = predicate
                
        do {
            let fetchedPerson: PersonEntity = try context.fetch(request).first!
            fetchedPerson.wasDeleted = true
            
            persistenceController.saveContext(withContext: context)
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
