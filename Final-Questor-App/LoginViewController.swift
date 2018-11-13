//
//  LoginViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 6/16/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
import Alamofire



//This username and password login have not been set up yet
class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var topConstriant: NSLayoutConstraint!
    @IBOutlet weak var loginButton: UIButton!
    //TODO:Fix spelling
    @IBOutlet weak var backgroundImagaeView: UIImageView!
    var backgroundImage = UIImage(named: "Background")
    
    @IBOutlet weak var backButton: UIButton!
    let borderAlpha : CGFloat = 0.7
    let cornerRadius : CGFloat = 5.0
    
    @IBAction func backAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //Back button
        backButton.setImage(UIImage(named: "BackButtonLeft"), for: UIControlState())
        
        //Login button
        loginButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        loginButton.setTitle("Login", for: UIControlState())
        loginButton.setTitleColor(UIColor.white, for: UIControlState())
        loginButton.backgroundColor = UIColor.clear
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        loginButton.layer.cornerRadius = cornerRadius
        
        //Set up background image
        backgroundImagaeView.image = backgroundImage
        
        //Text fields
        emailTextField.delegate = self
        passwordTextField.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        emailTextField.alpha = 0.5
        passwordTextField.alpha = 0.5
        
        emailTextField.placeholder = "Email or Phone Number"
        passwordTextField.placeholder = "Password"
        
        if SessionManager.sharedInstance.deviceType != "iphone6Plus"{
            NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    func keyboardWillShow(_ sender: Notification) {/*
        if SessionManager.sharedInstance.deviceType == "iphone5" {
            topConstriant.constant = 20
        }else if SessionManager.sharedInstance.deviceType == "iphone6"{
            topConstriant.constant = 50
        }else if SessionManager.sharedInstance.deviceType == "iphone4"{
            topConstriant.constant = -50
        }
        */
        
    }
    
    func keyboardWillHide(_ sender: Notification) {
       // topConstriant.constant = 110
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        switch textField
        {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
            break
        case passwordTextField:
            
            loginAction(textField)
            textField.resignFirstResponder()
            break
        default:
            textField.resignFirstResponder()
            
        }
        return true
    }
    
    @IBAction func signUpAction(_ sender: AnyObject) {
        //self.performSegueWithIdentifier("signUpSegue", sender: self)
    }
    
    //Login action has not been set up yet
    @IBAction func loginAction(_ sender: AnyObject) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        if emailTextField.text == "" || passwordTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "Invalid login information. Please try again!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //Disble login button
        loginButton.isEnabled = false
        self.loginButton.titleLabel?.text = "Logging In"
        
        
        
        let urlString = "\(Constants.kBaseURL)login?email=\(email)&password=\(password)"
        let url = URL(string: urlString)
        
        
        //Make call to the API
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            print("inside api call")
            
            //get response
            if let result = response.result.value{
              
                
                //Check if the login was successfully or not
                if (result as AnyObject).value(forKey: "isVerified") as? String == "False"{
                    
                    //Show an error and tell them to try again
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: "Error", message: "Invalid login information. Please try again!", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                        self.loginButton.isEnabled = true
                        
                    })
                }
                else{
                    print("Log in was successful, downloading user information.")
                    
                    let array = result as! [[String:Any]]
                    for j in array{
                        
                        let userOne = GTLUserUser()
                        
                        if let firstname = j["first_name"] as? String{
                            userOne.firstName = firstname
                        }
                        if let matchedarray = j["matchedArray"] as? NSArray as? [AnyObject]{
                            userOne.matchedArray = matchedarray
                        }
                        if let likedarray = j["likedArray"] as? NSArray as? [AnyObject]{
                            userOne.likedArray = likedarray
                        }
                        if let age = j["age"] as? Int{
                            userOne.age = age as NSNumber!
                        }
                        if let ageLow = j["age_low"] as? Int{
                            userOne.ageLow = ageLow as NSNumber!
                        }
                        if let ageHigh = j["age_high"] as? Int{
                            userOne.ageHigh = ageHigh as NSNumber!
                        }
                        if let distance = j["distance_of_search"] as? Int{
                            userOne.distanceOfSearch = distance as NSNumber!
                        }
                        if let email = j["email"] as? String{
                            userOne.email = email
                        }
                        if let lookingfor = j["looking_for"] as? Int{
                            userOne.lookingFor = lookingfor as NSNumber!
                        }
                        if let gender = j["gender"] as? Int{
                            userOne.gender = gender as NSNumber!
                        }
                        if let likedarray = j["skippedArray"] as? NSArray as? [AnyObject]{
                            userOne.likedArray = likedarray
                        }
                        if let location = j["user_location"] as? String{
                            userOne.userLocation = location
                        }
                        if let userBucketReturned = j["user_bucket"] as? String{
                            userOne.userBucket = userBucketReturned
                        }
                        if let password = j["password"] as? String{
                            userOne.password = password
                        }
                        if let lat = j["lat"] as? Double{
                            userOne.lat = lat as NSNumber!
                        }
                        if let lon = j["lon"] as? Double{
                            userOne.lon = lon as NSNumber!
                        }
                        if let usergifarray = j["profile_gif"] as? NSArray as? [AnyObject]{
                            userOne.profileGif = usergifarray
                        }
                        if let bio = j["bio"] as? String{
                            userOne.bio = bio
                        }
                        if let profileGif = j["profile_gif"] as? NSArray as? [AnyObject]{
                            userOne.profileGif = profileGif
                        }
                        if let profileUrls = j["profile_video_urls"] as? NSArray as? [AnyObject]{
                            userOne.profileVideoUrls = profileUrls
                            
                            //TODO: Download the video into the app's file system
                        }
                        
                        //Add location to returned user object
                        userOne.lat = Constants.lat as NSNumber!
                        userOne.lon = Constants.lon as NSNumber!
                        
                        
                        //Saves user in Session Manamger
                        SessionManager.sharedInstance.user = userOne
                        
                        
                        //Don't need SessionManager.sharedInstance.user?.entityKey = newUsers[0].entityKey
                        SessionManager.sharedInstance.user?.userBucket = userOne.userBucket

                        if Constants.lat != 0{
                            SessionManager.sharedInstance.lat = Constants.lat
                        }
                        if Constants.lon != 0{
                            SessionManager.sharedInstance.long = Constants.lon
                        }
                        
                        //Add all of the logged in user's information into the app
                        SessionManager.sharedInstance.user = userOne
                        let didInsert = CoreDataDAO.insertUserLogin(userOne)
                        assert(didInsert, "Could not write to the database")
                        
                        //Save the user's return bucekt name and entity key to the nsuserdefaults
                        UserDefaults.standard.set(userOne.userBucket as String, forKey: "bucketName")
                        
                        //Set this so that the pop ups will not show for people just starting to use the app
                        UserDefaults.standard.set(false, forKey: "firstUser")
                        
                        //Anytime someone logs in or signs up, all notifications will be set back to true,
                        UserDefaults.standard.set(true, forKey: "likeNotification")
                        
                        UserDefaults.standard.set(true, forKey: "newMessageNotification")
                        
                        UserDefaults.standard.set(true, forKey: "NewMatchesNotification")
                        
                        
                        //Set up array just like in sign up and populate videos this way
                        UserDefaults.standard.set(0, forKey: "profileVideoCount")
                        let videoUrlsArray = NSMutableArray()
                        UserDefaults.standard.set(videoUrlsArray, forKey: "profileVideoUrls")
                        
                        if let token = UserDefaults.standard.string(forKey: "registrationToken"){
                            DAO.saveRegistrationToken(token)
                            print("This is the toke from the user defaults", token)
                        }
                        
                        //Set log in
                        SessionManager.sharedInstance.isUserLoggedIn = true
                        UserDefaults.standard.set(true, forKey: "login")
                        
                        DispatchQueue.main.async(execute: {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc: MainViewController = storyboard.instantiateViewController(withIdentifier: "MainView") as! MainViewController
                            vc.login = true
                            //self.navigationController?.pushViewController(vc, animated: true)
                            UIApplication.shared.keyWindow?.rootViewController = vc
                        })
                    }
                }
            }
            else{
                print("serialization error")
            }
        }
    }
    
        override var prefersStatusBarHidden : Bool {
            return true
        }
        
        
}

