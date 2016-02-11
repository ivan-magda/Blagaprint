//
//  ItemSizeCollectionViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 11.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import UIKit

public class ItemSizeCollectionViewController: UICollectionViewController {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    public var sizes: [String]?
    
    public var selectedSizeIndexPath: NSIndexPath?
    
    //--------------------------------------
    // MARK: - View Life Cycle
    //--------------------------------------
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //--------------------------------------
    // MARK: - Private
    //--------------------------------------
    
    private func updateCellBackgroundColorWithSelectState(select: Bool, cell: ItemSizeCollectionViewCell) {
        if select {
            cell.backgroundColor = AppAppearance.AppColors.green
            cell.sizeLabel?.textColor = UIColor.whiteColor()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
            cell.sizeLabel?.textColor = self.view.tintColor
        }
    }
    
    //--------------------------------------
    // MARK: - UICollectionViewDataSource
    //--------------------------------------
    
    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sizes?.count ?? 0
    }
    
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ItemSizeCollectionViewCell.cellReuseIdentifier, forIndexPath: indexPath) as! ItemSizeCollectionViewCell
        
        if let selectedIndex = selectedSizeIndexPath?.row where selectedIndex == indexPath.row {
            updateCellBackgroundColorWithSelectState(true, cell: cell)
        } else {
            updateCellBackgroundColorWithSelectState(false, cell: cell)
        }
        
        if sizes?.count <= 0 {
            cell.sizeLabel?.text = nil
            
            return cell
        } else {
            cell.sizeLabel?.text = sizes![indexPath.row]
            
            return cell
        }
    }
    
    //--------------------------------------
    // MARK: - UICollectionViewDelegate
    //--------------------------------------
    
    override public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Updates cell background color and sizeLabel text color
        // Green background color for the selected item
        // White color for the non selected item.
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ItemSizeCollectionViewCell
        
        if let selectedSizeIndex = self.selectedSizeIndexPath {
            // If index path's are the same, then deselect item.
            if selectedSizeIndex.row == indexPath.row {
                updateCellBackgroundColorWithSelectState(false, cell: cell)
                
                self.selectedSizeIndexPath = nil
                
                return
            } else {
                if selectedSizeIndexPath?.row > (collectionView.numberOfItemsInSection(0) - 1) {
                    updateCellBackgroundColorWithSelectState(true, cell: cell)
                } else {
                    let previousCell = collectionView.cellForItemAtIndexPath(selectedSizeIndex) as! ItemSizeCollectionViewCell
                    updateCellBackgroundColorWithSelectState(false, cell: previousCell)
                    
                    updateCellBackgroundColorWithSelectState(true, cell: cell)
                }
            }
        } else {
            updateCellBackgroundColorWithSelectState(true, cell: cell)
        }
        
        self.selectedSizeIndexPath = indexPath
    }
}
