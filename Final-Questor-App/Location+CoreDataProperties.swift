//
//  Location+CoreDataProperties.swift
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

extension Location {

    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var longitude: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var countryCode: String?
    @NSManaged var user: User?

}
