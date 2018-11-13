//
//  ViewController.swift
//  AMLoginSingup
//
//  Created by amir on 10/11/16.
//  Copyright © 2016 amirs.eu. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView

enum AMLoginSignupViewMode {
    case login
    case signup
}

enum EmailPhoneToggle {
    case unedited
    case edited
}

enum FinishSignUp {
    case done
    case undone
}

enum VeriicationCodeSentStatus{
    case notSent
    case sent
    case recieved
    case verified
    case invalidCode
    case email
}


class InitalViewController: UIViewController, UITextFieldDelegate, VerificationCodeDelegate{
    
    
    let animationDuration = 0.25
    var mode:AMLoginSignupViewMode = .signup
    var toggle:EmailPhoneToggle = .unedited
    var input:FinishSignUp = .undone
    var verified:Bool = false
    var status:VeriicationCodeSentStatus = .notSent
    var entityKey:String = ""
    var phoneNumber:String = ""
    
    //MARK: - background image constraints
    @IBOutlet weak var backImageLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var backImageBottomConstraint: NSLayoutConstraint!
    
    
    //MARK: - login views and constrains
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginContentView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonVerticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginWidthConstraint: NSLayoutConstraint!
    
    
    //MARK: - signup views and constrains
    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var signupContentView: UIView!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signupButtonVerticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var signupButtonTopConstraint: NSLayoutConstraint!
    
    
    //MARK: - logo and constrains
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoButtomInSingupConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoCenterConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var forgotPassTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var socialsView: UIView!
    @IBOutlet weak var InstagramView: UIImageView!
    
    
    //MARK: - input views
    @IBOutlet weak var loginEmailInputView: AMInputView!
    @IBOutlet weak var loginPasswordInputView: AMInputView!
    @IBOutlet weak var signupEmailInputView: AMInputView!
    @IBOutlet weak var signupPasswordInputView: AMInputView!
    @IBOutlet weak var signupPasswordConfirmInputView: AMInputView!
    
    
    
    
    //MARK: - controller
    override func viewDidLoad() {
        super.viewDidLoad()
        //add tap gesture to uiview
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.instagramPressed))
        socialsView.addGestureRecognizer(tapGesture)
        
        //Add email and phone number toggle
        signupEmailInputView.textFieldView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        signupEmailInputView.delegate = self
        
        // set view to login mode
        toggleViewMode(animated: false)
        
        //add keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboarFrameChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    //MARK: - button actions
    @IBAction func loginButtonTouchUpInside(_ sender: AnyObject) {
        
        if mode == .signup {
            toggleViewMode(animated: true)
            
        }else{
            
          if loginEmailInputView.textFieldView.text == "" || loginPasswordInputView.textFieldView.text == "" {
                let alert = UIAlertController(title: "Error", message: "Empty email or password not allowed", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
                return
            }else{
            
            let email = loginEmailInputView.textFieldView.text!
            let password = loginPasswordInputView.textFieldView.text!
            if email == "" || password == "" {
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
        }
    }
    
    @IBAction func signupButtonTouchUpInside(_ sender: AnyObject) {
        
        if mode == .login {
            toggleViewMode(animated: true)
            
        }else{
            //If the user signed up with their phone number and got code
            if status == .sent{
                checkCode()
            }
            else{
                
                if signupPasswordInputView.textFieldView.text != signupPasswordConfirmInputView.textFieldView.text {
                    let alert = UIAlertController(title: "Error", message: "Passwords do not match!", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }else if signupPasswordInputView.textFieldView.text == "" || signupEmailInputView.textFieldView.text == "" {
                    let alert = UIAlertController(title: "Error", message: "Empty email or password not allowed", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                else{
                    if let signUpController = storyboard!.instantiateViewController(withIdentifier: "SignUP") as? SignUpViewController {
                        
                        
                        SessionManager.sharedInstance
                        //check whether it is a email or phone number
                        if(isValidEmail(signupEmailInputView.textFieldView.text!)){
                            SessionManager.sharedInstance.user?.email = signupEmailInputView.textFieldView.text!
                        }
                        else{
                            if let myInteger = Int(signupEmailInputView.textFieldView.text!) {
                                let myNumber = NSNumber(value:myInteger)
                                SessionManager.sharedInstance.user?.phoneNumber = myNumber
                            }
                        }
                        
                        SessionManager.sharedInstance.user?.password = signupPasswordInputView.textFieldView.text!
                    }
                }
            }
        }
    }
    
    
    
    //MARK: - toggle view
    func toggleViewMode(animated:Bool){
        
        // toggle mode
        mode = mode == .login ? .signup:.login
        
        
        // set constraints changes
        backImageLeftConstraint.constant = mode == .login ? 0:-self.view.frame.size.width
        
        
        loginWidthConstraint.isActive = mode == .signup ? true:false
        logoCenterConstraint.constant = (mode == .login ? -1:1) * (loginWidthConstraint.multiplier * self.view.frame.size.width)/2
        loginButtonVerticalCenterConstraint.priority = mode == .login ? 300:900
        signupButtonVerticalCenterConstraint.priority = mode == .signup ? 300:900
        
        
        //animate
        self.view.endEditing(true)
        
        UIView.animate(withDuration:animated ? animationDuration:0) {
            
            //animate constraints
            self.view.layoutIfNeeded()
            
            //hide or show views
            self.loginContentView.alpha = self.mode == .login ? 1:0
            self.signupContentView.alpha = self.mode == .signup ? 1:0
            
            
            // rotate and scale login button
            let scaleLogin:CGFloat = self.mode == .login ? 1:0.4
            let rotateAngleLogin:CGFloat = self.mode == .login ? 0:CGFloat(-M_PI_2)
            
            var transformLogin = CGAffineTransform(scaleX: scaleLogin, y: scaleLogin)
            transformLogin = transformLogin.rotated(by: rotateAngleLogin)
            self.loginButton.transform = transformLogin
            
            
            // rotate and scale signup button
            let scaleSignup:CGFloat = self.mode == .signup ? 1:0.4
            let rotateAngleSignup:CGFloat = self.mode == .signup ? 0:CGFloat(-M_PI_2)
            
            var transformSignup = CGAffineTransform(scaleX: scaleSignup, y: scaleSignup)
            transformSignup = transformSignup.rotated(by: rotateAngleSignup)
            self.signupButton.transform = transformSignup
        }
        
    }
    
    
    
    //MARK: - keyboard
    func keyboarFrameChange(notification:NSNotification){
        
        if(toggle == .unedited){
            input = .undone
        }
        if(toggle == .edited && input == .undone){
            emailToggle()
        }
        if(status == . verified){
            self.signupButton.setTitle("Sign Up", for: .normal)
        }
        
        
        let userInfo = notification.userInfo as! [String:AnyObject]
        
        // get top of keyboard in view
        let topOfKetboard = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue .origin.y
        
        
        // get animation curve for animate view like keyboard animation
        var animationDuration:TimeInterval = 0.25
        var animationCurve:UIViewAnimationCurve = .easeOut
        if let animDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            animationDuration = animDuration.doubleValue
        }
        
        if let animCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
            animationCurve =  UIViewAnimationCurve.init(rawValue: animCurve.intValue)!
        }
        
        
        // check keyboard is showing
        let keyboardShow = topOfKetboard != self.view.frame.size.height
        
        
        //hide logo in little devices
        let hideLogo = self.view.frame.size.height < 667
        
        // set constraints
        backImageBottomConstraint.constant = self.view.frame.size.height - topOfKetboard
        
        logoTopConstraint.constant = keyboardShow ? (hideLogo ? 0:20):50
        logoHeightConstraint.constant = keyboardShow ? (hideLogo ? 0:40):60
        logoBottomConstraint.constant = keyboardShow ? 20:32
        logoButtomInSingupConstraint.constant = keyboardShow ? 20:32
        
        forgotPassTopConstraint.constant = keyboardShow ? 30:45
        
        loginButtonTopConstraint.constant = keyboardShow ? 25:30
        signupButtonTopConstraint.constant = keyboardShow ? 23:35
        
        loginButton.alpha = keyboardShow ? 1:0.7
        signupButton.alpha = keyboardShow ? 1:0.7
        
        
        
        // animate constraints changes
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(animationCurve)
        
        self.view.layoutIfNeeded()
        
        UIView.commitAnimations()
        
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if (signupEmailInputView.textFieldView.text == ""){
            toggle = .unedited
        }
        else{
            toggle = .edited
        }
    }
    
    func instagramPressed(_ sender: UITapGestureRecognizer){
        if(mode == .signup){
            print("Mode is signup")
        }
        else{
            print("Mode is login")
        }
        print("Instagram pressed")
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPhoneNumber(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}\\d{3}\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func emailToggle(){
        //Check if the user has entered a phone number or a email
        let string = signupEmailInputView.textFieldView.text!
        print("IsValidEmail", isValidEmail(string))
        print("isValidPhone", isValidPhoneNumber(value: string))
        print("email has been edited")
        if (isValidEmail(string) || isValidPhoneNumber(value: string)){
            print("Valid phone or email")
            //They have entered a valid phone number or a valid email, so move on, if valid phone number send verification code
            if(isValidPhoneNumber(value: string)){
                //Send user verification code
                self.phoneNumber = string
                
                //close keyboard
                self.signupEmailInputView.textFieldView.resignFirstResponder()
                
                //send verification code
                let alert = UIAlertController(title: "Verification Code", message: "A Verification Code Will Be Sent To You!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    //Set email text field to blank
                    self.signupEmailInputView.textFieldView.text = ""
                    
                    //Change "email or phone" to verification number
                    self.signupEmailInputView.Title = "Enter Verification Code"
                    
                    //Send the verification code
                    self.status = .sent
                    
                    //Set textfield to preforem action after 3 characters have been entered
                    self.signupEmailInputView.verificationTextField = true
                    
                    //SEND THE CODE !!
                    
                    //Create a GTLUserUser with only a phone number
                    let userForPhone = GTLUserUser()
                    userForPhone.phoneNumber = Int(self.phoneNumber) as NSNumber!
                    self.insertUserPhone(userForPhone)
                    
                    //Save phone number to defualts
                    UserDefaults.standard.set(self.phoneNumber, forKey: "phoneNumber")
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                //It is an email
                status = .email
            }
            //In order to keep this code from running everyime a text field is pressed
            input = .done
        }
        else{
            print("The enntry is invalid")
            //Not a valid emai or phone number
            let alert = UIAlertController(title: "Invalid Email of Phone Number", message: "Please enter a vlaid entry", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                //Set email text field to blank
                self.signupEmailInputView.textFieldView.text = ""
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    //MARK: VerificatoinCode Delegate Methods
    func checkCode(){
        print("The code has been checked!")
        let phonenumber = UserDefaults.standard.object(forKey: "phoneNumber") as! String
        let code = self.signupEmailInputView.textFieldView.text!
        print("code:" , code)
        let params = ["entityKey" : self.entityKey]
        let url = "https://final-questor-app.appspot.com/verifyphone/confirmCode?code=\(code)&phoneNumber=\(phonenumber)"
        
        //Change sign up button to verifying
        self.signupButton.width = self.signupButton.frame.width + 40
        self.signupButton.setTitle("Verifying...", for: .normal)
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            //Check the response, if true, go to the next page, else tell the user the code is wrong try again
            if let result = response.result.value{
                let JSON = result as! NSDictionary
                print(JSON)
                let resp =  JSON.value(forKey: "Confirmed")! as! String
                if resp == "true"{
                    //Set verified to true
                    self.verified = true
                    
                    //Set button the verified
                    self.signupButton.setTitle("Verified!", for: .normal)
                    
                    //Set status so use can move on
                    self.status = .verified
                    
                    //If correct code, simply reset title
                    self.signupEmailInputView.Title = "Phone"
                    
                    //Set email or phone number
                    self.signupEmailInputView.textFieldView.text = UserDefaults.standard.object(forKey: "phoneNumber") as! String
                
                }
                else{
                    //Alert the user that the code was wrong and to try again, call view did load
                    let alert = UIAlertController(title: "Invalid Code", message: "Please Try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        //Set email text field to blank
                        self.signupEmailInputView.textFieldView.text = ""
                        
                        //Reset sign up button
                        self.signupButton.setTitle("Verify", for: .normal)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        
        }
        
    }
    
    func insertUserPhone(_ newUser: GTLUserUser){
        print("insert user called")
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
                print("create user successfully")
                self.verifyPhoneNumber(self.phoneNumber)
                
                //save entitykey
                let returnedUser = response as! GTLUserUser
                newUser.entityKey = returnedUser.entityKey
                self.entityKey = returnedUser.entityKey
                
                
            }
            
        })
        }
    
    func verifyPhoneNumber(_ phoneNumber: String){
        print("Verified called")
        print("This is the phone number passed in" , self.phoneNumber)
        let params = ["test" : "test"]
        let url = "https://final-questor-app.appspot.com/verifyphone?phoneNumber=\(self.phoneNumber)"
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //Do Nohting, this simply sends them a verification text
            self.status = .sent
            
            //Set sign up button to "verify"
            self.signupButton.setTitle("Verify", for: .normal)
            
        }
        }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "SignupSegue" {
                if status == .verified || status == .email {
                    return true
                }
            }
        }
        return false
    }
    
    //MARK: - hide status bar in swift3
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

