//
//  IntoVideoViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 8/15/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
import SCLAlertView

class IntoVideoViewController: UIViewController, PlayerDelegate {

    var player: Player!
    var playUrl:String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Ok") {
            self.player.playFromBeginning()
        }
        
        let icon = UIImage(named:"CameraPopup")
        let color = UIColor.orange
        
        alert.showCustom("Hello!", subTitle: "Here's a message from the creators of Tru! \nEnjoy!", color: color, icon: icon!)
        
        self.player = Player()
        self.player.delegate = self
        self.player.view.frame = self.view.bounds
        
        
        self.addChildViewController(self.player)
        self.view.addSubview(self.player.view)
        self.player.didMove(toParentViewController: self)
        
        let path = Bundle.main.path(forResource: "IMG_2803", ofType:"MOV")
        
        self.player.setUrl(URL(fileURLWithPath: path!))
        
        
        self.player.fillMode = AVLayerVideoGravityResizeAspect
        
        //Play video even though phone is on silent
        if (self.player.muted == true){
            self.player.muted = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Player Delegete
    func playerReady(_ player: Player){
        
    }
    func playerPlaybackStateDidChange(_ player: Player){
        
    }
    func playerBufferingStateDidChange(_ player: Player){
        
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player){
   
    }
    
    func playerPlaybackDidEnd(_ player: Player){
        //Go to the next view
        
        if let signUpController = storyboard!.instantiateViewController(withIdentifier: "SignUp3") as? CameraViewController<AnyObject> {
            
            signUpController.isGifCamera = false
            signUpController.infoPopup = true
            signUpController.isProfileVideo = true
            
       self.show(signUpController, sender: self)
        }
        
        
    }
    


}
