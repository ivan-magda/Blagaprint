//
//  CategoryData+CoreDataProperties.swift
//  Blagaprint
//
//  Created by Иван Магда on 13.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CategoryData {

    @NSManaged var name: String?
    @NSManaged var record: NSObject?
    @NSManaged var recordName: String?
    @NSManaged var type: String?
    @NSManaged var imageUrl: NSObject?
    @NSManaged var image: NSData?
    @NSManaged var items: NSSet?

}
