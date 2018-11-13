//
//  Matched_User+CoreDataProperties.swift
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

extension Matched_User {

    @NSManaged var matchedUserID: String?
    @NSManaged var matchID: NSNumber?
    @NSManaged var user: User?

}
