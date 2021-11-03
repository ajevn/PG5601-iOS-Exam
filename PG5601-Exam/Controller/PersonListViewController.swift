//
//  ViewController.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 20/10/2021.
//

import UIKit
import Kingfisher
import CoreData

class PersonListViewController: UIViewController {
    
    var personsArray = [PersonEntity]()
    let persistenceController = PersistenceController()
    let personManager = PersonManager()
    var selectedRowIndex = 0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var personTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        personTableView.dataSource = self
        personTableView.delegate = self
        personTableView.register(UINib(nibName: K.personListCellName, bundle: nil), forCellReuseIdentifier: K.personListCellIdentifier)
        
        //Updates data in list using delegate
        personManager.personManagerDelegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        initData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PersonInfoViewController {
            destinationViewController.selectedPerson = personsArray[selectedRowIndex]
        }
    }
    
    func initData () {
        if let persons = persistenceController.loadPersons(withContext: context){
            if (persons.count > 0){
                personsArray = []
                for person in persons {
                    if(!person.wasDeleted){
                        personsArray.append(person)
                    }
                }
            } else {
                personManager.fetchData(withBaseURL: K.personApiBaseUrl,
                                        withURLSeed: K.personApiURLStandardSeed,
                                        withURLNationality: K.personApiURLNationality,
                                        withURLExcludedFields: K.personApiURLExcludedFields,
                                        withResultCount: "100")
            }
        }
        DispatchQueue.main.async {
            self.personTableView.reloadData()
        }
    }
}

extension PersonListViewController: PersonManagerDelegate {
    func didFetchPersons(personArray: PersonDataResults) {
        print("Fetched updated person data from API.")
        
        for person in personArray.results {
            let newPerson = PersonEntity(context: context)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
            guard let dobDate = dateFormatter.date(from: person.dob.date.components(separatedBy: "T")[0]) else {
                print("Error formatting date.")
                return
            }
            newPerson.dob = dobDate
            newPerson.city = person.location.city
            newPerson.email = person.email
            newPerson.age = Int16(person.dob.age)
            newPerson.coordinatesLat = person.location.coordinates.latitude
            newPerson.coordinatesLon = person.location.coordinates.longitude
            newPerson.county = person.location.state
            newPerson.firstName = person.name.first
            newPerson.lastName = person.name.last
            newPerson.gender = person.gender
            newPerson.id = person.id.value
            newPerson.postCode = person.location.postcode
            newPerson.pictureLargeUrl = person.picture.large
            newPerson.pictureSmallUrl = person.picture.medium
            newPerson.pictureThumbnailUrl = person.picture.thumbnail
            newPerson.phoneNumber = person.phone
            newPerson.nationality = person.nat
        }
        persistenceController.deleteAllPersons(withContext: context)
        persistenceController.saveContext(withContext: context)
        initData()
    }
    func didFailWithError(error: Error) {
        print("Error fetching data: \(error)")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error fetching data", message: "Check your network connection and try again.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                self.initData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                print("Cancel Pressed")
            }))

            self.present(alert, animated: true)
        }
    }
}

extension PersonListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(personsArray.count > 0){
            return personsArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.personListCellIdentifier, for: indexPath) as! PersonCell
    
        if let firstName = personsArray[indexPath.row].firstName, let lastName = personsArray[indexPath.row].lastName {
            cell.fullNameLabel.text = "\(firstName) \(lastName)"
        }
        
        let imageUrl = personsArray[indexPath.row].pictureLargeUrl!
        cell.personImage.kf.indicatorType = .activity
        cell.personImage.kf.setImage(with: URL(string: imageUrl), placeholder: .none, options:      [.processor(RoundCornerImageProcessor(cornerRadius: 20)),
            .transition(.fade(0.25)),])
        
        return cell
    }
}

extension PersonListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowIndex = indexPath.row
        self.performSegue(withIdentifier: "personInfoSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
