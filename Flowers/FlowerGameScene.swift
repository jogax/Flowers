//
//  GameScene.swift
//  JSprites
//
//  Created by Jozsef Romhanyi on 11.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import AVFoundation

class FlowerGameScene: MyGameScene {
    override func getTexture(index: Int)->SKTexture {
        return atlas.textureNamed ("sprite\(index)")
    }
    override func makeSpezialThings() {
        let width:CGFloat = 1.0
        let height: CGFloat = 1.0
        sizeMultiplier = CGSizeMake(1.0, height / width)
    }
    override func setBGImageNode()->SKSpriteNode {
        return SKSpriteNode(imageNamed: "bgImage.png")
    }
    
    override func spriteDidCollideWithMovingSprite(node1:MySKNode, node2:MySKNode) {
        let movingSprite = node1
        let sprite = node2
        let movingSpriteColorIndex = movingSprite.colorIndex
        let spriteColorIndex = sprite.colorIndex
        
        //let aktColor = GV.colorSets[GV.colorSetIndex][sprite.colorIndex + 1].CGColor
        collisionActive = false
        
        let OK = movingSpriteColorIndex == spriteColorIndex
        if OK {
            
            push(sprite, status: .SizeChanged)
            push(movingSprite, status: .Removed)
            
            sprite.hitCounter = movingSprite.hitCounter + sprite.hitCounter
            sprite.hitLabel.text = "\(sprite.hitCounter)"
            
            //            let aktSize = spriteSize + 1.2 * CGFloat(sprite.hitCounter)
            //            sprite.size.width = aktSize
            //            sprite.size.height = aktSize
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

    override func spriteDidCollideWithContainer(node1:MySKNode, node2:MySKNode) {
        let movingSprite = node1
        let container = node2
        
        let containerColorIndex = container.colorIndex
        let spriteColorIndex = movingSprite.colorIndex
        let OK = containerColorIndex == spriteColorIndex
        
        push(container, status: .HitcounterChanged)
        push(movingSprite, status: .Removed)
        
        
        //print("spriteName: \(containerColorIndex), containerName: \(spriteColorIndex)")
        if OK {
            if movingSprite.hitCounter < 100 {
                container.hitCounter += scoreAddCorrected[movingSprite.hitCounter]! // when only 1 sprite, then add 0
            } else {
                container.hitCounter += movingSprite.hitCounter
            }
            showScore()
            playSound("Container", volume: GV.soundVolume)
        } else {
            container.hitCounter -= movingSprite.hitCounter
            showScore()
            playSound("Funk_Bot", volume: GV.soundVolume)
        }
        
        countMovingSprites = 0
        
        spriteCount--
        let spriteCountText: String = GV.language.getText(.TCSpriteCount)
        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
        
        collisionActive = false
        movingSprite.removeFromParent()
        gameArray[movingSprite.column][movingSprite.row] = false
        checkGameFinished()
    }


}