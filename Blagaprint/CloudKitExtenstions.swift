//
//  CloudKitExtenstions.swift
//  Blagaprint
//
//  Created by Иван Магда on 05.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import CloudKit

// MARK: - CloudKit Extenstions -

extension Category {
    static func countFromCloudKitWithCompletionHandler(countCallback: (Int) -> ()) {
        var count = 0
        let query = CKQuery(recordType: CategoryRecordType, predicate: NSPredicate(value: true))
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = []
        queryOperation.resultsLimit = CKQueryOperationMaximumResults
        queryOperation.recordFetchedBlock = {
            record in
            ++count
        }
        queryOperation.queryCompletionBlock = {
            cursor, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    countCallback(count)
                }
            }
        }
        CloudKitCentral.sharedInstance.publicDatabase.addOperation(queryOperation)
    }
}

extension CategoryItem {
    static func countFromCloudKitWithCompletionHandler(countCallback: (Int) -> ()) {
        var count = 0
        let query = CKQuery(recordType: CategoryItemRecordType, predicate: NSPredicate(value: true))
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = []
        queryOperation.resultsLimit = CKQueryOperationMaximumResults
        queryOperation.recordFetchedBlock = {
            record in
            ++count
        }
        queryOperation.queryCompletionBlock = {
            cursor, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    countCallback(count)
                }
            }
        }
        CloudKitCentral.sharedInstance.publicDatabase.addOperation(queryOperation)
    }
}
