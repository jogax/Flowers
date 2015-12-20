//
//  MySKContainer.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 13.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

enum MySKNodeType: Int {
    case SpriteType = 0, ContainerType, ButtonType
}

enum TremblingType: Int {
    case NoTrembling = 0, ChangeSize, ChangePos, ChangeDirection
}
let NoValue = -1
import SpriteKit

class MySKNode: SKSpriteNode {
    
    override var size: CGSize {
        didSet {
            if oldValue != CGSizeMake(0,0) && (type == .ContainerType || type == .SpriteType) {
                minValueLabel.fontSize = size.width * fontSizeMultiplier
                maxValueLabel.fontSize = size.width * fontSizeMultiplier
//                print("name: \(name), type: \(type), oldValue: \(oldValue), size: \(size)")
            }
        }
    }
    var column = 0
    var row = 0
    var colorIndex = 0
    var startPosition = CGPointZero
    var minValue: Int
    var maxValue: Int

    var origSize = CGSizeMake(0, 0)

    var trembling: CGFloat = 0
    var tremblingType: TremblingType = .NoTrembling
    
    var isCard = false
    

    var hitCounter: Int = 0

    let type: MySKNodeType
    var hitLabel = SKLabelNode()
    var maxValueLabel = SKLabelNode()
    var minValueLabel = SKLabelNode()
    var BGPicture = SKSpriteNode()
    var BGPictureAdded = false
    let fontSizeMultiplier: CGFloat = 0.35

    init(texture: SKTexture, type:MySKNodeType, value: Int) {
        self.type = type
        self.minValue = value
        self.maxValue = value
        
        if value > NoValue {
            isCard = true
        }
        
        switch type {
        case .ContainerType:
            hitCounter = 0
        case .ButtonType:
            hitCounter = 0
        case .SpriteType:
            hitCounter = 1
        }
        
        

        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        if type == .ButtonType {
            //hitLabel.position = CGPointMake(self.position.x, self.position.y -  self.size.height * 0.008)
            hitLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
            hitLabel.fontSize = 20;
            //hitLabel.text = "\(hitCounter)"
            hitLabel.zPosition = 1
            //print("\(hitLabel.text)")
        } else {
            
            hitLabel.position = CGPointMake(self.position.x, self.position.y + self.size.width * 0.08)
            hitLabel.fontSize = 15;
            hitLabel.text = "\(hitCounter)"
            
            minValueLabel.text = "\(minValue)"
            minValueLabel.zPosition = 1
            
            var positionOffset = CGPointMake(self.size.width * 0.05, -self.size.height * 0.06)
            if type == .SpriteType {
                positionOffset = CGPointMake(self.size.width * 0.035, -self.size.height * 0.04)
                minValueLabel.fontSize = 20
                maxValueLabel.fontSize = 20
            }
            minValueLabel.position = self.position - positionOffset //CGPointMake(23, -35)
        }
        
        setLabel(hitLabel, fontSize: 15)
        setLabel(maxValueLabel, fontSize: size.width * fontSizeMultiplier)
        setLabel(minValueLabel, fontSize: size.width * fontSizeMultiplier)
        

        
        if isCard {
            if type == .ContainerType && minValue == maxValue {
                self.alpha = 0.5
            }
            self.addChild(minValueLabel)
        } else {
            self.addChild(hitLabel)
        }

    }
    
    func setLabel(label: SKLabelNode, fontSize: CGFloat) {
        label.fontName = "ArielItalic"
//        label.fontSize = fontSize
        label.fontColor = SKColor.blackColor()
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        label.userInteractionEnabled = false
    }
    
    func reload() {
        if isCard {
            minValueLabel.text = "\(minValue)"
            maxValueLabel.text = "\(maxValue)"
            if minValue != maxValue {
                self.alpha = 1.0
            }
            let positionOffset = CGPointMake(self.size.width * -0.45, self.size.height * 0.45)
            let BGPicturePosition = CGPointMake(-self.size.width * 0.08, self.size.height * 0.30)
            let bgPictureName = "BGPicture"
            if minValue != maxValue {
                if !BGPictureAdded {
                    if self.childNodeWithName(bgPictureName) == nil {
                        self.addChild(BGPicture)
                        BGPicture.addChild(maxValueLabel)
                        BGPicture.name = bgPictureName
                    }
                    BGPicture.texture = self.texture
                    BGPictureAdded = true
                    BGPicture.position = BGPicturePosition // CGPointMake(-3, 25)
                    BGPicture.size = size
                    BGPicture.zPosition = self.zPosition - 1
                    BGPicture.userInteractionEnabled = false
                    maxValueLabel.position = positionOffset //CGPointMake(-20, 35)
                    maxValueLabel.zPosition = self.zPosition + 1
                }
            } else {
                if BGPictureAdded || self.childNodeWithName(bgPictureName) != nil {
                    maxValueLabel.removeFromParent()
                    BGPicture.removeFromParent()
                    BGPictureAdded = false
                    if type == .ContainerType {
                        self.alpha = 0.5
                    }
                }
            }
        } else {
            hitLabel.text = "\(hitCounter)"
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
