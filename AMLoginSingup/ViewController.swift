//
//  ViewController.swift
//  AMLoginSingup
//
//  Created by amir on 10/11/16.
//  Copyright © 2016 amirs.eu. All rights reserved.
//

import UIKit

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
}


class ViewController: UIViewController, UITextFieldDelegate, VerificationCodeDelegate{
    
    
    let animationDuration = 0.25
    var mode:AMLoginSignupViewMode = .signup
    var toggle:EmailPhoneToggle = .unedited
    var input:FinishSignUp = .undone
    var verified:Bool = false
    var status:VeriicationCodeSentStatus = .notSent
    
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
        
            //TODO: login by this data
            NSLog("Email:\(loginEmailInputView.textFieldView.text) Password:\(loginPasswordInputView.textFieldView.text)")
            
        }
    }
    
    @IBAction func signupButtonTouchUpInside(_ sender: AnyObject) {
   
        if mode == .login {
            toggleViewMode(animated: true)
        }else{
            
            //TODO: signup by this data
            NSLog("Email:\(signupEmailInputView.textFieldView.text) Password:\(signupPasswordInputView.textFieldView.text), PasswordConfirm:\(signupPasswordConfirmInputView.textFieldView.text)")
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
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
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
        
        //If correct code, simply reset title
        self.signupEmailInputView.Title = "Email or Phone"
        
        //Set email or phone number
        self.signupEmailInputView.textFieldView.text = "7708079716"
    }

    //MARK: - hide status bar in swift3

    override var prefersStatusBarHidden: Bool {
        return true
    }

}

