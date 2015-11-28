//
//  MySKContainer.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 13.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

enum MySKNodeType: Int {
    case SpriteType = 0, FrozenSprite, MovingSpriteType, ContainerType, ButtonType
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
    

    var hitCounter: Int = 0

    let type: MySKNodeType
    var hitLabel = SKLabelNode()
    var valueLabel = SKLabelNode()

    init(texture: SKTexture, type:MySKNodeType, value: Int) {
        self.type = type
        self.minValue = value
        self.maxValue = value
        
        switch type {
        case .ContainerType:
            hitCounter = 0
        case .ButtonType:
            hitCounter = 3
        case .SpriteType:
            hitCounter = 1
        default:
            hitCounter = 0
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
            
            valueLabel.position = self.position - CGPointMake(23, -35)
            valueLabel.fontSize = 25
            valueLabel.text = "\(maxValue)"
            valueLabel.zPosition = 100
        }
        
        hitLabel.fontName = "ArielBold"
        hitLabel.fontColor = SKColor.blackColor()
        hitLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        hitLabel.userInteractionEnabled = false

        valueLabel.fontName = "ArielBold"
        valueLabel.fontColor = SKColor.blackColor()
        valueLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        valueLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        valueLabel.userInteractionEnabled = false

        if type == .SpriteType || type == .ButtonType {
            if value > NoValue {
                self.addChild(valueLabel)
            } else {
                self.addChild(hitLabel)
            }
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
