//
//  ParseCentral.swift
//  Blagaprint
//
//  Created by Иван Магда on 02.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import Parse

/// The application id of Parse application.
private let applicationId = "S6q46qyVTC8tDSqkryAPvBo3fEkrkiFTtHSAHh3P"

/// The client key of Parse application.
private let clientKey = "1xTVWNh3TSB4ov5zoIseoDQ98JyMO86fjeBFwInr"

public typealias ParseCentralSuccessResultBlock = (() -> ())
public typealias ParseCentralFailureResultBlock = ((error: NSError?) -> ())
public typealias ParseCentralResultBlock = ((succeeded: Bool, error: NSError?) -> ())

class ParseCentral: NSObject {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
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
    
    /// This view is presenting when user adding item to the bag.
    private var activityView: ActivityView?
    
    private var rootViewController: UITabBarController? {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if let window = appDelegate.window {
                if let tabBarController = window.rootViewController as? UITabBarController {
                    return tabBarController
                }
            }
        }
        
        return nil
    }
    
    //--------------------------------------
    // MARK: - Initializers -
    //--------------------------------------
    
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
    
    //--------------------------------------
    // MARK: - Reachability -
    //--------------------------------------
    
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
    
    //--------------------------------------
    // MARK: NSNotificationCenter Observe
    //--------------------------------------
    
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
    
    //--------------------------------------
    // MARK: - Activity Indicator -
    //--------------------------------------
    
    private func presentActivityView() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let tabBarController = appDelegate.window!.rootViewController as! UITabBarController
        
        self.activityView = ActivityView(frame: tabBarController.view.bounds, message: NSLocalizedString("Adding...", comment: ""))
        tabBarController.view.addSubview(activityView!)
        activityView!.startAnimating()
    }
    
    private func removeActivityView(completion completion: (() -> ())?) {
        if let activityView = self.activityView {
            activityView.stopAnimating()
            activityView.removeFromSuperview()
            
            self.activityView = nil
            
            if let completion = completion {
                dispatch_async(dispatch_get_main_queue()) {
                    completion()
                }
            }
        }
    }
    
    //--------------------------------------
    // MARK: - Adding to Bag -
    //--------------------------------------
    
    /// Adds BagItem object to Bag of the current user.
    private func addItemToBag(bag: Bag, item: BagItem, block: ParseCentralResultBlock) {
        // Save item to Parse datastore.
        item.saveInBackgroundWithBlock() { (succeeded, error) in
            if succeeded {
                // Add this item to bag of the current user.
                bag.addUniqueObject(item.objectId!, forKey: Bag.FieldKey.items.rawValue)
                bag.saveInBackgroundWithBlock() { (succeeded, error) in
                    if succeeded {
                        block(succeeded: true, error: nil)
                    } else {
                        block(succeeded: false, error: error)
                    }
                }
            } else {
                block(succeeded: false, error: error)
            }
        }
    }
    
    /// Saves BagItem to the Bag of the current user asynchronously.
    func saveItem(item: BagItem, success: ParseCentralSuccessResultBlock?, failure: ParseCentralFailureResultBlock?) {
        if let user = BlagaprintUser.currentUser() {
            
            presentActivityView()
            
            // Find Bag of the user.
            let bagQuery = PFQuery(className: Bag.parseClassName())
            bagQuery.whereKey(Bag.FieldKey.userId.rawValue, equalTo: user.objectId!)
            bagQuery.findObjectsInBackgroundWithBlock() { (bag, error) in
                if let error = error {
                    print("Finding Bag of the user error: \(error.localizedDescription)")
                    
                    self.removeActivityView() {
                        if let failure = failure {
                            failure(error: error)
                        }
                    }
                } else if let bag = bag as? [Bag] {
                    assert(bag.count <= 1, "Bag must be unique for each user!")
                    
                    // Bag not exist, create it for the user.
                    if bag.count == 0 {
                        let bag = Bag()
                        bag.userId = user.objectId!
                        bag.saveInBackgroundWithBlock() { (succeeded, error) in
                            if succeeded {
                                self.addItemToBag(bag, item: item, block: { (succeeded, error) in
                                    if succeeded {
                                        if let success = success {
                                            self.removeActivityView() {
                                                success()
                                            }
                                        }
                                    } else {
                                        
                                        if let error = error {
                                            print("Error adding item to bag: \(error.localizedDescription)")
                                        }
                                        
                                        self.removeActivityView() {
                                            if let failure = failure {
                                                failure(error: error)
                                            }
                                        }
                                    }
                                })
                            } else {
                                
                                if let error = error {
                                    print("Bag saving error: \(error.localizedDescription)")
                                }
                                
                                self.removeActivityView() {
                                    if let failure = failure {
                                        failure(error: error)
                                    }
                                }
                            }
                        }
                        // Bag already exist and we found it.
                    } else {
                        self.addItemToBag(bag[bag.count - 1], item: item, block: { (succeeded, error) in
                            if succeeded {
                                if let success = success {
                                    self.removeActivityView() {
                                        success()
                                    }
                                }
                            } else {
                                
                                if let error = error {
                                    print("Adding item to bag error: \(error.localizedDescription)")
                                }
                                
                                self.removeActivityView() {
                                    if let failure = failure {
                                        failure(error: error)
                                    }
                                }
                            }
                        })
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: NSLocalizedString("You are not registred", comment: "Alert title when user not registered"), message: NSLocalizedString("If you want add item to bag, please login in your account", comment: "Alert message when user not logged in and want add item to bag"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Log In", comment: ""), style: .Default, handler: { (action) in
                if let rootViewController = self.rootViewController {
                    rootViewController.presentViewController(LoginViewController(), animated: true, completion: nil)
                }
            }))
            
            if let rootViewController = self.rootViewController {
                rootViewController.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    //--------------------------------------
    // MARK: - Deleting -
    //--------------------------------------
    
    func deleteItem(itemToDelete item: BagItem, succeeded:(() -> ())?, failure:((error: NSError?) -> ())?) {
        let bagQuery = PFQuery(className: Bag.parseClassName())
        bagQuery.whereKey(Bag.FieldKey.userId.rawValue, equalTo: item.userId)
        
        bagQuery.findObjectsInBackgroundWithBlock() { (results, error) in
            if let error = error {
                if let failure = failure {
                    failure(error: error)
                }
            } else if let bag = results as? [Bag] {
                assert(bag.count == 1, "Bag must be unique for each user!")
                
                let bag = bag[0]
                
                // Remove item from bag.
                for (index, element) in bag.items.enumerate() {
                    if element == item.objectId! {
                        bag.items.removeAtIndex(index)
                        break
                    }
                }
                
                // Save changes.
                bag.saveInBackground()
                
                // Delete item.
                item.deleteInBackgroundWithBlock() { (success, error) in
                    if success {
                        if let succeeded = succeeded {
                            succeeded()
                        }
                    } else {
                        if let failure = failure {
                            failure(error: error)
                        }
                    }
                }
            }
        }
    }
}
