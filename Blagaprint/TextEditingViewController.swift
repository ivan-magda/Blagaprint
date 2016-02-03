//
//  TextEditingViewController.swift
//  Blagaprint
//
//  Created by Niko on 14.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

enum TextEditingViewControllerTextFieldAttributes: Int {
    case KeyboardType
    case TextLengthLimit
}

class TextEditingViewController: UIViewController {
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    /// Text field.
    @IBOutlet weak var textField: UITextField!
    
    /// Done bar button.
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    /// Text for textFiled.
    var text: String = ""
    
    /// Text length limit for text filed.
    /// 0 and less is equal to unlimited.
    var textLengthLimit = 0
    
    /// Use this variable to set keyboard type of the text field.
    var keyboardType: UIKeyboardType?
    
    /// Done on text completion handler.
    var didDoneOnTextCompletionHandler: ((String) -> ())?

    //--------------------------------------
    // MARK: - View Life Cycle
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurateTextField()
        
        self.doneButton.enabled = false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        self.view.endEditing(true)
    }
    
    //--------------------------------------
    // MARK: - Private
    //--------------------------------------
    
    private func configurateTextField() {
        textField.text = text
        textField.delegate = self
        
        if let type = keyboardType {
            textField.keyboardType = type
        }
        
        textField.becomeFirstResponder()
    }
    
    private func doneOnText() {
        textField.resignFirstResponder()
        
        text = textField.text!.uppercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if let callBack = didDoneOnTextCompletionHandler {
            weak var weakSelf = self
            callBack(weakSelf!.text)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //--------------------------------------
    // MARK: - IBActions
    //--------------------------------------
    
    @IBAction func textFieldDidEndOnText(sender: UITextField) {
        doneOnText()
    }
    
    @IBAction func cancelButtonDidPressed(sender: UIBarButtonItem) {
        textField.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonDidPressed(sender: UIBarButtonItem) {
        doneOnText()
    }
}

//--------------------------------------
// MARK: - UITextFieldDelegate -
//--------------------------------------

extension TextEditingViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        text = newText.uppercaseString
        
        self.doneButton.enabled = newText.characters.count > 0
        
        // Check for length limit.
        if textLengthLimit <= 0 {
            return true
        } else {
            return newText.characters.count <= textLengthLimit
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
}
