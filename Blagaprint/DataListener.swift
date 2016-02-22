//
//  DataListener.swift
//  Blagaprint
//
//  Created by Иван Магда on 22.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation
import Firebase

internal final class DataListener: NSObject {
    
    //--------------------------------------
    // MARK: - Properties -
    //--------------------------------------
    
    private var dataService: DataService
    private var handler: FirebaseHandle?
    
    private var isListen = false
    
    //--------------------------------------
    // MARK: Class Variables
    //--------------------------------------
    
    class var sharedInstance: DataListener {
        struct Static {
            static var instance: DataListener?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = DataListener()
        }
        
        return Static.instance!
    }
    
    //--------------------------------------
    // MARK: - Init/Deinit -
    //--------------------------------------
    
    override init() {
        dataService = DataService()
        
        super.init()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("startListen"), name: NotificationName.DataListenerUserDidLogInNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("stopListen"), name: NotificationName.DataListenerUserDidLogOutNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //--------------------------------------
    // MARK: - Instance Functions -
    //--------------------------------------
    
    //--------------------------------------
    // MARK: Public
    //--------------------------------------
    
    func startListen() {
        guard isListen == false else {
            return
        }
        
        listenForBagChanges()
        
        isListen = true
    }
    
    func stopListen() {
        isListen = false
        
        stopListenForBagChanges()
    }
    
    //--------------------------------------
    // MARK: Private
    //--------------------------------------
    
    private func listenForBagChanges() {
        guard let userId = User.currentUserId else {
            return
        }
        
        let bagRef = dataService.bagReference
        
        handler = bagRef.queryOrderedByChild(FBag.Key.userId.rawValue).queryEqualToValue(userId).observeEventType(.Value, withBlock: { _ in
            print("\(String(DataListener.self)) did observe Bag event.")
        })
    }
    
    private func stopListenForBagChanges() {
        guard let handler = handler else {
            return
        }
        
        dataService.bagReference.removeObserverWithHandle(handler)
    }
    
}
