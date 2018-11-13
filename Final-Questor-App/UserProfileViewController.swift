//
//  UserProfileViewController.swift
//  Final-Questor-App
//
//  Created by Asad Khan on 02/08/2016.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
import Alamofire
//import Alamofire
import SCLAlertView

class UserProfileViewController: UIViewController, PlayerDelegate, UIScrollViewDelegate{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLocationLabel: UILabel!

    @IBOutlet weak var distanceAwayLabel: UILabel!
    
    var profileUser: GTLUserUser!
    
    var player1: Player!
    var player1url: String!
    
    var player2: Player!
    var player1ur2: String!
    
    var player3: Player!
    var player1url3: String!
    
    var profileVideoCount: Int!
    
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        fillScrollView()
        configurePageControl()
        setUpLabels()
        pageControl.addTarget(self, action: #selector(UserProfileViewController.changePage(_:)), for: UIControlEvents.valueChanged)
        textView.backgroundColor = UIColor.lightGray
        textView.alpha = 0.5
        textView.textColor = UIColor.white
        
        //Back Button
        backButton.setImage(UIImage(named: "BackButtonLeft"), for: UIControlState())
        
        //Flag button
        flagButton.setImage(UIImage(named: "Flag"), for: UIControlState())
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setUpLabels(){
        if let name = self.profileUser.firstName{
            self.nameLabel.text = name
            self.nameLabel.textColor = UIColor.white
        }
        if self.profileUser.age != nil && self.profileUser.userLocation != nil {
            self.ageLocationLabel.text = String(describing: self.profileUser.age) + " , " + self.profileUser.userLocation
            self.ageLocationLabel.textColor = UIColor.orange
        }
        else{
            self.ageLocationLabel.isHidden = true
        }
        if self.profileUser.bio != nil{
            self.textView.text = self.profileUser.bio
        }
        else{
            self.textView.isHidden = true
        }
        if profileUser.distanceAway != nil{
            var distanceText: String!
            if profileUser.distanceAway == 0{
                distanceText = "Less than\n1 mile away"
            }else if profileUser.distanceAway == 1{
                distanceText = String(describing: profileUser.distanceAway) + " mile\n away "
            }
            else{
                distanceText = String(describing: profileUser.distanceAway) + " miles\n away "
            }
            self.distanceAwayLabel.text = distanceText
            self.distanceAwayLabel.textColor = UIColor.white
            self.distanceAwayLabel.font = UIFont(name: "ArialHebrew-Light ", size: 14)

        }
        else{
            self.distanceAwayLabel.isHidden = true
            
        }
        
     }
    
    
    func configurePageControl(){
        // The total number of pages that are available is based on how many available colors we have.
        self.pageControl.numberOfPages = self.profileUser.profileVideoUrls.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.orange
        self.view.addSubview(pageControl)
    }
    
    func fillScrollView(){
        

        if (profileUser.profileVideoUrls.count == 1){
            
            //Scrollview 1
            self.view.autoresizingMask = ([UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight])
            //self.player1.fillMode = AVLayerVideoGravityResize
            //Add player to this one uiviewcontroller
            self.player1 = Player()
            self.player1.delegate = self
            self.player1.view.frame = self.view.bounds
            
            //Sets the video player to full screen
            //self.player.fillMode = AVLayerVideoGravityResize
            
            self.addChildViewController(self.player1)
            //self.view.addSubview(self.player1.view)
            self.player1.didMove(toParentViewController: self)
            
            //TODO: Put an if else statement on this to check if the user even has any profile videos
            let videoUrl = URL(string: self.profileUser.profileVideoUrls[0] as! String)
            self.player1.setUrl(videoUrl!)
            
            
            self.player1.playFromBeginning()
            self.player1.playbackLoops = true
            self.scrollView.addSubview(player1.view)
            
            self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - 66)
            
            
        }
        else if (profileUser.profileVideoUrls.count == 2){
            
            //Scrollview 1
            self.view.autoresizingMask = ([UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight])
            //self.player1.fillMode = AVLayerVideoGravityResize
            //Add player to this one uiviewcontroller
            self.player1 = Player()
            self.player1.delegate = self
            self.player1.view.frame = self.view.bounds
            
            //Sets the video player to full screen
            //self.player.fillMode = AVLayerVideoGravityResize
            
            self.addChildViewController(self.player1)
            //self.view.addSubview(self.player1.view)
            self.player1.didMove(toParentViewController: self)
            
            //TODO: Put an if else statement on this to check if the user even has any profile videos
            let videoUrl = URL(string: self.profileUser.profileVideoUrls[0] as! String)
            self.player1.setUrl(videoUrl!)
            
            
            self.player1.playFromBeginning()
            self.player1.playbackLoops = true
            self.scrollView.addSubview(player1.view)
            
            //SCrollview 2
            self.player2 = Player()
            self.player2.delegate = self
            self.player2.view.frame = self.view.bounds
            
            //Sets the video player to full screen
            //self.player.fillMode = AVLayerVideoGravityResize
            
            self.addChildViewController(self.player2)
            //self.view.addSubview(self.player1.view)
            self.player2.didMove(toParentViewController: self)
            
            //TODO: Put an if else statement on this to check if the user even has any profile videos
            let videoUrl1 = URL(string: self.profileUser.profileVideoUrls[1] as! String)
            self.player2.setUrl(videoUrl1!)
            
            var frame1 = player2.view.frame
            frame1.origin.x = self.view.frame.size.width
            player2.view.frame = frame1
            
            //self.player2.playFromBeginning()
            self.player2.playbackLoops = true
            self.scrollView.addSubview(player2.view)
            
            self.scrollView.contentSize = CGSize(width: self.view.frame.size.width * 2, height: self.view.frame.size.height - 66)
            
        }
        else if(profileUser.profileVideoUrls.count == 3){
            
            //Scrollview 1
            self.view.autoresizingMask = ([UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight])
            //self.player1.fillMode = AVLayerVideoGravityResize
            //Add player to this one uiviewcontroller
            self.player1 = Player()
            self.player1.delegate = self
            self.player1.view.frame = self.view.bounds
            
            //Sets the video player to full screen
            //self.player.fillMode = AVLayerVideoGravityResize
            
            self.addChildViewController(self.player1)
            //self.view.addSubview(self.player1.view)
            self.player1.didMove(toParentViewController: self)
            
            //TODO: Put an if else statement on this to check if the user even has any profile videos
            let videoUrl = URL(string: self.profileUser.profileVideoUrls[0] as! String)
            self.player1.setUrl(videoUrl!)
            
            
            self.player1.playFromBeginning()
            self.player1.playbackLoops = true
            self.scrollView.addSubview(player1.view)
            
            //SCrollview 2
            self.player2 = Player()
            self.player2.delegate = self
            self.player2.view.frame = self.view.bounds
            
            //Sets the video player to full screen
            //self.player.fillMode = AVLayerVideoGravityResize
            
            self.addChildViewController(self.player2)
            //self.view.addSubview(self.player1.view)
            self.player2.didMove(toParentViewController: self)
            
            //TODO: Put an if else statement on this to check if the user even has any profile videos
            let videoUrl1 = URL(string: self.profileUser.profileVideoUrls[1] as! String)
            self.player2.setUrl(videoUrl1!)
            
            var frame1 = player2.view.frame
            frame1.origin.x = self.view.frame.size.width
            player2.view.frame = frame1
            
            //self.player2.playFromBeginning()
            self.player2.playbackLoops = true
            self.scrollView.addSubview(player2.view)
            
            //SCrollview
            self.player3 = Player()
            self.player3.delegate = self
            self.player3.view.frame = self.view.bounds
            
            //Sets the video player to full screen
            //self.player.fillMode = AVLayerVideoGravityResize
            
            self.addChildViewController(self.player3)
            //self.view.addSubview(self.player1.view)
            self.player3.didMove(toParentViewController: self)
            
            //TODO: Put an if else statement on this to check if the user even has any profile videos
            let videoUrl2 = URL(string: self.profileUser.profileVideoUrls[2] as! String)
            self.player3.setUrl(videoUrl2!)
            
            var frame2 = player3.view.frame
            frame2.origin.x = self.view.frame.size.width * 2
            player3.view.frame = frame2
            
            // self.player3.playFromBeginning()
            self.player3.playbackLoops = true
            self.scrollView.addSubview(player3.view)
            
            
            //Sets the size of scrollViiew to fit the number of views that we have
            self.scrollView.contentSize = CGSize(width: self.view.frame.size.width * 3, height: self.view.frame.size.height - 66)
            
            
        }
        else{
            print("This user have no videos")
        }
        //If 2 videos
        
        //If 3 video
        
        
        
    }
    
    func changePage(_ sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        
        if self.profileVideoCount == 1 {
            //Do not need to pause and play videos
        }
        else if self.profileVideoCount == 2 {
            //Do this
            if (scrollView.contentOffset.x == self.view.frame.size.width){
                //pause the first player, and play the second
                self.player1.pause()
                self.player2.playFromBeginning()
            }
            else if (scrollView.contentOffset.x == 0 && self.player2.playbackState == .playing){
                //Pause the second and start the first
                self.player2.pause()
                self.player1.playFromBeginning()
            }
        }
        else if self.profileVideoCount == 3 {
            //If it goes to the second pay it pause 1
            if (scrollView.contentOffset.x == self.view.frame.size.width){
                //pause the first player, and play the second
                
                //If from the first screen pause 1
                if (self.player1.playbackState == .playing){
                    self.player1.pause()
                    self.player2.playFromBeginning()}
                else {
                    //It is from the third player pause third player
                    self.player3.pause()
                    self.player2.playFromBeginning()
                }
            }
            else if (scrollView.contentOffset.x == 0 && self.player2.playbackState == .playing){
                //Pause the second and start the first
                self.player2.pause()
                self.player1.playFromBeginning()
            }
            else if (scrollView.contentOffset.x == self.view.frame.size.width * 2 && self.player2.playbackState == .playing){
                //pause the second and play the third
                self.player2.pause()
                self.player3.playFromBeginning()
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func flagAction(_ sender: AnyObject) {
        //Are you sure that you want to flag this video
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Yes!"){
            var selfBucket = SessionManager.sharedInstance.user?.userBucket
            if selfBucket == nil {
                selfBucket = DAO.getBucketNameForLoggedInUser()
            }
            let count = self.pageControl.currentPage
            let videoFlag = "flag" + String(count)
            let url = "https://final-questor-app.appspot.com/report"
            let params = ["bucketToReport" : self.profileUser!.userBucket!, "selfBucket": selfBucket!, "content" : videoFlag]
            
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { (response) in
                //Do nothing
                print(response)
            })
            
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addButton("NO"){
            
        }
        
        let icon = UIImage(named:"CameraPopup")
        let color = UIColor.orange
        
        alert.showCustom("Wait", subTitle: "Are you sure you want to flag this user's video?", color: color, icon: icon!)
        

    }
    
    func playerReady(_ player: Player){}
    func playerPlaybackStateDidChange(_ player: Player){}
    func playerBufferingStateDidChange(_ player: Player){}
    
    func playerPlaybackWillStartFromBeginning(_ player: Player){}
    func playerPlaybackDidEnd(_ player: Player){}

}
