//
//  TextEditingViewController.swift
//  Blagaprint
//
//  Created by Niko on 14.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class TextEditingViewController: UIViewController {
    // MARK: - Properties
    
    /// Text field.
    @IBOutlet weak var textField: UITextField!
    
    /// Done bar button.
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    /// Case text.
    var text: String = ""
    
    /// Done on text completion handler.
    var didDoneOnTextCompletionHandler: ((String) -> ())?

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurateTextField()
    }
    
    // MARK: - Private
    
    private func configurateTextField() {
        textField.text = text
        textField.delegate = self
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
    
    // MARK: - IBActions
    
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

// MARK: - UITextFieldDelegate -

extension TextEditingViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        text = newText.uppercaseString
        
        return true
    }
}
