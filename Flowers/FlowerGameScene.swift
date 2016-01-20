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

    var levelsForPlay = LevelsForPlayWithSprites()

    override func getTexture(index: Int)->SKTexture {
        return atlas.textureNamed ("sprite\(index)")
    }
    
    override func updateSpriteCount(adder: Int) {
        spriteCount += adder
        let spriteCountText: String = GV.language.getText(.TCSpriteCount)
        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
    }

    override func generateSprites(first: Bool) {
        var positionsTab = [(Int, Int)]() // all available Positions
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if !gameArray[column][row] {
                    let appendValue = (column, row)
                    positionsTab.append(appendValue)
                }
            }
        }
        
        while colorTab.count > 0 && checkGameArray() < maxUsedCells {
            let colorTabIndex = colorTab.count - 1 //GV.random(0, max: colorTab.count - 1)
            let colorIndex = colorTab[colorTabIndex].colorIndex
            let spriteName = colorTab[colorTabIndex].spriteName
            let value = colorTab[colorTabIndex].spriteValue
            colorTab.removeAtIndex(colorTabIndex)
            
            let sprite = MySKNode(texture: getTexture(colorIndex), type: .SpriteType, value:value)
            tableCellSize = spriteTabRect.width / CGFloat(countColumns)
            
            let index = random!.getRandomInt(0, max: positionsTab.count - 1)
            let (aktColumn, aktRow) = positionsTab[index]
            
            let xPosition = spriteTabRect.origin.x - spriteTabRect.size.width / 2 + CGFloat(aktColumn) * tableCellSize + tableCellSize / 2
            let yPosition = spriteTabRect.origin.y - spriteTabRect.size.height / 2 + tableCellSize / 2 + CGFloat(aktRow) * tableCellSize
            
            sprite.position = CGPoint(x: xPosition, y: yPosition)
            sprite.startPosition = sprite.position
            gameArray[aktColumn][aktRow] = true
            positionsTab.removeAtIndex(index)
            
            sprite.column = aktColumn
            sprite.row = aktRow
            sprite.colorIndex = colorIndex
            sprite.name = spriteName
            
            sprite.size = CGSizeMake(spriteSize.width, spriteSize.height)
            
            addPhysicsBody(sprite)
            push(sprite, status: .Added)
            addChild(sprite)
        }
        if first {
            countUp = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("doCountUp"), userInfo: nil, repeats: true)
        }
        
        stopped = false
    }

    override func makeSpezialThings(first: Bool) {
        if !first {
            levelIndex = levelsForPlay.getNextLevel()
        }
        let width:CGFloat = 1.0
        let height: CGFloat = 1.0
        sizeMultiplier = CGSizeMake(1.0, height / width)
        levelsForPlay.setAktLevel(levelIndex)
        
        countContainers = levelsForPlay.aktLevel.countContainers
        countSpritesProContainer = levelsForPlay.aktLevel.countSpritesProContainer
        targetScoreKorr = levelsForPlay.aktLevel.targetScoreKorr
        countColumns = levelsForPlay.aktLevel.countColumns
        countRows = levelsForPlay.aktLevel.countRows
        minUsedCells = levelsForPlay.aktLevel.minProzent * countColumns * countRows / 100
        maxUsedCells = levelsForPlay.aktLevel.maxProzent * countColumns * countRows / 100
        containerSize = CGSizeMake(CGFloat(containerSizeOrig) * sizeMultiplier.width, CGFloat(containerSizeOrig) * sizeMultiplier.height)
        spriteSize = CGSizeMake(CGFloat(spriteSizeOrig) * sizeMultiplier.width, CGFloat(spriteSizeOrig) * sizeMultiplier.height )
        
    }
    override func setBGImageNode()->SKSpriteNode {
        return SKSpriteNode(imageNamed: "bgImage.png")
    }

    override func showScore() {
        levelScore = 0
        for index in 0..<containers.count {
            levelScore += containers[index].mySKNode.hitCounter
//            containers[index].label.text = "\(containers[index].mySKNode.hitCounter)"
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
        
        let gameScoreText: String = GV.language.getText(.TCGameScore) + " \(gameScore)"
        targetScore = countContainers * countSpritesProContainer! * targetScoreKorr
        let targetScoreText: String = GV.language.getText(.TCTargetScore) + " \(targetScore)"
        spriteCount = Int(CGFloat(countContainers * countSpritesProContainer!))
        let spriteCountText: String = GV.language.getText(.TCSpriteCount) + " \(spriteCount)"
        
        createLabels(gameScoreLabel, text: gameScoreText, position: CGPointMake(self.position.x + self.size.width * gameScorePosKorr.x, self.position.y + self.size.height * gameScorePosKorr.y), horAlignment: .Left)
        createLabels(levelScoreLabel, text: "", position: CGPointMake(self.position.x + self.size.width * levelScorePosKorr.x, self.position.y + self.size.height * levelScorePosKorr.y), horAlignment: .Left)
        createLabels(targetScoreLabel, text: targetScoreText, position: CGPointMake(self.position.x + self.size.width * targetPosKorr.x, self.position.y + self.size.height * targetPosKorr.y), horAlignment: .Right)
        createLabels(spriteCountLabel, text: spriteCountText, position: CGPointMake(self.position.x + self.size.width * spriteCountPosKorr.x, self.position.y + self.size.height * spriteCountPosKorr.y), horAlignment: .Left)

        showScore()
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
            updateSpriteCount(-1)
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
            updateSpriteCount(-2)
//            spriteCount--
            playSound("Drop", volume: GV.soundVolume)
            showScore()
        }
//        spriteCount--
//        let spriteCountText: String = GV.language.getText(.TCSpriteCount)
//        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
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
            container.hitLabel.text = "\(container.hitCounter)"
            showScore()
            playSound("Container", volume: GV.soundVolume)
        } else {
            container.hitCounter -= movingSprite.hitCounter
            showScore()
            playSound("Funk_Bot", volume: GV.soundVolume)
            container.hitLabel.text = "\(container.hitCounter)"

        }
        
        countMovingSprites = 0
        
        updateSpriteCount(-1)
        
//        spriteCount--
//        let spriteCountText: String = GV.language.getText(.TCSpriteCount)
//        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
        
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
            //cont = Container(mySKNode: MySKNode(texture: getTexture(index), type: .ContainerType, value: getValueForContainer()), label: SKLabelNode(), countHits: 0)
            cont = Container(mySKNode: MySKNode(texture: getTexture(index), type: .ContainerType, value: getValueForContainer()))
            containers.append(cont)
            containers[index].mySKNode.name = "\(index)"
            containers[index].mySKNode.position = CGPoint(x: centerX, y: centerY)
            containers[index].mySKNode.size.width = containerSize.width
            containers[index].mySKNode.size.height = containerSize.height
            
//            containers[index].label.text = "0"
//            containers[index].label.fontSize = 20;
//            containers[index].label.fontName = "ArielBold"
//            containers[index].label.position = CGPointMake(CGRectGetMidX(containers[index].mySKNode.frame), CGRectGetMidY(containers[index].mySKNode.frame) * 1.03)
//            containers[index].label.name = "label"
//            containers[index].label.fontColor = SKColor.blackColor()
//            self.addChild(containers[index].label)
            
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

    override func pull() {
        let duration = 0.2
        var actionMoveArray = [SKAction]()
        if let savedSprite:SavedSprite = stack.pull() {
            var savedSpriteInCycle = savedSprite
            var run = true
            var stopSoon = false
            
            repeat {
                
                switch savedSpriteInCycle.status {
                case .Added:
                    if stack.countChangesInStack() > 0 {
                        let spriteName = savedSpriteInCycle.name
                        let colorIndex = savedSpriteInCycle.colorIndex
                        let searchName = "\(spriteName)"
                        self.childNodeWithName(searchName)!.removeFromParent()
                        let colorTabLine = ColorTabLine(colorIndex: colorIndex, spriteName: spriteName, spriteValue: savedSpriteInCycle.minValue)
                        colorTab.append(colorTabLine)
                        gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row] = false
                    }
                case .Removed:
                    //let spriteTexture = SKTexture(imageNamed: "sprite\(savedSpriteInCycle.colorIndex)")
                    let spriteTexture = getTexture(savedSpriteInCycle.colorIndex)
                    let sprite = MySKNode(texture: spriteTexture, type: .SpriteType, value: savedSpriteInCycle.minValue)
                    sprite.colorIndex = savedSpriteInCycle.colorIndex
                    sprite.position = savedSpriteInCycle.endPosition
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    sprite.size = savedSpriteInCycle.size
                    sprite.column = savedSpriteInCycle.column
                    sprite.row = savedSpriteInCycle.row
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    sprite.name = savedSpriteInCycle.name
                    gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row] = true
                    addPhysicsBody(sprite)
                    self.addChild(sprite)
                    updateSpriteCount(1)
                    sprite.reload()
                    
                case .Unification:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    sprite.size = savedSpriteInCycle.size
                    sprite.hitLabel.text = "\(sprite.hitCounter)"
                    sprite.reload()
                    
                case .HitcounterChanged:
                    let container = containers[savedSpriteInCycle.colorIndex].mySKNode
                    container.hitCounter = savedSpriteInCycle.hitCounter
                    container.reload()
                    showScore()
                    
                case .MovingStarted:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    sprite.hitLabel.text = "\(sprite.hitCounter)"
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                    sprite.reload()
                    sprite.runAction(SKAction.sequence(actionMoveArray))
                    
                case .FallingMovingSprite:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    containers[savedSpriteInCycle.colorIndex].mySKNode.hitCounter += sprite.hitCounter
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                    
                case .FirstCardAdded:
                    break
                    
                case .FallingSprite:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    containers[savedSpriteInCycle.colorIndex].mySKNode.hitCounter += sprite.hitCounter
                    let moveFallingSprite = SKAction.moveTo(savedSpriteInCycle.startPosition, duration: duration)
                    sprite.runAction(SKAction.sequence([moveFallingSprite]))
                    
                case .Mirrored:
                    //var sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                case .Exchanged: _ = 0
                    //default: run = false
                case .Nothing: break
                default: break
                }
                if let savedSprite:SavedSprite = stack.pull() {
                    savedSpriteInCycle = savedSprite
                    if (savedSpriteInCycle.status == .Added && stack.countChangesInStack() == 0) || stopSoon {
                        stack.push(savedSpriteInCycle)
                        run = false
                    }
                    if savedSpriteInCycle.status == .MovingStarted {
                        stopSoon = true
                    }
                } else {
                    run = false
                }
            } while run
            showScore()
        }
        
        
        
    }

    
    override func readNextLevel() -> Int {
        return levelsForPlay.getNextLevel()
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        while self.childNodeWithName("myLine") != nil {
            self.childNodeWithName("myLine")!.removeFromParent()
        }
        while self.childNodeWithName("nodeOnTheWall") != nil {
            self.childNodeWithName("nodeOnTheWall")!.removeFromParent()
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.locationInNode(self)
        let testNode = self.nodeAtPoint(touchLocation)
        
        let aktNodeType = analyzeNode(testNode)
        //        if self.inFirstGenerateSprites {
        //            switch aktNodeType {
        //            case MyNodeTypes.LabelNode, MyNodeTypes.SpriteNode: showNextSprite(touchLocation)
        //            default: return
        //            }
        //            return
        //        }
        if movedFromNode != nil && !stopped {
            //let countTouches = touches.count
            var aktNode: SKNode? = nil
            
            let startNode = movedFromNode
            
            switch aktNodeType {
            case MyNodeTypes.LabelNode: aktNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
            case MyNodeTypes.SpriteNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
            case MyNodeTypes.ButtonNode:
                //(testNode as! MySKNode).texture = SKTexture(imageNamed: "\(testNode.name!)")
                //(testNode as! MySKNode).texture = atlas.textureNamed("\(testNode.name!)")
                aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
            default: aktNode = nil
            }
            
            if showFingerNode {
                
                if let fingerNode = self.childNodeWithName("finger")! as? SKSpriteNode {
                    fingerNode.removeFromParent()
                }
                
            }
            if aktNode != nil && (aktNode as! MySKNode).type == .ButtonType && startNode.type == .ButtonType  {
                //            if aktNode != nil && mySKNode.type == .ButtonType && startNode.type == .ButtonType  {
                var mySKNode = aktNode as! MySKNode
                
                //                var name = (aktNode as! MySKNode).parent!.name
                if mySKNode.name == buttonName {
                    mySKNode = (mySKNode.parent) as! MySKNode
                }
                //switch (aktNode as! MySKNode).name! {
                switch mySKNode.name! {
                case "settings": settingsButtonPressed()
                case "undo": undoButtonPressed()
//                case "exchange": exchangeButtonPressed()
                case "restart": restartButtonPressed()
                default: specialButtonPressed(mySKNode.name!)
                }
                return
            }
            
            if exchangeModus {
                let myAktNode = aktNode as! MySKNode
                if startNode != nil && startNode != myAktNode && myAktNode.type == .SpriteType {
                    let column = startNode.column
                    let row = startNode.row
                    let startPosition = startNode.startPosition
                    
                    push(startNode, sprite2: aktNode as! MySKNode)
                    startNode.zPosition = 5
                    myAktNode.zPosition = 4
                    let actionMove1 = SKAction.moveTo(startNode.position, duration: 1.0)
                    myAktNode.runAction(SKAction.sequence([actionMove1]))
                    let actionMove2 = SKAction.moveTo(myAktNode.position, duration: 1.0)
                    startNode.runAction(SKAction.sequence([actionMove2]))
                    
                    startNode.column = (aktNode as! MySKNode).column
                    startNode.row = (aktNode as! MySKNode).row
                    startNode.startPosition = (aktNode as! MySKNode).startPosition
                    
                    (aktNode as! MySKNode).column = column
                    (aktNode as! MySKNode).row = row
                    (aktNode as! MySKNode).startPosition = startPosition
                    
                }
                for index in 0..<tremblingSprites.count {
                    tremblingSprites[index].size = tremblingSprites[index].origSize
                    tremblingSprites[index].tremblingType = .NoTrembling
                    tremblingSprites[index].zRotation = 0
                    tremblingSprites[index].zPosition = 0
                }
                tremblingSprites.removeAll()
                exchangeModus = false
                return
            }
            
            
            if startNode.type == .SpriteType && (aktNode == nil || (aktNode as! MySKNode) != movedFromNode) {
                let sprite = movedFromNode// as! SKSpriteNode
                
                
                sprite!.physicsBody = SKPhysicsBody(circleOfRadius: sprite!.size.width/2)
                sprite.physicsBody?.dynamic = true
                sprite.physicsBody?.categoryBitMask = PhysicsCategory.MovingSprite
                sprite.physicsBody?.contactTestBitMask = PhysicsCategory.Sprite | PhysicsCategory.Container //| PhysicsCategory.WallAround
                sprite.physicsBody?.collisionBitMask = PhysicsCategory.None
                //sprite.physicsBody?.velocity=CGVectorMake(200, 200)
                
                sprite.physicsBody?.usesPreciseCollisionDetection = true
                /*
                let offset = touchLocation - movedFromNode.position
                
                let direction = offset.normalized()
                
                // 7 - Make it shoot far enough to be guaranteed off screen
                let shootAmount = direction * 1000
                
                // 8 - Add the shoot amount to the current position
                let realDest = shootAmount + movedFromNode.position
                */
                push(sprite, status: .MovingStarted)
                
                // 9 - Create the actions
                let line = JGXLine(fromPoint: movedFromNode.position, toPoint: touchLocation, inFrame: self.frame, lineSize: movedFromNode.size.width)
                let pointOnTheWall = line.line.toPoint
                
                let mirroredLine1 = line.createMirroredLine()
                let pointOnTheWall1 = mirroredLine1.line.toPoint
                
                let mirroredLine2 = mirroredLine1.createMirroredLine()
                let pointOnTheWall2 = mirroredLine2.line.toPoint
                
                let mirroredLine3 = mirroredLine2.createMirroredLine()
                let pointOnTheWall3 = mirroredLine3.line.toPoint
                
                let countAndPushAction = SKAction.runBlock({
                    self.push(sprite, status: .Mirrored)
                    sprite.hitCounter *= 2
                    sprite.hitLabel.text = "\(sprite.hitCounter)"
                })
                
                
                
                let actionMove = SKAction.moveTo(pointOnTheWall, duration: line.duration)
                
                let actionEmpty = SKAction.runBlock({
                    self.makeEmptyCard(sprite.column, row: sprite.row)
                })
                
                let actionMove1 = SKAction.moveTo(pointOnTheWall1, duration: mirroredLine1.duration)
                
                let actionMove2 = SKAction.moveTo(pointOnTheWall2, duration: mirroredLine2.duration)
                
                let actionMove3 = SKAction.moveTo(pointOnTheWall3, duration: mirroredLine3.duration)
                
                
                //                let waitSparkAction = SKAction.runBlock({
                //                    sprite.hidden = true
                //                    sleep(0)
                //                    sprite.removeFromParent()
                //                })
                //
                let actionMoveStopped =  SKAction.runBlock({
                    self.push(sprite, status: .Removed)
                    sprite.hidden = true
                    self.gameArray[sprite.column][sprite.row] = false
                    //sprite.size = CGSizeMake(sprite.size.width / 3, sprite.size.height / 3)
                    sprite.colorBlendFactor = 4
                    self.playSound("Drop", volume: GV.soundVolume)
                    sprite.removeFromParent()
                    //                    let sparkEmitter = SKEmitterNode(fileNamed: "MyParticle.sks")
                    //                    sparkEmitter?.position = sprite.position
                    //                    sparkEmitter?.zPosition = 1
                    //                    sparkEmitter?.particleLifetime = 1
                    //                    let emitterDuration = CGFloat(sparkEmitter!.numParticlesToEmit) * sparkEmitter!.particleLifetime
                    //
                    //                    let wait = SKAction.waitForDuration(NSTimeInterval(emitterDuration))
                    //
                    //                    let remove = SKAction.runBlock({sparkEmitter!.removeFromParent()/*; print("Emitter removed")*/})
                    //                    sparkEmitter!.runAction(SKAction.sequence([wait, remove]))
                    //                    self.addChild(sparkEmitter!)
                    self.pull()
                    self.userInteractionEnabled = true
                    
                    
                })
                
                
                
                
                //let actionMoveDone = SKAction.removeFromParent()
                collisionActive = true
                lastMirrored = ""
                
                self.userInteractionEnabled = false  // userInteraction forbidden!
                countMovingSprites = 1
                self.waitForSKActionEnded = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("checkCountMovingSprites"), userInfo: nil, repeats: false) // start timer for check
                
                movedFromNode.runAction(SKAction.sequence([actionEmpty, actionMove, countAndPushAction, actionMove1, countAndPushAction, actionMove2, countAndPushAction, actionMove3, actionMoveStopped//,
                    /*waitSparkAction*/]))
                //actionMoveDone]))
            }
            
        }
    }

}