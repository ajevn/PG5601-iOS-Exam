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
    //Optional single value object if user presses "open location in Map" in PersonInfoViewController. This should only render 1 person to map. This is handled by checking if selectedIndividualPerson exists, if not map will render array of all persons.
    var selectedIndividualPerson: AnyObject?
    var personsArray = [AnyObject]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let logger = Logger(label: "MapViewController")
    
    @IBOutlet weak var mapKitView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapKitView.showsUserLocation = false
        mapKitView.delegate = self
        
        initData()
    }
    
    func initData() {
        if (selectedIndividualPerson != nil){
            //Creates signle annotation and sets the region to the corresponding coordinates.
            let personAnnotation = createAnnotation(person: selectedIndividualPerson!)
            let coordinate = CLLocationCoordinate2D(latitude: personAnnotation.coordinate.latitude, longitude: personAnnotation.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            
            DispatchQueue.main.async {
                let region = MKCoordinateRegion(center: coordinate, span: span)
                self.mapKitView.setRegion(region, animated: true)
                self.mapKitView.addAnnotation(personAnnotation)
            }
            
        } else {
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
                
                var annotationList = [MKAnnotation]()
                for person in personsArray {
                    annotationList.append(createAnnotation(person: person))
                }
                
                DispatchQueue.main.async {
                    self.mapKitView.addAnnotations(annotationList)
                }
            }
        }
    }
    
    func createAnnotation(person: AnyObject) -> MKAnnotation{
        let annotation = MKPointAnnotation()
        let personLat = Double(person.coordinatesLat!)
        let personLon = Double(person.coordinatesLon!)
        annotation.title = person.id!
        annotation.subtitle = person.pictureSmallUrl!
        annotation.coordinate = CLLocationCoordinate2D(latitude: personLat!, longitude: personLon!)
        
        return annotation
    }
    func resizePinImage(from data: Data) -> UIImage{
        let pinImage = UIImage(data: data)
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContext(size)
        pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
        return UIGraphicsGetImageFromCurrentImageContext()!
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
         //Ensures font size scales to fit whole name on top of annotation picture
         let annotationLabel = UILabel(frame: CGRect(x: -40, y: -35, width: 105, height: 30))
         annotationLabel.numberOfLines = 0
         annotationLabel.adjustsFontSizeToFitWidth = true
         annotationLabel.textAlignment = .center
         
         let selectedPerson = personsArray.first(where: {
             $0.id == annotation.title
         })
         
         if ( selectedIndividualPerson != nil ) {
             if let safeFirstName = selectedIndividualPerson?.firstName, let safeLastName = selectedIndividualPerson?.lastName {
                 annotationLabel.text = "\(safeFirstName!) \(safeLastName!)"
             }
         } else {
             let person = personsArray.first(where: {
                 $0.id == annotation.title
             })
             if let safeFirstName = person?.firstName, let safeLastName = person?.lastName {
                 annotationLabel.text = "\(safeFirstName!) \(safeLastName!)"
             }
         }
         
         if annotationView == nil {
             annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: K.personMapAnnotationKey)
             annotationView?.canShowCallout = false
             annotationView?.addSubview(annotationLabel)
         } else {
             annotationView?.annotation = annotation
         }
         
         //Sets image depening on whether map was rendered with single person or all persons
         if let safeImage = selectedPerson?.pictureData{
             let resizedImage = resizePinImage(from: safeImage!)
             annotationView?.image = resizedImage
         } else {
             let resizedImage = resizePinImage(from: selectedIndividualPerson!.pictureData!)
             annotationView?.image = resizedImage
         }

        return annotationView
    }
    //Handles user selecting one of the different annotations - redirecting to respective person info page
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let personInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "personInfoViewController") as! PersonInfoViewController
        
        if ( selectedIndividualPerson != nil ) {
            personInfoViewController.selectedPerson = selectedIndividualPerson
        } else {
            personInfoViewController.selectedPerson = personsArray.first(where: {
                $0.id == view.annotation?.title
            })
        }
        
        self.navigationController?.pushViewController(personInfoViewController, animated: true)
    }
}
