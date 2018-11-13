//
//  MessageUserViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 6/20/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView

//this View controller will need a lot of attention as well. We will need to come up with a ui and a lot of specifications on how the chat is to be set up and what the users can and can not do. 

protocol MatchesReloadDelegate :class{
    func reloadTableData()
    func unmatchUser(_ bucekt: String)
}

class MessageUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, VideoPlayerDelegate {
    
    var userToSend: GTLUserUser!
    
    //This is the array of signedURLS of all of the videos from that person
    var videoURLs = [String]()
    
    //This will hold the object names of the videos that have been sent. We are creating this array so we can delete the videos once the user watches it
    var objectNames = [String]()
    
    //Delegate to reload the table
    weak var delegate :MatchesReloadDelegate?
    
    //Camera button
    @IBOutlet weak var cameraButton: UIButton!
    
    
    //Table View to hold all of the videos that have not been seen yet
    @IBOutlet weak var tableView: UITableView!
    
    //Name label
    @IBOutlet weak var nameLabel: UILabel!

    //The menu button
    @IBOutlet weak var menuButton: UIButton!
    
    //The back button
    @IBOutlet weak var backButton: UIButton!
    
    //The menu button action
    @IBAction func menuButtonAction(_ sender: AnyObject) {
    }
    
    //The back button action
    @IBAction func backButtonAction(_ sender: AnyObject) {
        //Delegate should reload mathes table view when the view is dismissed
        //TODO: Dismiss with the persons gif playing
        delegate?.reloadTableData()
        
        let transition: CATransition = CATransition()
        transition.duration = 0.2
        
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        //Change this
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: { _ in })
    }

    
    //Image for menu
    var menuImage = UIImage(named: "MenuButton")
    
    //Image for back button
    var backButtonImage = UIImage(named: "BackButton")
    
    //Image for sent video
    var sentVideoImage = UIImage(named: "Sent")
    
    //Image for receieved video
    var receivedImage = UIImage(named: "Received")
    
    //Image for video you received that was opened
    var openedReceivedImage = UIImage(named: "OpenedReceived")
    
    //Image for a video that you sent that was opened
    var openedSentImage = UIImage(named: "OpenedSent")
    
    //Cameraa button image
    var cameraButtonImage = UIImage(named: "CameraButton")
    
    //Array of Booleans to keep track which video have been watched
    var wasWatched = [Bool]()
    
    //Url to be passed in
    var playUrlToPass = String()
    
    //ObjectName to be passed in
    var objectNameToPass = String()
    
    //Edge screen recognizer
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    var currentRadius:CGFloat = 0.0
    
    //Image view for the background image
    @IBOutlet weak var backGroundImageView: UIImageView!
    
    //Gif image view, if no videos have been sent between you two then the iamge view will show
    @IBOutlet weak var gifImageView: UIImageView!
    
    //Array of images to pass in if the user decides to chat with them now
    var imageArray = [UIImage]()
    
    //This will be true if the view was initialized from the match screen
    var fromMatchScreen = Bool()
    
    /*--------------------------------------------------------*/
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.gifImageView.layer.cornerRadius = self.gifImageView.frame.size.width/2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set the first image to the image of the background
        if (fromMatchScreen){
        }
        
        //Animate the gif with the images that were passed in
        if ( self.imageArray.isEmpty){
            //Add a place holder to the gif
            print("The imagearray was nil and not passed in")
        }
        else{
            //Add the background Image
            self.backGroundImageView.image = imageArray[0]
            self.backGroundImageView.contentMode = .scaleAspectFill
            
            //Blurr the image
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width + 10, height: self.view.frame.size.height + 10)
            self.backGroundImageView.addSubview(blurEffectView)
        
            
            //Animate the gif
            self.gifImageView.contentMode = .scaleAspectFill
            self.gifImageView.animationImages = self.imageArray
            self.gifImageView.animationDuration = 1.0
            self.gifImageView.startAnimating()
            self.gifImageView.clipsToBounds = true
        }
        
        //Configue camera button
        cameraButton.setImage(cameraButtonImage, for: UIControlState())
        
        //Set the menu button
        menuButton.setImage(menuImage, for: UIControlState())
        
        //Set the back button
        backButton.setImage(backButtonImage, for: UIControlState())
        
        //Set the name of the user
        nameLabel.textColor = UIColor.white
        nameLabel.text = userToSend.firstName
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        
        //This method returns the signed urls of all the videos that the user has sent the user using the app
        //In this method we should update the UI that the video has been loaded, even though it hasnt, we just grabbed the url
        loadVideo(userToSend.userBucket)
        
        self.tableView.isHidden = true
        tableView.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //This function will start playing the video
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("The video should start playing")
        
        self.playUrlToPass = self.videoURLs[indexPath.row]
        self.objectNameToPass = self.objectNames[indexPath.row]
        
        //Presents the view controller that wil play the video
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "VideoPlayer", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if videoURLs.isEmpty{
            return 0
        }
        else{
            return (videoURLs.count)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! VideoMessageTableViewCell
        
        //Check if the video has been watched or not
        if self.wasWatched[indexPath.row] == false{
            //If the video has not been watched yet, set accordingly
            
            //Set image to received
            cell.imageView?.image = receivedImage
            
            //Set status label to 
            cell.statusLabel.text = "NEW MESSAGE"
            
            //Set time stamp
            
        }
        else{
            //Since this video has been watched set accodingly
            cell.imageView?.image = openedSentImage
            
            //Set status label to opened
            cell.statusLabel.text = "OPENED"
 
            //Set time stamp
            
            
            //Make sure they can't watch the video again
            cell.isUserInteractionEnabled = false
            
        }
        
        
        return cell
    }
    
    func reloadTable(_ objectName: String){
        var int = 0
        var count = 0
        
        //Check which index this object name is at in the object array, then set that same index of the bool to true
        for i in self.objectNames{
            if i == objectName{
                int = count
            }
            count+=1
        }
        
        //Set the array of bools to true with this index
        self.wasWatched[int] = true
        
        //Reload table
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "VideoPlayer" {
            let vc : VideoPlayerViewController = segue.destination as! VideoPlayerViewController
            vc.playUrl = self.playUrlToPass
            vc.objectName = self.objectNameToPass
            vc.delegate = self
        }
    }


    @IBAction func presentCamera(_ sender: AnyObject) {
        let vc = CameraViewController<AnyObject>()
        vc.userToSend = userToSend
        self.present(vc, animated: true, completion: nil)
    }
    
    func loadVideo(_ bucket: String){
        var selfBucket = SessionManager.sharedInstance.user?.userBucket
        if selfBucket == nil {
            selfBucket = DAO.getBucketNameForLoggedInUser()
        }
        let url = "https://final-questor-app.appspot.com/messages"
        let params = ["bucketname" : bucket, "selfBucket": selfBucket!]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            //API returns an array of all the users that have sent you a video
            if let result = response.result.value{
                let JSON = result as! NSDictionary
                
                //Add returned video urls to arrays
                self.videoURLs = JSON.value(forKey: "signedURLS") as! [String]
                self.objectNames = JSON.value(forKey: "objectNames")! as! [String]
                
                if self.videoURLs.isEmpty{
                    //If they have no videos hide the table view and show their gif
                    self.tableView.isHidden = true
                   
                }
                else{
                    //Show the table view so that they can watch video
                    self.tableView.isHidden = false
                     print("They have videos to watch, and this is the :", self.videoURLs)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    for i in self.objectNames{
                        self.wasWatched.append(false)
                    }
                }
                
            }
        }
    }

    
    @IBAction func menuButton(_ sender: AnyObject) {
        
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: true)
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Unmatch " + userToSend.firstName) {
            self.unmatchUser()
        }
        
        alert.addButton("Report " + userToSend.firstName){
            self.reportUser()
        }
        
        alert.addButton("Block " + userToSend.firstName){
            self.blockUSer()
        }
        
        let icon = UIImage(named:"CameraPopup")
        let color = UIColor.orange
        
        alert.showCustom("Menu", subTitle: "", color: color, icon: icon!)
        
    }
    
    func unmatchUser(){
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Yes!"){
            DAO.unmatchUser(self.userToSend)
            self.delegate!.unmatchUser(self.userToSend.userBucket)
            self.delegate?.reloadTableData()
            
            let transition: CATransition = CATransition()
            transition.duration = 0.2
            
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionPush
            //Change this
            transition.subtype = kCATransitionFromRight
            self.view.window!.layer.add(transition, forKey: nil)
            self.dismiss(animated: false, completion: { _ in })
            
        }
        
        alert.addButton("NO"){
            
        }
        
        let icon = UIImage(named:"CameraPopup")
        let color = UIColor.orange
        
        alert.showCustom("Wait", subTitle: "Are you sure you want to unmatch this user?", color: color, icon: icon!)
        
    }
    
    func reportUser(){
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Yes!"){
            let alert = SCLAlertView(appearance: appearance)
            let txt = alert.addTextField("Tell us what happened!")
            alert.addButton("Send") {
                self.sendReport(txt.text!)
                let alert = SCLAlertView(appearance: appearance)

                alert.addButton("OK") {
                    
                }
                let icon = UIImage(named:"CameraPopup")
                let color = UIColor.orange
            
                
                alert.showCustom("GOT IT!", subTitle: "We will remove this user within 24 hours!", color: color, icon: icon!)
            }
            let icon = UIImage(named:"CameraPopup")
            let color = UIColor.orange
            
            alert.showCustom("Report", subTitle: "Please provide what happened in detail. There is no word limit!" , color: color, icon: icon!)
        }
        
        alert.addButton("No"){
            
        }
        
        let icon = UIImage(named:"CameraPopup")
        let color = UIColor.orange
        
        alert.showCustom("Wait", subTitle: "Are you sure you want to report this user?", color: color, icon: icon!)//
    }
    
    func blockUSer(){
        
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Yes!"){
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("OK") {
                DAO.unmatchUser(self.userToSend)
                self.delegate!.unmatchUser(self.userToSend.userBucket)
                self.delegate?.reloadTableData()
                
                let transition: CATransition = CATransition()
                transition.duration = 0.2
                
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionPush
                //Change this
                transition.subtype = kCATransitionFromRight
                self.view.window!.layer.add(transition, forKey: nil)
                self.dismiss(animated: false, completion: { _ in })

                
            }
            let icon = UIImage(named:"CameraPopup")
            let color = UIColor.orange
            
            
            alert.showCustom("GOT IT!", subTitle: "This user has been blocked and removed from your matches and can no longer message you!", color: color, icon: icon!)
            
            
        }
        
        alert.addButton("NO"){
            
        }
        
        let icon = UIImage(named:"CameraPopup")
        let color = UIColor.orange
        
        alert.showCustom("Wait", subTitle: "Are you sure you want block this user?", color: color, icon: icon!)
        
        
        
    }
    
    func sendReport(_ content: String){
        var selfBucket = SessionManager.sharedInstance.user?.userBucket
        if selfBucket == nil {
            selfBucket = DAO.getBucketNameForLoggedInUser()
        }
        let url = "https://final-questor-app.appspot.com/report"

        let params = ["bucketToReport" : userToSend!.userBucket!, "selfBucket": selfBucket!, "content" : content]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //Do nothing
        }

    }
    
}

