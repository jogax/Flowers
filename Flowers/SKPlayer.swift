//
//  SKPlayerNode.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 04/04/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import RealmSwift

class SKPlayer: SKSpriteNode, UITextFieldDelegate {
    var view: UIView
    var nameInputField = UITextField()

    init(parent: SKSpriteNode, view: UIView) {
        self.view = view
        let countLines = GV.realm.objects(PlayerModel).count
        
        let texture: SKTexture = SKTexture(image: DrawImages().getTableImage(CGSizeMake(parent.frame.size.width, parent.frame.size.height),countLines: countLines, countRows: 1))
        
        super.init(texture: texture, color: UIColor.whiteColor(), size: parent.frame.size)
        if countLines == 1 && GV.realm.objects(PlayerModel).first!.name == GV.language.getText(.TCGuest) {
            let name = getPlayerName(GV.language.getText(.TCName))
            print (name)
        } else {
            
        }

        self.position = CGPointMake(10, -10)
        self.color = UIColor.yellowColor()
        self.zPosition = parent.zPosition + 200

        self.alpha = 1.0
        self.userInteractionEnabled = true
        parent.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.removeFromParent()
    }
    
    func getPlayerName(placeHolder: String)->String{
        nameInputField.text = placeHolder
        nameInputField.placeholder = GV.language.getText(.TCName)
        nameInputField.frame.origin = self.frame.origin
        nameInputField.borderStyle = .RoundedRect
        nameInputField.layer.borderColor = UIColor.blackColor().CGColor
        nameInputField.delegate  = self
        nameInputField.returnKeyType = UIReturnKeyType.Default
        nameInputField.autocorrectionType = .No
        //nameInputField.layer.shadowColor = UIColor.blackColor().CGColor
        //nameInputField.layer.shadowOffset = CGSizeMake(5, 5)
        nameInputField.layer.borderWidth = 1.0
        nameInputField.translatesAutoresizingMaskIntoConstraints = false
        nameInputField.becomeFirstResponder()
        view.addSubview(nameInputField)
        return nameInputField.text!
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let _ = 0
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textFieldEditingDidChange(sender: AnyObject) {
        print("textField:hier)")
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        _ = 0
    }


}
