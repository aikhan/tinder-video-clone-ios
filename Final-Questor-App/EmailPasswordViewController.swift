//
//  EmailPasswordViewController.swift
//  Final-Questor-App
//
//  Created by Asad Khan on 22/07/2016.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit

class EmailPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTectField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
     var backgroundImage = UIImage(named: "Background")
    @IBOutlet weak var doneButton: UIButton!
    
    let borderAlpha : CGFloat = 0.7
    let cornerRadius : CGFloat = 5.0
    
    @IBAction func backAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Back button
        backButton.setImage(UIImage(named: "BackButtonLeft"), for: UIControlState())
        
        //Set up background
        backgroundImageView.image = backgroundImage
        backgroundImageView.clipsToBounds = true
        
        //Set up buttons and text fields
        doneButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        doneButton.setTitle("Done", for: UIControlState())
        doneButton.setTitleColor(UIColor.white, for: UIControlState())
        doneButton.backgroundColor = UIColor.clear
        doneButton.layer.borderWidth = 1.0
        doneButton.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        doneButton.layer.cornerRadius = cornerRadius
        
        //Text fields 
        emailTextField.alpha = 0.5
        passwordTectField.alpha = 0.5
        confirmPasswordTextField.alpha = 0.5
        
        
        self.hideKeyboardWhenTappedAround()
        emailTextField.delegate = self
        passwordTectField.delegate = self
        confirmPasswordTextField.delegate = self
        // Do any additional setup after loading the view.
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
            topConstraint.constant = 0
        }else if SessionManager.sharedInstance.deviceType == "iphone6"{
            topConstraint.constant = 50
        }else if SessionManager.sharedInstance.deviceType == "iphone4"{
            topConstraint.constant = -100
        }
        
        
    }
    
    func keyboardWillHide(_ sender: Notification) {
        topConstraint.constant = 80
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        switch textField
        {
        case emailTextField:
            passwordTectField.becomeFirstResponder()
            break
        case passwordTectField:
            confirmPasswordTextField.becomeFirstResponder()
            break
        case confirmPasswordTextField:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
            
        }
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        if passwordTectField.text != confirmPasswordTextField.text {
            let alert = UIAlertController(title: "Error", message: "Passwords do not match!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            return
        }else if passwordTectField.text == "" || emailTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "Empty email or password not allowed", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            return
        }else if !isValidEmail(emailTextField.text!){
            let alert = UIAlertController(title: "Error", message: "Not a valid email address. Try again", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        else{
            if let signUpController = storyboard!.instantiateViewController(withIdentifier: "SignUP") as? SignUpViewController {
                
                //A Verification email was sent to the email that you entered, please enter the 3 digit code
                
                SessionManager.sharedInstance
                SessionManager.sharedInstance.user?.email = emailTextField.text
                SessionManager.sharedInstance.user?.password = passwordTectField.text
                self.navigationController?.pushViewController(signUpController, animated: true)
                print("SignUp Button was pressed")
            }
        }
        //Take the user to signup view controller
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPhoneNumber(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }

}
