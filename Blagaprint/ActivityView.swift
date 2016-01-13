//
//  LoadingView.swift
//  Blagaprint
//
//  Created by Иван Магда on 12.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class ActivityView: UIView {
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    private var activityIndicator: UIActivityIndicatorView
    
    //--------------------------------------
    // MARK: - Initializers
    //--------------------------------------
    
    init(frame: CGRect, message: String) {
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        self.activityIndicator.hidesWhenStopped = true
        
        super.init(frame: frame)
        
        viewSetupWithMessage(message)
    }
    
    override init(frame: CGRect) {
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        self.activityIndicator.hidesWhenStopped = true
        
        super.init(frame: frame)
        
        viewSetupWithMessage("")
    }

    required init?(coder aDecoder: NSCoder) {
        self.activityIndicator = UIActivityIndicatorView()
        
        super.init(coder: aDecoder)
    }
    
    //--------------------------------------
    // MARK: - Setup
    //--------------------------------------
    
    private func viewSetupWithMessage(message: String) {
        self.backgroundColor = UIColor.clearColor()
        
        let activityIndicatorSize = self.activityIndicator.bounds.size
        
        let messageLabel = UILabel(frame: CGRectZero)
        messageLabel.text = message
        messageLabel.textColor = UIColor.whiteColor()
        messageLabel.sizeToFit()
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        visualEffectView.frame = frame
        
        let placeholderView = UIView(frame: CGRectZero)
        let horizontalSpace: CGFloat = 8.0
        let width = activityIndicatorSize.width + horizontalSpace + CGRectGetWidth(messageLabel.bounds)
        let height = CGRectGetHeight(messageLabel.bounds)
        let rect = CGRectMake(CGRectGetWidth(frame) / 2.0 - width / 2.0, CGRectGetHeight(frame) / 2.0 - height / 2.0, width, height)
        placeholderView.frame = rect
        
        let loadingLabelRect = CGRectMake(activityIndicatorSize.width + horizontalSpace, 0.0, CGRectGetWidth(messageLabel.bounds), CGRectGetHeight(messageLabel.bounds))
        messageLabel.frame = loadingLabelRect
        
        placeholderView.addSubview(self.activityIndicator)
        placeholderView.addSubview(messageLabel)
        visualEffectView.addSubview(placeholderView)
        self.addSubview(visualEffectView)
    }
    
    //--------------------------------------
    // MARK: - Behavior
    //--------------------------------------
    
    func startAnimating() {
        self.activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        self.activityIndicator.stopAnimating()
    }
}
