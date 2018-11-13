//
//  CloudDAO.swift
//  Final-Questor-App
//
//  Created by Asad Khan on 09/07/2016.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import Foundation
import Alamofire

public protocol NoUsersDelegeate {
    func addNoUsersLabels()
}


class CloudDAO{
    
    
    //This will hold all of the user objects and all of their information, this is initialized here and will from here on checked for emptiness only and should not be re-initialized anywhere else.
    static var unviewedUsers :[GTLUserUser]? = []
    
    //Delegate
    var delegate : NoUsersDelegeate? = nil
    
    init() {
        print("Init Cloud DAO")
    }
    
    /*
        This method will login user from the cloud
        Currently its not implemented and just returns false.
        All authentication will be in this method.
        Local Data store will not be used to authenticate user, it it stores all the user information
    */
    class func loginUserCloudCheckWith(_ email :String, password :String) ->Bool{
        return false
    }
    
    class func updateUserLocation(_ long :Double, lat: Double, city: String){
        
        let bucket = CoreDataDAO.getBucketNameForLoggedInUser()
        //Swift 3.0
        let params = ["bucketname" : bucket!, "lat" : CGFloat(lat), "lon" : CGFloat(long), "city" : city] as [String : Any]
        let url = "https://final-questor-app.appspot.com/update/location"
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //Do Nothing
            print(response)
        }
    }
    
    
    class func addBucketNameToSkippedArray(_ skippedUserBucketName:String ){
        let url = "https://final-questor-app.appspot.com/add"
        var name = SessionManager.sharedInstance.user?.userBucket
        if name == nil {
            name = DAO.getBucketNameForLoggedInUser()
        }
        let params = ["bucketname" : name!, "bucketToSave" : skippedUserBucketName, "toSave" : "skipped", ]
        
        //Swift 3.0
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //Do Nothing
            print(response)
        }
    }
    
    class func addBucketNameToLikedArray(_ likedUserBucketName :String ){
        let url = "https://final-questor-app.appspot.com/add"
        var name = SessionManager.sharedInstance.user?.userBucket
        if name == nil {
            name = DAO.getBucketNameForLoggedInUser()
        }
        UserDefaults.standard.set(true, forKey: "login")

        let params = ["bucketname" : name!, "bucketToSave" : likedUserBucketName, "toSave" : "liked", ]
        
        //Swift 3.0
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //Do Nothing
            print(response)
        }
    }
    
    class func sendNotificationLike(_ bucket: String){
        
        var name = SessionManager.sharedInstance.user?.firstName
        if name == nil {
            name = CoreDataDAO.getLoggedInUserInfo()!.firstName
        }

        let params = ["firstName" : name!, "toBucket" : bucket, "notificationType" : "like"]
        let url = "https://final-questor-app.appspot.com/notification"

        //Swift 3.0
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //Do Nothing
            print(response)
        }
    }
    
    class func sendNotificationMatch(_ bucket: String){
        
        var firstName = SessionManager.sharedInstance.user?.firstName
        if firstName == nil{
            firstName = DAO.getCurrentLoggedUser()!.firstName!
        }

        let params = ["firstName" : firstName!, "toBucket" : bucket, "notificationType" : "match"]
        let url = "https://final-questor-app.appspot.com/notification"
        
        //Swift 3.0
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //Do Nothing
            print(response)
        }
    }
    
    
    //This method adds the bucketname to the users matched array as well as add the user to the other person matched array
    class func addBucketNameToMatchedArray(_ matchedUserBucketName :String ){
        let url = "https://final-questor-app.appspot.com/add"
        var name = SessionManager.sharedInstance.user?.userBucket
        if name == nil {
            name = DAO.getBucketNameForLoggedInUser()
        }

        let params = ["bucketname" : name!, "bucketToSave" : matchedUserBucketName]
        
        //Swift 3.0
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //Do Nothing
            print(response)
            sendNotificationMatch(matchedUserBucketName)
        }

    }
    
    class func unmatchUser(_ bucket: String){
        let url = "https://final-questor-app.appspot.com/unmatch"
        var selfBucket = SessionManager.sharedInstance.user?.userBucket
        if selfBucket == nil {
            selfBucket = DAO.getBucketNameForLoggedInUser()
        }
        
        let params = ["selfBucket" : selfBucket!, "bucketToUnmatch" : bucket]

        //Swift 3.0
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //Do Nothing
            print(response)
        }
    }
    
    
    /*
     Fetches the unviewed users from the server and stores them in local database and also in the session manager class for easy manipulation in the appliaction.
     */
    class func fetchUnviewUsers(){
        #function
        if SessionManager.sharedInstance.isUserLoggedIn != true {
            print("returned user is not logged in")
            return
        }
        if SessionManager.sharedInstance.lat == 0.0 || SessionManager.sharedInstance.long == 0 {
            //This should somehow setupcorelocation, then call this again
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            print("grabbed user location")
            appDelegate.setupCoreLocation()
            
            //Dont return grab their location and try again
            
        }
        
        //Get all of the user's information
        let user = CoreDataDAO.getLoggedInUserInfo()!
        
        let dating = Int(user.dating!)
        print("Dating = ", dating)
        let ageLow = user.ageLow
        let ageHigh = user.ageHigh
        let userAge = user.age
        let lat = SessionManager.sharedInstance.lat
        let lon = SessionManager.sharedInstance.long
        let gender = user.gender?.int32Value
        let lookingFor = user.lookingFor?.int32Value
        let distanceOfSearch = user.distanceOfSearch
        var userBucket = SessionManager.sharedInstance.user?.userBucket
        if userBucket == nil {
            userBucket = DAO.getBucketNameForLoggedInUser()
        }
        
        
        if gender == nil || lookingFor == nil || distanceOfSearch == nil || lat == 0.0 || lon == 0.0 {
            print("gender = " , gender)
            print("lookingfor = ", lookingFor)
            print("distnace ", distanceOfSearch)
            print("lat = ", lat)
            print("lon = " , lon)
            
            //Do not return, ask for what they are missing and try again!
        }
        //Query all of the unviewed users with the user's information
        let urlString = "\(Constants.kBaseURL)queryUnviewed?lat=\(lat)&lon=\(lon)&gender=\(gender!)&lookingFor=\(lookingFor!)&distanceOfSearch=\(distanceOfSearch!)&userBucket=\(userBucket!)&ageLow=\(ageLow!)&ageHigh=\(ageHigh!)&userAge=\(userAge!)&dating=\(dating)"
        let url = URL(string: urlString)
        
        let params = ["lat": lat, "lon": lon, "gender": gender!, "lookingFor": lookingFor!, "distanceOfSearch": distanceOfSearch!, "userBucket": userBucket!, "ageLow": ageLow!, "ageHigh": ageHigh!, "userAge": userAge!, "dating": dating] as [String : Any]
        
        //Absolute String
        print(url!.absoluteString)
        
        //Make the api call to fetch unview users using params
        Alamofire.request(url!, method: .get, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            //get the response
            if let result = response.result.value{
                
                //Cast the json object to an array of Strings AnyObjects
                let array = result as! [[String:Any]]
                for j in array{
                    
                    let userOne = GTLUserUser()
                    
                    if let firstname = j["first_name"] as? String{
                        userOne.firstName = firstname
                    }
                    if let age = j["age"] as? Int{
                        userOne.age = age as NSNumber!
                    }
                    if let distance = j["distance_of_search"] as? Int{
                        userOne.distanceOfSearch = distance as NSNumber!
                    }
                    if let location = j["user_location"] as? String{
                        userOne.userLocation = location
                    }
                    if let userBucketReturned = j["user_bucket"] as? String{
                        userOne.userBucket = userBucketReturned
                    }
                    if let profileVideoUrls = j["profile_video_urls"] as? NSArray as? [AnyObject]{
                        userOne.profileVideoUrls = profileVideoUrls
                    }
                    if let likedyou = j["liked_you"] as? String{
                        userOne.likedYou = likedyou
                    }
                    if let distanceaway = j["distance_away"] as? Int?{
                        userOne.distanceAway = distanceaway as NSNumber!
                    }
                    if let profilegifarray = j["profile_gif"] as? NSArray as? [AnyObject]{
                        userOne.profileGif = profilegifarray
                    }
                    if let bio = j["bio"] as? String{
                        userOne.bio = bio
                    }
                    
                    //Add this user to the array of unviewed users
                    self.unviewedUsers!.append(userOne)
                    
                    //If the user does not have any profile videos then do not add them to the queue
                    if(userOne.profileVideoUrls.count != 0){
                        SessionManager.sharedInstance.userQueue.enqueue(userOne)
                    }
                    else{
                        print("The user does not have any profile videos")
                    }
                    
                }
                SessionManager.sharedInstance.usersArray = self.unviewedUsers
            }
            else{
                print("Query Users Json failed")
            }
        }
    }
    

    
    class func saveRegistrationToken(_ token:String){

        //let bucket = CoreDataDAO.getBucketNameForLoggedInUser()
        let bucket = SessionManager.sharedInstance.user?.userBucket

        let params = ["bucketname" : bucket!, "registrationToken" : token]
        let url = "https://final-questor-app.appspot.com/update/registrationToken"
        
        //Swift 3.0
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //Do Nothing
            print(response)
        }
    }
}
