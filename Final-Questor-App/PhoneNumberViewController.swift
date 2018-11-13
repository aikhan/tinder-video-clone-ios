//
//  PhoneNumberViewController.swift
//  Final-Questor-App
//
//  Created by Asad Khan on 21/07/2016.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView

class PhoneNumberViewController: UIViewController, UITextFieldDelegate {

    
    
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var confirmPhoneTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    var backgroundImage = UIImage(named: "Background")
    
    @IBOutlet weak var backButton: UIButton!
    let borderAlpha : CGFloat = 0.7
    let cornerRadius : CGFloat = 5.0
    
    //Checks if the phone number has been entered and made request to API
    var numberEntered = Bool()
    
    //Checks if they have been verified
    var verified = Bool()
    
    //Save entity key to be deleted
    var entityKey = ""
    
    
    @IBAction func backAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //Background image
        backgroundImageView.image = backgroundImage
        backgroundImageView.clipsToBounds = true
        
        //Back Button
         backButton.setImage(UIImage(named: "BackButtonLeft"), for: UIControlState())
        
        //Hide the confirmation code text field until the user enters their phone number and presses doneButton
        confirmPhoneTextField.isHidden = true
        
        //Set verified to false
        verified = false
        
        //Done button
        doneButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        doneButton.setTitle("Continue", for: UIControlState())
        doneButton.setTitleColor(UIColor.white, for: UIControlState())
        doneButton.backgroundColor = UIColor.clear
        doneButton.layer.borderWidth = 1.0
        doneButton.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        doneButton.layer.cornerRadius = cornerRadius
        
        //Text fields
        phoneNumberTextField.alpha = 0.5
        confirmPhoneTextField.alpha = 0.5
        
        self.hideKeyboardWhenTappedAround()
        self.phoneNumberTextField.delegate = self
        self.confirmPhoneTextField.delegate = self
        
        if SessionManager.sharedInstance.deviceType != "iphone6Plus"{
            NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    func keyboardWillShow(_ sender: Notification) {
        if SessionManager.sharedInstance.deviceType == "iphone5" {
            logoTopConstraint.constant = 20
        }else if SessionManager.sharedInstance.deviceType == "iphone4"{
            logoTopConstraint.constant = -50
        }
        
        
    }
    
    func keyboardWillHide(_ sender: Notification) {
        logoTopConstraint.constant = 110
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        print("Continue button pressed")
        
        //Make sure that there is a phone number evern entered
        if (phoneNumberTextField.text == ""){
            //Show an alert
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("Gotcha! 😃") {
                
            }
            
            let icon = UIImage(named:"CameraPopup")
            let color = UIColor.orange
            
            alert.showCustom("Enter Phone Number!", subTitle: "Sorry ! \nYou need to enter your mobile phone number in order to move on.\nPlease try again.", color: color, icon: icon!)
            
        }else{
        //If the user is submitting the phone number, create user, and send phone number for verification code
        if self.numberEntered == false{
            print("created new user")
            //Create a GTLUserUser with only a phone number
            let userForPhone = GTLUserUser()
            userForPhone.phoneNumber = Int(self.phoneNumberTextField.text!) as NSNumber!
            insertUserPhone(userForPhone)
            
            let phoneNumber = Int(self.phoneNumberTextField.text!)
            UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
            
            //Turn the continue button functionailty off, then turn back on when the pop up shows
            self.doneButton.isUserInteractionEnabled = false
            self.doneButton.setTitle("Sending...", for: UIControlState())
            
        }
        else if (self.verified == true){
            //Check if they even entered anything in the fields
            if (phoneNumberTextField.text == "" || confirmPhoneTextField.text == ""){
                //Tell user to enter a password
                //Show alert to tell them they do not match
                let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
                let alert = SCLAlertView(appearance: appearance)
                alert.addButton("Will Do! 😃") {
                    
                    
                    self.phoneNumberTextField.text = ""
                    self.phoneNumberTextField.placeholder = "Password"
                    self.phoneNumberTextField.keyboardType = UIKeyboardType.default
                    self.phoneNumberTextField.isSecureTextEntry = true
                    
                    self.confirmPhoneTextField.text = ""
                    self.confirmPhoneTextField.placeholder = "Confirm Password"
                    self.confirmPhoneTextField.keyboardType = UIKeyboardType.default
                    self.confirmPhoneTextField.isSecureTextEntry = true
                    
                }
                
                let icon = UIImage(named:"CameraPopup")
                let color = UIColor.orange
                
                alert.showCustom("Please Enter Passwords", subTitle: "Sorry ! \nYou must enter a password.\nPlease try again.", color: color, icon: icon!)
                
            }else{
                
                
                //check if the passwords match, if they do, then move on, if not, show alert and try again
                if(phoneNumberTextField.text! == confirmPhoneTextField.text!){
                    SessionManager.sharedInstance.user?.password = phoneNumberTextField.text!
                    UserDefaults.standard.set(phoneNumberTextField.text!, forKey: "password")
                    //Send user to the next page
                    if let signUpController = self.storyboard?.instantiateViewController(withIdentifier: "SignUP") as? SignUpViewController{
                        
                        self.navigationController?.pushViewController(signUpController, animated: true)
                    }
                    
                }
                else{
                    print("passwords do not match")
                    //Show alert to tell them they do not match
                    let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
                    let alert = SCLAlertView(appearance: appearance)

                    alert.addButton("Will Do! 😃") {
                        
                        self.phoneNumberTextField.text = ""
                        self.phoneNumberTextField.placeholder = "Password"
                        self.phoneNumberTextField.keyboardType = UIKeyboardType.default
                        self.phoneNumberTextField.isSecureTextEntry = true
                        
                        self.confirmPhoneTextField.text = ""
                        self.confirmPhoneTextField.placeholder = "Confirm Password"
                        self.confirmPhoneTextField.keyboardType = UIKeyboardType.default
                        self.confirmPhoneTextField.isSecureTextEntry = true
                        
                    }
                    
                    let icon = UIImage(named:"CameraPopup")
                    let color = UIColor.orange
                    
                    alert.showCustom("OOPS !", subTitle: "The passwords that you entered do not match.\nPlease try again.", color: color, icon: icon!)
                    
                }
            }
            
        }
        else{
            //Take the confirmation code that the entered then check
            checkConfirmationCode(self.confirmPhoneTextField.text!)
            
        }
        }
    }
    
    func verifyPhoneNumber(_ phoneNumber: String){
        print("Verified called")

        let params = ["phoneNumber" : phoneNumber ]
        let url = "https://final-questor-app.appspot.com/verifyphone"
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            print("verified returned successfully")
            
            //Turn the donebutton back on
            self.doneButton.isUserInteractionEnabled = true
            self.doneButton.setTitle("Continue", for: .normal)
            
            //The user has sent the phone number set bool to true
            self.numberEntered = true
            
            //Unhide the confirmation text field
            self.confirmPhoneTextField.isHidden = false
            
            //Tell the user that a text message has been sent to them , enter it in the field to move forward
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("Gotcha! 😃") {
                
            }
            
            let icon = UIImage(named:"CameraPopup")
            let color = UIColor.orange
            
            alert.showCustom("Verification Code Sent", subTitle: "Enter the 3 digit Verification Code.\nIf you do not receive a text within 30 seconds, enter your phone number and press 'Continue' again.", color: color, icon: icon!)
        }
        
        //If it does not work for some reason then call view did load
    }
    
    func checkConfirmationCode(_ code: String){
        
        
        let params = ["code" : code, "phoneNumber" : self.phoneNumberTextField.text! , "entityKey" : self.entityKey]
        let url = "https://final-questor-app.appspot.com/verifyphone/confirmCode"
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            //Check the response, if true, go to the next page, else tell the user the code is wrong try again
            if let result = response.result.value{
                let JSON = result as! NSDictionary
                let resp =  JSON.value(forKey: "Confirmed")! as! String
                if resp == "true"{
                    //Set verified to true
                    self.verified = true
                    
                    //Ask user for a password
                    self.askForPassword()
                    
                    
                }
                else{
                    //Alert the user that the code was wrong and to try again, call view did load
                    
                    let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
                    let alert = SCLAlertView(appearance: appearance)
                    alert.addButton("Gotcha! 😃") {
                        
                    }
                    
                    let icon = UIImage(named:"CameraPopup")
                    let color = UIColor.orange
                    
                    alert.showCustom("Wrong Code", subTitle: "The Verification Code that you entered does not match the code that we sent you.\nYou can enter your number again and we will send you another Verification Code.", color: color, icon: icon!)
                    
                    //Reload the view
                    self.viewDidLoad()
                    
                }
                
            }
        }
        
    }
    
    //This will create a user for the person using that app with only thier phone number, so that way I can save their confirmation code and verify it once they send it back in.
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
                self.verifyPhoneNumber(self.phoneNumberTextField.text!)
                
                //save entitykey
                let returnedUser = response as! GTLUserUser
                newUser.entityKey = returnedUser.entityKey
                self.entityKey = returnedUser.entityKey
                print(self.entityKey)
                
                
            }
            
        })
    }
    
    //When this function is called it verifies number, will gie an alert, will change the placeholder of the text fields to ask for the passwords, then it will proceed
    func askForPassword(){
        //Alert user that they have been comfirmed and now need to create a password
        
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Gotcha! 😃") {
            
            
            self.phoneNumberTextField.text = ""
            self.phoneNumberTextField.placeholder = "Password"
            self.phoneNumberTextField.keyboardType = UIKeyboardType.default
             self.phoneNumberTextField.isSecureTextEntry = true
            
            self.confirmPhoneTextField.text = ""
            self.confirmPhoneTextField.placeholder = "Confirm Password"
            self.confirmPhoneTextField.keyboardType = UIKeyboardType.default
            self.confirmPhoneTextField.isSecureTextEntry = true
        }
        
        let icon = UIImage(named:"CameraPopup")
        let color = UIColor.orange
        
        alert.showCustom("Verified! 😀", subTitle: "Your cell phone number has been verified!\n Now create and confirm a secure password!", color: color, icon: icon!)
        
        
    }
    
    

}
