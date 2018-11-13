//
//  NewSignUpViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 5/18/17.
//  Copyright © 2017 Adrian Humphrey. All rights reserved.
//


import UIKit
import Eureka
import Alamofire



class NewSignUpViewController : FormViewController {
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Done button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingsViewController.dismiss as (SettingsViewController) -> () -> ()))
        self.navigationController?.navigationBar.tintColor = UIColor.orange
        
        URLRow.defaultCellUpdate = { cell, row in cell.textField.textColor = .blue }
        LabelRow.defaultCellUpdate = { cell, row in cell.detailTextLabel?.textColor = .orange  }
        CheckRow.defaultCellSetup = { cell, row in cell.tintColor = .orange }
        DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }
        
        //Set up entire Form
        form +++
            
            Section("My Account")
            
            //First Name
            <<< NameRow() {
                $0.tag = "FirstName"
                $0.title =  "First Name"
                $0.placeholder = "Enter First Name"
                $0.placeholderColor = UIColor.gray
                
            }
            
            //Location
            <<< NameRow() {
                $0.title =  "Location"
                $0.tag = "Location"
                if(SessionManager.sharedInstance.userCity == "" || SessionManager.sharedInstance.userCity == nil){
                    $0.value = "Enter Current Location"
                }else{
                    $0.value = SessionManager.sharedInstance.userCity
                }
                
                $0.placeholderColor = UIColor.gray
            }
            
            //Gender
            <<< PushRow<Emoji>() {
                $0.title = "Gender"
                $0.tag = "Gender"
                $0.value = 👩🏽
                $0.options = [👨🏻,👨🏼,👨🏽,👨🏾,👨🏿,👩🏻,👩🏼,👩🏽,👩🏾,👩🏿]
                $0.selectorTitle = "Your Gender"
                }.onChange({ (row) in
                    
                    //Save Gender when pressed
                    print(row.value! as String)
                    let gender = self.setGender(gender: row.value!)
                    SessionManager.sharedInstance.user?.gender = gender
                })
            
            //Age
            <<< SliderRow() {
                $0.title = "Age"
                $0.maximumValue = 50.0
                $0.minimumValue = 18.0
                $0.value = 18.0
                $0.steps = 0
                }.onChange({ (row) in
                    SessionManager.sharedInstance.user?.age = row.value as NSNumber?
                })
            
            //Bio
            +++ Section("Bio")
            
            <<< TextAreaRow() {
                $0.placeholder = "Tell people what makes you unique! Be yourself. Have Fun!"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
                }.onChange({ (row) in
                    SessionManager.sharedInstance.user?.bio = row.value! as String
                })
            
            //New Section Preferences
            +++ Section("Preferences")
            
            //Looking For
            <<< PushRow<Emoji>() {
                $0.title = "Looking For"
                $0.tag = "lookingFor"
                $0.options = ["Male", "Female", "Both"]
                $0.value = "Male"
                $0.selectorTitle = "Looking For"
                }.onChange({ (row) in
                    if(row.value == "Male"){
                        SessionManager.sharedInstance.user?.lookingFor = 0
                    }
                    else if(row.value == "Female"){
                        SessionManager.sharedInstance.user?.lookingFor = 1
                    }
                    else{
                        SessionManager.sharedInstance.user?.lookingFor = 2
                    }
                })
            
            
            //Relationship TODO:Look up what the heck is what
            <<< PushRow<Emoji>() {
                $0.title = "Relationship"
                $0.tag = "relationship"
                $0.options = ["Dating", "Friends", "Both"]
                $0.value = "Dating"
                $0.selectorTitle = "Relationship"
                }.onChange({ (row) in
                    if(row.value == "Dating"){
                        SessionManager.sharedInstance.user?.lookingFor = 0
                    }
                    else if(row.value == "Both"){
                        SessionManager.sharedInstance.user?.lookingFor = 1
                    }
                    else{
                        SessionManager.sharedInstance.user?.lookingFor = 2
                    }
                })
            
            //Search Distance
            <<< SliderRow() {
                $0.title = "Distance Of Search"
                $0.maximumValue = 50.0
                $0.minimumValue = 1.0
                $0.value = 20
                $0.steps = 0
                }.onChange({ (row) in
                    SessionManager.sharedInstance.user?.distanceOfSearch = row.value as NSNumber?
                })
            
            //Max Age
            <<< SliderRow() {
                $0.title = "Max Age"
                $0.maximumValue = 70.0
                $0.minimumValue = 18.0
                $0.value = 35
                $0.steps = 0
                }.onChange({ (row) in
                    SessionManager.sharedInstance.user?.ageHigh = row.value as NSNumber?
                })
            
            //Min Age
            <<< SliderRow() {
                $0.title = "Min Age"
                $0.maximumValue = 70.0
                $0.minimumValue = 18.0
                $0.value = 18
                $0.steps = 0
                }.onChange({ (row) in
                    SessionManager.sharedInstance.user?.ageLow = row.value as NSNumber?
                })
        
    }
    
    /*
     * Every time that the settings page is dismissed, it should save all of the values to core data as well as update them in the cloud
     */
    func dismiss(){
        
        
        
        //Save first name
        var row: NameRow? = form.rowBy(tag: "FirstName")
        if let firstName = (row?.value){
            SessionManager.sharedInstance.user?.firstName = firstName as String
        }
        
        //Save location
        row = form.rowBy(tag: "Location")
        if let location = (row?.value){
            SessionManager.sharedInstance.user?.userLocation = location as String
        }
        
        //Save Dating
        row = form.rowBy(tag: "relationship")
        if(row?.value == "Dating"){
            SessionManager.sharedInstance.user?.lookingFor = 0
        }
        else if(row?.value == "Both"){
            SessionManager.sharedInstance.user?.lookingFor = 1
        }
        else{
            SessionManager.sharedInstance.user?.lookingFor = 2
        }
        
        //Save location on Sign Up
        SessionManager.sharedInstance.user?.lat = SessionManager.sharedInstance.lat as NSNumber
        SessionManager.sharedInstance.user?.lon = SessionManager.sharedInstance.long as NSNumber
        
        
        if SessionManager.sharedInstance.user?.firstName == "" || SessionManager.sharedInstance.user?.userLocation == "" {
            var message = ""
            if SessionManager.sharedInstance.user?.firstName == ""{
                message = "Please enter your first name"
            }
            else if SessionManager.sharedInstance.user?.userLocation == ""{
                message = "Please enter your location"
            }
            
            let alert = UIAlertController(title: "Sorry", message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if Int((SessionManager.sharedInstance.user?.age!)!) < 18 {
            let alert = UIAlertController(title: "Sorry", message: "You must be at least 18 years old.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //Create User
        insertUser(SessionManager.sharedInstance.user!)
        
        //Set Notifications
        //Anytime someone logs in or signs up, all notifications will be set back to true,
        UserDefaults.standard.set(true, forKey: "likeNotification")
        
        UserDefaults.standard.set(true, forKey: "newMessageNotification")
        
        UserDefaults.standard.set(true, forKey: "NewMatchesNotification")

        //Show the next view controller
        if let introViewController = storyboard!.instantiateViewController(withIdentifier: "IntroVideo") as? IntoVideoViewController {
            self.navigationController?.pushViewController(introViewController, animated: true)
        }
    }
    
    func setGender(gender: String) -> NSNumber{
        
        switch gender {
        case 👨🏻:
            return 0
        case 👨🏼:
            return 0
        case 👨🏽:
            return 0
        case 👨🏾:
            return 0
        case 👨🏿:
            return 0
        case 👩🏻:
            return 1
        case 👩🏼:
            return 1
        case 👩🏽:
            return 1
        case 👩🏾:
            return 1
        case 👩🏿:
            return 1
        default:
            return user.gender!
        }
    }
    
    
    func checkPhoneNumber(number: String) -> Bool{
        let phone = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        if (phone.characters.count == 10){
            return true
        }
        else{
            return false
        }
    }
    

}
