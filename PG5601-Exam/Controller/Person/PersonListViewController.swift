//
//  ViewController.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 20/10/2021.
//

import UIKit
import Kingfisher
import CoreData
import Logging

//Global Variables
let sharedNetworkManager = NetworkManager()
let sharedPersistenceManager = PersistenceManager()

//Using NotificationCenter to notify multiple classes of data being successfully fetched
//Primarily in PersonListViewController and SettingsViewController to avoid multiple delegates which breaks the intended pattern usage
extension Notification.Name {
    static let didFetchPersons = Notification.Name("didFetchPersons")
    static let didFailWithError = Notification.Name("didFailWithError")
}

class PersonListViewController: UIViewController {
    
    var personsArray = [AnyObject]()
    var selectedRowIndex = 0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let logger = Logger(label: "PersonListViewController")
    
    @IBOutlet weak var personTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Printing filepath to application CoreData
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        personTableView.dataSource = self
        personTableView.delegate = self
        personTableView.register(UINib(nibName: K.personListCellName, bundle: nil), forCellReuseIdentifier: K.personListCellIdentifier)

        
        
        //Subscribing to networkManager delegate to perform actions based on success or error
        sharedNetworkManager.networkManagerDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Passes object of clicked person to PersonInfoViewController as selectedPerson object
        if let destinationViewController = segue.destination as? PersonInfoViewController {
            destinationViewController.selectedPerson = personsArray[selectedRowIndex]
        }
    }
    
    func initData () {
        //Loads data from context unless context is empty - If so it will fetch data from API, typically on first app launch
        if let persons = sharedPersistenceManager.loadPersons(withContext: context){
            if (persons.count > 0){
                personsArray = []
                for person in persons {
                    personsArray.append(person)
                }
                
                let editedPersons = sharedPersistenceManager.loadEditedPersons(withContext: context)
                    editedPersons?.forEach({person in
                        personsArray.append(person)
                    })
    
                personsArray.sort{
                    $0.firstName! < $1.firstName!
                }
            } else {
                let urlSeed: String
                if let safeUrlSeed = UserDefaults.standard.string(forKey: K.personApiSeedKey) {
                    urlSeed = safeUrlSeed
                } else {
                    urlSeed = K.personApiURLStandardSeed
                }
                sharedNetworkManager.fetchData(withBaseURL: K.personApiBaseUrl,
                                        withURLSeed: urlSeed,
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

extension PersonListViewController: NetworkManagerDelegate {
    func didFetchPersons(personArray: PersonDataResults) {
        //Fetches array of IDs of previously deleted or edited users ensuring they wont be saved to CoreData
        let deletedPersonIds = sharedPersistenceManager.loadDeletedPersonIds(withContext: context)
        let editedPersonIds = sharedPersistenceManager.loadEditedPersonIds(withContext: context)
        
        for person in personArray.results {
            
            //Ensures deleted or edited users will not be added when new data from API is processed and saved in Core Data
            if(deletedPersonIds?.contains(person.id.value) != true && editedPersonIds?.contains(person.id.value) != true){
                let newPerson = PersonEntity(context: context)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
                guard let dobDate = dateFormatter.date(from: person.dob.date.components(separatedBy: "T")[0]) else {
                    logger.error("Error formatting date.")
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
                
                let pictureUrl = URL.init(string: person.picture.thumbnail)
                if let data = try? Data(contentsOf: pictureUrl!) {
                    newPerson.pictureData = data
                }
            }
        }
        sharedPersistenceManager.deleteAllPersons(withContext: context)
        sharedPersistenceManager.saveContext(withContext: context)
        initData()
    }
    func didFailWithError(error: Error) {
        //
        logger.error("Error fetching data: \(error)")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error fetching data", message: "Check your network connection and try again.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                self.initData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))

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
            cell.fullNameLabel.text = "\(firstName!) \(lastName!)"
        }
        
        let imageUrl = personsArray[indexPath.row].pictureLargeUrl!
        cell.personImage.kf.indicatorType = .activity
        cell.personImage.kf.setImage(with: URL(string: imageUrl!), placeholder: .none, options: [.processor(RoundCornerImageProcessor(cornerRadius: 20)),
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
