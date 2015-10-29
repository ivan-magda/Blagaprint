//
//  IPhoneCase.swift
//  Blagaprint
//
//  Created by Ivan Magda on 11.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

@IBDesignable
class CaseView: UIView {
    // MARK: - Properties
    
    /// Device.
    var device = Device.iPhone5() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Case fill color.
    var fillColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// Text color.
    var textColor: UIColor = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// Case background image.
    var image: UIImage = UIImage() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// Case text.
    var text: String = "BLAGAPRINT" {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// Background image visability.
    var showBackgroundImage: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Drawing
    
    override func drawRect(rect: CGRect) {
        let numberOfCharacters = text.characters.count
        let textRectHeight = getTextRectHeightFromNumberOfCharacters(numberOfCharacters)
        let textYscale = getTextYscaleFromNumberOfCharacters(numberOfCharacters)
        let textSize = getTextFontSizeFromNumberOfCharacters(numberOfCharacters)
        let textXscale = getTextXScaleFromText(text)
        
        if device.name == Device.iPhone4().name {
            PhoneCase.drawIPhone4Case(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, caseText: text, backgroundImageVisible: showBackgroundImage, textRectHeight: textRectHeight, textYscale: textYscale, textSize: textSize, textXscale: textXscale)
        } else if device.name == Device.iPhone5().name {
            PhoneCase.drawIPhone5Case(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, caseText: text, backgroundImageVisible: showBackgroundImage, textRectHeight: textRectHeight, textYscale: textYscale, textSize: textSize, textXscale: textXscale)
        } else if device.name == Device.iPhone6().name {
            PhoneCase.drawIPhone6Case(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, caseText: text, backgroundImageVisible: showBackgroundImage, textRectHeight: textRectHeight, textYscale: textYscale, textSize: textSize, textXscale: textXscale)
        } else if device.name == Device.iPhone6Plus().name {
            PhoneCase.drawIPhone6PlusCase(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, caseText: text, backgroundImageVisible: showBackgroundImage, textRectHeight: textRectHeight, textYscale: textYscale, textSize: textSize, textXscale: textXscale)
        } else if device.name == Device.galaxyS3().name {
            PhoneCase.drawGalaxyS3(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, caseText: text, backgroundImageVisible: showBackgroundImage, textRectHeight: textRectHeight, textYscale: textYscale, textSize: textSize, textXscale: textXscale)
        } else if device.name == Device.galaxyS4().name {
            PhoneCase.drawGalaxyS4(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, caseText: text, backgroundImageVisible: showBackgroundImage, textRectHeight: textRectHeight, textYscale: textYscale, textSize: textSize, textXscale: textXscale)
        } else if device.name == Device.galaxyS4Mini().name {
            PhoneCase.drawGalaxyS4Mini(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, caseText: text, backgroundImageVisible: showBackgroundImage, textRectHeight: textRectHeight, textYscale: textYscale, textSize: textSize, textXscale: textXscale)
        } else if device.name == Device.galaxyS5().name {
            PhoneCase.drawGalaxyS5(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, caseText: text, backgroundImageVisible: showBackgroundImage, textRectHeight: textRectHeight, textYscale: textYscale, textSize: textSize, textXscale: textXscale)
        } else if device.name == Device.galaxyS5Mini().name {
            PhoneCase.drawGalaxyS5Mini(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, caseText: text, backgroundImageVisible: showBackgroundImage, textRectHeight: textRectHeight, textYscale: textYscale, textSize: textSize, textXscale: textXscale)
        } else if device.name == Device.galaxyS6().name ||
                  device.name == Device.galaxyS6Edge().name {
            PhoneCase.drawGalaxyS6(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, caseText: text, backgroundImageVisible: showBackgroundImage, textRectHeight: textRectHeight, textYscale: textYscale, textSize: textSize, textXscale: textXscale, device: device)
        } else if device.name == Device.galaxyA3().name ||
                  device.name == Device.galaxyA5().name {
            PhoneCase.drawGalaxyA3A5(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, caseText: text, backgroundImageVisible: showBackgroundImage, textRectHeight: textRectHeight, textYscale: textYscale, textSize: textSize, textXscale: textXscale, device: device)
        } else if device.name == Device.galaxyA7().name {
            GalaxyA7.drawGalaxyA7Canvas(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, textXscale: textXscale, textSize: textSize, backgroundImageVisible: showBackgroundImage, caseText: text, textYscale: textYscale, textRectHeight: textRectHeight)
        }
    }
    
    // MARK: - Text Label Dimensions
    
    static func fontSizeThatFitsRect(rect: CGRect, withText text: String, maxFontSize: CGFloat, minFontSize: CGFloat) -> CGFloat {
        let label = UILabel(frame: rect)
        label.text = text
        
        // Try all font sizes from largest to smallest font size
        var fontSize = maxFontSize
        let minimumFontSize = minFontSize
        
        // Fit label width wize
        let constraintSize = CGSizeMake(label.frame.size.width, CGFloat.max)
        
        repeat {
            // Set current font size
            label.font = AppAppearance.andersonSupercarFontWithSize(fontSize)
            
            // Find label size for current font size
            let textRect = (label.text! as NSString).boundingRectWithSize(constraintSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: label.font], context: nil)
            
            let labelSize = textRect.size
            
            // Done, if created label is within target size
            if labelSize.height <= CGRectGetHeight(label.bounds) {
                break
            }
            
            // Decrease the font size and try again
            --fontSize
        } while fontSize > minimumFontSize
        
        return fontSize
    }
    
    private func getTextYscaleFromNumberOfCharacters(characters: Int) -> CGFloat {
        var scale: CGFloat = 1.0
        
        // Check for empty text.
        if characters == 0 {
            return scale
        }
        
        // Calculate scale.
        for i in 1...characters {
            if i > 3 {
                scale += 0.2
            }
        }
        print("Y scale = \(scale)")
        
        return scale
    }
    
    private func getTextXScaleFromText(text: String) -> CGFloat {
        let numberOfCharacters = text.characters.count
        var scale: CGFloat = 1.0
        var countOnWideCharacter = 0
        
        // Count for wide characters.
        for character in text.characters {
            if character == "M" || character == "W" {
                ++countOnWideCharacter
            }
        }
        
        // Add extra value to x scale for specific case.
        if device.name == Device.iPhone4().name      ||
           device.name == Device.iPhone6Plus().name  ||
           device.name == Device.galaxyS3().name     ||
           device.name == Device.galaxyS4().name     ||
           device.name == Device.galaxyS4Mini().name ||
           device.name == Device.galaxyS5().name     ||
           device.name == Device.galaxyS5Mini().name ||
           device.name == Device.galaxyS6().name     ||
           device.name == Device.galaxyS6Edge().name ||
           device.name == Device.galaxyA3().name     ||
           device.name == Device.galaxyA5().name     ||
           device.name == Device.galaxyA7().name {
                if countOnWideCharacter < 2 {
                    scale += 0.1
                    if numberOfCharacters < 4 {
                        scale += 0.2
                    } else if countOnWideCharacter == 0 {
                        if numberOfCharacters < 7 {
                            scale += 0.1
                        }
                    }
                } else if countOnWideCharacter < 3 && numberOfCharacters < 4 {
                    scale += 0.1
                }
        } else {
            if countOnWideCharacter < 2 {
                scale += 0.1
                if numberOfCharacters < 4 {
                    scale += 0.3
                } else if countOnWideCharacter == 0 {
                    if numberOfCharacters < 7 {
                        scale += 0.2
                    } else if numberOfCharacters < 13 {
                        scale += 0.1
                    }
                }
            } else if countOnWideCharacter < 3 && numberOfCharacters < 4 {
                scale += 0.2
            }
        }
        
        print("X scale = \(scale)")
        
        return scale
    }
    
    private func getTextFontSizeFromNumberOfCharacters(characters: Int) -> CGFloat {
        if device.name == Device.iPhone5().name {
            switch characters {
            case 1, 2, 3:
                return 200.0
            case 4:
                return 151.0
            case 5:
                return 121.0
            case 6:
                return 100.0
            case 7:
                return 86.0
            case 8:
                return 75.0
            case 9:
                return 67.0
            case 10:
                return 60.0
            case 11:
                return 55.0
            case 12:
                return 50.0
            default:
                return 46.0
            }
        } else if device.name == Device.iPhone4().name  ||
                  device.name == Device.galaxyS3().name ||
                  device.name == Device.galaxyS5Mini().name ||
                  device.name == Device.galaxyA7().name {
            switch characters {
            case 1, 2:
                return 200.0
            case 3:
                return 191.0
            case 4:
                return 143.0
            case 5:
                return 114.0
            case 6:
                return 95.0
            case 7:
                return 81.0
            case 8:
                return 71.0
            case 9:
                return 63.0
            case 10:
                return 57.0
            case 11:
                return 52.0
            case 12:
                return 47
            default:
                return 44.0
            }
        } else if device.name == Device.iPhone6().name {
            switch characters {
            case 1, 2:
                return 220.0
            case 3:
                return 216.0
            case 4:
                return 162.0
            case 5:
                return 129.0
            case 6:
                return 108.0
            case 7:
                return 92.0
            case 8:
                return 81.0
            case 9:
                return 72.0
            case 10:
                return 64.0
            case 11:
                return 58.0
            case 12:
                return 54
            default:
                return 49.0
            }
        } else if device.name == Device.iPhone6Plus().name {
            switch characters {
            case 1, 2:
                return 240.0
            case 3:
                return 230.0
            case 4:
                return 173.0
            case 5:
                return 138.0
            case 6:
                return 115.0
            case 7:
                return 98.0
            case 8:
                return 86.0
            case 9:
                return 76.0
            case 10:
                return 69.0
            case 11:
                return 62.0
            case 12:
                return 57
            default:
                return 53.0
            }
        } else if device.name == Device.galaxyS4().name {
            switch characters {
            case 1, 2:
                return 220.0
            case 3:
                return 194.0
            case 4:
                return 145.0
            case 5:
                return 116.0
            case 6:
                return 97.0
            case 7:
                return 83.0
            case 8:
                return 72.0
            case 9:
                return 64.0
            case 10:
                return 58.0
            case 11:
                return 53.0
            case 12:
                return 48
            default:
                return 44.0
            }
        } else if device.name == Device.galaxyS4Mini().name ||
                  device.name == Device.galaxyA3().name     ||
                  device.name == Device.galaxyA5().name {
            switch characters {
            case 1, 2:
                return 220.0
            case 3:
                return 173.0
            case 4:
                return 129.0
            case 5:
                return 103.0
            case 6:
                return 86.0
            case 7:
                return 74.0
            case 8:
                return 64.0
            case 9:
                return 57.0
            case 10:
                return 51.0
            case 11:
                return 47.0
            case 12:
                return 43
            default:
                return 39.0
            }
        } else if device.name == Device.galaxyS5().name ||
                  device.name == Device.galaxyS6().name ||
                  device.name == Device.galaxyS6Edge().name {
            switch characters {
            case 1, 2:
                return 225.0
            case 3:
                return 201.0
            case 4:
                return 151.0
            case 5:
                return 121.0
            case 6:
                return 100.0
            case 7:
                return 86.0
            case 8:
                return 75.0
            case 9:
                return 67.0
            case 10:
                return 60.0
            case 11:
                return 55.0
            case 12:
                return 50.0
            default:
                return 46.0
            }
        }
        return 0.0
    }
    
    private func getTextRectHeightFromNumberOfCharacters(characters: Int) -> CGFloat {
        if device.name == Device.iPhone4().name      ||
           device.name == Device.iPhone5().name      ||
           device.name == Device.galaxyS3().name     ||
           device.name == Device.galaxyS4Mini().name ||
           device.name == Device.galaxyS5Mini().name ||
           device.name == Device.galaxyA3().name     ||
           device.name == Device.galaxyA5().name     ||
           device.name == Device.galaxyA7().name {
            switch characters {
            case 1, 2, 3:
                return 200.0
            case 4:
                return 167.0
            case 5:
                return 143.0
            case 6:
                return 125.0
            case 7:
                return 112.0
            case 8:
                return 100.0
            case 9:
                return 91.0
            case 10:
                return 84.0
            case 11:
                return 77.0
            case 12:
                return 72.0
            default:
                return 67.0
            }
        } else if device.name == Device.iPhone6().name ||
                  device.name == Device.galaxyS4().name {
            switch characters {
            case 1, 2, 3:
                return 220.0
            case 4:
                return 184.0
            case 5:
                return 157.0
            case 6:
                return 137.5
            case 7:
                return 122.0
            case 8:
                return 110.0
            case 9:
                return 100.0
            case 10:
                return 92.0
            case 11:
                return 85.0
            case 12:
                return 79.0
            default:
                return 74.0
            }
        } else if device.name == Device.iPhone6Plus().name {
            switch characters {
            case 1, 2, 3:
                return 240.0
            case 4:
                return 200.0
            case 5:
                return 171.5
            case 6:
                return 150.0
            case 7:
                return 133.0
            case 8:
                return 120.0
            case 9:
                return 109.0
            case 10:
                return 100.0
            case 11:
                return 92.0
            case 12:
                return 85.0
            default:
                return 80.0
            }
        } else if device.name == Device.galaxyS5().name ||
                  device.name == Device.galaxyS6().name ||
                  device.name == Device.galaxyS6Edge().name {
            switch characters {
            case 1, 2, 3:
                return 225.0
            case 4:
                return 187.5
            case 5:
                return 161.0
            case 6:
                return 141.0
            case 7:
                return 125.0
            case 8:
                return 112.5
            case 9:
                return 102.0
            case 10:
                return 94.0
            case 11:
                return 86.5
            case 12:
                return 80.0
            default:
                return 75.0
            }
        }
        return 0.0
    }
}

// MARK: - NSShadow Extension -

extension NSShadow {
    convenience init(color: AnyObject!, offset: CGSize, blurRadius: CGFloat) {
        self.init()
        self.shadowColor = color
        self.shadowOffset = offset
        self.shadowBlurRadius = blurRadius
    }
}

// MARK: - objc Protocols -

@objc protocol StyleKitSettableImage {
    var image: UIImage! { get set }
}

@objc protocol StyleKitSettableSelectedImage {
    var selectedImage: UIImage! { get set }
}
