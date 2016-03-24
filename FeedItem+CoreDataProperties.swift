//
//  FeedItem+CoreDataProperties.swift
//  exchangeAGram
//
//  Created by Andrew Morrison on 2016-03-24.
//  Copyright © 2016 Andrew Morrison. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FeedItem {

    @NSManaged var caption: String?
    @NSManaged var image: NSData?
    @NSManaged var thumbnail: NSData?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var uniqueID: String?
    @NSManaged var filtered: NSNumber?

}
