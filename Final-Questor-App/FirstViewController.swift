//
//  FirstViewController.swift
//  Final-Questor-App
//
//  Created by Asad Khan on 21/07/2016.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var backgroundImage = UIImage(named: "Background")
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    let borderAlpha : CGFloat = 0.7
    let cornerRadius : CGFloat = 5.0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        
        
        backgroundImageView.image = backgroundImage
        
        if (SessionManager.sharedInstance.isUserLoggedIn == true){
            DAO.getCurrentLoggedUser()

            self.navigationController?.popToRootViewController(animated: false)
            performSegue(withIdentifier: "Show Main", sender: self)
        
        }
        
        //Buttons
        loginButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        loginButton.setTitle("Login", for: UIControlState())
        loginButton.setTitleColor(UIColor.white, for: UIControlState())
        loginButton.backgroundColor = UIColor.clear
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        loginButton.layer.cornerRadius = cornerRadius
        
        signupButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        signupButton.setTitle("Sign Up", for: UIControlState())
        signupButton.setTitleColor(UIColor.white, for: UIControlState())
        signupButton.backgroundColor = UIColor.clear
        signupButton.layer.borderWidth = 1.0
        signupButton.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        signupButton.layer.cornerRadius = cornerRadius
    }
    
    @IBAction func logInTapped(_ sender: UIButton) {
       // performSegueWithIdentifier("Show Login", sender: sender)
        
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func termsOfServiceButton(_ sender: AnyObject) {
        let vc2: UIViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsOfService1")
        self.present(vc2, animated: true, completion: nil)
    }

    

}
