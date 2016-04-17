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
    let heightOfTableRow: CGFloat = 40
    var view: UIView
    var nameInputField = UITextField()
    var nameTable = [nameTableMember]()
    var nameTableIndex = 0
    var parentNode: SKSpriteNode
    var positionMultiplier = GV.deviceConstants.cardPositionMultiplier * 0.6
    var countLines = 0
    let myColumnWidths: [CGFloat] = [60, 10, 10, 10, 10]
    let deleteImage = DrawImages.getDeleteImage(CGSizeMake(30,30))
    let modifyImage = DrawImages.getModifyImage(CGSizeMake(30,30))
    let OKImage = DrawImages.getOKImage(CGSizeMake(30,30))
    let statisticImage = DrawImages.getStatisticImage(CGSizeMake(30,30))
    let myName = "MyName"


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
        self.name = myName
        
        let myPosition = CGPointMake(0, (parent.size.height - size.height) / 2 - 10)
        
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
        let yPosition = parentNode.position.y - parentNode.size.height * 0.474 + (CGFloat(row) * heightOfTableRow)
        let xPosition = parentNode.position.x - 0.405 * parentNode.size.width
        let name = nameTable[row].name == GV.language.getText(.TCGuest) ? "" : nameTable[row].name
        let myFont = UIFont(name: "ArialMT", size: fontSize)
        nameInputField.font = myFont
        nameInputField.textColor = UIColor.blueColor()
        nameInputField.text = name
        nameInputField.placeholder = GV.language.getText(.TCNewName)
        nameInputField.backgroundColor = UIColor.whiteColor()
        nameInputField.frame = CGRectMake(xPosition, yPosition,
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
        nameInputField.removeFromSuperview()
        changeActPlayer()
        updatePlayers()
        showPlayers()
    }
    
    
    func textFieldShouldReturn(textField: UITextField)->Bool {
        textFieldDidEndEditing(textField)
        return true
    }

    func showPlayers() {
        for index in 0..<nameTable.count {
            let name = nameTable[index].name
            showElementOfTable(name, column: 0, row: index, selected: nameTable[index].isActPlayer)
            showImageInTable(OKImage, column: 1, row: index, selected: nameTable[index].isActPlayer)
            showImageInTable(modifyImage, column: 2, row: index, selected: nameTable[index].isActPlayer)
            showImageInTable(deleteImage, column: 3, row: index, selected: nameTable[index].isActPlayer)
            showImageInTable(statisticImage, column: 4, row: index, selected: nameTable[index].isActPlayer)
        }
        showElementOfTable(GV.language.getText(.TCNewName), column: 0, row: nameTable.count, selected: false)
    }
    
    func updatePlayers() {
        GV.realm.beginWrite()
        if let editedPlayer = GV.realm.objects(PlayerModel).filter("ID = \(nameTableIndex)").first {
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
        if !(touchesBeganAtNode is SKLabelNode || (touchesBeganAtNode is SKSpriteNode && touchesBeganAtNode!.name != myName)) {
            touchesBeganAtNode = nil
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
        let touchesEndedAtNode = nodeAtPoint(touchLocation)
        if touchesBeganAtNode != nil && touchesEndedAtNode is SKLabelNode || (touchesEndedAtNode is SKSpriteNode && touchesEndedAtNode.name != myName) {
            let (column, row) = getColumnRowOfElement(touchesBeganAtNode!.name!)
            nameTableIndex = row
           if row == nameTable.count { // add new Player
                nameTable.append(nameTableMember(playerID: row, name: "", isActPlayer: false))
                nameTableIndex = nameTable.count - 1
                let size = CGSizeMake(parent!.frame.width * 0.9, CGFloat(countLines) * heightOfTableRow)
                reDraw(size, columnWidths: myColumnWidths, columns: 0, rows: nameTableIndex + 1)
                getPlayerName(row)

            } else {
                switch column {
                case 0: // select a Player
                    changeActPlayer()
                    showPlayers()

                case 1: // choose a Player
                    changeActPlayer()
                    removeFromParent()
                case 2: // modify the player
                    let playerToModify = GV.realm.objects(PlayerModel).filter("ID = \(nameTable[nameTableIndex].playerID)").first
                    getPlayerName(playerToModify!.ID)
                case 3: // delete the player
                    if GV.realm.objects(PlayerModel).count > 1 {
                        let playerToDelete = GV.realm.objects(PlayerModel).filter("ID =  \(nameTable[nameTableIndex].playerID)").first
                        GV.realm.delete(playerToDelete!)
                    }
                case 4: // show statistic of the player
                    let playerforStatistic = GV.realm.objects(PlayerModel).filter("ID =  \(nameTable[nameTableIndex].playerID)").first

                default: break
                }
             }
        }
        
        
    }
    
    func changeActPlayer () {
        GV.realm.beginWrite()
        let oldActPlayer = GV.realm.objects(PlayerModel).filter("isActPlayer = true").first
        var newActPlayer = GV.realm.objects(PlayerModel).filter("ID =  \(nameTable[nameTableIndex].playerID)").first
        if newActPlayer == nil {
            newActPlayer = PlayerModel()
            newActPlayer!.ID = nameTable[nameTableIndex].playerID
            newActPlayer!.name = nameTable[nameTableIndex].name
        }
        oldActPlayer!.isActPlayer = false
        newActPlayer!.isActPlayer = true
        nameTable[oldActPlayer!.ID].isActPlayer = false
        nameTable[newActPlayer!.ID].isActPlayer = true
        GV.realm.add(oldActPlayer!, update: true)
        GV.realm.add(newActPlayer!, update: true)
        try! GV.realm.commitWrite()
    }
    
    

}
