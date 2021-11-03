//
//  SettingsViewController.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 02/11/2021.
//

import UIKit
import Logging

class SettingsViewController: UIViewController {
    let logger = Logger(label: "SettingsViewController")
    
    @IBOutlet weak var apiSeedTextField: UITextField!
    @IBAction func didPressSave(_ sender: Any) {
        UserDefaults.standard.set(apiSeedTextField.text, forKey: K.personApiSeedKey)
        logger.info("Updated API-Seed with value: \(String(describing: apiSeedTextField.text!))")
  
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Successfully updated API-Seed", message: "New seed: \(String(describing: UserDefaults.standard.string(forKey: K.personApiSeedKey)!))", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: .none))
            self.present(alert, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiSeedTextField.text = UserDefaults.standard.string(forKey: K.personApiSeedKey)
        // Do any additional setup after loading the view.
    }
}
