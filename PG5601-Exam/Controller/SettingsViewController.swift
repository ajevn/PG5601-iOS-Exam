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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func didPressSave(_ sender: Any) {
        UserDefaults.standard.set(apiSeedTextField.text, forKey: K.personApiSeedKey)
        logger.info("Updated API-Seed with value: \(String(describing: apiSeedTextField.text!))")
        apiSeedTextField.endEditing(true)
        
        reloadData()
    }
    func reloadData() {
        
        let urlSeed: String
        if let safeUrlSeed = UserDefaults.standard.string(forKey: K.personApiSeedKey) {
            urlSeed = safeUrlSeed
        } else {
            urlSeed = K.personApiURLStandardSeed
        }
        
        showSpinner()
        //Reloads data from API
        sharedNetworkManager.fetchData(withBaseURL: K.personApiBaseUrl,
                                withURLSeed: urlSeed,
                                withURLNationality: K.personApiURLNationality,
                                withURLExcludedFields: K.personApiURLExcludedFields,
                                withResultCount: "100")
        
    }
    
    private func showSpinner() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }

    private func hideSpinner() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.hideSpinner()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUpdateDataSuccessfully(_:)), name: .didFetchPersons, object: nil)
        
        apiSeedTextField.delegate = self
        apiSeedTextField.text = UserDefaults.standard.string(forKey: K.personApiSeedKey)
    }
    @objc func onDidUpdateDataSuccessfully(_ notification: NSNotification){
        
        DispatchQueue.main.async {
            self.hideSpinner()
            let alert = UIAlertController(title: "Successfully updated API-Seed", message: "New seed: \(String(describing: UserDefaults.standard.string(forKey: K.personApiSeedKey)!))", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: .none))
            self.present(alert, animated: true)
        }
    }
    
    @objc func onDidFailUpdateDataWithError(_ notification: NSNotification){
        logger.error("Error fetching data")
        DispatchQueue.main.async {
            self.hideSpinner()
            let alert = UIAlertController(title: "Error updating data", message: "Check your network connection and try again.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                self.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))

            self.present(alert, animated: true)
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
