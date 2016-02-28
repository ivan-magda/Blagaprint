//
//  DataServiceReachability.swift
//  Blagaprint
//
//  Created by Иван Магда on 28.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation

public final class DataServiceReachability: NSObject {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    private var hostReach: Reachability?
    private var networkStatus: Reachability.NetworkStatus?
    private var hostName: String
    
    //--------------------------------------
    // MARK: Init
    //--------------------------------------
    
    init(hostName: String) {
        self.hostName = hostName
        
        super.init()
    }
    
    deinit {
        hostReach?.stopNotifier()
    }

    //--------------------------------------
    // MARK: Reachability
    //--------------------------------------
    
    public func isReachable() -> Bool {
        if let networkStatus = networkStatus {
            return networkStatus != Reachability.NetworkStatus.NotReachable
        } else {
            return false
        }
    }
    
    public func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        networkStatus = reachability.currentReachabilityStatus
        
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                print("Reachable via Wi-Fi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Not reachable")
        }
    }
    
    public func monitorReachability() {
        do {
            hostReach = try Reachability(hostname: hostName)
        } catch let error as NSError {
            print("Unable to create Reachability. Error: \(error.localizedDescription)")
            return
        }
        
        addReachabilityChangedObserver()
    }
    
    //--------------------------------------
    // MARK: NSNotificationCenter Observe
    //--------------------------------------
    
    func addObservers() {
        addReachabilityChangedObserver()
    }
    
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        hostReach?.stopNotifier()
    }
    
    private func addReachabilityChangedObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: hostReach!)
        
        do {
            try hostReach?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
}
