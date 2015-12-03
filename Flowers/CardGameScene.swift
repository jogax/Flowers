//
//  CardGameScene.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 11. 26..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import AVFoundation

class CardGameScene: MyGameScene {
    
    var valueTab = [Int]()
    override func getTexture(index: Int)->SKTexture {
        return atlas.textureNamed ("card\(index)")
    }
    override func makeSpezialThings() {
        let multiplier: CGFloat = 1.5
        let width:CGFloat = 64.0
        let height: CGFloat = 89.0
        sizeMultiplier = CGSizeMake(multiplier, multiplier * height / width)
    }
    override func setBGImageNode()->SKSpriteNode {
        return SKSpriteNode(imageNamed: "Holz.png")
    }

    override func generateValue(colorIndex: Int)->Int {
        while valueTab.count < colorIndex + 1 {
            valueTab.append(1)
        }
        return valueTab[colorIndex]++
            
    }
    
    override func spezialPrepareFunc() {
        valueTab.removeAll()
    }

    override func spriteDidCollideWithMovingSprite(node1:MySKNode, node2:MySKNode) {
        let movingSprite = node1
        let sprite = node2
        let movingSpriteColorIndex = movingSprite.colorIndex
        let spriteColorIndex = sprite.colorIndex
        
        //let aktColor = GV.colorSets[GV.colorSetIndex][sprite.colorIndex + 1].CGColor
        collisionActive = false
        
        let OK = movingSpriteColorIndex == spriteColorIndex &&
        (
            movingSprite.maxValue + 1 == sprite.minValue ||
            movingSprite.minValue - 1 == sprite.maxValue
        )
        if OK {
            
            
            push(sprite, status: .SizeChanged)
            push(movingSprite, status: .Removed)
            
            if sprite.maxValue < movingSprite.minValue {
                sprite.maxValue = movingSprite.maxValue
            } else {
                sprite.minValue = movingSprite.minValue
            }
            sprite.hitCounter = movingSprite.hitCounter + sprite.hitCounter
            sprite.hitLabel.text = "\(sprite.hitCounter)"
            sprite.reload()
            
            playSound("Sprite1", volume: GV.soundVolume)
            
            gameArray[movingSprite.column][movingSprite.row] = false
            movingSprite.removeFromParent()
            countMovingSprites = 0
        } else {
            push(sprite, status: .FallingSprite)
            push(movingSprite, status: .FallingMovingSprite)
            
            sprite.zPosition = 0
            movingSprite.zPosition = 0
            movingSprite.physicsBody?.categoryBitMask = PhysicsCategory.None
            containers[movingSprite.colorIndex].mySKNode.hitCounter -= movingSprite.hitCounter
            containers[sprite.colorIndex].mySKNode.hitCounter -= sprite.hitCounter
            let movingSpriteDest = CGPointMake(movingSprite.position.x * 0.5, 0)
            
            movingSprite.startPosition = movingSprite.position
            movingSprite.position = movingSpriteDest
            push(movingSprite, status: .Removed)
            
            countMovingSprites = 2
            
            let movingSpriteAction = SKAction.moveTo(movingSpriteDest, duration: 1.0)
            let actionMoveDone = SKAction.removeFromParent()
            
            movingSprite.runAction(SKAction.sequence([movingSpriteAction, actionMoveDone]), completion: {self.countMovingSprites--})
            
            
            let spriteDest = CGPointMake(sprite.position.x * 1.5, 0)
            sprite.startPosition = sprite.position
            sprite.position = spriteDest
            push(sprite, status: .Removed)
            
            
            let actionMove2 = SKAction.moveTo(spriteDest, duration: 1.5)
            sprite.runAction(SKAction.sequence([actionMove2, actionMoveDone]), completion: {self.countMovingSprites--})
            gameArray[movingSprite.column][movingSprite.row] = false
            gameArray[sprite.column][sprite.row] = false
            spriteCount--
            playSound("Drop", volume: GV.soundVolume)
            showScore()
        }
        spriteCount--
        let spriteCountText: String = GV.language.getText(.TCSpriteCount)
        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
        checkGameFinished()
    }

}
