//
//  MatchPopUPViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 7/27/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
protocol MessageUserDelegate :class{
    func didTapMessageUser(_ user: GTLUserUser)
    
}

protocol PlayerFromMatchDelegate: class {
    func playerPlay()
    func reloadMatches()
}

class MatchPopUPViewController: UIViewController {
    
    weak var delegate :MessageUserDelegate?
    weak var playerDelegate: PlayerFromMatchDelegate?
    
    //image view that will animate all of my images
    @IBOutlet weak var selfImageGif: UIImageView!
    
    //image view that will animate all of the matches images
    @IBOutlet weak var matchImageGif: UIImageView!
    
    //label that will hold the name of the person that you just matched with
    @IBOutlet weak var matchNameLabel: UILabel!
    
    //Background which is the first image of the gif
    @IBOutlet weak var backGroundImgae: UIImageView!

    //View that sits ontop of the blurred image
    @IBOutlet weak var backgroundTransparentview: UIView!
    
    //user that is passed into the view
    var matchedUser: GTLUserUser?
    
    //Holds the images in the view controller so if the user wants to send a video now, then the pictures will play automatically
    var imageArray = [UIImage]()
    
    @IBOutlet weak var keepSearchingButton: UIButton!
    @IBOutlet weak var sendMessage: UIButton!
    
    
    let borderAlpha : CGFloat = 0.7
    let cornerRadius : CGFloat = 5.0
    
    //These are all of the constraints that will be edited based on phone size
    
    //User gif height
    @IBOutlet weak var userGifHeight: NSLayoutConstraint!
    
    //User gif width
    @IBOutlet weak var userGifWidth: NSLayoutConstraint!
    
    //User gif from left
    @IBOutlet weak var userGifFromLeft: NSLayoutConstraint!
    
    //Match gif height
    @IBOutlet weak var matchGifHeight: NSLayoutConstraint!
    
    //Match gif width
    @IBOutlet weak var matchGifWidth: NSLayoutConstraint!
    
    //Match gif from left
    @IBOutlet weak var matchGifFromRight: NSLayoutConstraint!
    
    //button from bottom
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    //MAtch label with two names
    @IBOutlet weak var matchLabelWithNames: UILabel!
    
  
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.backgroundTransparentview.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        self.selfImageGif.layer.cornerRadius = self.selfImageGif.frame.size.width / 2;
        self.matchImageGif.layer.cornerRadius = self.matchImageGif.frame.size.width / 2;
        
        if SessionManager.sharedInstance.deviceType == "iphone5" {
            //Both sides are 15
            userGifFromLeft.constant = 15
            matchGifFromRight.constant = 15
            
            
            //Boxes are 110
            userGifWidth.constant = 110
            userGifHeight.constant = 110
            
            matchGifWidth.constant = 110
            matchGifHeight.constant = 110
            
            //Bottom is 40
            bottomConstraint.constant = 30
           
        }else if SessionManager.sharedInstance.deviceType == "iphone4"{
            //Make boxes 100
            
            //Bottom Constraint is 30
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //Match label
        matchLabelWithNames.text = "You and " + (matchedUser?.firstName!)!
        
        
        //Keep searching button
        keepSearchingButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        keepSearchingButton.setTitle("Keep Searching", for: UIControlState())
        keepSearchingButton.setTitleColor(UIColor.white, for: UIControlState())
        keepSearchingButton.backgroundColor = UIColor.clear
        keepSearchingButton.layer.borderWidth = 1.0
        keepSearchingButton.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        keepSearchingButton.layer.cornerRadius = cornerRadius
        
        //Send Message button
        sendMessage.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        sendMessage.setTitle("Introduce Yourself", for: UIControlState())
        sendMessage.setTitleColor(UIColor.white, for: UIControlState())
        sendMessage.backgroundColor = UIColor.clear
        sendMessage.layer.borderWidth = 1.0
        sendMessage.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        sendMessage.layer.cornerRadius = cornerRadius
        sendMessage.backgroundColor = UIColor.orange
        
        //Set the background to transparent
        view?.backgroundColor = UIColor(white: 1, alpha: 0.5)
       
        //Add the name of the user to the view
        matchNameLabel.text = matchedUser?.firstName
        
        //Animate the imageview of yourself
        var selfBucket = SessionManager.sharedInstance.user?.userBucket
        if selfBucket == nil {
            selfBucket = DAO.getBucketNameForLoggedInUser()
        }
        let gifArrayWithBucketName = "gifPhotosfor"
        
        if let array = UserDefaults.standard.object(forKey: gifArrayWithBucketName) {
            
            print("The array is " + String(gifArrayWithBucketName))
            //Set the users gif to the main screen
            let imageArray = self.loadGIFPicturesFromFileSystem(array as! [String])
            self.selfImageGif.layer.cornerRadius = self.selfImageGif.frame.size.width / 2;
            self.selfImageGif.contentMode = .scaleAspectFill
            self.selfImageGif.animationImages = imageArray
            self.selfImageGif.animationDuration = 1.0
            self.selfImageGif.startAnimating()
            self.selfImageGif.clipsToBounds = true
            
        }
        else{
            print("Images for match")
        }
        
        //Animate the images for the user that just matched with you
        
        if let array = UserDefaults.standard.object(forKey: "gifPhotosformatch") {
            
            print("The array is " + String("gifPhotosformatch"))
            
            
            //Set the users gif to the main screen
            let imageArray = self.loadGIFPicturesFromFileSystem(array as! [String])
            
            //Set the background image
            self.backGroundImgae.image = imageArray[0]
            self.backGroundImgae.contentMode = .scaleAspectFill
            
            //Blurr the image
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width + 10, height: self.view.frame.size.height + 10)
            self.backGroundImgae.addSubview(blurEffectView)
            
            //Animate gif
            self.matchImageGif.layer.cornerRadius = self.matchImageGif.frame.size.width / 2;
            self.matchImageGif.contentMode = .scaleAspectFill
            self.matchImageGif.animationImages = imageArray
            self.matchImageGif.animationDuration = 1.0
            self.matchImageGif.startAnimating()
            self.matchImageGif.clipsToBounds = true
            
            //Save the images to pass to the message with user array
            self.imageArray = imageArray
            
            //Now that you are matched with this user save thier pictures with their bucket name to be loaded from the match table view
            self.saveGIFPicturesToFileSystem((matchedUser?.userBucket)! as String, images: imageArray)
        }
        else{
            print("Your images could not be found")
        }


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func keepSearchingAction(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
        playerDelegate?.playerPlay()
        playerDelegate?.reloadMatches()
        //self.performSegueWithIdentifier("sendMessage", sender: self)
    }
    
    @IBAction func sendMessageAction(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
        self.delegate?.didTapMessageUser(matchedUser!)
        
 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc : MessageUserViewController = segue.destination as! MessageUserViewController
        vc.userToSend = matchedUser
        vc.imageArray = self.imageArray
        vc.fromMatchScreen = true
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

}
