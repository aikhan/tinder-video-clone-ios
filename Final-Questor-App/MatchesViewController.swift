//
//  MatchesViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 6/16/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Foundation


//This is the view controller that will take the most work, You must query the all the users that are in the users array. It is easy to get the names of the people however it is actually very hard to actually query those objects so their information can be passed into the next view controller, the chat. I have done the best that I can up to this point and will do the best to explain
protocol NotificationDelegate :class{
    func notifyUserOfMessage()
    func printSome()
}



class MatchesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageUserFromMatchDelegate, MatchesReloadDelegate, UIScrollViewDelegate {
    

    @IBOutlet weak var messagesTableView: UITableView!
    
    var matches = [GTLUserUser]()
    var matchesCore = [String]()
    var hasMatches = false
    var delegateScroll: ScrollViewChangeDelegate? = nil
    
    
    //Array of all the Users that sent that person a video
    var buckets = [String]()
    
    //Array to hold images that were downloaded becasue pictures could not be found in file system
    var tempGif = [UIImage]()
    
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
    
    //User to send when tapped
    var userToSend = GTLUserUser()
    
    //An array of [UIImage] arrays that will hold thier profile gif
    var gifArray = [[UIImage]()]
    
    //This will show when the user first open the app, hide if they have matches
    @IBOutlet weak var noMatchesView: UIView!
    
    //temp arrary of uiimmages
    var tempImageArrary = [UIImage]()
    
    var testimage = UIImage()
    
    //Button to move the screen back to the middle
    @IBOutlet weak var logoBackMainButton: UIButton!
    var logoButtonImage = UIImage(named: "navlogo")
    
    //Constraint for messages label
    @IBOutlet weak var leftConstraintMessage: NSLayoutConstraint!
    
    //Scrollview
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    //Delegate for main, scrollview
    var delegate : ScrollViewChangeDelegate? = nil
    
    //Delegate for cardsView
    weak var delegateCard : NotificationDelegate?

    @IBAction func backMainScreenAction(_ sender: Any) {
        delegateScroll?.changeScrollViewToMain()
    }
    
    func presentMessage(_ user: GTLUserUser){
        print("The user was passed into the messageuser")
        self.userToSend = user
        self.performSegue(withIdentifier: "MessageUserSegue", sender: self)
        
    }
    
    func reloadTableData(){
        //self.viewDidLoad()
        self.messagesTableView.reloadData()
    }
    
    func unmatchUser(_ bucket: String) {
        //Remove this user from the table
        for user in self.matches{
            if user.userBucket == bucket{
                self.matches = self.matches.filter{$0 != user}
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Grab matches from Core Data
        matchesCore = getMatchesFromCoreData()

        //Set up scroll View, Will have people that you matched with and have not messaged
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true

        //Set Back button
        logoBackMainButton.setImage(UIImage(named:"logoBack"), for: UIControlState())
        
        //TODO: Fill the scroll view with your matches from core data
        fillScrollView()
        
        
        //TODO: Figure This one out
        getMatchesFromCloud()
        
        //Check if the user has a video from someone
        checkForVideos { (UIBackgroundFetchResult) in
            //Add notification
            
        }
        
    }
    
    func createGifView(_ count: CGFloat, bucketName: String) -> UIView{
        
        //Create an image view and place it in the center
        let imageFrame = CGRect(x: 80 * count, y: 0, width: 70, height: 70)
        let imageView = UIImageView(frame: imageFrame)
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        //Animate the images for this user, their images should be saved
        let arrayName = "gifPhotosfor" + bucketName
        if let array = UserDefaults.standard.object(forKey: arrayName) {
            
            print("The array is in matches " + String(arrayName))
            
            //Check if the pictures are missing at this location
            let imageArray = self.loadGIFPicturesFromFileSystem(array as! [String])
            if (imageArray.count != 0){
                imageView.animationImages = imageArray
                imageView.animationDuration = 1.0
                imageView.startAnimating()
                imageView.backgroundColor = UIColor.black
                print("The imageArray count is :,", imageArray.count)
                return imageView
                
            }
            else{
                print("The imageArray was nil, or the count was ,", imageArray.count)
                //Set images to loading image and wait for downloaded images
                imageView.image = UIImage(named:"LoadingImage")
                imageView.startRotating()
                
                //Download thier images becuase they were deleted somehow from core data. Update maybe?
                getProfileGifURLS(bucketName: bucketName)
                return imageView
            }
        }
        else{
            //Set images to loading image and wait for downloaded images
            imageView.image = UIImage(named:"LoadingImage")
            imageView.startRotating()
            
            //Download thier images becuase they were a match by someone else
            getProfileGifURLS(bucketName: bucketName)
            return imageView
        }
    }
    
    func fillScrollView(){
        
        //If the matches array is emtpy then make a placeholder in the scrollview
        if matchesCore.isEmpty{
            print("Self.matches is empty")
            
            //TODO: Make gif view for a place holder, grey image
            
        }
        else{
            var count = 0
            for index in matchesCore{
                let placeholder: UIView = self.createGifView(CGFloat(count), bucketName: index )
                
                //Add thier name to the bottom of the uiview
                let x = placeholder.frame.size.width
                let y = placeholder.frame.size.height
                
                //Create label with width of x and height of y
                let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: x, height: y))
                nameLabel.center = CGPoint(x: 160, y: 285)
                nameLabel.textAlignment = .center
                
                //Set the name to the label
                nameLabel.text = getCapitolizedName(bucketName: index)
                placeholder.addSubview(nameLabel)
                
                //TODO: Add tap gesture to the uiimageview
                
                scrollView.addSubview(placeholder)
                count+=1
            }
        }
    }
    
    func getMatchesFromCloud(){
        
        //Set up scrollview, should be how many matches they have
        self.scrollView.contentSize = CGSize(width: 3000, height: 85)
        
        self.matches.removeAll()
        var selfBucket = SessionManager.sharedInstance.user?.userBucket
        if selfBucket == nil {
            selfBucket = DAO.getBucketNameForLoggedInUser()
        }
        
        //Query all of the user's matches
        let urlString = "\(Constants.kBaseURL)queryMatches?bucketName=\(selfBucket!)"
        let url = URL(string: urlString)
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if let urlContent = data{
                do{
                    let jsonresult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                    print("MAtches result == ", jsonresult)
                    let array = jsonresult as! [[String : AnyObject]]
                    for j in array {
                        
                        let userOne = GTLUserUser()
                        if let firstname = j["first_name"] as? String{
                            userOne.firstName = firstname
                        }
                        if let age = j["age"] as? Int{
                            userOne.age = age as NSNumber
                        }
                        if let gender = j["gender"] as? NSNumber{
                            userOne.gender = gender
                        }
                        if let location = j["user_location"] as? String{
                            userOne.userLocation = location
                        }
                        if let userBucket = j["user_bucket"] as? String{
                            userOne.userBucket = userBucket
                        }
                        if let profilegifarray = j["profile_gif"] as? NSArray as [AnyObject]?{
                            userOne.profileGif = profilegifarray
                        }
                        if let profileVideoUrls = j["profile_video_urls"] as? NSArray as [AnyObject]?{
                            userOne.profileVideoUrls = profileVideoUrls
                        }
                        if let bio = j["bio"] as? String{
                            userOne.bio = bio
                        }
                        self.matches.append(userOne)
                        
                        //The user has matches, if they don't tell them to tell more people
                        if(self.matches.count > 0){
                            self.hasMatches = true
                            print("The matches are," , self.matches)
                        }
                    }
                    
                    DispatchQueue.main.async(execute: {
                        //Add all the users to core data, then reload view
                        for match in self.matches{
                            DAO.insertUser(match)
                        }
                        
                        //display the ui that says, you have no matches, interact with more people.
                        //Set up scrollview
                        self.scrollView.contentSize = CGSize(width: self.matches.count * 100, height: 85)
                        //self.fillScrollView()
                        
                        //Set a place holder for the table view
                        self.hasMatches = true
                        self.messagesTableView.reloadData()
                    })
                    
                }catch{
                    print("The user has no matches")
                }
            }
            
        })
        task.resume()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        let footerView = UIView()
        footerView.frame = CGRect(x: 0, y: 0, width: 320, height: 500)
        return footerView
    }
 
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat{
        return 500
    }
    */
    
    //Keep cell from being highlighted
    
    //Write this code that will instantiate a new View Controller with that a GTLUser to pass in
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Take this user and save it
        self.userToSend = matches[indexPath.row]
        print("print")
        self.transition()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    /*
    * CellForRow:
    * This function sets up cell, the gif picture, the name, and any notifications
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
         return UITableViewCell()
         */
        
        let cell = self.messagesTableView.dequeueReusableCell(withIdentifier: "matchesCell", for: indexPath) as! MatchesTableViewCell
        
        //Animate the images for this user, their images should be saved
        if matchesCore.count == 0{
            //So Nothing
        }else{
            let arrayName = "gifPhotosfor" + matchesCore[indexPath.row]
            if let array = UserDefaults.standard.object(forKey: arrayName) {
                
                print("The array is " + String(arrayName))
                print("However the images that it tried to load were the profile images which arent there")
                //Set the users gif to the main screen
                let imageArray = self.loadGIFPicturesFromFileSystem(array as! [String])
                cell.profileGIF.layer.cornerRadius = cell.profileGIF.frame.size.width / 2;
                cell.profileGIF.contentMode = .scaleAspectFill
                cell.profileGIF.animationImages = imageArray
                cell.profileGIF.animationDuration = 1.0
                cell.profileGIF.startAnimating()
                cell.profileGIF.clipsToBounds = true
                cell.profileGIF.stopRotating()
            }
            else{
                //Set images to loading image and wait for downloaded images
                //cell.profileGIF.image = UIImage(named:"LoadingImage")
                //cell.profileGIF.startRotating()
                print("Your images could not be found")
            }
            
        }
        //If it is a new match and nothing has happened between the users then set the status image to nothing and make it clear
        cell.profileGIF.layer.cornerRadius = cell.profileGIF.frame.size.width / 2;
        cell.statusImage.backgroundColor = UIColor.clear
        
        //Check if the images have been downloaded yet
        if self.gifArray[0].isEmpty {
            print("Ooops, it's empty")
            //Set images to loading image and wait for downloaded images
            //cell.profileGIF.image = UIImage(named:"LoadingImage")
            //cell.profileGIF.startRotating()
        }
        else {
            print("No, it's not empty")
            let imageArray = gifArray[0]
            //Animate the uiimage view with the images that were grabbed
            cell.profileGIF.contentMode = .scaleAspectFill
            cell.profileGIF.animationImages = imageArray
            cell.profileGIF.animationDuration = 1.0
            cell.profileGIF.startAnimating()
            cell.profileGIF.clipsToBounds = true
            //cell.profileGIF.stopRotating()
        }
        
        //Check if thee user has sent you a video but first make sure self.buckets is not nil
        if self.buckets.isEmpty{
            //Do Nothing
        }
        else{
            //If self.bucket is not empty the check if the user's bucket name is in that array
            if self.buckets.contains(matches[indexPath.row].userBucket){
                //seet the user's image to new video
                cell.statusImage.image = receivedImage
            }
        }
        
        //Check the constraints
        cell.profileGIF.backgroundColor = UIColor.black
        
        cell.nameLabel.text = getCapitolizedName(bucketName: matchesCore[indexPath.row])
        
        return cell

    }
    
    func transition(){
        self.performSegue(withIdentifier: "MessageUserSegue", sender: self)
    }
    
    func grabImagesWithURLS(_ urls: [String], bucketName: String, completionHandler: ((UIBackgroundFetchResult) -> Void)!){
        var array = [UIImage]()
        var count = 0
        for i in urls{
            print("The count = " , count)
            Alamofire.request(i)
                .responseImage { response in
                    print(response)
                    if let image = response.result.value {
                        array.append(image)
                    }
            }
            count+=1
            if(count == 5){
                self.saveGIFPicturesToFileSystem(bucketName, images: array)
                self.fillScrollView()
            }
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func checkForVideos(_ completionHandler: ((UIBackgroundFetchResult) -> Void)!){
        
        let bucketname = DAO.getBucketNameForLoggedInUser()
        let url = "https://final-questor-app.appspot.com/messages/check"
        
        let params = ["bucketname" : bucketname!]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //API returns an array of all the users that have sent you a video
            if let result =  response.result.value{
                
                let JSON = result as! NSDictionary
                self.buckets = (JSON.value(forKey: "buckets")! as? [String])!
                
                if self.buckets.isEmpty{
                    //Do Nothing
                }
                else{
                    
                    //TODO: Down the road this will pass in the number of videos that have not been watched yet and they the udate accordingly
                    self.delegateCard?.notifyUserOfMessage()
                    
                    print("buckets==" , self.buckets)
                }
                
                //Reload table data
                DispatchQueue.main.async {
                    //self.tableView.reloadData()
                }
            }
        }
    }
    
    //Prepare for segue so that I can pass in user object
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc : MessageUserViewController = segue.destination as! MessageUserViewController
        vc.userToSend = self.userToSend
        vc.delegate = self
        
        //Check if they have gif images saved, if they do, then pass them into the gif image
        if let bucket = self.userToSend.userBucket as? String{
            let arrayName = "gifPhotosfor" + bucket
            if let array = UserDefaults.standard.object(forKey: arrayName) {
                
                print("The array is " + String(arrayName))
                print("However the images that it tried to load were the profile images which arent there")
                //Set the users gif to the main screen
                let imageArray = self.loadGIFPicturesFromFileSystem(array as! [String])
                vc.imageArray = imageArray
            }
            else{
                print("Your images could not be found")
            }
        }
    }

    
    //This function will get the urls for the profile gifs and save the images
    func getProfileGifURLS(bucketName: String){
        print("get profile gif was called")
        let url = "https://final-questor-app.appspot.com/getProfileGIF?bucketname=\(bucketName)"
        
        Alamofire.request(url).responseJSON { (response) in
            if let result = response.result.value{
                print("Getprofilegif response: ",  response)
                let JSON = result as! NSDictionary
                let tempArray = JSON.value(forKey: "signedURLS")! as! [String]
                print("temp array:", tempArray)
                
                self.downloadForMatch(bucketName: bucketName, gifUrls: tempArray)
            }
        }
    }
    
    func getMatchesFromCoreData() -> [String]{
        //Grab the matches from the user's Core Data
        let user = CoreDataDAO.getLoggedInUserInfo()!
        let matched = user.matchedArray
        if let matchedArray = matched?.components(separatedBy: ","){
            self.matchesCore = matchedArray
            return matchedArray
            print("Self.matches = ", self.matchesCore)
        }else{
            return []
        }
    }
    
    //Call this method once your recieve signed urls from server, pass in temparray
    func downloadForMatch(bucketName: String, gifUrls: [String]){
        print("Downloaded called for matched user")
        //Download the gif pictures into the file system
        self.downloadImagesForMatch(gifUrls, match: false, bucketName: bucketName) { (UIBackgroundFetchResult) in
            
            let gifArrayWithBucketName = "gifPhotosfor" + bucketName
            if let array = UserDefaults.standard.object(forKey: gifArrayWithBucketName) {
                print("The array is " + String(gifArrayWithBucketName))
                
                //Set the users gif to the main screen
                let imageArray = self.loadGIFPicturesFromFileSystem(array as! [String])
                DispatchQueue.main.async(execute: {
                    //Set a place holder for the table view
                    self.fillScrollView()
                   // self.tableView.reloadData()
                })
            }
        }
    }
    
    func getCapitolizedName(bucketName: String) -> String{
        return bucketName.components(separatedBy: "-")[0].capitalized
    }
}
