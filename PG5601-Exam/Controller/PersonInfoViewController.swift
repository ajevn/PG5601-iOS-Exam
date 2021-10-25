//
//  PersonInfoViewController.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 25/10/2021.
//

import UIKit
import Kingfisher

class PersonInfoViewController: UIViewController {
    
    
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var postalCodeLabel: UILabel!
    
    var selectedPerson: PersonData?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //nameLabel.text = selectedPerson?.name.first
        
        let imageUrl = selectedPerson!.picture.large
        personImage.kf.indicatorType = .activity
        personImage.kf.setImage(with: URL(string: imageUrl), placeholder: .none,
                                options: [.processor(RoundCornerImageProcessor(cornerRadius: 20)),
                                          .transition(.fade(0.25)),])
        
        
        firstNameLabel.text = selectedPerson?.name.first
        lastNameLabel.text = selectedPerson?.name.last
        ageLabel.text = "\(String(describing: selectedPerson!.dob.age))"
        birthDateLabel.text = selectedPerson?.dob.date.components(separatedBy: "T")[0]
        emailLabel.text = selectedPerson?.email
        cityLabel.text = selectedPerson?.location.city
        countyLabel.text = selectedPerson?.location.state
        postalCodeLabel.text = selectedPerson?.location.postcode
    }

}
