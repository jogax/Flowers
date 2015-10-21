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
import SpriteKit

class MySKNode: SKSpriteNode {
    
    var column = 0
    var row = 0
    var colorIndex = 0
    var startPosition = CGPointZero
    

    var hitCounter: Int = 0

    let type: MySKNodeType
    var hitLabel = SKLabelNode()
    var frozen = SKSpriteNode(imageNamed: "frozen.png" )
    

    init(texture: SKTexture, type:MySKNodeType) {
        self.type = type
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
        //hitCounter = type == .ContainerType ? 0 : 1  // Sprites have a Startvalue 1
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
      
        if type == .ButtonType {
            //hitLabel.position = CGPointMake(self.position.x, self.position.y -  self.size.height * 0.008)
            hitLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
            hitLabel.fontSize = 20;
            //hitLabel.text = "\(hitCounter)"
            hitLabel.zPosition = 100
            print("\(hitLabel.text)")
        } else {
            hitLabel.position = CGPointMake(self.position.x, self.position.y + self.size.height * 0.1)
            hitLabel.fontSize = 15;
            hitLabel.text = "\(hitCounter)"
        }
        //hitLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) * 0.08)

        //hitLabel.size = self.size
        
        hitLabel.fontName = "ArielBold"
        hitLabel.fontColor = SKColor.blackColor()
        hitLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        //hitLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        hitLabel.userInteractionEnabled = false
        
        if type == .FrozenSprite {
            frozen.position = self.position
            frozen.size = CGSizeMake(30, 30)
            frozen.zPosition = 100
            frozen.colorBlendFactor = 0.5
            self.addChild(frozen)
        }
        
        if type == .SpriteType || type == .ButtonType {
            self.addChild(hitLabel)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
/*
    func setText() {
        //hitLabel.text = "\(hitCounter)"
    }
*/
    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let firstTouch = touches.first
//        let touchLocation = firstTouch!.locationInNode(self)
//    }

}
