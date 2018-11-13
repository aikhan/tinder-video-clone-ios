//
//  SessionManager.swift
//  Final-Questor-App
//
//  Created by Asad Khan on 08/07/2016.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import Foundation

class SessionManager{
    
    var usersArray:[GTLUserUser]?
    var user :GTLUserUser?
    var isUserLoggedIn :Bool
    //var justLoggedIn : Bool
    var userCity :String?
    var userCountry :String?
    var lat :Double = 0.0
    var long :Double = 0.0{
        didSet{
            if abs(oldValue - long) > 1 && isUserLoggedIn == true {
                //Call the KVO 
                CloudDAO.fetchUnviewUsers()
            }
        }
    }
    var userQueue :Queue<GTLUserUser>
    var deviceType :String
    var deviceToken :String
    var parkedViewController = UIViewController()//see a workaround for this
    
    var liked: Bool?
    var newMatch: Bool?
    var newMessage: Bool?
    
    
    
    //static let sharedInstance = SessionManager()
    static let sharedInstance: SessionManager = {
        let instance = SessionManager()
        return instance
    }()
    fileprivate init(){
        user = GTLUserUser()
        usersArray = [GTLUserUser]()
        isUserLoggedIn = UserDefaults.standard.bool(forKey: "login")
        long = 0.0
        lat = 0.0
        userQueue = Queue<GTLUserUser>()
        deviceType = ""
        deviceToken = ""
    
        //Notifications
        //New Likes
        if let liked = UserDefaults.standard.object(forKey: "likeNotification") as? Bool{
            self.liked = liked
        }else{
            self.liked = true
        }
        
        //New Matches
        if let newMatch = UserDefaults.standard.object(forKey: "newMessageNotification") as? Bool{
            self.newMatch = newMatch
        }else{
            self.newMatch = true
        }
        
        //New Messages
        if let newMessage = UserDefaults.standard.object(forKey: "NewMatchesNotification") as? Bool{
            self.newMessage = newMessage
        }else{
            self.newMessage = true
        }
        
        
    }
}
