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
    let myColumnWidths: [CGFloat] = [80, 10, 10]
    let deleteImage = DrawImages().getDeleteImage(CGSizeMake(40,50))
    let modifyImage = DrawImages().getModifyImage(CGSizeMake(50,50))


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
        super.init(size: size, columnWidths: myColumnWidths, columns: 3, rows:countLines)

        let myPosition = CGPointMake(0, parent.position.y - parent.size.height * 0.58 )
        self.nameInputField.delegate = self
        self.position = myPosition
        
        self.zPosition = parent.zPosition + 200
        
        if countLines == 1 && nameTable[0].name == GV.language.getText(.TCGuest) {
            getPlayerName(0)
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
    
    func getPlayerName(row: Int) {
        let name = nameTable[row].name == GV.language.getText(.TCGuest) ? "" : nameTable[row].name
        nameInputField.text = name
        nameInputField.placeholder = GV.language.getText(.TCName)
        nameInputField.backgroundColor = UIColor(red: 229/255, green: 255/255, blue: 229/255, alpha: 1.0 )
        nameInputField.frame = CGRectMake(parentNode.position.x - 0.9 * (parentNode.size.width / 2),
                                          parentNode.position.y - 0.92 * (parentNode.size.height / 2),
                                          size.width * 0.8,
                                          0.8 * self.size.height / CGFloat(countLines))
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
    
    
    func textFieldShouldReturn(textField: UITextField)->Bool {
        textFieldDidEndEditing(textField)
        return true
    }

    func showPlayers() {
        for index in 0..<nameTable.count {
//            let fixedLength = 40
//            let lengthOfName = nameTable[index].name.characters.count
//            let spaces = String(count: fixedLength - lengthOfName, repeatedValue: (" " as Character))
            let name = nameTable[index].name // + spaces + ">"
            showElementOfTable(name, column: 0, row: index, selected: nameTable[index].isActPlayer)
            showImageInTable(modifyImage, column: 1, row: index, selected: nameTable[index].isActPlayer)
            showImageInTable(deleteImage, column: 2, row: index, selected: nameTable[index].isActPlayer)
        }
        showElementOfTable("+", column: 0, row: nameTable.count, selected: false)
    }
    
    func updatePlayers() {
        var doUpdate = true
        GV.realm.beginWrite()
        if let editedPlayer = GV.realm.objects(PlayerModel).filter("ID = \(nameTable[nameTableIndex].playerID)").first {
            editedPlayer.name = nameTable[nameTableIndex].name
            GV.realm.add(editedPlayer, update: true)
        } else {
            let newPlayer = PlayerModel()
            newPlayer.aktLanguageKey = GV.language.getAktLanguageKey()
            newPlayer.name = nameTable[nameTableIndex].name
            newPlayer.isActPlayer = true
            newPlayer.ID = nameTableIndex
            GV.realm.add(newPlayer)
        }
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
        
        if touchesBeganAtNode != nil && touchesBeganAtNode == touchesEndedAtNode && touchesBeganAtNode is SKLabelNode {
            let (column, row) = getColumnRowOfElement(touchesBeganAtNode!.name!)
            if row == nameTable.count {
                nameTable.append(nameTableMember(playerID: row, name: "", isActPlayer: false))
                nameTableIndex = nameTable.count
                let size = CGSizeMake(parent!.frame.width * 0.9, CGFloat(countLines) * heightOfTableRow)

                reDraw(size, columnWidths: myColumnWidths, columns: 0, rows: nameTableIndex)

            }
            nameTableIndex = row
            getPlayerName(row)
        }
        
        
    }
    
    

}
