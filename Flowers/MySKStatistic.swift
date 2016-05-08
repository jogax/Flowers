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
    
    var callBack: ()->()
    let heightOfTableRow: CGFloat = 40
    var nameTable = [PlayerModel]()
    let myColumnWidths: [CGFloat] = [30, 30, 30, 10]  // in %
    let myName = "MySKStatistic"

    
    
    
    init(parent: SKSpriteNode, callBack: ()->()) {
        nameTable = Array(GV.realm.objects(PlayerModel))
        let countLines = nameTable.count + 1
        let countLevelLines = Int(LevelsForPlayWithCards().count() + 1)
        self.callBack = callBack
        
        
        super.init(columnWidths: myColumnWidths, rows:countLines, headLines: "", parent: parent, width: parent.parent!.frame.width * 0.9)
        self.showVerticalLines = true
        self.name = myName
        
        let myPosition = CGPointMake(0, (parent.size.height - size.height) / 2 - 10)
        self.position = myPosition
        
        self.zPosition = parent.zPosition + 200
        
        showPlayerStatistic()
        
        
        self.alpha = 1.0
        //        self.userInteractionEnabled = true
        parent.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showPlayerStatistic() {
        let elements: [MultiVar] = [MultiVar(string: GV.language.getText(.TCPlayer)),
                                    MultiVar(string: GV.language.getText(.TCCountPlays)),
                                    MultiVar(string: GV.language.getText(.TCAllTime)),
                                   ]
        showLineOfTable(elements, row: 0, selected: true)
        for row in 0..<nameTable.count {
            let statisticTable = GV.realm.objects(StatisticModel).filter("playerID = %d", nameTable[row].ID)
            var allTime = 0
            var countPlays = 0
            for index in 0..<statisticTable.count {
                allTime += statisticTable[index].allTime
                countPlays += statisticTable[index].countPlays
            }
            let elements: [MultiVar] = [MultiVar(string: nameTable[row].name),
                                         MultiVar(string: "\(countPlays)"),
                                         MultiVar(string: allTime.hourMinSec),
                                         MultiVar(image: DrawImages.getGoForwardImage(CGSizeMake(20, 20)))
            ]
            showLineOfTable(elements, row: row + 1, selected: true)
        }
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
            removeFromParent()
            callBack()
        case .NoEvent:
            let touchesEndedAtNode = nodeAtPoint(touchLocation)
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

