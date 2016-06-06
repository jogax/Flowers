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
//    var heightOfTableRow: CGFloat = 0
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
    var sleepTime: Double = 0



    init(parent: SKSpriteNode, view: UIView, callBack: ()->()) {
        nameTable = Array(realm.objects(PlayerModel).sorted("created", ascending: true))
        countLines = nameTable.count// + (nameTable[0].name == GV.language.getText(.TCGuest) ? 0 : 1)
        self.parentNode = parent
        self.callBack = callBack
        self.deleteImage = DrawImages.getDeleteImage(imageSize)
        self.modifyImage = DrawImages.getModifyImage(imageSize)
        self.OKImage = DrawImages.getOKImage(imageSize)

        
//        let texture: SKTexture = SKTexture(image: DrawImages().getTableImage(parent.frame.size,countLines: Int(countLines), countRows: 1))
        super.init(columnWidths: myColumnWidths, rows:countLines, headLines: [], parent: parent)

        self.name = myName
        self.parentView = view
//        let size = CGSizeMake(parent.frame.width * 0.9, CGFloat(countLines) * self.heightOfLabelRow)
        
//        let myStartPosition = CGPointMake(0, (parent.size.height - size.height) / 2 - 10)
//        self.position = myStartPosition
        
//        let myTargetPosition = CGPointMake(view.frame.size.width / 2, view.frame.size.height / 2)
        
        self.nameInputField.delegate = self
        self.zPosition = parent.zPosition + 200
        
        
        showMe(showPlayers)
        

//        self.alpha = 1.0
//        let actionMove = SKAction.moveTo(myTargetPosition, duration: 0.5)
//        let alphaAction = SKAction.fadeOutWithDuration(0.5)
//        parent.parent!.addChild(self)
//        
//        parent.runAction(alphaAction)
//        self.runAction(actionMove)
//        parent.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func getPlayerName(row: Int) {
        self.userInteractionEnabled = false
        let name = nameTable[row].name == GV.language.getText(.TCAnonym) ? "" : nameTable[row].name
        let myFont = UIFont(name: "Times New Roman", size: fontSize)
        
        let labelName = "0\(separator)\(row)"
        
        if childNodeWithName(labelName) == nil {
           addNewPlayerWhenRequired()
        }
        
        let position = (self.childNodeWithName(labelName) as! SKLabelNode).position

        
        let xPosition = parentView!.frame.size.width / 2 + position.x
        let yPosition = parentView!.frame.size.height / 2 - position.y - heightOfLabelRow * 0.45
        nameInputField.hidden = false
        nameInputField.font = myFont
        nameInputField.textColor = UIColor.blueColor()
        nameInputField.text = name
        nameInputField.placeholder = GV.language.getText(.TCNewName)
        nameInputField.backgroundColor = UIColor.whiteColor()
        nameInputField.frame = CGRectMake(xPosition, yPosition,
                                          size.width * 0.6,
                                          heightOfLabelRow * 0.8)
        nameInputField.autocorrectionType = .No
        nameInputField.layer.borderWidth = 0.0
        nameInputField.becomeFirstResponder()
        parentView!.addSubview(nameInputField)
        
//        return nameInputField.text!
    }
    
    func removeBraces(s:String)->String {
        return s.stringByTrimmingCharactersInSet(NSCharacterSet.init(charactersInString: "{}"))
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        try! realm.write({
            nameTable[nameTableIndex].name = nameInputField.text!
        })
        nameInputField.hidden = true
        nameInputField.removeFromSuperview()
        sleep(0.5)
        addNewPlayerWhenRequired()
        showPlayers()
        self.userInteractionEnabled = true
    }
    
    func sleep(delay: Double) {
        let startTime = NSDate()
        var endTime: NSDate
        repeat {
            endTime = NSDate()
        } while endTime.timeIntervalSinceDate(startTime) < delay
        print(endTime.timeIntervalSinceDate(startTime))
    }
    
    
    func textFieldShouldReturn(textField: UITextField)->Bool {
        nameInputField.removeFromSuperview()
        return true
    }

    func showPlayers() {
        reDrawWhenChanged(myColumnWidths, rows: realm.objects(PlayerModel).count)
        for index in 0..<nameTable.count {
            let name = nameTable[index].name == GV.language.getText(.TCAnonym) ? "+" : nameTable[index].name
            var elements: [MultiVar] = [MultiVar(string: name)]
            if !(name == "+") {
                elements.append(MultiVar(image: modifyImage))
                if nameTable.count > 2 {
                    elements.append(MultiVar(image: deleteImage))
                }
            }
            showRowOfTable(elements, row: index, selected: nameTable[index].isActPlayer)
        }
        if nameTable[0].name == GV.language.getText(.TCAnonym) {
            getPlayerName(0)
        }
    }
    

    func changeActPlayer () {
        try! realm.write({
            let oldActPlayer = realm.objects(PlayerModel).filter("isActPlayer = true").first
            var newActPlayer = realm.objects(PlayerModel).filter("ID =  \(nameTable[nameTableIndex].ID)").first
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
            realm.add(oldActPlayer!, update: true)
            realm.add(newActPlayer!, update: true)
            GV.player = newActPlayer
        })
        GV.language.setLanguage(GV.player!.aktLanguageKey)
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
            GV.player = realm.objects(PlayerModel).filter("isActPlayer = true").first
            let fadeInAction = SKAction.fadeInWithDuration(0.5)
            myParent.runAction(fadeInAction)
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
                    case 1: // modify the player
                        let playerToModify = realm.objects(PlayerModel).filter("ID = \(nameTable[nameTableIndex].ID)").first
                        getPlayerName(indexOfPlayerID(playerToModify!.ID)!)
                    case 2: // delete the player
                        deletePlayer()
                    default: break
                    }
                 }
            }
        }
        
    }
    
    func addNewPlayerWhenRequired() -> Int {
        let lastPlayer = realm.objects(PlayerModel).sorted("created", ascending: false).first!
        if lastPlayer.name == GV.language.getText(.TCAnonym) {
            return lastPlayer.ID
        } else {
            let newPlayerID = GV.createNewPlayer()
            if newPlayerID > 0 {
                let array = Array(realm.objects(PlayerModel).filter("ID = %d", newPlayerID))
                nameTable.appendContentsOf(array)
                nameTableIndex = nameTable.count - 1
            }
            return newPlayerID
        }
    }
    
    func deletePlayer() {
        if realm.objects(PlayerModel).count > 1 {
            let playerToDelete = realm.objects(PlayerModel).filter("ID = %d", nameTable[nameTableIndex].ID).first!
            try! realm.write({
                nameTable.removeAtIndex(nameTableIndex)
                realm.delete(realm.objects(StatisticModel).filter("playerID = %d", playerToDelete.ID))
                realm.delete(realm.objects(GameToPlayerModel).filter("playerID = %d", playerToDelete.ID))
                realm.delete(playerToDelete)
                let playerToSetActPlayer = nameTable[0]
                playerToSetActPlayer.isActPlayer = true
                realm.add(playerToSetActPlayer, update: true)
                GV.player = playerToSetActPlayer
                //                        nameTable.removeAtIndex(nameTableIndex)
            })
            if realm.objects(PlayerModel).filter("name = %c", GV.language.getText(.TCAnonym)).count == 0 {
                addNewPlayerWhenRequired()
            }
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
    override func setMyDeviceSpecialConstants() {
        switch GV.deviceConstants.type {
        case .iPadPro12_9:
            fontSize = CGFloat(20)
            heightOfLabelRow = 40
        case .iPad2:
            fontSize = CGFloat(20)
            heightOfLabelRow = 40
        case .iPadMini:
            fontSize = CGFloat(20)
            heightOfLabelRow = 40
        case .iPhone6Plus:
            fontSize = CGFloat(15)
            heightOfLabelRow = 35
        case .iPhone6:
            fontSize = CGFloat(15)
            heightOfLabelRow = 35
        case .iPhone5:
            fontSize = CGFloat(13)
            heightOfLabelRow = 30
        case .iPhone4:
            fontSize = CGFloat(12)
            heightOfLabelRow = 30
        default:
            break
        }
    }
}
