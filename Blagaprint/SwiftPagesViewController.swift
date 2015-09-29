//
//  SwiftPagesViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 29.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class SwiftPagesViewController: UIViewController {

    @IBOutlet weak var swiftPagesView: SwiftPages!
    @IBOutlet weak var barButton: UIButton!
    
// MARK: - ViewController lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSwiftPages()
    }
    
    func setUpSwiftPages() {
        //Initiation
        let VCIDs : [String] = ["ViewController", "TestViewController"]
        let buttonTitles : [String] = ["Индивидуальное", "Сервисные Услуги"]
        
        //Customization
        swiftPagesView.setOriginY(0.0)
        swiftPagesView.setTopBarBackground(self.navigationController!.navigationBar.barTintColor!)
        swiftPagesView.enableBarShadow(false)
        swiftPagesView.setContainerViewBackground(UIColor(red: 40.0 / 255.0, green: 37.0 / 255.0, blue: 60.0 / 255.0, alpha: 1))
        swiftPagesView.setButtonsTextFontAndSize(UIFont.systemFontOfSize(14.0))
        
        let malibu = UIColor(red:89.0 / 255.0, green:189.0 / 255.0, blue:247.0 / 255.0, alpha:1)
        swiftPagesView.setButtonsTextColor(malibu)
        swiftPagesView.setAnimatedBarColor(malibu)
        
        swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
    }
    
// MARK: - Navigation -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MenuSegue" {
            let destinationVC = segue.destinationViewController as! GuillotineMenuViewController
            destinationVC.hostNavigationBarHeight = CGRectGetHeight(self.navigationController!.navigationBar.frame)
            destinationVC.hostTitleText = self.navigationItem.title
            destinationVC.view!.backgroundColor = self.navigationController!.navigationBar.barTintColor
            destinationVC.setMenuButtonWithImage(self.barButton.imageView!.image!)
        }
    }
}
