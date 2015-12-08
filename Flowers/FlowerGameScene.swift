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
    let levelScorePosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.93 : 0.92)
    let gameScorePosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.95 : 0.94)
    let spriteCountPosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.91 : 0.90)
    let targetPosKorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.93 : 0.92)
    
    var gameScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var levelScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var targetScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    
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

    override func showScore() {
        levelScore = 0
        for index in 0..<containers.count {
            levelScore += containers[index].mySKNode.hitCounter
            containers[index].label.text = "\(containers[index].mySKNode.hitCounter)"
        }
        let levelScoreText: String = GV.language.getText(.TCLevelScore)
        levelScoreLabel.text = "\(levelScoreText) \(levelScore)"
        
    }
    
    override func changeLanguage()->Bool {
        playerLabel.text = GV.language.getText(TextConstants.TCGamer) + ": \(GV.globalParam.aktName)"
        levelLabel.text = GV.language.getText(TextConstants.TCLevel) + ": \(levelIndex + 1)"
        gameScoreLabel.text = "\(GV.language.getText(.TCGameScore)) \(gameScore)"
        spriteCountLabel.text = "\(GV.language.getText(.TCSpriteCount)) \(spriteCount)"
        targetScoreLabel.text = "\(GV.language.getText(.TCTargetScore)) \(targetScore)"
        showScore()
        showTimeLeft()
        return true
    }

    override func spezialPrepareFunc() {
        let gameScoreText: String = GV.language.getText(.TCGameScore)
        gameScoreLabel.text = "\(gameScoreText) \(gameScore)"
        
        createLabels(gameScoreLabel, text: "", position: CGPointMake(self.position.x + self.size.width * gameScorePosKorr.x, self.position.y + self.size.height * gameScorePosKorr.y), horAlignment: .Left)
        
//        gameScoreLabel.position = CGPointMake(self.position.x + self.size.width * gameScorePosKorr.x, self.position.y + self.size.height * gameScorePosKorr.y)
//        gameScoreLabel.fontColor = SKColor.blackColor()
//        gameScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
//        gameScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
//        gameScoreLabel.fontSize = 15;
//        //gameScoreLabel.fontName = "ArielBold"
//        self.addChild(gameScoreLabel)
        
        //createLabels(levelScoreLabel, text: <#T##String#>, position: <#T##CGPoint#>, horAlignment: <#T##SKLabelHorizontalAlignmentMode#>)
        levelScoreLabel.position = CGPointMake(self.position.x + self.size.width * levelScorePosKorr.x, self.position.y + self.size.height * levelScorePosKorr.y)
        levelScoreLabel.fontColor = SKColor.blackColor()
        levelScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        levelScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        levelScoreLabel.fontSize = 15;
        //levelScoreLabel.fontName = "ArielBold"
        self.addChild(levelScoreLabel)
        showScore()

        targetScoreLabel.position = CGPointMake(self.position.x + self.size.width * targetPosKorr.x, self.position.y + self.size.height * targetPosKorr.y)
        targetScoreLabel.fontColor = SKColor.blackColor()
        targetScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        targetScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        targetScoreLabel.fontSize = 15;
        targetScore = countContainers * countSpritesProContainer! * targetScoreKorr
        let targetScoreText: String = GV.language.getText(.TCTargetScore)
        targetScoreLabel.text = "\(targetScoreText) \(targetScore)"
        self.addChild(targetScoreLabel)

        spriteCountLabel.position = CGPointMake(self.position.x + self.size.width * spriteCountPosKorr.x, self.position.y + self.size.height * spriteCountPosKorr.y)
        spriteCountLabel.fontColor = SKColor.blackColor()
        spriteCountLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        spriteCountLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        spriteCountLabel.fontSize = 15;
        spriteCount = Int(CGFloat(countContainers * countSpritesProContainer!))
        let spriteCountText: String = GV.language.getText(.TCSpriteCount)
        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
        self.addChild(spriteCountLabel)
        
        gameScoreLabel.text = "\(gameScoreText) \(gameScore)"

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
            
            push(sprite, status: .Unification)
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
    override func prepareContainers() {
        
        colorTab.removeAll(keepCapacity: false)
        var spriteName = 10000
        
        for _ in 0..<countSpritesProContainer! {
            for containerIndex in 0..<countContainers {
                let colorTabLine = ColorTabLine(colorIndex: containerIndex, spriteName: "\(spriteName++)", spriteValue: generateValue(containerIndex))
                colorTab.append(colorTabLine)
            }
        }
        
        let xDelta = size.width / CGFloat(countContainers)
        for index in 0..<countContainers {
            let centerX = (size.width / CGFloat(countContainers)) * CGFloat(index) + xDelta / 2
            let centerY = size.height * containersPosCorr.y
            let cont: Container
            cont = Container(mySKNode: MySKNode(texture: getTexture(index), type: .ContainerType, value: getValueForContainer()), label: SKLabelNode(), countHits: 0)
            containers.append(cont)
            containers[index].mySKNode.name = "\(index)"
            containers[index].mySKNode.position = CGPoint(x: centerX, y: centerY)
            containers[index].mySKNode.size.width = containerSize.width
            containers[index].mySKNode.size.height = containerSize.height
            
            containers[index].label.text = "0"
            containers[index].label.fontSize = 20;
            containers[index].label.fontName = "ArielBold"
            containers[index].label.position = CGPointMake(CGRectGetMidX(containers[index].mySKNode.frame), CGRectGetMidY(containers[index].mySKNode.frame) * 1.03)
            containers[index].label.name = "label"
            containers[index].label.fontColor = SKColor.blackColor()
            self.addChild(containers[index].label)
            
            containers[index].mySKNode.colorIndex = index
            containers[index].mySKNode.physicsBody = SKPhysicsBody(circleOfRadius: containers[index].mySKNode.size.width / 3) // 1
            containers[index].mySKNode.physicsBody?.dynamic = true // 2
            containers[index].mySKNode.physicsBody?.categoryBitMask = PhysicsCategory.Container
            containers[index].mySKNode.physicsBody?.contactTestBitMask = PhysicsCategory.MovingSprite
            containers[index].mySKNode.physicsBody?.collisionBitMask = PhysicsCategory.None
            countColorsProContainer.append(countSpritesProContainer!)
            addChild(containers[index].mySKNode)
        }
    }



}