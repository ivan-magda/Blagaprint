//
//  LoadingView.swift
//  Blagaprint
//
//  Created by Иван Магда on 12.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    // MARK: - Properties
    
    private var activityIndicator: UIActivityIndicatorView
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        
        super.init(frame: frame)
        
        self.activityIndicator.color = AppAppearance.AppColors.vulcanColor
        let activityIndicatorSize = CGSizeMake(20.0, 20.0)
        
        let loadingLabel = UILabel(frame: CGRectZero)
        loadingLabel.text = "Загрузка..."
        loadingLabel.sizeToFit()
        
        let placeholderView = UIView(frame: CGRectZero)
        let horizontalSpace: CGFloat = 8.0
        let width: CGFloat = activityIndicatorSize.width + horizontalSpace + CGRectGetWidth(loadingLabel.bounds)
        let height: CGFloat = CGRectGetHeight(loadingLabel.bounds)
        let rect = CGRectMake(CGRectGetWidth(frame) / 2.0 - width / 2.0, CGRectGetHeight(frame) / 2.0 - height / 2.0, width, height)
        placeholderView.frame = rect
        
        let loadingLabelRect = CGRectMake(activityIndicatorSize.width + horizontalSpace, 0.0, CGRectGetWidth(loadingLabel.bounds), CGRectGetHeight(loadingLabel.bounds))
        loadingLabel.frame = loadingLabelRect
        
        placeholderView.addSubview(self.activityIndicator)
        placeholderView.addSubview(loadingLabel)
        self.addSubview(placeholderView)
        
        startAnimating()
    }

    required init?(coder aDecoder: NSCoder) {
        self.activityIndicator = UIActivityIndicatorView()
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - Behavior
    
    func startAnimating() {
        self.activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        self.activityIndicator.stopAnimating()
    }
}
