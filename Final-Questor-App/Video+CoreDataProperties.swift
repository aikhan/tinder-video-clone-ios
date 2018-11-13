//
//  Photo+CoreDataProperties.swift
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

extension Video {

    @NSManaged var streamURL: String?
    @NSManaged var videoID: NSNumber?
    @NSManaged var localURL: String?
    @NSManaged var user: User?

}
