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
    
    struct nameTableMember {
        var playerID: Int
        var name: String
        var isActPlayer: Bool
        init(playerID: Int, name: String, isActPlayer:Bool) {
            self.playerID = playerID
            self.name = name
            self.isActPlayer = isActPlayer
        }
    }
    var view: UIView
    var nameInputField = UITextField()
    var nameTable = [nameTableMember]()
    var nameTableIndex = 0
    var parentNode: SKSpriteNode

    init(parent: SKSpriteNode, view: UIView) {
        self.view = view
        let members = GV.realm.objects(PlayerModel)
        for index in 0..<members.count {
            nameTable.append(nameTableMember(playerID: members[index].ID, name: members[index].name, isActPlayer: members[index].isActPlayer))
        }
        let countLines = nameTable.count + (nameTable[0].name == GV.language.getText(.TCGuest) ? 0 : 1)
        self.parentNode = parent

        
        let texture: SKTexture = SKTexture(image: DrawImages().getTableImage(CGSizeMake(parent.frame.size.width, parent.frame.size.height),countLines: countLines, countRows: 1))
        super.init(texture: texture, color: UIColor.whiteColor(), size: parent.frame.size)

        self.position = CGPointMake(10, -10)
        self.color = UIColor.yellowColor()
        self.zPosition = parent.zPosition + 200
        
        if countLines == 1 && nameTable[0].name == GV.language.getText(.TCGuest) {
            getPlayerName("")
        } else {
            showPlayers()
        }

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
    
    func getPlayerName(name: String) {
        
        nameInputField.text = ""
        nameInputField.placeholder = GV.language.getText(.TCName)
        nameInputField.backgroundColor = UIColor(red: 229/255, green: 255/255, blue: 229/255, alpha: 1.0 )
        nameInputField.frame = CGRectMake(parentNode.position.x - parentNode.size.width / 2 + 50, parentNode.position.y - 50, size.width - 50, 30)
        nameInputField.delegate  = self
        nameInputField.autocorrectionType = .No
        nameInputField.layer.borderWidth = 0.0
        nameInputField.becomeFirstResponder()
        view.addSubview(nameInputField)
        
//        return nameInputField.text!
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        nameTable[nameTableIndex].name = nameInputField.text!
        updatePlayers()
        showPlayers()
        nameInputField.removeFromSuperview()
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

    func showPlayers() {
        
    }
    func updatePlayers() {
        GV.realm.beginWrite()
        let editedPlayer = GV.realm.objects(PlayerModel).filter("ID = \(nameTable[nameTableIndex].playerID)").first
        editedPlayer!.name = nameTable[nameTableIndex].name
        GV.realm.add(editedPlayer!, update: true)
        try! GV.realm.commitWrite()
    }
    

}
