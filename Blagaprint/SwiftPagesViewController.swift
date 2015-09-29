//
//  SwiftPagesViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 29.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class SwiftPagesViewController: UIViewController {
    
    private let kGuillotineMenuSegueIdentifier = "MenuSegue"

    @IBOutlet weak var swiftPagesView: SwiftPages!
    @IBOutlet weak var barButton: UIButton!
    
// MARK: - ViewController lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSwiftPages()
    }
    
// MARK: - SwiftPages -
    
    func setUpSwiftPages() {
        //Initiation
        let VCIDs : [String] = ["ViewController", "ViewController"]
        let buttonTitles : [String] = ["Индивидуальное", "Сервисные Услуги"]
        
        //Customization
        swiftPagesView.setOriginY(0.0)
        swiftPagesView.setTopBarHeight(44.0)
        swiftPagesView.setAnimatedBarHeight(2.0)
        swiftPagesView.setTopBarBackground(AppAppearance.ebonyClayColor)
        swiftPagesView.setContainerViewBackground(AppAppearance.ebonyClayColor)
        swiftPagesView.setButtonsTextFontAndSize(UIFont.systemFontOfSize(14.0))
        swiftPagesView.setButtonsTextColor(AppAppearance.malibuColor)
        swiftPagesView.setAnimatedBarColor(AppAppearance.malibuColor)
        swiftPagesView.enableBarShadow(true)
        swiftPagesView.enableButtonsWithImages(false)
        //Initialize
        swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
    }
    
// MARK: - Navigation -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kGuillotineMenuSegueIdentifier {
            let destinationVC = segue.destinationViewController as! GuillotineMenuViewController
            destinationVC.hostNavigationBarHeight = CGRectGetHeight(self.navigationController!.navigationBar.frame)
            destinationVC.hostTitleText = self.navigationItem.title
            destinationVC.view!.backgroundColor = self.navigationController!.navigationBar.barTintColor
            destinationVC.setMenuButtonWithImage(self.barButton.imageView!.image!)
        }
    }
}
