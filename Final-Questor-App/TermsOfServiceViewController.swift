//
//  TermsOfServiceViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 8/8/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit

class TermsOfServiceViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        
        //Creates the first view controller to the far left
        let vc0: UIViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsOfService")
        
        self.addChildViewController(vc0)
        self.scrollView.addSubview(vc0.view)
        vc0.didMove(toParentViewController: self)
        
        //Creates the middle View controller
        let vc1: UIViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PrivacyPolicy")
        var frame1 = vc1.view.frame
        frame1.origin.x = self.view.frame.size.width
        vc1.view.frame = frame1
        
        self.addChildViewController(vc1)
        self.scrollView.addSubview(vc1.view)
        vc1.didMove(toParentViewController: self)
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width * 2, height: self.view.frame.size.height * 3)
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    


}
