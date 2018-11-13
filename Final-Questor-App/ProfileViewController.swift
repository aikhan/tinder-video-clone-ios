//
//  ProfileViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 6/16/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
import Alamofire
import AVKit
import AVFoundation
import SCLAlertView
import Alamofire
import SwiftForms


class ProfileViewController: UIViewController, UIScrollViewDelegate, PlayerDelegate, ReloadProfileView{

    
    var player : Player!
    var delegateScroll: ScrollViewChangeDelegate? = nil
    
    @IBOutlet weak var backButton: UIButton!
    var login = Bool()
    var loginVideo = Bool()
    
    //Page Control
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageTopContraint: NSLayoutConstraint!
    @IBOutlet weak var pageLeadingConstriant: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
  
    @IBOutlet weak var bioTextConstriant: NSLayoutConstraint!
    @IBOutlet weak var videoButtonConstraint: NSLayoutConstraint!
    
    
    @IBAction func backButtonAction(_ sender: AnyObject) {
        delegateScroll?.changeScrollViewToMain()
    }

    @IBAction func testBack(_ sender: AnyObject) {
        if let userProfile = storyboard!.instantiateViewController(withIdentifier: "userProfile") as? UserProfileViewController {
            self.present(userProfile, animated: false, completion: nil)
        }
    }
    
    func reload(){
        print("Profile Relaoded")
        self.viewDidLoad()
        
    }
    
    //TODO: Check how many profile videos that person has in their bucket
    //You would initialize that scroll view with that  number of videos
    @IBOutlet weak var playerView: UIView!
    
    //Logo button image
    var logoButtonImage = UIImage(named: "navlogo")
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var agePlusLocationLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var testImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var scrollViewTest: UIScrollView!
    @IBOutlet weak var settingsButton: UIButton!
    
    var counter :CGFloat = 0.0
    
     let user :GTLUserUser = SessionManager.sharedInstance.user!
    
    var imagesArray: [UIImage]? = nil
    var itemAtIndexsToBeRemoved = [Int]()
    
    var isDeleting = false
    enum AppError: Error {
        case invalidResource(name :String, type :String)
        case generalFailure
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("VIewill appear in profile view")
        

    
    }
    //TODO: decide if the corners will be round like bumble or full screen like snapchat. Put it inside scroll view if they have more than one video
    @IBAction func uploadVideoAction(_ sender: AnyObject) {
        if UserDefaults.standard.integer(forKey: "profileVideoCount") == 3{
            //Show pop up saying that they can not upload naymore videos until they delete some
            
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("Got it!") {
                
            }
            
            let icon = UIImage(named:"CameraPopup")
            let color = UIColor.orange
            
            alert.showCustom("3 Videos Max!", subTitle: "You have reached you video limit.\n If you would like to upload another video, first delete one or two of your current videos.", color: color, icon: icon!)
            
            
        }else{
            if let signUpController = storyboard!.instantiateViewController(withIdentifier: "SignUp3") as? CameraViewController<AnyObject> {
                
                signUpController.fromProfile = true
                signUpController.isProfileVideo = true
                //signUpController.delegate = self
                self.present(signUpController, animated: true, completion: nil)
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if login{
            downloadVideoForlogin()
        }
        let user = CoreDataDAO.getLoggedInUserInfo()
        print(user!.firstName)
        nameLabel.text = user!.firstName
        if let location = user!.userLocation{
            agePlusLocationLabel.text = "\(user!.age!.intValue), \(location)"

        }
                if let text = user!.bio {
            bioTextView.text = text
        }
       
        
        scrollViewTest.delegate = self
        imagesArray = imagesFromVideos()
        fillScrollViewWithElemnets()
        configurePageControl()
        
       
        
        //Settings and edit button
        editButton.setImage(UIImage(named: "pencil"), for: UIControlState())
        
        settingsButton.setImage(UIImage(named: "Settings"), for: UIControlState())
        backButton.setImage(UIImage(named:"logoBack"), for: UIControlState())
        print(SessionManager.sharedInstance.deviceType)
        if SessionManager.sharedInstance.deviceType == "iphone4"{
            bioTextConstriant.constant = 35
            videoButtonConstraint.constant = 10
        }

        
        
        
    }
    
    func configurePageControl(){
        //Configure constraints
       // self.pageTopContraint.constant = 66 + scrollViewTest.frame.size.height - 20
        self.pageLeadingConstriant.constant = self.view.frame.size.width/2 - self.pageControl.frame.size.width/2
        
        // The total number of pages that are available is based on how many available colors we have.
        self.pageControl.numberOfPages = (imagesArray?.count)!
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.orange
        self.view.addSubview(pageControl)
    }
    
    func fillScrollViewWithElemnets(){
        
        //imagesArray = imagesFromVideos()
        for image in imagesArray! {
            print("image")
            let myImageView = UIImageView(image: image)
            myImageView.backgroundColor = UIColor.green
            myImageView.frame = CGRect(x: counter * (self.view.frame.width), y: 75, width: self.view.frame.width, height: scrollViewTest.frame.height)
            myImageView.contentMode = UIViewContentMode.scaleAspectFill
            let playButtonOnTop = UIButton(type: UIButtonType.custom) as UIButton
            let image = UIImage(named: "PlayButton") as UIImage? //TODO: Chnage it to the play image
            playButtonOnTop.frame = CGRect(x: myImageView.frame.width/2 - 50, y: myImageView.frame.height/2 - 50, width: 50, height: 50)
            playButtonOnTop.setImage(image, for: UIControlState())
            counter = counter + 1
            playButtonOnTop.tag = Int(counter)
            playButtonOnTop.addTarget(self, action: #selector(playVideoButtonTapped(_:)), for:.touchUpInside)
            myImageView.isUserInteractionEnabled = true
            myImageView.addSubview(playButtonOnTop)
            scrollViewTest.addSubview(myImageView)
            print("counter value is \(counter)")
            
        }
        scrollViewTest.backgroundColor = UIColor.gray
        
        scrollViewTest.isScrollEnabled = true
        scrollViewTest.contentSize = CGSize(width: (self.view.frame.width * CGFloat((imagesArray?.count)!)), height: scrollViewTest.frame.height)
        
        //reset counter value
        counter = 0.0
    }
    
//    func playVideo(sender :UIButton){
//        var tag = sender.tag - 1
//        if let array = NSUserDefaults.standardUserDefaults().arrayForKey("profileVideoUrls"){
//        
//            
//             let pathURL = NSURL(fileURLWithPath: array[Int(tag)] as! String)
//            
//            self.player = Player()
//            self.player.delegate = self
//            self.player.view.frame = self.view.bounds
//            
//            self.addChildViewController(self.player)
//            self.view.addSubview(self.player.view)
//            self.player.didMoveToParentViewController(self)
//            
//            self.player.setUrl(pathURL)
//        
//         self.player.playFromBeginning()
//
//        }
//
//    }
    
    func shakeAnimateView(_ view :UIView){
        let transformAnim  = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values  = [NSValue(caTransform3D: CATransform3DMakeRotation(0.04, 0.0, 0.0, 1.0)),NSValue(caTransform3D: CATransform3DMakeRotation(-0.04 , 0, 0, 1))]
        transformAnim.autoreverses = true
        transformAnim.duration  = 0.105
        transformAnim.repeatCount = Float.infinity
        view.layer.add(transformAnim, forKey: "transform")
    }
    
  

    @IBAction func editButtonTapped(_ sender: AnyObject) {
        print("delete the video")
        var tagCountDeleteButton = 1
        if isDeleting {// This is now DONE button

            isDeleting = false
            let subViews = self.scrollViewTest.subviews
            for subview in subViews{// so that scrollview scroll indicators are not removed.
                if subview.isUserInteractionEnabled {
                    subview.layer.removeAllAnimations()
                    subview.removeFromSuperview()
                    print("Removing subview with tag \(subview.tag)")
                    

                    
                }
                //            }
                //            if !itemAtIndexsToBeRemoved.isEmpty {
                //                for index in itemAtIndexsToBeRemoved{
                //                    print("index for image array to be removed is \(index)")
                //                    imagesArray?.removeAtIndex(index)
                //                }
            }
            
            fillScrollViewWithElemnets()
            if let middleButton = self.view.viewWithTag(tagCountDeleteButton) as? UIButton{
                let image = UIImage(named: "PlayButton") as UIImage?
                middleButton.setImage(image, for: UIControlState())
                tagCountDeleteButton += 1
            }
        }else{

            
            let scrollViewSubViews =  scrollViewTest.subviews
            for view in scrollViewSubViews{
                if view.isKind(of: UIImageView.self) && view.isUserInteractionEnabled{
                    let deleteImage = UIImage(named: "red-delete")
                    
                    if let middleButton = self.view.viewWithTag(tagCountDeleteButton) as? UIButton{
                        middleButton.setImage(deleteImage, for: UIControlState())
                        isDeleting = true
                        shakeAnimateView(view)
                        tagCountDeleteButton += 1
                    }
                }
            }
        }
        
    }
    func playVideoButtonTapped(_ sender :UIButton){

        if isDeleting == true {
            if imagesArray!.count <= 1{
                print("cannot have less than 1 video")
                let alert = UIAlertController(title: "Sorry", message: "cannot have less than 1 video", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            }else{
                let subViews = self.scrollViewTest.subviews
                subViews[sender.tag-1].removeFromSuperview()
                imagesArray?.remove(at: sender.tag-1)
                print("tag value to be reoved is \(sender.tag-1)")
                if let array = UserDefaults.standard.array(forKey: "profileVideoUrls"){
                    deleteVideo(array[sender.tag-1] as! String)
                }
                self.editButtonTapped(self.editButton)
            }
        }else{
            tryPlayingVideo(sender)
        }
        
    }
    func playVideoButtonTapped(){
        print("My precious 1 ")
    }
    func actuallyDeleteTheVideoAndUpdateUI(_ sender :AnyObject){
       print("Deleted the video")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("did end scrolling")
    }
    
    //Hailey is weird af
    
    func imagesFromVideos() ->[UIImage]?{
        
        var videoImagesView :[UIImage] = [UIImage]()
        if let array = UserDefaults.standard.array(forKey: "profileVideoUrls"){
            for i in array{
                
                let pathURL1 = URL(fileURLWithPath: i as! String)
            videoImagesView.append(previewImageForLocalVideo(pathURL1)!)
                
            }
        }
        
        return videoImagesView
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // varpose of any resources that can be recreated.
    }
    
    @IBAction func signOut(_ sender: AnyObject) {
        
        UserDefaults.standard.set(false, forKey: "login") //just in case
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        //Set everything in the session manager to nil
        SessionManager.sharedInstance.isUserLoggedIn = false
        SessionManager.sharedInstance.lat = 0
        SessionManager.sharedInstance.long = 0
        SessionManager.sharedInstance.user = nil
        SessionManager.sharedInstance.usersArray = nil
        SessionManager.sharedInstance.userCity = nil
        SessionManager.sharedInstance.userCountry = nil
        
        
        //Remove all core data when user logs out
        DAO.clearAllLocalDataStore()
        
        
        let StoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let login: UIViewController = StoryBoard.instantiateViewController(withIdentifier: "Login")
        self.navigationController?.popToRootViewController(animated: true)
        self.navigationController?.pushViewController(login, animated: true)
        //self.presentViewController(login, animated: true, completion: nil)
        
        
    }
    
    func previewImageForLocalVideo(_ url:URL) -> UIImage?
    {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        //If possible - take not the first frame (it could be completely black or white on camara's videos)
        time.value = min(time.value, 20)
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    func tryPlayingVideo(_ sender: UIButton){
        do {
            try playVideo(sender)
        } catch AppError.invalidResource(let name, let type) {
            debugPrint("Could not find resource \(name).\(type)")
        } catch {
            debugPrint("Generic error")
        }
    }
    fileprivate func playVideo(_ sender: UIButton) throws {
        let cardsVC = SessionManager.sharedInstance.parkedViewController as? CardsViewController
        if cardsVC!.player != nil {
            cardsVC!.player.pause()
            cardsVC?.turnOffGestures()
            //cardsVC!.hideUpInfoOnView()
        }
        
        var count = 0
        let tag = sender.tag - 1
        if let array = UserDefaults.standard.array(forKey: "profileVideoUrls"){
            
            
            //let pathURL = NSURL(fileURLWithPath: array[Int(tag)] as! String)
            let player = AVPlayer(url: URL(fileURLWithPath: array[Int(tag)] as! String))
            let playerController = AVPlayerViewController()
            playerController.player = player
            self.present(playerController, animated: true) {
                player.play()
            }
            
        }
    }

    
    @IBAction func presentSettings(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "SettingsSegue", sender: self)
    }
    
    //Prepare for segue so that I can pass in user object
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        let vc : SettingsViewController = nav.topViewController as! SettingsViewController
        vc.reloadDelegate = self
    }
    
    func downloadVideoForlogin(){
        //for all of the videos in the videos download the video and assign the path to the array
        for i in (SessionManager.sharedInstance.user?.profileVideoUrls)!{
            let j = URL(string: i as! String)
            self.saveProfileVideoToFileSystem(j!)
        }
        self.loginVideo = true
        self.login = false
        self.viewDidLoad()

    }

    
    //MARK DELEGATE
    func playerReady(_ player: Player){}
    func playerPlaybackStateDidChange(_ player: Player){}
    func playerBufferingStateDidChange(_ player: Player){}
    func playerPlaybackWillStartFromBeginning(_ player: Player){}
    func playerPlaybackDidEnd(_ player: Player){
    self.player.view.removeFromSuperview()}


}


