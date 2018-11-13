//
//  ViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 6/16/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SCLAlertView
import Photos

protocol pausePlayerDelegate{
    func pausePlayer()
    func isPlaying() -> Bool
    func playVideo()
    func checkPlayer() -> Bool
    //func enableTapFunction()
    //func disableTapFunction()
}


class MainViewController: UIViewController, UIScrollViewDelegate, ScrollViewChangeDelegate  {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var delegate : pausePlayerDelegate?
    
    var login = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set delegate for cards view
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.delegate = self
        CloudDAO.fetchUnviewUsers()
        
        //Creates the first view controller to the far left
        let vc0: MatchesViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Matches") as! MatchesViewController
        
        self.addChildViewController(vc0)
        self.scrollView.addSubview(vc0.view)
        vc0.didMove(toParentViewController: self)
        vc0.delegateScroll = self
        
        //Creates the middle View controller
        let vc1: CardsViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Cards") as! CardsViewController
        vc1.delegate = self
        vc1.delegateMessageUser = vc0
        if login{
            vc1.login = true
        }
        var frame1 = vc1.view.frame
        frame1.origin.x = self.view.frame.size.width
        vc1.view.frame = frame1
        
        self.addChildViewController(vc1)
        self.scrollView.addSubview(vc1.view)
        vc1.didMove(toParentViewController: self)
        
        //Set the delegate of the main controller to CardViewControleller
        delegate = vc1
        
        //This creates the third view
        let vc2: ProfileViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        if login{
            vc2.login = true
        }
        vc2.delegateScroll = self
        var frame2 = vc2.view.frame
        frame2.origin.x = self.view.frame.size.width * 2
        vc2.view.frame = frame2
        
        self.addChildViewController(vc2)
        self.scrollView.addSubview(vc2.view)
        vc2.didMove(toParentViewController: self)
        
        //Sets the size of scrollViiew to fit the number of views that we have
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width * 3, height: self.view.frame.size.height - 66)
        self.scrollView.contentOffset.x = self.view.frame.size.width
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Check to make sure the video player is not nil
        if (delegate?.checkPlayer() == true){
            //Check if the player on the cards view is playing
            if (delegate?.isPlaying() == true){
                print("the video player is playing")
                //If there is a video playing pause it
                self.delegate?.pausePlayer()
            }
        }
        
        //Disable tap functions
        //delegate?.disableTapFunction()
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //if the scollview lands on the messages and it is the user's first time using the app, then show these pop ups
        if (UserDefaults.standard.bool(forKey: "firstUserMessage") == true){
            //set it to not nil
            UserDefaults.standard.set(false, forKey: "firstUserMessage")
            if (scrollView.contentOffset.x == 0){
                //Show the pop ups
                showMessageWarning()
            }
        }
        
        //Check if the scrollview is back on the cards,
        if (scrollView.contentOffset.x == self.view.frame.size.width){
            //Then check if there is a video paused, if there is play video
            self.delegate?.playVideo()
        }
        
        //Enable tap functions
        //delegate?.enableTapFunction()
    }
    
    func changeScrollViewToMain(){
        self.scrollView.setContentOffset(CGPoint(x:self.view.frame.size.width, y: 0), animated: true)
    }
    
    
    
    func changeOffset(_ direction: String){
        if (direction == "Left") {
            //Offset the scroll view to the messages view
            print("Offset left to messages")
            self.scrollView.setContentOffset(CGPoint(x:0, y: 0), animated: true)
        }
        else{
            //Offset the scroll view to the profile view
            print("Offset right to profile")
            self.scrollView.setContentOffset(CGPoint(x:self.view.frame.size.width*2, y: 0), animated: true)
        }
    }
    
    func showMessageWarning(){
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Awesome 😜") {
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("Got it!") {
            }
            let icon = UIImage(named:"CameraPopup")
            let color = UIColor.orange
            alert.showCustom("Inappropriate Content", subTitle: "1.If at any time you are reported for inappropriate content that you have sent, your account will be perminently deleted", color: color, icon: icon!)
        }
        let icon = UIImage(named:"CameraPopup")
        let color = UIColor.orange
        alert.showCustom("Matches", subTitle: "1. Here is where you will be able to see all of the people that you have matched with.\n2.You can send and recieve as many videos as you would like.\n3.All videos are a maximum of 15 seconds!", color: color, icon: icon!)
    }
}

