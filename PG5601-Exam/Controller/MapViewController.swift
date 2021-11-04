//
//  MapViewController.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 03/11/2021.
//

import UIKit
import MapKit
import Logging
import Kingfisher
import SwiftUI

class MapViewController: UIViewController {
    
    var personsArray = [AnyObject]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let logger = Logger(label: "MapViewController")
    
    @IBOutlet weak var mapKitView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()

        mapKitView.showsUserLocation = false
        mapKitView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initData()
    }
    
    func initData() {
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
            }
            for person in personsArray {
                let annotation = MKPointAnnotation()
                let personLat = Double(person.coordinatesLat!)
                let personLon = Double(person.coordinatesLon!)
                
                annotation.title = person.id!
                annotation.subtitle = person.pictureSmallUrl!
                annotation.coordinate = CLLocationCoordinate2D(latitude: personLon!, longitude: personLat!)
                
                DispatchQueue.main.async {
                    self.mapKitView.addAnnotation(annotation)
                }
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
 
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         guard !(annotation is MKUserLocation) else {
                 // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
                 return nil
             }
         
         var annotationView = mapKitView.dequeueReusableAnnotationView(
            withIdentifier: K.personMapAnnotationKey)
         
         if annotationView == nil {
             annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: K.personMapAnnotationKey)
             annotationView?.canShowCallout = false
         } else {
             annotationView?.annotation = annotation
         }
         let selectedPerson = personsArray.first(where: {
             $0.id == annotation.title
         })
         let image: Data = selectedPerson!.pictureData!!
         annotationView?.image = UIImage(data: image)
         
         
         
         //annotationView?.image = image

        return annotationView
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selectedPerson = personsArray.first(where: {
            $0.id == view.annotation?.title
        })
        
        let personInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "personInfoViewController") as! PersonInfoViewController
        personInfoViewController.selectedPerson = selectedPerson
        self.navigationController?.pushViewController(personInfoViewController, animated: true)
    }
}
