//
//  MySKTextField.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 11/06/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import RealmSwift

class MySKTextField: SKShapeNode, UITextFieldDelegate {
    var inputField = UITextField()
    var callBack: (String)->()
    init(parent: SKScene, position: CGPoint, callBack: (String)->()) {
        self.callBack = callBack
        super.init()
        let rect = CGRect(origin: CGPointMake(parent.frame.midX, parent.frame.midY), size: CGSizeMake(100, 30))
        self.path = CGPathCreateWithRect(rect, nil)

        self.position = rect.origin
        self.fillColor = UIColor.whiteColor()
        self.zPosition = 100
        
        
        self.inputField.delegate = self
        inputField.hidden = false
        inputField.font = UIFont(name: "Times New Roman", size: 30)
        inputField.textColor = UIColor.whiteColor()
        inputField.text = ""
        inputField.placeholder = "0"
        inputField.backgroundColor = UIColor.clearColor()
        inputField.frame = rect
        inputField.autocorrectionType = .No
        inputField.layer.borderWidth = 0.0
        inputField.becomeFirstResponder()
        inputField.keyboardType = .NumberPad
        parent.view!.addSubview(inputField)
        parent.addChild(self)
    }
    
    func textFieldShouldReturn(textField: UITextField)->Bool {
        let text = textField.text
        inputField.removeFromSuperview()
        self.removeFromParent()
        callBack(text!)
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

            let numberOnly = NSCharacterSet.init(charactersInString: "0123456789")
            
            let stringFromTextField = NSCharacterSet.init(charactersInString: string)
            
            let strValid = numberOnly.isSupersetOfSet(stringFromTextField)
            
            return strValid
        }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
