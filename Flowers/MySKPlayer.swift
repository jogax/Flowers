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
    
    var callBack: ()->()
    let heightOfTableRow: CGFloat = 40
    var view: UIView
    var nameInputField = UITextField()
    var nameTable = [PlayerModel]()
    var nameTableIndex = 0
    var parentNode: SKSpriteNode
    var positionMultiplier = GV.deviceConstants.cardPositionMultiplier * 0.6
    var countLines = 0
    let myColumnWidths: [CGFloat] = [80, 10, 10]  // in %
    let deleteImage = DrawImages.getDeleteImage(CGSizeMake(30,30))
    let modifyImage = DrawImages.getModifyImage(CGSizeMake(30,30))
    let OKImage = DrawImages.getOKImage(CGSizeMake(30,30))
//    let statisticImage = DrawImages.getStatisticImage(CGSizeMake(30,30))
    let myName = "MyName"



    init(parent: SKSpriteNode, view: UIView, callBack: ()->()) {
        self.view = view
        nameTable = Array(GV.realm.objects(PlayerModel))
        countLines = nameTable.count// + (nameTable[0].name == GV.language.getText(.TCGuest) ? 0 : 1)
        self.parentNode = parent
        self.callBack = callBack
        let size = CGSizeMake(parent.frame.width * 0.9, CGFloat(countLines) * heightOfTableRow)

        
//        let texture: SKTexture = SKTexture(image: DrawImages().getTableImage(parent.frame.size,countLines: Int(countLines), countRows: 1))
        super.init(columnWidths: myColumnWidths, rows:countLines, headLines: "", parent: parent)
        self.name = myName
        
        let myPosition = CGPointMake(0, (parent.size.height - size.height) / 2 - 10)
        self.position = myPosition
        
        self.nameInputField.delegate = self
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
        self.userInteractionEnabled = false
        let yPosition = parentNode.position.y - parentNode.size.height * 0.435 + (CGFloat(row) * heightOfTableRow)
        let xPosition = parentNode.position.x - 0.405 * parentNode.size.width
        let name = nameTable[row].name == GV.language.getText(.TCGuest) ? "" : nameTable[row].name
        let myFont = UIFont(name: "Courier", size: fontSize)
        nameInputField.hidden = false
        nameInputField.font = myFont
        nameInputField.textColor = UIColor.blueColor()
        nameInputField.text = name
        nameInputField.placeholder = GV.language.getText(.TCNewName)
        nameInputField.backgroundColor = UIColor.whiteColor()
        nameInputField.frame = CGRectMake(xPosition, yPosition,
                                          size.width * 0.6,
                                          0.6 * self.size.height / CGFloat(countLines))
        nameInputField.autocorrectionType = .No
        nameInputField.layer.borderWidth = 0.0
        nameInputField.becomeFirstResponder()
        view.addSubview(nameInputField)
        
//        return nameInputField.text!
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        GV.realm.beginWrite()
        nameTable[nameTableIndex].name = nameInputField.text!
        try! GV.realm.commitWrite()
//        if nameTable.count > 1 {
//            changeActPlayer()
//        }
        nameInputField.hidden = true
        nameInputField.removeFromSuperview()
        addNewPlayerWhenRequired()
        showPlayers()
        self.userInteractionEnabled = true
    }
    
    
    func textFieldShouldReturn(textField: UITextField)->Bool {
        nameInputField.removeFromSuperview()
        return true
    }

    func showPlayers() {
        reDrawWhenChanged(myColumnWidths, rows: GV.realm.objects(PlayerModel).count)
        for index in 0..<nameTable.count {
            let name = nameTable[index].name == GV.language.getText(.TCGuest) ? "+" : nameTable[index].name
            showElementOfTable(name, column: 0, row: index, selected: nameTable[index].isActPlayer)
            showImageInTable(modifyImage, column: 1, row: index, selected: nameTable[index].isActPlayer)
            showImageInTable(deleteImage, column: 2, row: index, selected: nameTable[index].isActPlayer)
        }
    }
    

    func changeActPlayer () {
        GV.realm.beginWrite()
        let oldActPlayer = GV.realm.objects(PlayerModel).filter("isActPlayer = true").first
        var newActPlayer = GV.realm.objects(PlayerModel).filter("ID =  \(nameTable[nameTableIndex].ID)").first
        if newActPlayer == nil || newActPlayer!.name == GV.language.getText(.TCGuest) {
            newActPlayer = PlayerModel()
            newActPlayer!.ID = nameTable[nameTableIndex].ID
            newActPlayer!.name = nameTable[nameTableIndex].name
        }
        oldActPlayer!.isActPlayer = false
        newActPlayer!.isActPlayer = true
        let oldIndex = indexOfPlayerID(oldActPlayer!.ID)
        let newIndex = indexOfPlayerID(newActPlayer!.ID)
        nameTable[oldIndex!].isActPlayer = false
        nameTable[newIndex!].isActPlayer = true
        GV.realm.add(oldActPlayer!, update: true)
        GV.realm.add(newActPlayer!, update: true)
        try! GV.realm.commitWrite()
        showPlayers()
    }
    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
        touchesBeganAtNode = nodeAtPoint(touchLocation)
        if !(touchesBeganAtNode is SKLabelNode || (touchesBeganAtNode is SKSpriteNode && touchesBeganAtNode!.name != myName)) {
            touchesBeganAtNode = nil
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        _ = touches.first!.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
        let touchesEndedAtNode = nodeAtPoint(touchLocation)
        
        switch checkTouches(touches, withEvent: event) {
        case MyEvents.GoBackEvent:
            removeFromParent()
            callBack()
        case .NoEvent:

            if touchesBeganAtNode != nil && touchesEndedAtNode is SKLabelNode || (touchesEndedAtNode is SKSpriteNode && touchesEndedAtNode.name != myName) {
                let (column, row) = getColumnRowOfElement(touchesBeganAtNode!.name!)
                nameTableIndex = row
               if row == nameTable.count - 1 { // add new Player
                    let newPlayerID = addNewPlayerWhenRequired()
                    getPlayerName(indexOfPlayerID(newPlayerID)!)

                } else {
                    switch column {
                    case 0: // select a Player
                        changeActPlayer()
    //                    showPlayers()

//                    case 1: // choose a Player
//                        removeFromParent()
//                        callBack()
                    case 1: // modify the player
                        let playerToModify = GV.realm.objects(PlayerModel).filter("ID = \(nameTable[nameTableIndex].ID)").first
                        getPlayerName(indexOfPlayerID(playerToModify!.ID)!)
                    case 2: // delete the player
                        deletePlayer()
//                    case 4: // show statistic of the player
//                        _ = GV.realm.objects(PlayerModel).filter("ID =  \(nameTable[nameTableIndex].ID)").first
//
                    default: break
                    }
                 }
            }
        }
        
    }
    
    func addNewPlayerWhenRequired() -> Int {
        let lastPlayer = GV.realm.objects(PlayerModel).last!
        if lastPlayer.name == GV.language.getText(.TCGuest) {
            return lastPlayer.ID
        } else {
            let newPlayerID = GV.createNewPlayer()
            let array = Array(GV.realm.objects(PlayerModel).filter("ID = %d", newPlayerID))
            nameTable.appendContentsOf(array)
            nameTableIndex = nameTable.count - 1
//            changeActPlayer()
            return newPlayerID
        }
    }
    
    func deletePlayer() {
        if GV.realm.objects(PlayerModel).count > 1 {
            let playerToDelete = GV.realm.objects(PlayerModel).filter("ID = %d", nameTable[nameTableIndex].ID).first!
            GV.realm.beginWrite()
            nameTable.removeAtIndex(nameTableIndex)
            if GV.realm.objects(StatisticModel).filter("playerID = %d",  (playerToDelete.ID)).count > 0 {
                GV.realm.delete(GV.realm.objects(StatisticModel).filter("playerID = %d", playerToDelete.ID))
            }
            GV.playerID.putOldID(playerToDelete.ID)
            GV.realm.delete(playerToDelete)
            let playerToSetActPlayer = nameTable[0]
            playerToSetActPlayer.isActPlayer = true
            GV.realm.add(playerToSetActPlayer, update: true)
            //                        nameTable.removeAtIndex(nameTableIndex)
            try! GV.realm.commitWrite()
//            let size = CGSizeMake(parent!.frame.width * 0.9, CGFloat(nameTable.count + 1) * heightOfTableRow)
//            reDraw(size, columnWidths: myColumnWidths, rows: nameTable.count + 1)
            showPlayers()
        }
    }
    
    func indexOfPlayerID(ID:Int)->Int? {
        for index in 0..<nameTable.count {
            if nameTable[index].ID == ID {
                return index
            }
        }
        return nil
    }
}
