//
//  SKPlayerNode.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 04/04/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import RealmSwift

class MySKPlayer: MySKTable, UITextFieldDelegate {
    
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
    let heightOfTableRow: CGFloat = 30
    var view: UIView
    var nameInputField = UITextField()
    var nameTable = [nameTableMember]()
    var nameTableIndex = 0
    var parentNode: SKSpriteNode
    var positionMultiplier = GV.deviceConstants.cardPositionMultiplier * 0.6
    var countLines = 0

    init(parent: SKSpriteNode, view: UIView) {
        self.view = view
        let members = GV.realm.objects(PlayerModel)
        for index in 0..<members.count {
            nameTable.append(nameTableMember(playerID: members[index].ID, name: members[index].name, isActPlayer: members[index].isActPlayer))
        }
        countLines = nameTable.count + (nameTable[0].name == GV.language.getText(.TCGuest) ? 0 : 1)
        self.parentNode = parent
        let size = CGSizeMake(parent.frame.width * 0.9, CGFloat(countLines) * heightOfTableRow)

        
//        let texture: SKTexture = SKTexture(image: DrawImages().getTableImage(parent.frame.size,countLines: Int(countLines), countRows: 1))
        super.init(size: size, columns: 1, rows:countLines)

        let myPosition = CGPointMake(0, parent.position.y - parent.size.height * 0.58 )
        self.position = myPosition
        
        self.zPosition = parent.zPosition + 200
        
        if countLines == 1 && nameTable[0].name == GV.language.getText(.TCGuest) {
            getPlayerName("")
        } else {
            showPlayers()
        }

        self.alpha = 1.0
//        self.userInteractionEnabled = true
        parent.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func getPlayerName(name: String) {
        
        nameInputField.text = name
        nameInputField.placeholder = GV.language.getText(.TCName)
        nameInputField.backgroundColor = UIColor(red: 229/255, green: 255/255, blue: 229/255, alpha: 1.0 )
        nameInputField.frame = CGRectMake(parentNode.position.x - 0.9 * (parentNode.size.width / 2),
                                          parentNode.position.y - 0.92 * (parentNode.size.height / 2),
                                          size.width * 0.8,
                                          0.8 * self.size.height / CGFloat(countLines))
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
    
    func textFieldShouldReturn(textField: UITextField)->Bool {
        nameTable[nameTableIndex].name = nameInputField.text!
        updatePlayers()
        showPlayers()
        nameInputField.removeFromSuperview()

       return true
    }

    func showPlayers() {
        for index in 0..<nameTable.count {
            showElementOfTable(nameTable[index].name + "   >", column: 0, row: index, selected: nameTable[index].isActPlayer)
        }
        showElementOfTable("+", column: 0, row: nameTable.count, selected: false)
    }
    
    func updatePlayers() {
        GV.realm.beginWrite()
        let editedPlayer = GV.realm.objects(PlayerModel).filter("ID = \(nameTable[nameTableIndex].playerID)").first
        editedPlayer!.name = nameTable[nameTableIndex].name
        GV.realm.add(editedPlayer!, update: true)
        try! GV.realm.commitWrite()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
        touchesBeganAtNode = nodeAtPoint(touchLocation)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
        let touchesEndedAtNode = nodeAtPoint(touchLocation)
        
        if touchesBeganAtNode != nil && touchesBeganAtNode == touchesEndedAtNode {
            let (column, row) = getColumnRowOfElement(touchesEndedAtNode.name!)
            if row == nameTable.count {
                getPlayerName("Gálka")
            }
        }
        self.removeFromParent()
        
        
    }
    
    

}
