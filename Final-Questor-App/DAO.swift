//
//  DAO.swift
//  Final-Questor-App
//
//  Created by Asad Khan on 11/07/2016.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import Foundation
/*
 This class will be used to call methods in CloudDAO and CoreDataDAO.
 This calls will decide which objects to persist locally and which data/objects to persist on the backend service.
 Somethings will make sense to store local store only, some on the backend service onlyand some on both.
 This call will provide an easy interface to call persistence methods and will be the class which the viewcontroller will directly interact with
 */

class DAO{
    
    class func getCurrentLoggedUser() -> GTLUserUser?{
        let user = CoreDataDAO.getLoggedInUserInfo()
        let userGTL = GTLUserUser()
        
        userGTL.age = user?.age
        userGTL.distanceOfSearch = user?.distanceOfSearch
        userGTL.email = user?.email
        //userGTL.entityKey = user?.entity
        userGTL.firstName = user?.firstName
        userGTL.gender = user?.gender
        userGTL.lookingFor = user?.lookingFor
        
        if user?.likedArray != nil{
            userGTL.likedArray = user?.likedArray!.components(separatedBy: ",")
        }
        if user?.matchedArray != nil{
            userGTL.matchedArray = user?.matchedArray!.components(separatedBy: ",")
        }
        if user?.skippedArray != nil{
            userGTL.skippedArray = user?.skippedArray!.components(separatedBy: ",")
        }
        userGTL.userBucket = user?.userBucket
        userGTL.userLocation = user?.userLocation
        //userGTL?.userRealLocation = user?.userRealLocation
        
        SessionManager.sharedInstance.user = userGTL
        
        return userGTL
    }
    
    class func insertUser(_ userGTL :GTLUserUser) -> Bool {
        return CoreDataDAO.insertUser(userGTL)
    }
    class func getBucketNameForLoggedInUser() -> String? {
        var userBucket :String? = "error" //This default Error value in ViewController will prompt user to login by taking him/her to login screen
        if SessionManager.sharedInstance.user?.userBucket != nil{
            userBucket = SessionManager.sharedInstance.user?.userBucket
        }else {
            userBucket = CoreDataDAO.getBucketNameForLoggedInUser()
            SessionManager.sharedInstance.user?.userBucket = userBucket
        }
        return userBucket;
    }
    
    /*
        This method should be called when a new user logs into the database, we should not call it when user logs out. There's a case that the same user logs in so it would be a way easier to just load the same data.
    */
    class func clearAllLocalDataStore(){
        CoreDataDAO.deleteAllObjects("User")
        CoreDataDAO.deleteAllObjects("Messages")
        CoreDataDAO.deleteAllObjects("Location")
    }
    
    /*
        This function should only verify the login credentials from the cloud. Local authentication should be removed
    */
    class func loginUserWithEmail(_ email :String, password :String) ->Bool{
        var isVerified = CloudDAO.loginUserCloudCheckWith(email, password: password)
        if isVerified != true {
            isVerified = CoreDataDAO.loginUserWithUserNameWith(email, password: password)//TODO: Remove the local authentication routine
        }
        
        return isVerified
    }
    
    /*
        This functions adds the bucket name on skipped arrays on cloud and local storage both
     */
    class func userHasBeenSkippedWithBucketName(_ name :String){
        CloudDAO.addBucketNameToSkippedArray(name)
        CoreDataDAO.updateSkippedArrayWithItem(name)
    }
    
    /*
     Same as the above method but for likes
     */
    class func userHasBeenLikedWithBucketName(_ name :String, match: Bool){
        
    
        
        if match == true{
            //Add bucketname to matched array for both users
            CloudDAO.addBucketNameToMatchedArray(name)
            CoreDataDAO.updateMatchedArrayWithItem(name)
        
        }
        else{
            //Add bucket name to liked array
            CloudDAO.addBucketNameToLikedArray(name)
            CoreDataDAO.updateLikedArrayWithItem(name)
        }
        
    }
    
    class func unmatchUser(_ user: GTLUserUser){
        CloudDAO.unmatchUser(user.userBucket!)
    }
    
    
    /*
        Updates the users location in coredata and google app engine
     */
    class func updateCurrentUsersLocation(_ long :Double, lat :Double, city: String){
        if lat > 0 {
        SessionManager.sharedInstance.lat = lat
        SessionManager.sharedInstance.long = long
        
        if SessionManager.sharedInstance.isUserLoggedIn {
            CoreDataDAO.updateUserLocation(long, lat: lat)
            CloudDAO.updateUserLocation(long, lat:lat, city: city)
            
        }
        }
        else{
            //DO nothing because 0.0 was passed into the function and we do not want tho update location if it was faulty and passed in 0.0
        }
        
    }
    class func updateCurrentUsersNewLocation(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setupCoreLocation()
        
    }
    
    //I am unsure of how save this in the core data
    class func saveRegistrationToken(_ token: String){
        CloudDAO.saveRegistrationToken(token)
        CoreDataDAO.saveRegistrationToken(token)
    }
    
    
    
    
    
    
    
    
}
