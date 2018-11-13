//
//  Messages+CoreDataProperties.swift
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

extension Messages {

    @NSManaged var fromUserID: NSNumber?
    @NSManaged var userID: String?
    @NSManaged var viewed: NSNumber?
    @NSManaged var text: String?
    @NSManaged var localImageURL: String?
    @NSManaged var imageURL: String?
    @NSManaged var creationDateTime: Date?
    @NSManaged var user: User?

}
