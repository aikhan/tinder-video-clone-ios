//
//  SignUpViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 6/16/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
import SCLAlertView
import Alamofire
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}




class SignUpViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate, UIPopoverPresentationControllerDelegate {
    
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var sliderValueLabel: UILabel!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var ageRangeFromTextField: UITextField!
    @IBOutlet weak var ageRangeToTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var birthdayDatePicker: UIDatePicker!
    
    //Settings buttons
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var licenseButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var termsofserviceButton: UIButton!

    
    weak var delegate :ReloadProfileView?
    
    var distanceChanged = false
    
    //logout
    @IBAction func logoutAction(_ sender: AnyObject) {
        
        self.logOutAction()
        
    }
    
    //licenses
    @IBAction func licenseAction(_ sender: AnyObject) {
        
        let vc2: UIViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Licenses")
        self.present(vc2, animated: true, completion: nil)
    }
    
    //Delete Account
    @IBAction func deleteAccountAction(_ sender: AnyObject) {
        var selfBucket = SessionManager.sharedInstance.user?.userBucket
        if selfBucket == nil {
            selfBucket = DAO.getBucketNameForLoggedInUser()
        }
        
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Delete Account") {
            self.deleteUser(selfBucket!)
            self.logOutAction()
        }
        
        alert.addButton("Cancel"){
            alert.dismiss(animated: true, completion: nil)
        }
        
        let icon = UIImage(named:"CameraPopup")
        let color = UIColor.orange
        
        alert.showCustom("Delete Account", subTitle: "Are you sure that you want to permently delete your account?", color: color, icon: icon!)
    }
    
    //Terms of Service
    @IBAction func termsOfServiceAction(_ sender: AnyObject) {
        
        let vc2: UIViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsOfService1")
        self.present(vc2, animated: true, completion: nil)
    }
    
    var isGenderSelected = false
    var isLookingForSelected = false
    
    @IBOutlet weak var continueButton: UIButton!
    
    let cornerRadius : CGFloat = 5.0
    
    var fromProfile = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        if fromProfile{
            backButton.isHidden = false
            continueButton.isHidden = true
            birthdayDatePicker.isHidden = true
            
            birthdayLabel.isHidden = true
        }
        else{
            backButton.isHidden = true
            logoutButton.isHidden = true
            licenseButton.isHidden = true
            deleteButton.isHidden = true
            termsofserviceButton.isHidden = true
        }
        
        //Set border for uitextview
        bioTextView.delegate = self
        bioTextView.layer.cornerRadius = 5
        bioTextView.layer.borderColor = UIColor.lightGray.cgColor
        bioTextView.layer.borderWidth = 1
        bioTextView.text = "Enter the most interesting facts about yourself 😜"
        bioTextView.textColor = UIColor.lightGray
        
        //Text field borders and round corners
        if fromProfile{
            firstNameTextField.text = CoreDataDAO.getLoggedInUserInfo()?.firstName
        }
        firstNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        firstNameTextField.layer.borderWidth = 1
        
        if fromProfile{
            locationTextField.text = String(describing: CoreDataDAO.getLoggedInUserInfo()?.location)
        }
        locationTextField.layer.borderColor = UIColor.lightGray.cgColor
        locationTextField.layer.borderWidth = 1
        ageRangeFromTextField.layer.borderColor = UIColor.lightGray.cgColor
        if fromProfile{
            ageRangeFromTextField
                .text = String(describing: CoreDataDAO.getLoggedInUserInfo()!.ageLow!)
        }
        ageRangeFromTextField.layer.borderWidth = 1
        ageRangeToTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        if fromProfile{
            ageRangeToTextField.text = String(describing: CoreDataDAO.getLoggedInUserInfo()!.ageHigh!)
        }
        
        ageRangeToTextField.layer.borderWidth = 1
        firstNameTextField.layer.cornerRadius = 5
        locationTextField.layer.cornerRadius = 5
        ageRangeFromTextField.layer.cornerRadius = 5
        ageRangeToTextField.layer.cornerRadius = 5
        
        if fromProfile{
            bioTextView.text = CoreDataDAO.getLoggedInUserInfo()?.bio
            bioTextView.textColor = UIColor.black
        }
        
        //Set slider color
        distanceSlider.minimumTrackTintColor = UIColor.orange
        
        //Continue button
        continueButton.backgroundColor = UIColor.orange
        continueButton.layer.cornerRadius = cornerRadius

        
        //Allows the key board to dissapear when the the user taps somwhere on the screen
        scrollView.delegate = self
        firstNameTextField.delegate = self
        locationTextField.delegate = self
        ageRangeToTextField.delegate = self
        ageRangeFromTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        if SessionManager.sharedInstance.deviceType == "iphone6" {
            scrollView.contentSize = CGSize(width: 0, height: (self.view.frame.size.height)*1.2)
        }else if SessionManager.sharedInstance.deviceType == "iphone5"{
            scrollView.contentSize = CGSize(width: 0, height: (self.view.frame.size.height)*1.6)
        }else if SessionManager.sharedInstance.deviceType == "iphone4"{
            scrollView.contentSize = CGSize(width: 0, height: (self.view.frame.size.height)*2)
        }
        locationTextField.text = SessionManager.sharedInstance.userCity
    
    
    }
    
    @IBAction func pickerDateSelected(_ sender: UIDatePicker) {
        let selectedDate :Date = sender.date
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day , .month , .year], from: selectedDate)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        
        let myDOB = (Calendar.current as NSCalendar).date(era: 1, year: year!, month: month!, day: day!, hour: 0, minute: 0, second: 0, nanosecond: 0)
        if fromProfile{
            //Figure out a way how to get them to change the age
            SessionManager.sharedInstance.user?.age = DAO.getCurrentLoggedUser()!.age
        }
        else{
             SessionManager.sharedInstance.user?.age = Double(myDOB!.age) as NSNumber!
        }
       
    
    }
    @IBAction func genderButtonTapped(_ sender: AnyObject) {
        //display tableview with checkers
        isGenderSelected = true
        self.performSegue(withIdentifier: "GenderSegue", sender: self)
        
//        if let genderController = storyboard!.instantiateViewControllerWithIdentifier("Gender") as? GenderSelectionTableViewController {
//            
//            self.navigationController?.pushViewController(genderController, animated: true)
//        }
        
    }
    
    @IBAction func lookingForButtonTapped(_ sender: AnyObject) {
        isLookingForSelected = true
        self.performSegue(withIdentifier: "LookingForSegue", sender: self)
        
//        if let genderController = storyboard!.instantiateViewControllerWithIdentifier("Gender") as? GenderSelectionTableViewController {
//            genderController.isLookingFor = true
//            self.navigationController?.pushViewController(genderController, animated: true)
//        }
    }

    @IBAction func distanceSliderValueChanges(_ sender: UISlider) {
        sliderValueLabel.text = "\(Int(sender.value))"
        
    }
    
    @IBAction func sliderValueSelectedByUser(_ sender: UISlider) {
        SessionManager.sharedInstance.user?.distanceOfSearch = Int(sender.value) as NSNumber!
        distanceChanged =  true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("The memory warning came from SignUpViewController")
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        switch textField
        {
        case firstNameTextField:
            locationTextField.becomeFirstResponder()
            break
        case locationTextField:
            ageRangeFromTextField.becomeFirstResponder()
            break
        case ageRangeFromTextField:
            ageRangeToTextField.becomeFirstResponder()
            break
        case ageRangeToTextField:
            textField.resignFirstResponder()
            break
        case bioTextView:
            self.view.endEditing(true)
            break
        default:
            textField.resignFirstResponder()
            
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField){
        
        if textField == ageRangeFromTextField {
            ageRangeFromTextField.becomeFirstResponder()
            if Int(ageRangeFromTextField.text!) < 18 {
                let alert = UIAlertController(title: "Sorry", message: "Age cannot be less than 18", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
                ageRangeFromTextField.text = "18"
                //ageRangeFromTextField.becomeFirstResponder()
                
            }
        }
    }
    
    @IBAction func signUpAction(_ sender: AnyObject) {
        
        if firstNameTextField.text == "" || locationTextField.text == "" || ageRangeFromTextField.text == "" || ageRangeToTextField.text == ""{
            var message = ""
            if firstNameTextField.text == ""{
                message = "Please enter your first name"
            }
            else if locationTextField.text == ""{
                message = "Please enter your location"
            }else if ageRangeToTextField.text == "" {
                message = "Please enter your highest age prefernce"
            }
            else if ageRangeFromTextField.text == ""{
                message = "Please enter your lowest age preference"
            }
            
            let alert = UIAlertController(title: "Sorry", message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if isLookingForSelected != true {
            let alert = UIAlertController(title: "Sorry", message: "Please select your preference in Looking For", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if isGenderSelected == false {
            let alert = UIAlertController(title: "Sorry", message: "Please select your gender.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if Int(sliderValueLabel.text!)! == 0 {
            let alert = UIAlertController(title: "Sorry", message: "Please select the distance of search.", preferredStyle: .alert)
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
        
           // self.performSegueWithIdentifier("SignUp3Segue", sender: self)
        if let introViewController = storyboard!.instantiateViewController(withIdentifier: "IntroVideo") as? IntoVideoViewController {
            SessionManager.sharedInstance.user?.firstName = firstNameTextField.text
            SessionManager.sharedInstance.user?.userLocation = locationTextField.text
            SessionManager.sharedInstance.user?.ageLow = Int(ageRangeFromTextField.text!) as NSNumber!
            SessionManager.sharedInstance.user?.ageHigh = Int(ageRangeToTextField.text!) as NSNumber!
            SessionManager.sharedInstance.user?.distanceOfSearch = Int(sliderValueLabel.text!) as NSNumber!
            if bioTextView.textColor == UIColor.black {
                print("The user's bio was saved")
                SessionManager.sharedInstance.user?.bio = bioTextView.text!
            }
            else{
                print("The bio was not saved")
            }
            
            if let phoneNumber = UserDefaults.standard.object(forKey: "phoneNumber"){
                SessionManager.sharedInstance.user?.phoneNumber = phoneNumber as! NSNumber
            }
            if let password = UserDefaults.standard.object(forKey: "password"){
                SessionManager.sharedInstance.user?.password = password as! String
            }
            
            self.navigationController?.pushViewController(introViewController, animated: true)
            
            //Anytime someone logs in or signs up, all notifications will be set back to true,
            UserDefaults.standard.set(true, forKey: "likeNotification")
            
            UserDefaults.standard.set(true, forKey: "newMessageNotification")
            
            UserDefaults.standard.set(true, forKey: "NewMatchesNotification")
        
 
            insertUser(SessionManager.sharedInstance.user!)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if fromProfile{
            //Do not delete text from view
        }
        else{
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            }
            }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter the most interesting facts about yourself 😜"
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        
            SessionManager.sharedInstance.user?.firstName = firstNameTextField.text
            SessionManager.sharedInstance.user?.userLocation = locationTextField.text
            SessionManager.sharedInstance.user?.ageLow = Int(ageRangeFromTextField.text!) as NSNumber!
            SessionManager.sharedInstance.user?.ageHigh = Int(ageRangeToTextField.text!) as NSNumber!
        if (distanceChanged == true){
            SessionManager.sharedInstance.user?.distanceOfSearch = Int(sliderValueLabel.text!) as NSNumber!

        }
                        if bioTextView.textColor == UIColor.black {
                print("The user's bio was saved")
                SessionManager.sharedInstance.user?.bio = bioTextView.text!
            }
            else{
                print("The bio was not saved")
            }
            
            if let phoneNumber = UserDefaults.standard.object(forKey: "phoneNumber"){
                SessionManager.sharedInstance.user?.phoneNumber = phoneNumber as! NSNumber
            }
            if let password = UserDefaults.standard.object(forKey: "password"){
                SessionManager.sharedInstance.user?.password = password as! String
            }
            
            if fromProfile{
                //Add these to dao
                let didInsert = CoreDataDAO.insertUserLogin(SessionManager.sharedInstance.user!)
                assert(didInsert, "Could not write to the database")
               // SessionManager.sharedInstance.user?.entityKey = CoreDataDAO.getLoggedInUserInfo()?.userID
            }
            insertUser(SessionManager.sharedInstance.user!)
        delegate?.reload()

        self.navigationController?.popViewController(animated: true)
    }
    
    func logOutAction(){
        SessionManager.sharedInstance.user = nil
        DAO.clearAllLocalDataStore()
        let appDomain = Bundle.main.bundleIdentifier!
        
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        
        //Send user back to the main page
        UserDefaults.standard.set(false, forKey: "login") //just in case
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        //Set everything in the session manager to nil
        SessionManager.sharedInstance.isUserLoggedIn = false
        SessionManager.sharedInstance.lat = 0
        SessionManager.sharedInstance.long = 0
        SessionManager.sharedInstance.user = nil
        SessionManager.sharedInstance.usersArray = nil
        SessionManager.sharedInstance.userCity = nil
        SessionManager.sharedInstance.userCountry = nil
        
        //Remove all core data when user logs out
        DAO.clearAllLocalDataStore()
        
        //If the user did not sign it, meaning the root view controller is main, then it will pop back to main
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialView = mainStoryboard.instantiateViewController(withIdentifier: "InitialScreen") as! FirstViewController
        let nav = UINavigationController(rootViewController: initialView)
        nav.navigationBar.isTranslucent = false
        nav.isNavigationBarHidden = true
        appdelegate.window!.rootViewController = nav
        
    }
    
    func deleteUser(_ bucket: String){
        let params = ["bucketName" : bucket]
        let url = "https://final-questor-app.appspot.com/deleteAccount"
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            print(response)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "GenderSegue") {
            let vc = segue.destination
            let controller = vc.popoverPresentationController
            vc.preferredContentSize = CGSize(width: 200, height: 200)
            if controller != nil {
                controller?.delegate = self
            }
        }
        
        if (segue.identifier == "LookingForSegue"){
            let vc = segue.destination
            let controller = vc.popoverPresentationController
            vc.preferredContentSize = CGSize(width: 200, height: 200)
         
            if controller != nil {
                controller?.delegate = self
            }
        }
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //Once th back button is pressed then save al of their changes to the cloud.
    override func insertUser(_ newUser: GTLUserUser){
        
        if let entityKey = SessionManager.sharedInstance.user?.entityKey{
            newUser.entityKey = entityKey
            let query = GTLQueryUser.queryForUserCreate(withObject: newUser) as GTLQueryUser
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            service.executeQuery(query, completionHandler: {(ticket, response, error) -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if error != nil{
                    //Do some error handling
                    print(error.debugDescription)
                    return
                }
                else{
                    print("Updated settings successfully")
                    
                }
                
            })
        }
        else{
            
            let query = GTLQueryUser.queryForUserCreate(withObject: newUser) as GTLQueryUser
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            service.executeQuery(query, completionHandler: {(ticket, response, error) -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if error != nil{
                    //Do some error handling
                    print(error.debugDescription)
                    return
                }
                else{
                    print("Updated settings successfully")
                    
                }
                
            })
            
        }
    }
    
    


}
