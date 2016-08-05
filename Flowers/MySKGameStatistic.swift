//
//  MySKGameStatistic.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 05/08/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import RealmSwift

class MySKGameStatistic: MySKTable {
    
    var callBack: ()->()
    let myGameColumnWidths: [CGFloat] = [12, 15, 15, 20, 18, 20] // in %
    let myName = "MySKStatistic"
    let countLines = GV.levelsForPlay.count()
    let playerID: Int
    let levelID: Int
    
    
    
    
    
    init(playerID: Int, levelID: Int, parent: SKSpriteNode, callBack: ()->()) {
        self.playerID = playerID
        self.levelID = levelID
        let playerName = realm.objects(PlayerModel).filter("ID = %d", playerID).first!.name
        self.callBack = callBack
        let headLines = GV.language.getText(.TCPlayerStatisticHeader, values: playerName)
        super.init(columnWidths: myGameColumnWidths, rows:countLines + 1, headLines: [headLines], parent: parent, width: parent.parent!.frame.width * 0.9)
        self.showVerticalLines = true
        self.name = myName
        
        showMe(showStatistic)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showStatistic() {
        let elements: [MultiVar] = [MultiVar(string: GV.language.getText(.TCGame)),
                                    MultiVar(string: GV.language.getText(.TCGameArt)),
                                    MultiVar(string: GV.language.getText(.TCOpponent)),
                                    MultiVar(string: GV.language.getText(.TCScore)),
                                    MultiVar(string: GV.language.getText(.TCAllTime)),
                                    MultiVar(string: GV.language.getText(.TCVictory)),
                                    ]
        showRowOfTable(elements, row: 0, selected: true)
        let gamesOfThisLevel = realm.objects(GameModel).filter("playerID = %d and levelID = %d and played = true", playerID, levelID)
        var row = 1
        for game in gamesOfThisLevel {
            var gameArt = GV.language.getText(.TCGame) // simple Game
            var opponent = ""
            var score = String(game.playerScore)
            var victory = DrawImages.getOKImage(CGSizeMake(20, 20))
            if game.multiPlay {
                gameArt = GV.language.getText(.TCCompetition)
                opponent = game.opponentName
                score += " / " + String(game.opponentScore)
                if game.playerScore < game.opponentScore {
                    victory = DrawImages.getNOKImage(CGSizeMake(20, 20))
                }
            }
            let elements: [MultiVar] = [MultiVar(string: "#\(game.gameNumber)"),
                                        MultiVar(string: gameArt),
                                        MultiVar(string: opponent),
                                        MultiVar(string: score),
                                        MultiVar(string: game.time.dayHourMinSec),
                                        MultiVar(image: victory),
                                        ]
            showRowOfTable(elements, row: row, selected: true)
            row += 1
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
            callBack()
        case .NoEvent:
            let touchesEndedAtNode = nodeAtPoint(touchLocation)
            if touchesBeganAtNode != nil && touchesEndedAtNode is SKSpriteNode && touchesEndedAtNode.name != myName {
                let (column, row) = getColumnRowOfElement(touchesBeganAtNode!.name!)
                if column == myGameColumnWidths.count - 1 {
                    showDetailedPlayerStatistic(row - 1)
                }
            }
            
        }
        
    }
    
    func showDetailedPlayerStatistic(row: Int) {
        //        let countLevelLines = Int(LevelsForPlayWithCards().count() + 1)
        
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

