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
            hitCounter = 3
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
            
            minValueLabel.position = self.position - CGPointMake(23, -35)
            minValueLabel.fontSize = 25
            minValueLabel.text = "\(minValue)"
            minValueLabel.zPosition = 100
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
        maxValueLabel.fontSize = 25

        minValueLabel.fontName = "ArielBold"
        minValueLabel.fontColor = SKColor.blackColor()
        minValueLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        minValueLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        minValueLabel.userInteractionEnabled = false


        
        if type == .SpriteType || type == .ButtonType {
            if isCard {
                self.addChild(minValueLabel)
            } else {
                self.addChild(hitLabel)
            }
        }

    }
    
    func reload() {
        if isCard {
            minValueLabel.text = "\(minValue)"
            maxValueLabel.text = "\(maxValue)"
            if minValue != maxValue {
                if !BGPictureAdded {
                    self.addChild(BGPicture)
                    BGPicture.texture = self.texture
                    BGPictureAdded = true
                    BGPicture.position = CGPointMake(-3, 25)
                    BGPicture.size = size
                    BGPicture.zPosition = self.zPosition - 1
                    //print("vor addMaxValueLabel")
                    BGPicture.addChild(maxValueLabel)
                    //print("nach addMaxValueLabel")
                    BGPicture.userInteractionEnabled = false
                    maxValueLabel.position = CGPointMake(-20, 35)
                    maxValueLabel.zPosition = self.zPosition + 1
                }
            } else {
                if BGPictureAdded {
                    maxValueLabel.removeFromParent()
                    BGPicture.removeFromParent()
                    BGPictureAdded = false
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
