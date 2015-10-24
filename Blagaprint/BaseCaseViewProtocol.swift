//
//  BaseCaseViewProtocol.swift
//  Blagaprint
//
//  Created by Иван Магда on 24.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

protocol BaseCaseViewProtocol {
    // MARK: - Properties
    
    /// Device.
    var device: Device { get set }
    
    /// Case fill color.
    var fillColor: UIColor { get set }
    
    /// Text color.
    var textColor: UIColor { get set }
    
    /// Case background image.
    var image: UIImage { get set }
    
    /// Case text.
    var text: String { get set }
    
    /// Need to show case background image.
    var showBackgroundImage: Bool { get set }
    
    // MARK: - Functions
    
    static func getTextRectHeightFromNumberOfCharacters(characters: Int) -> CGFloat
    static func getTextYscaleFromNumberOfCharacters(characters: Int) -> CGFloat
    static func getTextXScaleFromText(text: String) -> CGFloat
    static func getTextFontSizeFromNumberOfCharacters(characters: Int) -> CGFloat
}
