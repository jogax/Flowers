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
        return SKSpriteNode(imageNamed: "cardBackground.png")
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

    override func getValueForContainer()->Int {
        return 0
    }

    override func spriteDidCollideWithContainer(node1:MySKNode, node2:MySKNode) {
        let movingSprite = node1
        let container = node2
        
        let containerColorIndex = container.colorIndex
        let movingSpriteColorIndex = movingSprite.colorIndex
        
        let OK = movingSpriteColorIndex == containerColorIndex &&
        (
            container.minValue == 0 ||
            movingSprite.maxValue + 1 == container.minValue ||
            movingSprite.minValue - 1 == container.maxValue
        )

        push(container, status: .HitcounterChanged)
        push(movingSprite, status: .Removed)
        
        
        //print("spriteName: \(containerColorIndex), containerName: \(spriteColorIndex)")
        if OK  {
            if container.maxValue < movingSprite.minValue {
                container.maxValue = movingSprite.maxValue
            } else {
                container.minValue = movingSprite.minValue
            }
            container.reload()
            //gameArray[movingSprite.column][movingSprite.row] = false
            movingSprite.removeFromParent()
            playSound("Container", volume: GV.soundVolume)
        } else {
            pull()
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
            
            
            push(sprite, status: .Unification)
            push(movingSprite, status: .Removed)
            
            if sprite.maxValue < movingSprite.minValue {
                sprite.maxValue = movingSprite.maxValue
            } else {
                sprite.minValue = movingSprite.minValue
            }
            sprite.reload()
            
            playSound("Sprite1", volume: GV.soundVolume)
            
            gameArray[movingSprite.column][movingSprite.row] = false
            movingSprite.removeFromParent()
            countMovingSprites = 0
        } else {
            push(sprite, status: .FallingSprite)
            push(movingSprite, status: .FallingMovingSprite)
//            pull()

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

    override func checkGameFinished() {
        
        
        let usedCellCount = checkGameArray()
        let containersOK = checkContainers()
        
        if usedCellCount == 0 && containersOK { // Level completed, start a new game
            
            stopTimer()
//            if countUp != nil {
//                countUp!.invalidate()
//                countUp = nil
//                //playMusic("Winner", volume: GV.soundVolume)
//            }
            playMusic("Winner", volume: GV.musicVolume, loops: 0)
            
            let alert = UIAlertController(title: GV.language.getText(.TCLevelComplete),
                message: GV.language.getText(TextConstants.TCCongratulations),
                preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: GV.language.getText(.TCReturn), style: .Cancel, handler: nil)
            let againAction = UIAlertAction(title: GV.language.getText(TextConstants.TCNextLevel), style: .Default,
                handler: {(paramAction:UIAlertAction!) in
                    self.newGame(true)
            })
            alert.addAction(cancelAction)
            alert.addAction(againAction)
            parentViewController!.presentViewController(alert, animated: true, completion: nil)
        }
        if usedCellCount < minUsedCells {
            generateSprites(false)  // Nachgenerierung
        }
    }

    func checkContainers()->Bool {
        for index in 0..<containers.count {
            if containers[index].mySKNode.minValue != 1 && containers[index].mySKNode.maxValue != countSpritesProContainer {
                return false
            }
        }
        return true

    }
}
