//
//  User+CoreDataProperties.swift
//  
//
//  Created by Asad Khan on 11/07/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var userLocation: String?
    @NSManaged var userRealLocation: String?
    @NSManaged var email: String?
    @NSManaged var phoneNumber: String?
    @NSManaged var age: NSNumber?
    @NSManaged var dating: NSNumber?
    @NSManaged var distanceOfSearch: NSNumber?
    @NSManaged var gender: NSNumber?
    @NSManaged var lookingFor: NSNumber?
    @NSManaged var password: String?
    @NSManaged var profilePicName: String?
    @NSManaged var userBucket: String?
    @NSManaged var ageLow: NSNumber?
    @NSManaged var ageHigh: NSNumber?
    @NSManaged var uploadURL: String?
    @NSManaged var likedArray: String?
    @NSManaged var skippedArray: String?
    @NSManaged var matchedArray: String?
    @NSManaged var bio: String?
    @NSManaged var userID: String?
    @NSManaged var firstName: String?
    @NSManaged var gifPicture1: Data?
    @NSManaged var gifPicture2: Data?
    @NSManaged var gifPicture3: Data?
    @NSManaged var gifPicture4: Data?
    @NSManaged var gifPicture5: Data?
    @NSManaged var isLoggedInUser: NSNumber?
    @NSManaged var match: NSSet?
    @NSManaged var video: Video?
    @NSManaged var message: Messages?
    @NSManaged var location: Location?

}
