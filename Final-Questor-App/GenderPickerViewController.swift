//
//  GenderPickerViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 9/21/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit

class GenderPickerViewController: UIViewController {
    
    @IBOutlet weak var maleButton: UIButton!
    
    @IBOutlet weak var femaleButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    let borderAlpha : CGFloat = 0.7
    let cornerRadius : CGFloat = 5.0
    
    var fillColor: UIColor = OppositeGradientHeaderView.hexStringToUIColor("#FF8B24")
    
    @IBAction func femaleAction(_ sender: AnyObject) {
        
        selectButton(1)
        nextButton.isUserInteractionEnabled = true
        nextButton.backgroundColor = fillColor
    }
    
    @IBAction func maleAction(_ sender: AnyObject) {
        
        selectButton(0)
        nextButton.isUserInteractionEnabled = true
        nextButton.backgroundColor = fillColor
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Male Button
        maleButton.setTitleColor(UIColor.black, for: UIControlState())
        maleButton.backgroundColor = UIColor.clear
        maleButton.tag = 1
        maleButton.layer.borderWidth = 1.0
        maleButton.layer.borderColor = UIColor.black.cgColor
        maleButton.layer.cornerRadius = cornerRadius
        
        
        //Female Button
        femaleButton.setTitleColor(UIColor.black, for: UIControlState())
        femaleButton.backgroundColor = UIColor.clear
        femaleButton.tag = 1
        femaleButton.layer.borderWidth = 1.0
        femaleButton.layer.borderColor = UIColor.black.cgColor
        femaleButton.layer.cornerRadius = cornerRadius
        
        
        //Next Button
        nextButton.setTitleColor(UIColor.black, for: UIControlState())
        nextButton.backgroundColor = UIColor.clear
        nextButton.tag = 1
        nextButton.layer.borderWidth = 1.0
        nextButton.layer.borderColor = UIColor.black.cgColor
        nextButton.layer.cornerRadius = cornerRadius
        
        //Check a value is set for dating friends or both
        if let tag = SessionManager.sharedInstance.user?.gender as? Int{
            print("It got one and it is : ", tag)
            if tag == 0 {
                //fill first
                print(tag, " == 0")
                self.maleButton.backgroundColor = fillColor
                nextButton.isUserInteractionEnabled = true
                nextButton.backgroundColor = fillColor
                
            }
            else {
                //fill second
                self.femaleButton.backgroundColor = fillColor
                nextButton.isUserInteractionEnabled = true
                nextButton.backgroundColor = fillColor
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectButton(_ tag: Int){
        
        //First deselct all the buttons
        deselectButtons()
        
        //Whatever tag was passed in change that button to a background color you like
        if tag == 0{
            maleButton.backgroundColor = fillColor
            
            SessionManager.sharedInstance.user?.gender = 0
            
        }
        else {
            femaleButton.backgroundColor = fillColor
            SessionManager.sharedInstance.user?.gender = 1
            
        }
    }
    
    func deselectButtons(){
        maleButton.backgroundColor = UIColor.clear
        femaleButton.backgroundColor = UIColor.clear
        nextButton.backgroundColor = UIColor.clear
    }
    
    
    
    
}
