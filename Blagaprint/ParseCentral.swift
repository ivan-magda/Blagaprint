//
//  ParseCentral.swift
//  Blagaprint
//
//  Created by Иван Магда on 02.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation

/// The application id of Parse application.
private let applicationId = "S6q46qyVTC8tDSqkryAPvBo3fEkrkiFTtHSAHh3P"

/// The client key of Parse application.
private let clientKey = "1xTVWNh3TSB4ov5zoIseoDQ98JyMO86fjeBFwInr"

class ParseCentral: NSObject {
    // MARK: - Properties
    
    let parse: Parse
    
    private var hostReach: Reachability?
    private var networkStatus: Reachability.NetworkStatus?
    
    class var sharedInstance: ParseCentral {
        struct Static {
            static var instance: ParseCentral?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = ParseCentral()
        }
        
        return Static.instance!
    }
    
    // MARK: - Initializers
    
    override init() {
        // Register subclasses.
        Category.registerSubclass()
        CategoryItem.registerSubclass()
        Bag.registerSubclass()
        BagItem.registerSubclass()
        
        // Initialize Parse.
        Parse.setApplicationId(applicationId, clientKey: clientKey)
        
        self.parse = Parse()
        
        super.init()
        
        self.monitorReachability()
    }
    
    // MARK: - Reachability
    
    func isParseReachable() -> Bool {
        if let networkStatus = self.networkStatus {
            return networkStatus != Reachability.NetworkStatus.NotReachable
        } else {
            return false
        }
    }
    
    private func monitorReachability() {
        do {
            self.hostReach = try Reachability(hostname: "api.parse.com")
        } catch let error as NSError {
            print("Unable to create Reachability. Error: \(error.localizedDescription)")
            return
        }
        
        addReachabilityChangedObserver()
    }
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        self.networkStatus = reachability.currentReachabilityStatus
        
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Not reachable")
        }
    }
    
    // MARK: NSNotificationCenter Observe
    
    func addObservers() {
        addReachabilityChangedObserver()
    }
    
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        self.hostReach!.stopNotifier()
    }
    
    private func addReachabilityChangedObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: self.hostReach!)
        
        do {
            try self.hostReach!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}
