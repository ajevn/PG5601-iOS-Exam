//
//  PersonInfoViewController.swift
//  PG5601-Exam
//
//  Created by Andreas Jevnaker on 25/10/2021.
//

import UIKit
import Kingfisher
import CoreData

extension Date {
    //https://stackoverflow.com/questions/27182023/getting-the-difference-between-two-dates-months-days-hours-minutes-seconds-in
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
            return calendar.component(component, from: self)
    }
}

extension String {
    //https://stackoverflow.com/questions/38809425/convert-apple-emoji-string-to-uiimage
    func image(width: CGFloat, height: CGFloat) -> UIImage? {
        let nsString = (self as NSString)
            let font = UIFont.systemFont(ofSize: 40) // you can change your font size here
            let stringAttributes = [NSAttributedString.Key.font: font]
            let imageSize = CGSize(width: width, height: height)//nsString.size(withAttributes: stringAttributes)

            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
            UIColor.clear.set() // clear background
            UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
            nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
            let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
            UIGraphicsEndImageContext() //  end image context

            return image ?? UIImage()
    }
}

class PersonInfoViewController: UIViewController {
    
    //selectedPerson object set to AnyObject to faciliate being set to both PersonEntity and EditedPersonEntity
    //this allows PersonEditInfoViewController to delete PersonEntity and create a new EditedPersonEntity after editing is done and replace selectedPerson with the new EditedPersonEntity object
    var selectedPerson: AnyObject?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var daysUntilBirthday: Int?
    var viewIsActive = true
    
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var birthdayEmojiImageView: UIImageView!
    
    @IBAction func didTapDelete(_ sender: Any) {
        deletePerson()
    }
    @IBAction func didTapOpenInMap(_ sender: Any) {
        let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "mapViewController") as! MapViewController
        mapViewController.selectedIndividualPerson = selectedPerson
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        daysUntilBirthday = calculateDaysUntilBirthday()
        if let safeDaysUntilBirthday = daysUntilBirthday {
            //Method returns number of days until birthday excluding current day - Checking if days until birthday is within the following week
            if safeDaysUntilBirthday >= -6 && safeDaysUntilBirthday < 0 {
                handleBirthdayFollowingWeek()
            }
        }
        
    }
    
    func handleBirthdayFollowingWeek() {
        let imageHeight = CGFloat(50)
        let imageWidth = CGFloat(50)

        let partyPopperImage = "🎉".image(width: imageWidth, height: imageHeight)
        let cakeSliceImage = "🍰".image(width: imageWidth, height: imageHeight)
        let cakeImage = "🎂".image(width: imageWidth, height: imageHeight)
        let cupcakeImage = "🧁".image(width: imageWidth, height: imageHeight)
        let celebrationEmojis = [cakeSliceImage, cakeImage, cupcakeImage]
        
        birthdayEmojiImageView.image = partyPopperImage
        
        //Schedules a recurring task every 0.5 seconds rendering a random birthday image to the screen with corresponding animations
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if (self.viewIsActive) {
                // Make API call here
                renderImageLocationRandom(with: celebrationEmojis.randomElement()!!)
            } else {
                timer.invalidate()
            }
            count += 1
        }
        
        //Manages UI events if person has birthday the following week
        func renderImageLocationRandom(with image: UIImage) {
            //Inspiration gotten from https://stackoverflow.com/questions/58169547/how-can-i-movetranslate-picture-randomly-any-position-of-the-screen
            let maxX = view.frame.maxX - imageWidth
            let maxY = view.frame.maxY - imageHeight
            let xCoord = CGFloat.random(in: 0...maxX)
            
            let imageView = UIImageView(frame: CGRect(x: CGFloat(xCoord), y: CGFloat(view.frame.minY), width: 50, height: 50))
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
  
            //Positions random image along y-axis witha  delayed animation scaling from 100% -> 0% after 2.5 seconds
            let translateYAnimation = CABasicAnimation(keyPath: "position.y")
            translateYAnimation.duration = 3
            translateYAnimation.fromValue = view.frame.minY
            translateYAnimation.toValue = maxY
            translateYAnimation.beginTime = CACurrentMediaTime()
            
            let translateScaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            translateScaleAnimation.fromValue = imageView.layer.mask?.value(forKeyPath:"transform.scale")
            translateScaleAnimation.toValue = 0
            translateScaleAnimation.duration = 0.5
            translateScaleAnimation.beginTime = CACurrentMediaTime() + 2.5
            
            imageView.layer.add(translateYAnimation, forKey: nil)
            imageView.layer.add(translateScaleAnimation, forKey: nil)
       
            //UI view has a bug - or I did not find a solution - where animating translation and scale makes the animation bounce back when near 100%
            /*
            UIView.animateKeyframes(withDuration: 3, delay: 0, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 3, animations: {
                    imageView.transform = CGAffineTransform(translationX: CGFloat(0.0), y: maxY)
                })
            })
             */
            DispatchQueue.main.async{
                self.view.addSubview(imageView)
            }
            //Removes imageview from superview just before animation is done running - 2.8 sec
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                imageView.removeFromSuperview()
             }
        }
    }
    
    //Method returns number of days until birthday excluding current day
    func calculateDaysUntilBirthday() -> Int? {
        let birthdayDate = selectedPerson?.dob
        let calenderDate = Calendar.current.dateComponents([.day, .year, .month], from: birthdayDate!!)
        
        let dateFormatter = DateFormatter()
        let dateNow = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: dateNow)
        let currentYear = components.year
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = "\(currentYear!)-\(calenderDate.month!)-\(calenderDate.day!)"
        guard let currentYearBirthDate = dateFormatter.date(from: dateString) else {
            print("Error formatting date.")
            return nil
        }

        return Date.now.days(from: currentYearBirthDate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initData()
        viewIsActive = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        viewIsActive = false
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
