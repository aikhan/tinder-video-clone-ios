//
//  LicenseViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 8/8/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit

class LicenseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

}