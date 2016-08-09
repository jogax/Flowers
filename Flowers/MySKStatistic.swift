//
//  MySKStatistic.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 05/05/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//


import SpriteKit
import RealmSwift

class MySKStatistic: MySKTable {
    
    var callBack: (Bool, Int, Int)->()
    var nameTable = [PlayerModel]()
    let myColumnWidths: [CGFloat] = [15, 13, 20, 30, 12, 10]  // in %
    let myName = "MySKPlayerStatistic"

    
    
    
    init(parent: SKSpriteNode, callBack: (Bool, Int, Int)->()) {
        nameTable = Array(realm.objects(PlayerModel).sorted("created", ascending: true))
        var countLines = nameTable.count
        if countLines == 1 {
            countLines += 1
        }
        
        self.callBack = callBack
        
        super.init(columnWidths: myColumnWidths, rows:countLines, headLines: [""], parent: parent, width: parent.parent!.frame.width * 0.9)
        self.showVerticalLines = true
        self.name = myName
        
//        let pSize = parent.parent!.scene!.size
//        let myStartPosition = CGPointMake(-pSize.width, (pSize.height - size.height) / 2 - 10)
//        let myZielPosition = CGPointMake(pSize.width / 2, pSize.height / 2) //(pSize.height - size.height) / 2 - 10)
//        self.position = myStartPosition
        
//        self.zPosition = parent.zPosition + 200
        
        
        showMe(showPlayerStatistic)
        
        
//        self.alpha = 1.0
//        //        self.userInteractionEnabled = true
//        let actionMove = SKAction.moveTo(myTargetPosition, duration: 1.0)
//        let alphaAction = SKAction.fadeOutWithDuration(1.0)
//        parent.parent!.addChild(self)
//        
//        parent.runAction(alphaAction)
//        self.runAction(actionMove)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showPlayerStatistic() {
        let elements: [MultiVar] = [MultiVar(string: GV.language.getText(.TCPlayer)),
                                    MultiVar(string: GV.language.getText(.TCCountPlays)),
                                    MultiVar(string: GV.language.getText(.TCCountCompetitions)),
                                    MultiVar(string: GV.language.getText(.TCCountVictorys)),
                                    MultiVar(string: GV.language.getText(.TCAllTime)),
                                   ]
        showRowOfTable(elements, row: 0, selected: true)
        for row in 0..<nameTable.count {
            if nameTable[row].name != GV.language.getText(.TCAnonym) || row == 0 {
                let statisticTable = realm.objects(StatisticModel).filter("playerID = %d", nameTable[row].ID)
                var allTime = 0
                var countPlays = 0
                var countMultiPlays = 0
                var countVictorys = 0
                var countDefeats = 0
                for index in 0..<statisticTable.count {
                    allTime += statisticTable[index].allTime
                    countPlays += statisticTable[index].countPlays
                    countMultiPlays += statisticTable[index].countMultiPlays
                    countVictorys += statisticTable[index].victorys
                    countDefeats += statisticTable[index].defeats
                }
                let elements: [MultiVar] = [MultiVar(string: convertNameWhenRequired(nameTable[row].name)),
                                            MultiVar(string: "\(countPlays)"),
                                            MultiVar(string: "\(countMultiPlays)"),
                                            MultiVar(string: "\(countVictorys) / \(countDefeats)"),
                                            MultiVar(string: allTime.dayHourMinSec),
                                            MultiVar(image: DrawImages.getGoForwardImage(CGSizeMake(20, 20)))
                ]
                showRowOfTable(elements, row: row + 1, selected: true)
            }
        }
    }
    
    func convertNameWhenRequired(name: String)->String {
        if name == GV.language.getText(.TCAnonym) {
            return GV.language.getText(.TCGuest)
        }
        return name
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
        switch checkTouches(touches, withEvent: event) {
        case MyEvents.GoBackEvent:
            let fadeInAction = SKAction.fadeInWithDuration(0.5)
            myParent.runAction(fadeInAction)
            removeFromParent()
            callBack(false, 0, 0)
        case .NoEvent:
            let touchesEndedAtNode = nodeAtPoint(touchLocation)
            if touchesBeganAtNode != nil && touchesEndedAtNode is SKSpriteNode && touchesEndedAtNode.name != myName {
                let (column, row) = getColumnRowOfElement(touchesBeganAtNode!.name!)
                if column == myColumnWidths.count - 1 {
                    showDetailedPlayerStatistic(row - 1)
                }
           }

        }
        
    }
    
    func showDetailedPlayerStatistic(row: Int) {
        let playerID = nameTable[row].ID
        _ = MySKDetailedStatistic(playerID: playerID, parent: self, callBack: backFromMySKDetailedStatistic)
        
    }
    
    func backFromMySKDetailedStatistic(startGame: Bool, gameNumber: Int, levelIndex: Int) {
        callBack(startGame, gameNumber, levelIndex)
    }
    override func setMyDeviceSpecialConstants() {
        switch GV.deviceConstants.type {
        case .iPadPro12_9:
            fontSize = CGFloat(20)
        case .iPad2:
            fontSize = CGFloat(20)
        case .iPadMini:
            fontSize = CGFloat(20)
        case .iPhone6Plus:
            fontSize = CGFloat(15)
        case .iPhone6:
            fontSize = CGFloat(15)
        case .iPhone5:
            fontSize = CGFloat(13)
        case .iPhone4:
            fontSize = CGFloat(12)
        default:
            break
        }
    }

    
}

