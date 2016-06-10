//
//  MySKLanguage.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 27/04/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import RealmSwift

class MySKLanguages: MySKTable {
    
    var callBack: ()->()
    let heightOfTableRow: CGFloat = 40
    var parentNode: SKSpriteNode
    var positionMultiplier = GV.deviceConstants.cardPositionMultiplier * 0.6
    var countLanguages = 0
    let myColumnWidths: [CGFloat] = [100]  // in %
    let deleteImage = DrawImages.getDeleteImage(CGSizeMake(30,30))
    let modifyImage = DrawImages.getModifyImage(CGSizeMake(30,30))
    let OKImage = DrawImages.getOKImage(CGSizeMake(30,30))
    //    let statisticImage = DrawImages.getStatisticImage(CGSizeMake(30,30))
    let myName = "MySKLanguages"
    
    
    
    init(parent: SKSpriteNode, callBack: ()->()) {
        countLanguages = GV.language.count()
        self.parentNode = parent
        self.callBack = callBack
//        let size = CGSizeMake(parent.frame.width * 0.9, heightOfTableRow + CGFloat(countLanguages) * heightOfTableRow)
        
        
        super.init(columnWidths: myColumnWidths, rows:countLanguages, headLines: [GV.language.getText(.TCChooseLanguage)], parent: parent)
        self.name = myName

        showMe(showLanguages)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showLanguages() {
        changeHeadLines([GV.language.getText(.TCChooseLanguage)])
        reDraw()
        for index in 0..<countLanguages {
            let (languageName, selected) = GV.language.getLanguageNames(LanguageCodes(rawValue:index)!)
            showElementOfTable(languageName, column: 0, row: index, selected: selected)
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
        let touchesEndedAtNode = nodeAtPoint(touchLocation)
        switch checkTouches(touches, withEvent: event) {
            case MyEvents.GoBackEvent:
                let fadeInAction = SKAction.fadeInWithDuration(0.5)
                myParent.runAction(fadeInAction)                
                removeFromParent()
                callBack()
            case .NoEvent:
                if touchesBeganAtNode != nil && touchesEndedAtNode is SKLabelNode || (touchesEndedAtNode is SKSpriteNode && touchesEndedAtNode.name != myName) {
                    let (_, row) = getColumnRowOfElement(touchesBeganAtNode!.name!)
                    GV.language.setLanguage(LanguageCodes(rawValue: row)!)
                    try! realm!.write({
                        GV.player!.aktLanguageKey = GV.language.getText(.TCAktLanguage)
                    })
                    showLanguages()
                }        
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

