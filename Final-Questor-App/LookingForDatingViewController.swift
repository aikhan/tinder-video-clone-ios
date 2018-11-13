//
//  LookingForDatingViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 9/21/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit

class LookingForDatingViewController: UIViewController {
    
    //Button outlets
    @IBOutlet weak var datingButton: UIButton!
    
    @IBOutlet weak var friendsButton: UIButton!
    
    @IBOutlet weak var bothButton: UIButton!

    @IBOutlet weak var nextButton: UIButton!
    
    let borderAlpha : CGFloat = 0.7
    let cornerRadius : CGFloat = 5.0
    
    var fillColor: UIColor = OppositeGradientHeaderView.hexStringToUIColor("#FF8B24")
    
    var genderShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        
        //Dating Button
        datingButton.setTitle("Dating", for: UIControlState())
        datingButton.setTitleColor(UIColor.black, for: UIControlState())
        datingButton.backgroundColor = UIColor.clear
        datingButton.tag = 0
        datingButton.layer.borderWidth = 1.0
        datingButton.layer.borderColor = UIColor.black.cgColor
        datingButton.layer.cornerRadius = cornerRadius
        
        //Friends Button
        friendsButton.setTitleColor(UIColor.black, for: UIControlState())
        friendsButton.backgroundColor = UIColor.clear
        friendsButton.tag = 1
        friendsButton.layer.borderWidth = 1.0
        friendsButton.layer.borderColor = UIColor.black.cgColor
        friendsButton.layer.cornerRadius = cornerRadius
        
        
        //Both Button
        bothButton.setTitleColor(UIColor.black, for: UIControlState())
        bothButton.backgroundColor = UIColor.clear
        bothButton.tag = 2
        bothButton.layer.borderWidth = 1.0
        bothButton.layer.borderColor = UIColor.black.cgColor
        bothButton.layer.cornerRadius = cornerRadius
        
        
        //Next Button
        nextButton.setTitleColor(UIColor.black, for: UIControlState())
        nextButton.backgroundColor = UIColor.clear
        nextButton.layer.borderWidth = 1.0
        nextButton.layer.borderColor = UIColor.black.cgColor
        nextButton.layer.cornerRadius = cornerRadius
        nextButton.isUserInteractionEnabled = false
        
        //Check a value is set for dating friends or both
        if let tag = SessionManager.sharedInstance.user?.dating as? Int{
            print("It got one and it is : ", tag)
            if tag == 0 {
                //fill first
                print(tag, " == 0")
                self.datingButton.backgroundColor = fillColor
                nextButton.isUserInteractionEnabled = true
                nextButton.backgroundColor = fillColor
                
            }
            else if tag == 1 {
                //fill second
                self.friendsButton.backgroundColor = fillColor
                nextButton.isUserInteractionEnabled = true
                nextButton.backgroundColor = fillColor
            }
            else{
                //fill third
                self.bothButton.backgroundColor = fillColor
                nextButton.isUserInteractionEnabled = true
                nextButton.backgroundColor = fillColor
            }
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func datingAction(_ sender: AnyObject) {
        selectButton(0)
        nextButton.isUserInteractionEnabled = true
        nextButton.backgroundColor = fillColor
    }
    

    @IBAction func friendsAction(_ sender: AnyObject) {
        selectButton(1)
        nextButton.isUserInteractionEnabled = true
        nextButton.backgroundColor = fillColor
        
    }
    
    @IBAction func bothAction(_ sender: AnyObject) {
        selectButton(2)
        nextButton.isUserInteractionEnabled = true
        nextButton.backgroundColor = fillColor
    }
    
    @IBAction func nextAction(_ sender: AnyObject) {
        if(genderShowing == true){
            self.dismiss(animated: true, completion: nil)
        }
        else{
            deselectButtons()
            
            //Check a value is set for male, femal, or both
            if let tag = SessionManager.sharedInstance.user?.lookingFor as? Int{
                print("tag = ", 0)
                if tag == 0 {
                    //fill first
                    
                    datingButton.backgroundColor = fillColor
                }
                else if tag == 1 {
                    //fill second
                    friendsButton.backgroundColor = fillColor
                }
                else{
                    //fill third
                    bothButton.backgroundColor = fillColor
                }
            }
           
            //Change dating and friends to say male and female
            datingButton.setTitle("Male", for: UIControlState())
            friendsButton.setTitle("Female", for: UIControlState())
            genderShowing = true
        }
        
        

    }
    
    func selectButton(_ tag: Int){
        
        //First deselct all the buttons
        deselectButtons()
        
        //Whatever tag was passed in change that button to a background color you like
        if tag == 0{
            datingButton.backgroundColor = fillColor
            
            if genderShowing == false{
            SessionManager.sharedInstance.user?.dating = 0
            }
            else{
               SessionManager.sharedInstance.user?.lookingFor = 0
            }
        }
        else if tag == 1{
            friendsButton.backgroundColor = fillColor
            
            if genderShowing == false{
            SessionManager.sharedInstance.user?.dating = 1
            }
            else{
                SessionManager.sharedInstance.user?.lookingFor = 1
            }
        }
        else{
            bothButton.backgroundColor = fillColor
            
            if genderShowing == false{
            SessionManager.sharedInstance.user?.dating = 2
            }
            else{
                SessionManager.sharedInstance.user?.lookingFor = 2
            }
        }
    }
    
    func deselectButtons(){
        datingButton.backgroundColor = UIColor.clear
        friendsButton.backgroundColor = UIColor.clear
        bothButton.backgroundColor = UIColor.clear
        nextButton.backgroundColor = UIColor.clear
    }
    
}
