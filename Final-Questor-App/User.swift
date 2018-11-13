//
//  User.swift
//  
//
//  Created by Asad Khan on 11/07/2016.
//
//


import Foundation
import CoreData
import Alamofire

@objc(User)
class User: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    func save(){
        saveToCloud()
        saveToCoreData()
    }
    
    //Saves edited user to the Core data
    func saveToCoreData(){
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //Sends the new user to the cloud
    func saveToCloud(){
        let newUser = GTLUserUser()
        
        if let location = self.userLocation{
            newUser.userLocation = location
        }
        
        if let email = self.email{
            newUser.email = email
        }
        if let phone = self.phoneNumber{
            if let myInteger = Int(phone) {
            let myNumber = NSNumber(value:myInteger)
            newUser.phoneNumber = myNumber
            }
        }
        if let age = self.age{
            newUser.age = age
        }
        
        if let dating = self.dating{
            newUser.dating = dating
        }
            
        if let dis = self.distanceOfSearch{
            newUser.distanceOfSearch = dis
        }
        
        if let gender = self.gender{
            newUser.gender = gender
        }
        
        if let lookingFor = self.lookingFor{
            newUser.lookingFor = lookingFor
        }
        
        if let password = self.password{
            newUser.password = password
        }
        
        if let agehigh = self.ageHigh{
            newUser.ageHigh = agehigh
        }
        
        if let agelow = self.ageLow{
            newUser.ageLow = agelow
        }
        
        if let bio = self.bio{
            newUser.bio = bio
        }
        
        if let firstname = self.firstName{
            newUser.firstName = firstname
        }
        
        if let key = UserDefaults.standard.object(forKey: "entityKey") as? String{
            newUser.entityKey = key
            print("This is the user's entity key that tries to save:" , newUser.entityKey)
            updateUser(newUser)
        }
        else{
            print("Error: Unable to save to cloud because of missing entity key")
            print("Grabbing thier entity key now")
            //self.getUserKey(newUser)
            self.grabKey(newUser: newUser) {
                //Retry to save user
                if (newUser.entityKey) != nil{
                    print("The key was successfully retrieved")
                    self.updateUser(newUser)
                }
                else{
                    print("The Entity Key is still null")
                }
            }
        }
    }
    
    
    func grabKey(newUser: GTLUserUser, completion: @escaping () -> ()){
        
        //Swift 3.0
        //let params = ["user_bucket" : adrian-21-adrian-1471580171"]
        print("grabKey: UserBucket = ", self.userBucket!)
        let url = "https://final-questor-app.appspot.com/_ah/api/user/v1/user/list?user_bucket=adrian-21-adrian-1471580171"
        print(url)
        Alamofire.request(url).responseJSON { (response) in
            if let result = response.result.value as? Dictionary<String, AnyObject>{
                if let data = result["items"] as? [[String : AnyObject]]{
                    print("This is the data that it is printing", data[0]["entityKey"]!)
                    if let entityKey = data[0]["entityKey"] as? String{
                        newUser.entityKey = entityKey
                        UserDefaults.standard.set(entityKey, forKey: "entityKey")
                        print("Successfully grabbed entity key")
                    }
                }
                completion()
            }
            else{
                print("There was an error with grabKey Function")
            }
        }
    }
    
    func getUserKey(_ newUser: GTLUserUser){
        
        let query = GTLQueryUser.queryForUserList(userBucket = self.userBucket!)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        service.executeQuery(query as! GTLQueryProtocol, completionHandler: {(ticket, response, error) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error != nil{
                //Do some error handling
                print(error.debugDescription)
                return
            }
            else{
                let returnedUser = response as! GTLUserUser
                newUser.entityKey = returnedUser.entityKey
                print("This is the users first name", returnedUser.firstName)
                print("This is the users entity key", newUser.entityKey)
                print("Updated settings successfully")
            }
        })
    }
    
    func updateUser(_ newUser: GTLUserUser){
            let query = GTLQueryUser.queryForUserCreate(withObject: newUser) as GTLQueryUser
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            service.executeQuery(query, completionHandler: {(ticket, response, error) -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if error != nil{
                    //Do some error handling
                    print(error.debugDescription)
                    return
                }
                else{
                    
                    print("Updated settings successfully")
                    }
            })
    }
}



