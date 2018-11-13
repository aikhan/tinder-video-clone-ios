//
//  CardsViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 6/16/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
import Alamofire
import Pulsator
import SCLAlertView




//This View controller has recieved a lot of work! The back in queries all of the users according to the users specification. It queries all of the users that are within its specified location, with the gender that they are looking for, and only the ones that they have not come across yet. Then it returns and aray of all of those user's unique bucket names to be queried one at a time. Considering these are videos, we might want to query them 3 at a time or more so there is no buffer time or time to wait. Maybe have multiple player instaniated then when you like or skip, you go to the next player and then we query another user.

//Will implement a true false variable in real time that will query users on the basis of if they are looking to date or if the are just looking for freinds, dating = true false

protocol ScrollViewChangeDelegate {
    func changeOffset(_ direction: String)
    func changeScrollViewToMain()
}

protocol MessageUserFromMatchDelegate :class{
    func presentMessage(_ user: GTLUserUser)
    func reloadTableData()
}


class CardsViewController: UIViewController, PlayerDelegate, pausePlayerDelegate, MessageUserDelegate, NotificationDelegate, PlayerFromMatchDelegate{
    
    var player: Player!
    var playUrl:String!
    
    var player2: Player!
    var playerUrl2: String!
    
    /*DELEGATE METHODS*/
    
    func didTapMessageUser(_ user: GTLUserUser) {
        
        delegate!.changeOffset("Left")
        delegateMessageUser?.presentMessage(user)
    }
    
    func notifyUserOfMessage(){
        self.messagesButtonImage = UIImage(named: "Notification")
        // self.viewDidLoad()
        print("The delegate was called, the message button should have changed")
    }
    
    func printSome(){
        print("This should work")
    }
    
    func playerPlay(){
        self.player.playFromBeginning()
        print("Player Should have started playing")
    }
    
    func reloadMatches(){
        delegateMessageUser?.reloadTableData()
        print("The table view was reloaded")
    }
    
    
    
    fileprivate struct HeartAttributes {
        static let heartSize: CGFloat = 36
        static let burstDelay: TimeInterval = 0.1
    }
    
    var burstTimer: Timer?
    
    
    var namelabel :UILabel = UILabel.init()
    var ageAndLocationLabel :UILabel = UILabel.init()
    var distanceLabel :UILabel = UILabel.init()
    var myFirstButton :UIButton!
    
    //Will tell CloudDAO whether they are dating or looking for friends, default dating
    var dating = true
    
    //If the view was loaded from login, then load pictures
    var login = Bool()
    
    //This will hold the match user object to send to the match popover screen
    var matchedUser: GTLUserUser?
    
    //This will hold all of the user objects and all of their information
    var unviewedUsers = [GTLUserUser]()
    
    //This is to hold the name of the bucket so they can save, like, or skip
    var bucketToSave: String!
    
    //This variable will keep track of the tap counts, we will use it to fetch next elements from the array to display on the view.
    
    var mbHud :MBProgressHUD!
    
    //This is a check to see if last user was just liked or disliked
    var lastUser = Bool()
    
    //This array will be an array of signed URLs of all of the user's profile videos
    var userProfileURLs = [String]()
    
    //This variable will be true if the user that you see has already liked you and false if not.
    var isMatchIfLiked = Bool()
    
    //Outlet to the messages button so we can show that they have a notification
    @IBOutlet weak var messagesButton: UIButton!
    
    //Profile Button
    @IBOutlet weak var profileButton: UIButton!
    
    //Image for message button
    var messagesButtonImage = UIImage(named: "Messages")
    
    //Image for profile button
    var profilebuttonImage = UIImage(named: "Profile")
    
    //Image for White snapchat icon
    var whiteSnapchatImage = UIImage(named: "WhiteSnapchat")
    
    //Image for white instagram icon
    var whiteInstagramImage = UIImage(named: "WhiteInstagram")
    
    //Image for colored Snapchat icon
    var coloredSnapchatImage = UIImage(named: "ColoredSnapchat")
    
    //Image for colored instagram icon
    var coloreInstagramImage = UIImage(named: "ColoredInstagram")
    
    //Image for colored appstore icon
    var coloredAppStoreImage = UIImage(named: "ColoredAppStoreLogo")
    
    //Image for white appstore logo
    var whiteAppStoreImage = UIImage(named: "AppStoreLogo")
    
    //Instgram button
    var instagramButton: UIButton!
    
    //Snapchat Button
    var snapchatButton: UIButton!
    
    //Appstore review button
    var appStoreButton: UIButton!
    
    //Delegate
    var delegate : ScrollViewChangeDelegate? = nil
    
    //Delegate to present user messages from pop up
    weak var delegateMessageUser :MessageUserFromMatchDelegate?
    
    
    //This is the navigation bar, bring in front of the video view,
    @IBOutlet weak var navigationBarView: UIView!
    
    
    var visable = true
    
    @IBOutlet weak var gifImageView: UIImageView!
    
    var endOfqueue = Bool()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        visable = true
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visable = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if endOfqueue == false{
            //Initialize players
            self.player = Player()
            self.player.delegate = self
            
            self.player2 = Player()
            self.player2.delegate = self
        }
        
        
        SessionManager.sharedInstance.parkedViewController = self
        
        //Congfigure messages button and profile button
        messagesButton.setImage(messagesButtonImage, for: UIControlState())
        profileButton.setImage(profilebuttonImage, for: UIControlState())
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(userDataLoaded), name: NSNotification.Name(rawValue: "UserDataDownloaded"), object: nil)
        
        //If this is the first time someone opens the app check to see if the player is playing, if it is, pasue it, and give instructions on how to use the app
        firstTimeUser()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Add the pulsator behind the gif profile image
        addPulsator()
        
        //Add social media buttons because there are no users in your area
        addNoUsersLabels()
        
        if login == true{
            downloadForLogin()
            login = false
        }
        
        if self.player.playbackState == .paused{
            self.player.playFromBeginning()
        }
        
        loadProfileGifs()

    }
    
    func userDataLoaded() {
        DispatchQueue.main.async(execute: {
            self.getNextUserNew()
            //  self.mbHud.hideAnimated(true)
        })
    }

    
    func wasSkipped(){
        print("was Skipped")
        if self.bucketToSave != nil {
            DAO.userHasBeenSkippedWithBucketName(self.bucketToSave)
        }
        //self.skippedAnimation()
        
        if self.lastUser == true{
            //Don't get the next user
            //self.player = nil
            hideUpInfoOnView()
        }
        else{
            //TODO: Dont get next user if it is the last one
            self.getNextUserNew()
        }
    }
    
    func wasDoubleTapped(){
        print("was double tapped")
        //If the person has been liked then insert them to core data
        DAO.insertUser(self.matchedUser!)
        
        //Save to the nsuserdefaults that the user has a match
        UserDefaults.standard.set(true, forKey: "hasMatches")
        
        if self.bucketToSave != nil {
            if isMatchIfLiked == true{
                //If the user has already liked you and you like them as well, the UI should update, stop paying the video, show the pop over, and add each other to both matched arrays in cloud and in coredata
                
                //stop playing the video and present a pop up
                //self.player.stop()
                
                //Present match pop up
                let popUpVc: MatchPopUPViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MatchPopUp") as! MatchPopUPViewController
                popUpVc.matchedUser = self.matchedUser
                popUpVc.delegate = self
                popUpVc.playerDelegate = self
                self.present(popUpVc, animated: false, completion: nil)
                
                //Save this user in the matches
                DAO.userHasBeenLikedWithBucketName(self.bucketToSave, match: true)
                print("Congratulations! You have a new match!")
            }
            else{
                DAO.userHasBeenLikedWithBucketName(self.bucketToSave, match: false)
                
                //print every one that is in the users like array
                let user = CoreDataDAO.getLoggedInUserInfo()!
                print("core data liked array ==" , user.likedArray!)
                CoreDataDAO.insertUser(self.matchedUser!)
                print("These are the users, "  )
                let users = CoreDataDAO.getAllUsers()
                print(users!)
            }
        }
        if self.lastUser == true && self.player != nil{
            //Do not get the next user
            //Stop the player and set it to nil
            //self.player = nil
            hideUpInfoOnView()
        }
        else{
            self.getNextUserNew()
        }
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This function will get the users from the prepopulated array in CloudDAO
    func getNextUserNew(){
        if (SessionManager.sharedInstance.userQueue.isEmpty()){
            //Since there are no more users, tell them, then tell them to add us on instagram
            //addNoUsersLabel()
            print("There are no more users in your area")
            
            //Just make the video nil so that the card view will show the gif
            print("Remove the video player view and make the player nil")
            if myFirstButton != nil{
                hideUpInfoOnView()
            }
            return
        }
        
        if let user = SessionManager.sharedInstance.userQueue.dequeue(){
            
            
            //If this is the last user, set the last user to true so when tapped or double tapped it will not call getNextUser
            if (SessionManager.sharedInstance.userQueue.isEmpty()){
                self.lastUser = true
                endOfqueue = true
            }
            
            self.bucketToSave = user.userBucket
            
            //Save this : so if the match the user can be passed into the match pop
            self.matchedUser = user
            
            //Download all of their images so that if you guys match, the pop over will be able to play their gif in that image view
            self.downloadImagesForMatch(user.profileGif as! [String], match: true, bucketName: "", completionHandler: { (UIBackgroundFetchResult) in
                //Do something here useful
            })
            
            //If this user has liked you then set isMatchedIfLiked to true, so if the user is double tapped then the match popup comes up and the user is put in both the users matched array
            if user.likedYou == "True"{
                isMatchIfLiked = true
            }
            
            //This may be the reason it is not going full screen in the view
            self.player.view.frame = self.view.bounds
            
            //Sets the video player to full screen
            self.player.fillMode = AVLayerVideoGravityResize
            
            self.addChildViewController(self.player)
            self.view.addSubview(self.player.view)
            self.player.didMove(toParentViewController: self)
            
            //TODO: Put an if else statement on this to check if the user even has any profile videos
            let videoUrl: URL = URL(string: user.profileVideoUrls[0] as! String)!
            self.player.setUrl(videoUrl)
            
            
            //Only start the player if the view is visable,
            if (visable){
                
                //Check if the screen is on the main
                
                self.player.playFromBeginning()
                self.player.playbackLoops = true
            }
            setUpInfoOnView(user)
        }else{
            DispatchQueue.main.async(execute: {
                let alert = UIAlertController(title: "Error", message: "Sorry no matches available this time", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            })
            
        }
    }
    func hideUpInfoOnView(){
        myFirstButton.isHidden = true
        namelabel.isHidden = true
        ageAndLocationLabel.isHidden = true
        distanceLabel.isHidden = true
        
        //self.player.stop()
        if self.player != nil{
            self.player.view.removeFromSuperview()}
        self.player.setUrl(URL(string: "")!)
        
        //Turn off the gestures
        turnOffGestures()
        
        
    }
    
    func pressed(_ sender: UIButton!) {
        
        self.player.pause()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "userProfile") as! UserProfileViewController
        vc.profileUser = self.matchedUser
        self.present(vc, animated: true, completion: nil)
        
    }
    func setUpInfoOnView(_ user :GTLUserUser) {
        if self.player.playbackState != .playing{
            //Do not ad these values to the screen
        }
        else{
            //create the name label and add it as a subview
            //TODO:change this to a button so that when they press it, their profile comes up
            
            namelabel.frame = CGRect(x: 25, y: self.view.bounds.height * (9/10) - 75, width: 200, height: 100)
            namelabel.text = user.firstName
            namelabel.textColor = UIColor.white
            namelabel.font = UIFont(name: "Arial-BoldMT", size: 20)
            namelabel.isHidden = false
            self.view.addSubview(namelabel)
            
            
            
            //The age and location label
            ageAndLocationLabel.frame = CGRect(x: 25, y: self.view.bounds.height * (9/10) - 50, width: 200, height: 100)
            ageAndLocationLabel.text = String(describing: user.age) + ", " + user.userLocation
            ageAndLocationLabel.textColor = UIColor.orange
            ageAndLocationLabel.font = UIFont(name: "ArialHebrew-Light ", size: 14)
            ageAndLocationLabel.isHidden = false
            self.view.addSubview(ageAndLocationLabel)
            
            //The the distance away label
            distanceLabel.frame = CGRect(x: self.view.bounds.width - 125, y: self.view.bounds.height * (9/10) - 75, width: 200, height: 150)
            var distanceText = String()
            distanceLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            distanceLabel.numberOfLines = 2
            distanceLabel.isHidden = false
            if user.distanceAway == 0{
                distanceText = "Less than\n1 mile away"
            }else if user.distanceAway == 1{
                distanceText = String(describing: user.distanceAway) + " mile\n away "
            }
            else{
                distanceText = String(describing: user.distanceAway) + " miles\n away "
            }
            distanceLabel.text = distanceText
            distanceLabel.textColor = UIColor.white
            distanceLabel.font = UIFont(name: "ArialHebrew-Light ", size: 14)
            self.view.addSubview(distanceLabel)
        }
        
        myFirstButton = UIButton()
        myFirstButton.setTitle("", for: UIControlState())
        myFirstButton.setTitleColor(UIColor.blue, for: UIControlState())
        myFirstButton.frame = CGRect(x: namelabel.frame.origin.x , y: namelabel.frame.origin.y, width: ageAndLocationLabel.frame.size.width, height: ageAndLocationLabel.frame.size.height + namelabel.frame.size.width)
        myFirstButton.addTarget(self, action: #selector(CardsViewController.pressed(_:)), for: .touchUpInside)
        self.view.addSubview(myFirstButton)
        
        
    }
    func checkPlayer() -> Bool{
        if self.player == nil{
            return false
        }
        else{
            return true
        }
        
    }
    
    func playVideo(){
        //Check the player is not nil
        if self.player != nil{
            if self.player.playbackState == .paused{
                
                //Play the video
                self.player.playFromBeginning()
            }
        }
    }
    
    func pausePlayer(){
        self.player.pause()
        print("Player was paused")
    }
    
    func isPlaying() -> Bool{
        if self.player.playbackState == .playing{
            return true
        }
        else{
            return false
        }
    }
    
    func swithPlayers(){
        //Check to see which player is currently playing
        
        //If 1 is playing, then remove from view, add player 2 and begin playing, just set the url for the player1 to ""
        if self.player.playbackState == .playing{
            //Set the url to blank string
            self.player.setUrl(URL(string: "")!)
            
            //Remove player from view
            self.player.view.removeFromSuperview()
            
            //The url should already be set for the second
        }
        
    }
    
    
    func getProfileVideoURLs(_ bucket: String, completionHandler: ((UIBackgroundFetchResult) -> Void)!){
        
        //Swift 3.0
        let params = ["bucketname" : bucket]
        let url = "https://final-questor-app.appspot.com/getProfileURLS"
        Alamofire.request(url, method: .get, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            print(response)
            
            //get status code
            if let status = response.response?.statusCode{
                switch(status){
                case 201:
                    print("example success")
                default:
                    print("error with response status: \(status)")
                }
            }
            
            //get the json return value
            if let result = response.result.value{
                let JSON = result as! NSDictionary
                self.userProfileURLs = (JSON.value(forKey: "signedURLS") as? [String])!
                if JSON.value(forKey: "signedURLS") == nil {
                    print("The user does not have any profile videos")
                }
            }
        }
    
        
        /* This was the Swift 2, AFNetworking way
        manager.GET(url, parameters: params, progress: nil, success: { (s:URLSessionDataTask, response) in
            //var array = response?.valueForKey("signedURLS")! as! [String]
            self.userProfileURLs = (response?.valueForKey("signedURLS"))! as? [String]
            for url in self.userProfileURLs!{
                print(url)
            }
            if response?.valueForKey("signedURLS") == nil{
                print("The user does not have any profile videos")
            }
            completionHandler(UIBackgroundFetchResult.NewData)
            
        }) { (s: URLSessionDataTask?, e:NSError?) in
            print(e)
        }
 */
    }
    
    @IBAction func messageAction(_ sender: AnyObject) {
        delegate!.changeOffset("Left")
        
    }
    
    @IBAction func profileAction(_ sender: AnyObject) {
        delegate!.changeOffset("Right")
    }
    
    
    // MARK: Player Delegete
    func playerReady(_ player: Player){
        
    }
    func playerPlaybackStateDidChange(_ player: Player){
        
    }
    func playerBufferingStateDidChange(_ player: Player){
        
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player){
        setUpInfoOnView(self.matchedUser!)
        
        //If this is the first time someone has downloaded the app and there are people already playing then mute the video instead of stopping it
        if (UserDefaults.standard.object(forKey: "firstUser") == nil){
            self.player.muted = true
        }
        
        
        //Add the navigation bar ontop of this view will all of the constraints
        self.view.addSubview(self.navigationBarView)
        
        turnOnGestures()
        
    }
    
    func playerPlaybackDidEnd(_ player: Player){
        hideUpInfoOnView()
        
    }
    
    func turnOffGestures(){
        if view.gestureRecognizers != nil {
            for gesture in view.gestureRecognizers! {
                if let recognizer = gesture as? UISwipeGestureRecognizer {
                    view.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
    
    func turnOnGestures(){
        //Add tap gesture recognizers
        let tap = UITapGestureRecognizer(target: self, action: #selector(wasSkipped))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(wasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
        
        self.view.isUserInteractionEnabled = true
        
        tap.require(toFail: doubleTap)
        
        
        Constants.tapCount += 1
    }
    
    func downloadForLogin(){
        print("Downloaded called")
        //Download the gif pictures into the file system
        if let profileGifs = SessionManager.sharedInstance.user?.profileGif {
            self.downloadImagesForMatch(profileGifs as! [String], match: false, bucketName: "") { (UIBackgroundFetchResult) in
                print("completion")
                var selfBucket = SessionManager.sharedInstance.user?.userBucket
                if selfBucket == nil {
                    selfBucket = DAO.getBucketNameForLoggedInUser()
                }
                let gifArrayWithBucketName = "gifPhotosfor"
                
                if let array = UserDefaults.standard.object(forKey: gifArrayWithBucketName) {
                    
                    print("The array is " + String(gifArrayWithBucketName))
                    //Set the users gif to the main screen
                    let imageArray = self.loadGIFPicturesFromFileSystem(array as! [String])
                    self.gifImageView.layer.cornerRadius = self.gifImageView.frame.size.width / 2;
                    self.gifImageView.contentMode = .scaleAspectFill
                    self.gifImageView.animationImages = imageArray
                    self.gifImageView.animationDuration = 1.0
                    self.gifImageView.startAnimating()
                    self.gifImageView.clipsToBounds = true
                }
                else{
                    print("++++++++++++")
                    
                }
                
            }
            
        }
    }
    
    func firstTimeUser(){
        if (UserDefaults.standard.object(forKey: "firstUser") == nil){
            if self.player != nil{
                self.player.pause()
            }
            //Show them all the directions to go through
            print("This is a first time user")
            
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            
            //Present first pop up
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("Awesome 😃") {
                //Present second pop up
                let alert = SCLAlertView(appearance: appearance)
                alert.addButton("Gotcha 😜") {
                    let alert = SCLAlertView(appearance: appearance)
                    alert.addButton("Will Do! 😃") {
                        UserDefaults.standard.set(false, forKey: "firstUser")
                        //If the player is not nil and it is playing muted, then unmute it
                        if self.player != nil{
                            if self.player.playbackState == .playing{
                                if self.player.muted == true{
                                    self.player.muted = false
                                }
                            }
                        }
                    }
                    
                    let icon = UIImage(named:"CameraPopup")
                    let color = UIColor.orange
                    
                    alert.showCustom("Community! 🎉", subTitle: "1.Be Yourself! 😊\n2. Keep the TRU community fun and safe!\n3. Tell all your friends about this amazing new app so you can increase your chances of meeting someone!\n4. HAVE FUN! 😉 ", color: color, icon: icon!)
                }
                
                let icon = UIImage(named:"CameraPopup")
                let color = UIColor.orange
                
                alert.showCustom("Navigation", subTitle: "1. You will be shown videos of people in your area matching your preferences.\n2.If you like that person simply double tap the screen.\n3.If you would like to see the next person then simply tap the screen once. \n4.If you would like to see more videos from that user, press their name!", color: color, icon: icon!)
            }
            
            let icon = UIImage(named:"CameraPopup")
            let color = UIColor.orange
            
            alert.showCustom("Congratulations! 🎉", subTitle: "You are now on your way to meeting new and exciting people in your area in a new and exciting way!", color: color, icon: icon!)
            
        }
    }
    
    func addPulsator(){
        let pulsator = Pulsator()
        let mainFrame = UIScreen.main.bounds
        let y = (mainFrame.height/2)-(pulsator.frame.size.height/2)
        let x = (mainFrame.width/2)-(pulsator.frame.size.width/2)
        pulsator.position = CGPoint(x: x, y: y)
        pulsator.backgroundColor = UIColor(red: 247.0/255, green: 148/255, blue:30/255, alpha:1.0).cgColor
        
        self.view.layer.addSublayer(pulsator)
        self.view.bringSubview(toFront: self.gifImageView)
        
        pulsator.radius = 200.0
        pulsator.start()
    }
    
    /*When Query returns from server with no users, then add labels with social media buttons*/
    func addNoUsersLabels(){
        
        
        //Set up button frames
        let x = self.view.frame.size.width
        let y = self.view.frame.size.height
        
        //Set the buttons to be 1/5 the size of the frame
        let frameWidHgt = x/6
        
        let fromLeft = x/6
        let fromRight = x - frameWidHgt - x/6
        let fromBottom = y - 50 - x/6
        
        //Set frame for buttons
        let leftFrame = CGRect(x: fromLeft, y: fromBottom, width: frameWidHgt, height: frameWidHgt)
        let rightFrame = CGRect(x: fromRight, y: fromBottom, width: frameWidHgt, height: frameWidHgt)
        let middleFrame = CGRect(x: x/2 - frameWidHgt/2, y: fromBottom, width: frameWidHgt, height: frameWidHgt)

        //Set up buttons
        instagramButton = UIButton(frame: rightFrame)
        snapchatButton = UIButton(frame: middleFrame)
        appStoreButton = UIButton(frame: leftFrame)

        //Set image to buttons
        instagramButton.setImage(coloreInstagramImage, for: UIControlState())
        snapchatButton.setImage(coloredSnapchatImage, for: UIControlState())
        appStoreButton.setImage(coloredAppStoreImage, for: UIControlState())
        
        //Add function to buttons addTarget(objectWhichHasMethod, action: #selector(classWhichHasMethod.yourMethod), for: someUIControlEvents)
        instagramButton.addTarget(self, action: #selector(CardsViewController.instagram(_:)), for: .touchUpInside)
        snapchatButton.addTarget(self, action: #selector(CardsViewController.snapchat(_:)), for: .touchUpInside)
        appStoreButton.addTarget(self, action: #selector(CardsViewController.appstore(_:)), for: .touchUpInside)
        
        //Add buttons to view
        self.view.addSubview(instagramButton)
        self.view.addSubview(snapchatButton)
        self.view.addSubview(appStoreButton)
        
        //Add label that says "Give us a review and follow us!"
        let reviewHeight = CGFloat(30)
        let reviewFrame = CGRect(x: x/9, y: fromBottom - reviewHeight - 10, width: x*(7/9), height: reviewHeight)
        let reviewLabel = UILabel(frame: reviewFrame)
        reviewLabel.adjustsFontSizeToFitWidth = true
        reviewLabel.text = "Give us a review and follow us!"
        reviewLabel.textAlignment = .center
        self.view.addSubview(reviewLabel)
        
        
        //Add label that says "There are no users in your area"
        let noUserHeight = CGFloat(30)
        let noUserFrame = CGRect(x: x/9, y: 66 + 40, width: x*(7/9), height: noUserHeight)
        let noUsersLabel = UILabel(frame: noUserFrame)
        noUsersLabel.adjustsFontSizeToFitWidth = true
        noUsersLabel.text = "There are no users in you area."
        noUsersLabel.textAlignment = .center
        self.view.addSubview(noUsersLabel)
        
    }
    
    func loadProfileGifs(){
        
        var selfBucket = SessionManager.sharedInstance.user?.userBucket
        if selfBucket == nil {
            selfBucket = DAO.getBucketNameForLoggedInUser()
        }
        let gifArrayWithBucketName = "gifPhotosfor"
        
        if let array = UserDefaults.standard.object(forKey: gifArrayWithBucketName) {
            
            print("The array is " + String(gifArrayWithBucketName))
            //Set the users gif to the main screen
            let imageArray = self.loadGIFPicturesFromFileSystem(array as! [String])
            self.gifImageView.layer.cornerRadius = self.gifImageView.frame.size.width / 2;
            self.gifImageView.contentMode = .scaleAspectFill
            self.gifImageView.animationImages = imageArray
            self.gifImageView.animationDuration = 1.0
            self.gifImageView.startAnimating()
            self.gifImageView.clipsToBounds = true
        }
        else{
            print("The profile gif was not loaded because the array for the profile paths were not found or somehow the user got around not uploading gif pictures")
            
        }
    }
    
    func instagram(_ sender: UIButton!) {
        
        print("instagram was tapped")
    
        let instagramURL = URL(string: "https://www.instagram.com/oauth/authorize/?client_id=251646d8c4964babab495e2a1afbb046&redirect_uri=http://com.HumpTrump.TruDating&response_type=code")!
        if UIApplication.shared.canOpenURL(instagramURL) {
            UIApplication.shared.openURL(instagramURL)
        }
        else{
            //Tell the user that there was a problem opening up instagram
        }

    }
    
    func snapchat(_ sender: UIButton!) {
        
        print("snapchat was tapped")
        let instagramURL = URL(string: "snapchat://add/trudating")!
        if UIApplication.shared.canOpenURL(instagramURL) {
            UIApplication.shared.openURL(instagramURL)
        }
        else{
            //Tell the user that there was a problem opening up snapchat
        }
        
    }
    
    func appstore(_ sender: UIButton!) {
        //1140017112
        print("appstore was tapped")
        let instagramURL = URL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1140017112&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8")
        if UIApplication.shared.canOpenURL(instagramURL!) {
            UIApplication.shared.openURL(instagramURL!)
        }
        else{
            //Tell the user that there was a problem opening up appstore
        }
        
    }
    
    
    
    
}
