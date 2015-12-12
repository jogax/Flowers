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
let NoValue = -1
import SpriteKit

class MySKNode: SKSpriteNode {
    
    var column = 0
    var row = 0
    var colorIndex = 0
    var startPosition = CGPointZero
    var minValue: Int
    var maxValue: Int
    
    var isCard = false
    

    var hitCounter: Int = 0

    let type: MySKNodeType
    var hitLabel = SKLabelNode()
    var maxValueLabel = SKLabelNode()
    var minValueLabel = SKLabelNode()
    var BGPicture = SKSpriteNode()
    var BGPictureAdded = false

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
            hitLabel.zPosition = 100
            //print("\(hitLabel.text)")
        } else {
            
            hitLabel.position = CGPointMake(self.position.x, self.position.y + self.size.width * 0.08)
            hitLabel.fontSize = 15;
            hitLabel.text = "\(hitCounter)"
            
            minValueLabel.fontSize = 25
            maxValueLabel.fontSize = 25
            minValueLabel.text = "\(minValue)"
            minValueLabel.zPosition = 100
            
            var positionOffset = CGPointMake(self.size.width * 0.05, -self.size.height * 0.06)
            if type == .SpriteType {
                positionOffset = CGPointMake(self.size.width * 0.035, -self.size.height * 0.04)
                minValueLabel.fontSize = 20
                maxValueLabel.fontSize = 20
            }
            minValueLabel.position = self.position - positionOffset //CGPointMake(23, -35)
        }
        
        hitLabel.fontName = "ArielBold"
        hitLabel.fontColor = SKColor.blackColor()
        hitLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        hitLabel.userInteractionEnabled = false

        maxValueLabel.fontName = "ArielBold"
        maxValueLabel.fontColor = SKColor.blackColor()
        maxValueLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        maxValueLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        maxValueLabel.userInteractionEnabled = false

        minValueLabel.fontName = "ArielBold"
        minValueLabel.fontColor = SKColor.blackColor()
        minValueLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        minValueLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        minValueLabel.userInteractionEnabled = false


        
        if isCard {
            if type == .ContainerType && minValue == maxValue {
                self.alpha = 0.5
            }
            self.addChild(minValueLabel)
        } else {
            self.addChild(hitLabel)
        }

    }
    
    func reload() {
        if isCard {
            minValueLabel.text = "\(minValue)"
            maxValueLabel.text = "\(maxValue)"
            let positionOffset = CGPointMake(self.size.width * -0.45, self.size.height * 0.45)
            let BGPicturePosition = CGPointMake(-self.size.width * 0.08, self.size.height * 0.30)
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
