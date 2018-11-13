//
//  UserDAO.swift
//  Final-Questor-App
//
//  Created by Asad Khan on 08/07/2016.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import Foundation
import CoreData


let appDelegate = UIApplication.shared.delegate as! AppDelegate
let managedContext = appDelegate.managedObjectContext

class CoreDataDAO{
    // MARK:- Fetch Methods
    /*
     This method returns the information about the currently logged in user
     */
    class func getLoggedInUserInfo() -> User? {
        var loggedUser :User?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        #if DEBUG
            fetchRequest.returnsObjectsAsFaults = false;
        #endif
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format:"isLoggedInUser == 1")
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.fetch(fetchRequest)
            // print(result)
            let myArray = result as! [User]
            for user in myArray{
                if user.isLoggedInUser == true{
                    loggedUser = user
                }
            }
            //print(loggedUser!)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            loggedUser = nil
        }
        
        return loggedUser
    }
    
    
    
    /*
     This method returns the bucket name of the currently logged in user.
     */
    class func getBucketNameForLoggedInUser() -> String? {
        var bucketName :String?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        #if DEBUG
            fetchRequest.returnsObjectsAsFaults = false;
        #endif
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format:"isLoggedInUser == 1")
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.fetch(fetchRequest)
            if result.count <= 0 {
                bucketName = "error"
            }
            else{
                let myArray = result as! [User]
                bucketName = myArray[0].userBucket
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return bucketName!
    }
    
    /*
     This method returns the first name of the currently logged in user.
     */
    class func getFirstNameForLoggedInUser() -> String? {
        var firstName :String?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        #if DEBUG
            fetchRequest.returnsObjectsAsFaults = false;
        #endif
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format:"isLoggedInUser == 1")
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.fetch(fetchRequest)
            let myArray = result as! [User]
            firstName = myArray[0].firstName
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return firstName!
    }
    
    
    class func loginUserWithUserNameWith(_ email :String, password :String) ->Bool{
        var isVerified = false
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        #if DEBUG
            fetchRequest.returnsObjectsAsFaults = false;
        #endif
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format:"email == %@ AND password == %@", email, password)
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.fetch(fetchRequest)
            //let myArray = result as! [User]
            if result.isEmpty {
                isVerified = false
            }else{
                isVerified = true
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return isVerified
    }
    /*
     This method returns the bucket name of the currently logged in user.
     */
    class func getBucketNameForUser(_ userEmail :String) -> String? {
        var bucketName :String?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        #if DEBUG
            fetchRequest.returnsObjectsAsFaults = false;
        #endif
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format:"email == %@", userEmail)
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.fetch(fetchRequest)
            let myArray = result as! [User]
            bucketName = myArray[0].userBucket
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return bucketName!
    }
    /*
     This method returns All of the users in the database
     */
    class func getAllUsers() -> [User]? {
        var myArray :[User]?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        #if DEBUG
            fetchRequest.returnsObjectsAsFaults = false;
        #endif
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.fetch(fetchRequest)
            myArray = result as? [User]
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
       
        print("And item count is \(myArray!.count)")
        return myArray
    }
    
    /*
     This method returns the skipped Array of the currently logged in user
     */
    class func getSkippedArrayForUserWithBucketName(_ bucketName :String?) ->[String]?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        #if DEBUG
            fetchRequest.returnsObjectsAsFaults = false;
        #endif
        var skippedArray :[String]?
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format:"isLoggedInUser == 1")
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.fetch(fetchRequest)
            let usersReturned = result as! [User]
            let particularUser = usersReturned[0]
            
            if let skippedArrayString = particularUser.skippedArray {
                let tempArray :[String] = skippedArrayString.components(separatedBy: ",")
                //skippedArray.appendContentsOf(tempArray)
                skippedArray = [String]()
                for skippeditem in tempArray {
                    skippedArray?.append(skippeditem)
                }
            }
            else{
                skippedArray = nil
            }
        }
        catch{
            let fetchError = error as NSError
            print(fetchError)
        }
        return skippedArray
    }
    /*
     This method delete the messages from one particular user, similar to what unmatch from messages you hve on tinder
     */
    class func getMessagesFromUser(_ bucketName :String) {
        
        //TODO: Need to implement 
    }
    
    /*
     This method is same as above it just returns matched user array instead of skipped
     */
    class func getMatchedArrayForUserWithBucketName(_ bucketName :String?) ->[String]?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        #if DEBUG
            fetchRequest.returnsObjectsAsFaults = false;
        #endif
        var matchedArray :[String]?
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format:"isLoggedInUser == 1")
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.fetch(fetchRequest)
            let usersReturned = result as! [User]
            let particularUser = usersReturned[0]
            
            if let matchedArrayString = particularUser.matchedArray {
                var tempArray :[String] = matchedArrayString.components(separatedBy: ",")
                tempArray = Array(Set(tempArray)) //to make sure the returned array is unique
                matchedArray = [String]()
                for matcheditem in tempArray {
                    matchedArray?.append(matcheditem)
                }
                
            }
            else{
                matchedArray = nil
            }
        }
        catch{
            let fetchError = error as NSError
            print(fetchError)
        }
        return matchedArray
    }
    /*
     This method returns user object for the given bucket name
     */
    class func getUserWithBucketName(_ bucketName :String?) ->User?{
        var userOfInterest :User?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        #if DEBUG //This below code just works in debug version of builds what it does is it fetches whole objects instead of faults which makes debugging a little easier while developing
            fetchRequest.returnsObjectsAsFaults = false;
        #endif
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format:"name == \(bucketName!)")
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.fetch(fetchRequest)
            // print(result)
            let myArray = result as! [User]
            for user in myArray{
                if user.isLoggedInUser == true{
                    userOfInterest = user
                }
            }
            print(userOfInterest!)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            userOfInterest = nil
        }
        return userOfInterest
        
    }
    /*
     This method returns user object for the given bucket name
     */
    //TODO: This methods cast is suspicious recheck it
    class func getVideoStreamURLsForBucketName(_ bucketName :String?) ->[String?]?{
        var arrayOfVideoURLs :[String?]? = [String?]()
        var myVideosArray :[Video]?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        #if DEBUG
            fetchRequest.returnsObjectsAsFaults = false;
        #endif
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format:"userBucket == \(bucketName!)")
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.fetch(fetchRequest)
            // print(result)
            let myUser = result[0] as? User
            myVideosArray = (myUser!.video as? [Video]?)!
            for myVideo in myVideosArray! {
                arrayOfVideoURLs?.append(myVideo.streamURL)
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            myVideosArray = nil
        }
        return arrayOfVideoURLs
        
    }
    
    // MARK:- Insert Methods
    /*
     This method should be renamed
     This method will be called when the user will login into the app
     */
    class func insertUserLogin(_ user :GTLUserUser) -> Bool {
        
        var success = false
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        let newPerson = NSManagedObject(entity: entityDescription!, insertInto: managedContext)
        
        if let bucket = user.userBucket{
            newPerson.setValue(bucket, forKey: "userBucket")
        }
        newPerson.setValue(true, forKey: "isLoggedInUser")
        
        if user.firstName != nil{
            newPerson.setValue(user.firstName, forKey: "firstName")
        }
        if user.age != nil{
           newPerson.setValue(user.age, forKey: "age")
        }
        if user.dating != nil {
            newPerson.setValue(user.dating, forKey: "dating")
        }
        if user.password != nil{
          newPerson.setValue(user.password, forKey: "password")
        }
        if user.ageLow != nil{
            newPerson.setValue(user.ageLow, forKey: "ageLow")
        }
        if user.ageHigh != nil{
           newPerson.setValue(user.ageHigh, forKey: "ageHigh")
        }
        if user.email != nil{
            newPerson.setValue(user.email, forKey: "email")
        }
        if user.phoneNumber != nil{
            let tempNumber = user.phoneNumber as! Int
            let phonenumber = String(tempNumber)
            newPerson.setValue(phonenumber, forKey: "phoneNumber")
        }
        if user.gender != nil{
            newPerson.setValue(user.gender, forKey: "gender")
        }
        if user.bio != nil{
           newPerson.setValue(user.bio, forKey: "bio")
        }
        
        if let temp = user.likedArray as? [String]{
            newPerson.setValue(temp.joined(separator: ","), forKey: "likedArray")
        }
        if let temp = user.matchedArray as? [String]{
            newPerson.setValue(temp.joined(separator: ","), forKey: "matchedArray")
        }
        if let temp = user.skippedArray as? [String]{
            newPerson.setValue(temp.joined(separator: ","), forKey: "skippedArray")
        }
        if user.lookingFor != nil{
          newPerson.setValue(user.lookingFor, forKey: "lookingFor")
        }
        if user.userLocation != nil {
          newPerson.setValue(user.userLocation, forKey: "userLocation")
        }
        if user.distanceOfSearch != nil{
            newPerson.setValue(user.distanceOfSearch, forKey: "distanceOfSearch")
        }
        
        
        success = saveData()
        return success
    }
    /*
     This method inserts the message for the user in the core data store. It takes 2 arguments message body and from(either the bucket name or whatever that will uniquely identify the user)
     */
    class func insertMessage(_ message :String?, from :String) {
        if let user :User? = getLoggedInUserInfo(){
            let messageEntityDescription = NSEntityDescription.entity(forEntityName: "Message", in: managedContext)
            let newMessage = NSManagedObject(entity: messageEntityDescription!, insertInto: managedContext)
            newMessage.setValue(message, forKey: "text")
            newMessage.setValue(from, forKey: "fromUserID")
            newMessage.setValue(Date(), forKey: "creationDateTime")//TODO: this date is the date and time when message is added to the user this should be accessed from server and should show exactly when was the message sent. Message could have been sent way earlier and user just openned the app after sometime.
            user!.message = newMessage as? Messages
            saveData()
        }
    }
    class func updateUserLocation(_ long :Double, lat: Double){
            if let user :User? = getLoggedInUserInfo(){
                let entityDescription = NSEntityDescription.entity(forEntityName: "Location", in: managedContext)
                let newLocation = NSManagedObject(entity: entityDescription!, insertInto: managedContext)
                newLocation.setValue(lat as NSNumber, forKey: "longitude")
                newLocation.setValue(long as NSNumber, forKey: "latitude")
                newLocation.setValue(SessionManager.sharedInstance.userCity, forKey: "city")
                newLocation.setValue(SessionManager.sharedInstance.userCountry, forKey: "country")
                user?.location?.setValue(newLocation, forKey: "location")
               
                saveData()
        }
    }
    /*
     This method lets you add other users to the database, this method can also be used to add information for the user that wants login
     */
    
    class func insertUser(_ user :GTLUserUser) -> Bool {
        var success = false
        if checkIfUserExists(user) {
            success = false
        }else{
            //Grab the time the user was added
            let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
            let newPerson = NSManagedObject(entity: entityDescription!, insertInto: managedContext)
            
            if let bucket = user.userBucket{
                newPerson.setValue(bucket, forKey: "userBucket")
            }
            newPerson.setValue(false, forKey: "isLoggedInUser")
            
            if user.firstName != nil{
                newPerson.setValue(user.firstName, forKey: "firstName")
            }
            if user.age != nil{
                newPerson.setValue(user.age, forKey: "age")
            }
            
            if user.gender != nil{
                newPerson.setValue(user.gender, forKey: "gender")
            }
            if user.bio != nil{
                newPerson.setValue(user.bio, forKey: "bio")
            }

            if user.userLocation != nil {
                newPerson.setValue(user.userLocation, forKey: "userLocation")
            }
            if user.distanceOfSearch != nil{
                newPerson.setValue(user.distanceOfSearch, forKey: "distanceOfSearch")
            }
            
            success = saveData()
        }
        return success
    }
    
    /*
     This method when called updates the skipped array for the currently logged in user it does not return anything
     */
    class func updateSkippedArrayWithItem(_ bucketName :String?){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        #if DEBUG
            fetchRequest.returnsObjectsAsFaults = false;
        #endif
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format:"isLoggedInUser == 1")
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.fetch(fetchRequest)
            let usersReturned = result as! [User]
            let particularUser = usersReturned[0]
            
            if var skippedArrayString = particularUser.skippedArray{
                var skippedArray = skippedArrayString.components(separatedBy: ",")
                skippedArray.append(bucketName!)
                skippedArray = Array(Set(skippedArray)) //Added to make the array unique, note the orginal order will not be mainted, this is really fast compared to custom loops.
                skippedArrayString = skippedArray.joined(separator: ",")
                particularUser.skippedArray = skippedArrayString
                
            }else{
                
                particularUser.setValue(bucketName!, forKey: "skippedArray")
                
            }
            saveData()
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    /*
     This method when called updates the Liked array for the currently logged in user it does not return anything
     */
    class func updateLikedArrayWithItem(_ bucketName :String?){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        #if DEBUG
            fetchRequest.returnsObjectsAsFaults = false;
        #endif
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format:"isLoggedInUser == 1")
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.fetch(fetchRequest)
            let usersReturned = result as! [User]
            let particularUser = usersReturned[0]
            
            if var likedArrayString = particularUser.likedArray{
                var likedArray = likedArrayString.components(separatedBy: ",")
                likedArray.append(bucketName!)
                likedArray = Array(Set(likedArray)) //Added to make the array unique, note the orginal order will not be mainted, this is really fast compared to custom loops.
                likedArrayString = likedArray.joined(separator: ",")
                particularUser.likedArray = likedArrayString
                
            }else{
                
                particularUser.setValue(bucketName!, forKey: "likedArray")
                
            }
            saveData()
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    /*
     This method when called updates the Matched array for the currently logged in user it does not return anything
     */
    class func updateMatchedArrayWithItem(_ bucketName :String?){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        #if DEBUG
            fetchRequest.returnsObjectsAsFaults = false;
        #endif
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format:"isLoggedInUser == 1")
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.fetch(fetchRequest)
            let usersReturned = result as! [User]
            let particularUser = usersReturned[0]
            
            if var matchedArrayString = particularUser.matchedArray{
                var matchedArray = matchedArrayString.components(separatedBy: ",")
                matchedArray.append(bucketName!)
                matchedArray = Array(Set(matchedArray)) //Added to make the array unique, note the orginal order will not be mainted, this is really fast compared to custom loops.
                matchedArrayString = matchedArray.joined(separator: ",")
                particularUser.likedArray = matchedArrayString
                
            }else{
                
                particularUser.setValue(bucketName!, forKey: "matchedArray")
                
            }
            saveData()
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    /*
     This method when called updates the skipped array for the currently logged in user it does not return anything
     */
    class func checkIfUserExists(_ user :GTLUserUser?) -> Bool{
        
        var userExists = true
        
        //Test
        let moc = managedContext
        let employeesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        employeesFetch.propertiesToFetch = NSArray(object: "email") as [AnyObject]
        
        
        do {
            let result = try moc.fetch(employeesFetch) as! [String]
            if result.contains((user?.email!)!){
                print("User already exists")
            }else{
                userExists = false
            }
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        return userExists
    }
    
    
    /*
     This method delete the messages from one particular user, similar to what unmatch from messages you hve on tinder
     */
    class func deleteMessageForUser(_ bucketName :String) {
        
        if let _ :User? = getLoggedInUserInfo(){
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            let entityDescription = NSEntityDescription.entity(forEntityName: "Messages", in: managedContext)
            fetchRequest.entity = entityDescription
            
            do {
                let items = try managedContext.fetch(fetchRequest)
                for item in items {
                    managedContext.delete(item as! NSManagedObject)
                }
            }catch{
                
            }
        }
    }
    
    
    /*
     General method that actually saves whatever is in the context.
     */
    // MARK:- General methods
    class func saveData() -> Bool{
        var success = true
        if (managedContext.hasChanges){
            do {
                try managedContext.save()
            } catch {
                print(error)
                success = false
            }
        }
        return success
    }
    
    /*
     This method Deletes any entity that have been specified by the calling code. The list of entities that can be deleted according to the data mode are
     1. User
     2. Video
     3. Match
     4. Messages
     5. Location
     
     Delete rule such as cascade and nullify will all apply as programmed.
     */
    
    class func deleteAllObjects(_ entityDescription :String){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: entityDescription, in: managedContext)
        fetchRequest.entity = entityDescription
        
        do {
            let items = try managedContext.fetch(fetchRequest)
            for item in items {
                managedContext.delete(item as! NSManagedObject)
            }
        }catch{
            
        }
    }
    
    //Unsure of how to save things to core data
    class func saveRegistrationToken(_ token: String){
        
    }
    
    
}
