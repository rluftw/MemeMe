//
//  TextFieldDelegate.swift
//  MemeMe
//
//  Created by Xing Hui Lu on 2/5/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation
import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text == "TOP" || text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
