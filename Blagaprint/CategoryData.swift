//
//  CategoryData.swift
//  Blagaprint
//
//  Created by Иван Магда on 13.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import CoreData

let CategoryDataEntityName = "CategoryData"

class CategoryData: NSManagedObject {
    // MARK: - Methods
    
    class func getAllCategories(context: NSManagedObjectContext) -> [CategoryData]? {
        let request = NSFetchRequest(entityName: CategoryDataEntityName)
        var fetchedCategories: [CategoryData]?
        do {
            fetchedCategories = try context.executeFetchRequest(request) as? [CategoryData]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }

        return fetchedCategories
    }

}
