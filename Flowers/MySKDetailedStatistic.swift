//
//  MySKDetailedStatistic.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 11/05/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import RealmSwift

class MySKDetailedStatistic: MySKTable {
    
    var callBack: (Bool, Int, Int)->()
    let myDetailedColumnWidths: [CGFloat] = [15, 13, 20, 30, 12, 10] // in %
    let myName = "MySKStatistic"
    let countLines = GV.levelsForPlay.count()
    let playerID: Int
    let parentNode: SKSpriteNode

    
    
    
    
    init(playerID: Int, parent: SKSpriteNode, callBack: (Bool, Int, Int)->()) {
        self.playerID = playerID
        let playerName = realm.objects(PlayerModel).filter("ID = %d", playerID).first!.name
        self.parentNode = parent
        self.callBack = callBack
        let headLines = GV.language.getText(.TCPlayerStatisticHeader, values: playerName)
        super.init(columnWidths: myDetailedColumnWidths, rows:countLines + 1, headLines: [headLines], parent: parent, width: parent.parent!.frame.width * 0.9)
        self.showVerticalLines = true
        self.name = myName
        
        showMe(showStatistic)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showStatistic() {
        let elements: [MultiVar] = [MultiVar(string: GV.language.getText(.TCLevel)),
                                    MultiVar(string: GV.language.getText(.TCCountPlays)),
                                    MultiVar(string: GV.language.getText(.TCCountCompetitions)),
                                    MultiVar(string: GV.language.getText(.TCCountVictorys)),
                                    MultiVar(string: GV.language.getText(.TCAllTime)),
                                    ]
        showRowOfTable(elements, row: 0, selected: true)
        for levelID in 0..<countLines {
            var statistic: StatisticModel?
            statistic = realm.objects(StatisticModel).filter("playerID = %d and levelID = %d", playerID, levelID).first
            if statistic == nil {
                statistic = StatisticModel()
            }
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.NoStyle // .DecimalStyle
//            let bestScoreString = formatter.stringFromNumber(statistic!.bestScore)
            let elements: [MultiVar] = [MultiVar(string: String(levelID + 1)),
                                        MultiVar(string: "\(statistic!.countPlays)"),
                                        MultiVar(string: "\(statistic!.countMultiPlays)"),
                                        MultiVar(string: "\(statistic!.victorys) / \(statistic!.defeats)"),
                                        MultiVar(string: "\(statistic!.allTime.dayHourMinSec)"),
                                        MultiVar(image: DrawImages.getGoForwardImage(CGSizeMake(20, 20))),
            ]
            showRowOfTable(elements, row: levelID + 1, selected: true)
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
                if column == myDetailedColumnWidths.count - 1 {
                    showDetailedPlayerStatistic(row - 1)
                }
            }
            
        }
        
    }
    
    
    func showDetailedPlayerStatistic(row: Int) {
        _ = MySKGameStatistic(playerID: playerID, levelID: row, parent: self, callBack: callBackFromGameStatistic)
    }
 
    func callBackFromGameStatistic(startGame: Bool = false, gameNumber: Int = 0, levelIndex: Int = 0) {
        if startGame {
            callBack(startGame, gameNumber, levelIndex - 1)
        }
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

