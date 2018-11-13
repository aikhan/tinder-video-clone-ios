//
//  PhoneOrEmailViewController.swift
//  Final-Questor-App
//
//  Created by Asad Khan on 21/07/2016.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit

class PhoneOrEmailViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    var backgroundImage = UIImage(named: "Background")
    
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var phoneNumberButton: UIButton!
    
    let borderAlpha : CGFloat = 0.7
    let cornerRadius : CGFloat = 5.0
    
    @IBOutlet weak var backButton: UIButton!
    @IBAction func back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Background image
        backgroundImageView.image = backgroundImage
        
        //Back button
        backButton.setImage(UIImage(named: "BackButtonLeft"), for: UIControlState())
        
        //Buttons
        emailButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        emailButton.setTitle("Email", for: UIControlState())
        emailButton.setTitleColor(UIColor.white, for: UIControlState())
        emailButton.backgroundColor = UIColor.clear
        emailButton.layer.borderWidth = 1.0
        emailButton.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        emailButton.layer.cornerRadius = cornerRadius
        
        phoneNumberButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        phoneNumberButton.setTitle("Phone Number", for: UIControlState())
        phoneNumberButton.setTitleColor(UIColor.white, for: UIControlState())
        phoneNumberButton.backgroundColor = UIColor.clear
        phoneNumberButton.layer.borderWidth = 1.0
        phoneNumberButton.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        phoneNumberButton.layer.cornerRadius = cornerRadius


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
