//
//  ViewController.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 20/10/2021.
//

import UIKit
import Kingfisher

class PersonListViewController: UIViewController {
    
    var personsArray: [PersonData]?
    var personsInfo: ResultInfo?
    var selectedRowIndex = 0
    
    @IBOutlet weak var personTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        personsArray = []
        
        personTableView.dataSource = self
        personTableView.delegate = self
        personTableView.register(UINib(nibName: K.personListCellName, bundle: nil), forCellReuseIdentifier: K.personListCellIdentifier)
        
        let personManager = PersonManager()
        personManager.personManagerDelegate = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PersonInfoViewController {
            destinationViewController.selectedPerson = personsArray![selectedRowIndex]
        }
    }
}

extension PersonListViewController: PersonManagerDelegate {
    func didFetchPersons(personArray: PersonDataResults) {
        print("Fetched updated person data")
        for person in personArray.results {
            personsArray!.append(person)
        }
        personsInfo = personArray.info
            DispatchQueue.main.async {
                self.personTableView.reloadData()
                //let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                //self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
    }
    func didFailWithError(error: Error) {
        print("From Extension: \(error)")
    }
}

extension PersonListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(personsArray!.count > 0){
            return personsArray!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.personListCellIdentifier, for: indexPath) as! PersonCell
    
        cell.fullNameLabel.text = ("\(personsArray![indexPath.row].name.first) \(personsArray![indexPath.row].name.last)")
        let imageUrl = personsArray![indexPath.row].picture.large
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
    }
}
