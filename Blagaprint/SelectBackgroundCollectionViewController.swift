//
//  SelectBackgroundCollectionViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 12.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class SelectBackgroundCollectionViewController: UICollectionViewController {
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    /// Cell identifier.
    static let kCellIdentifier = "BackgroundCell"
    
    /// Call back when done button presses with picked color.
    var didSelectColorCompletionHandler: ((UIColor) -> ())?
    
    /// Current selected color.
    var selectedColor: UIColor!
    
    /// Supported colors.
    let colors: [UIColor] = [UIColor.blackColor(), UIColor.darkGrayColor(), UIColor.lightGrayColor(), UIColor.whiteColor(), UIColor.grayColor(), UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.cyanColor(), UIColor.yellowColor(), UIColor.magentaColor(), UIColor.orangeColor(), UIColor.purpleColor(), UIColor.brownColor()]
    
    //--------------------------------------
    // MARK: - View Life Cycle
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(selectedColor != nil)
    }
    
    //--------------------------------------
    // MARK: - Private
    //--------------------------------------
    
    private func doneWithColorSelecting(color: UIColor) {
        if let callBack = didSelectColorCompletionHandler {
            callBack(color)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //--------------------------------------
    // MARK: - UICollectionView
    //--------------------------------------
    
    //--------------------------------------
    // MARK: UICollectionViewDataSource
    //--------------------------------------
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SelectBackgroundCollectionViewController.kCellIdentifier, forIndexPath: indexPath) as! BackgroundCollectionViewCell
        cell.ovalView.fillColor = colors[indexPath.row]
        cell.ovalView.checkmarkVisible = cell.ovalView.fillColor == selectedColor
        
        return cell
    }
    
    //--------------------------------------
    // MARK: UICollectionViewDelegate
    //--------------------------------------
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedColor = colors[indexPath.row]
        collectionView.reloadData()
    }
    
    //--------------------------------------
    // MARK: IBActions
    //--------------------------------------

    @IBAction func cancelButtonDidPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonDidPressed(sender: UIBarButtonItem) {
        doneWithColorSelecting(selectedColor)
    }
}
