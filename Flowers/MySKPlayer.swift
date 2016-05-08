//
//  MySKPlayer.swift
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
    var nameInputField = UITextField()
    var nameTable = [PlayerModel]()
    var nameTableIndex = 0
    var parentNode: SKSpriteNode
    var positionMultiplier = GV.deviceConstants.cardPositionMultiplier * 0.6
    var countLines = 0
    let myColumnWidths: [CGFloat] = [70, 15, 15]  // in %
    let imageSize = CGSizeMake(30 * GV.deviceConstants.imageSizeMultiplier,30 * GV.deviceConstants.imageSizeMultiplier)
    var deleteImage: UIImage
    var modifyImage: UIImage
    var OKImage: UIImage
//    let statisticImage = DrawImages.getStatisticImage(CGSizeMake(30,30))
    let myName = "MySKPlayer"



    init(parent: SKSpriteNode, view: UIView, callBack: ()->()) {
        nameTable = Array(GV.realm.objects(PlayerModel))
        countLines = nameTable.count// + (nameTable[0].name == GV.language.getText(.TCGuest) ? 0 : 1)
        self.parentNode = parent
        self.callBack = callBack
        let size = CGSizeMake(parent.frame.width * 0.9, CGFloat(countLines) * heightOfTableRow)
        self.deleteImage = DrawImages.getDeleteImage(imageSize)
        self.modifyImage = DrawImages.getModifyImage(imageSize)
        self.OKImage = DrawImages.getOKImage(imageSize)

        
//        let texture: SKTexture = SKTexture(image: DrawImages().getTableImage(parent.frame.size,countLines: Int(countLines), countRows: 1))
        super.init(columnWidths: myColumnWidths, rows:countLines, headLines: "", parent: parent)
        self.name = myName
        self.parentView = view
        
        let myPosition = CGPointMake(0, (parent.size.height - size.height) / 2 - 10)
        self.position = myPosition
        
        self.nameInputField.delegate = self
        self.zPosition = parent.zPosition + 200
        
        
        showPlayers()

        

        self.alpha = 1.0
//        self.userInteractionEnabled = true
        parent.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPlayerName(row: Int) {
        self.userInteractionEnabled = false
        let name = nameTable[row].name == GV.language.getText(.TCAnonym) ? "" : nameTable[row].name
        let myFont = UIFont(name: "Times New Roman", size: fontSize)
        
        let xPosition = positionsTable[0][row].x
        let yPosition = parentView!.frame.size.height - positionsTable[0][row].y - 0.8 * heightOfLabelRow / 2
        nameInputField.hidden = false
        nameInputField.font = myFont
        nameInputField.textColor = UIColor.blueColor()
        nameInputField.text = name
        nameInputField.placeholder = GV.language.getText(.TCNewName)
        nameInputField.backgroundColor = UIColor.whiteColor()
        nameInputField.frame = CGRectMake(xPosition, yPosition,
                                          size.width * 0.6,
                                          heightOfTableRow * 0.8)
        nameInputField.autocorrectionType = .No
        nameInputField.layer.borderWidth = 0.0
        nameInputField.becomeFirstResponder()
        parentView!.addSubview(nameInputField)
        
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
            let name = nameTable[index].name == GV.language.getText(.TCAnonym) ? "+" : nameTable[index].name
            var elements: [MultiVar] = [MultiVar(string: name)]
            if !(name == "+") {
                elements.append(MultiVar(image: modifyImage))
                elements.append(MultiVar(image: deleteImage))
            }
            showLineOfTable(elements, row: index, selected: nameTable[index].isActPlayer)
        }
        if nameTable[0].name == GV.language.getText(.TCAnonym) {
            getPlayerName(0)
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
        if lastPlayer.name == GV.language.getText(.TCAnonym) {
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
