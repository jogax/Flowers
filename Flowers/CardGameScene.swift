
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
    let spriteCountPosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.95 : 0.95)
    var levelsForPlay = LevelsForPlayWithCards()

    var lastUpdateSec = 0

    override func getTexture(index: Int)->SKTexture {
        if index == NoColor {
            return atlas.textureNamed("emptycard")
        } else {
            return atlas.textureNamed ("card\(index)")
        }
    }
    override func makeSpezialThings(first: Bool) {
        let multiplier = GV.deviceConstants.sizeMultiplier
        let width:CGFloat = 64.0
        let height: CGFloat = 89.0
        sizeMultiplier = CGSizeMake(multiplier, multiplier * height / width)
        levelsForPlay.setAktLevel(levelIndex)
    }
        
    override func specialPrepareFuncFirst() {
        countContainers = levelsForPlay.aktLevel.countContainers
        countSpritesProContainer = levelsForPlay.aktLevel.countSpritesProContainer
        countColumns = levelsForPlay.aktLevel.countColumns
        countRows = levelsForPlay.aktLevel.countRows
        minUsedCells = levelsForPlay.aktLevel.minProzent * countColumns * countRows / 100
        maxUsedCells = levelsForPlay.aktLevel.maxProzent * countColumns * countRows / 100
        containerSize = CGSizeMake(CGFloat(containerSizeOrig) * sizeMultiplier.width, CGFloat(containerSizeOrig) * sizeMultiplier.height)
        spriteSize = CGSizeMake(CGFloat(spriteSizeOrig) * sizeMultiplier.width, CGFloat(spriteSizeOrig) * sizeMultiplier.height )
    }
    
    override func updateSpriteCount(adder: Int) {
        spriteCount += adder
        let spriteCountText: String = GV.language.getText(.TCCardCount)
        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
    }

    override func changeLanguage()->Bool {
        playerLabel.text = GV.language.getText(TextConstants.TCGamer) + ": \(GV.globalParam.aktName)"
        levelLabel.text = GV.language.getText(TextConstants.TCLevel) + ": \(levelIndex + 1)"
        spriteCountLabel.text = "\(GV.language.getText(.TCCardCount)) + \(spriteCount)"
        showTimeLeft()
        return true
    }

    override func setBGImageNode()->SKSpriteNode {
        return SKSpriteNode(imageNamed: "cardBackground.png")
    }

    override func generateValue(colorIndex: Int)->Int {
        if valueTab.count < colorIndex + 1 {
            valueTab.append(1)
        }
        return valueTab[colorIndex]++
            
    }
    
    override func spezialPrepareFunc() {
        valueTab.removeAll()
        spriteCount = Int(CGFloat(countContainers * countSpritesProContainer!))
        let spriteCountText: String = GV.language.getText(.TCCardCount) + " \(spriteCount)"
        createLabels(spriteCountLabel, text: spriteCountText, position: CGPointMake(self.position.x + self.size.width * spriteCountPosKorr.x, self.position.y + self.size.height * spriteCountPosKorr.y), horAlignment: .Left)
    }

    override func getValueForContainer()->Int {
        return countSpritesProContainer!// + 1
    }
    
    override func update(currentTime: NSTimeInterval) {
        let sec10: Int = Int(currentTime * 10) % 2
        if sec10 != lastUpdateSec && sec10 == 0 {
            let adder:CGFloat = 5
            backgroudScrollUpdate()
            for index in 0..<tremblingSprites.count {
                let aktSprite = tremblingSprites[index]
                switch aktSprite.trembling {
                    case 0: aktSprite.trembling = adder
                    case adder: aktSprite.trembling = -adder
                    case -adder: aktSprite.trembling = adder
                    default: aktSprite.trembling = adder
                }
                switch aktSprite.tremblingType {
                    case .NoTrembling: break
                    case .ChangeSize:  aktSprite.size = CGSizeMake(aktSprite.origSize.width +  aktSprite.trembling, aktSprite.origSize.height +  aktSprite.trembling)
                    case .ChangePos: break
                case .ChangeDirection: aktSprite.zRotation = CGFloat(CGFloat(M_PI)/CGFloat(aktSprite.trembling == 0 ? 16 : aktSprite.trembling * CGFloat(8)))
                }
            }
        }
        lastUpdateSec = sec10
    }

    override func spriteDidCollideWithContainer(node1:MySKNode, node2:MySKNode) {
        let movingSprite = node1
        let container = node2
        
        var containerColorIndex = container.colorIndex
        let movingSpriteColorIndex = movingSprite.colorIndex
        
        
        if container.minValue == container.maxValue && container.maxValue == NoColor && movingSprite.maxValue + 1 == MaxCardValue {
            push(container, status: .FirstCardAdded)
            containerColorIndex = movingSpriteColorIndex
            container.colorIndex = containerColorIndex
            container.texture = getTexture(containerColorIndex)
//            container.minValue = movingSprite.minValue
//            container.maxValue = movingSprite.maxValue
//            container.reload()
        }
        
        let OK = movingSpriteColorIndex == containerColorIndex &&
        (
            container.minValue == NoColor ||
            movingSprite.maxValue + 1 == container.minValue ||
            movingSprite.minValue - 1 == container.maxValue ||
            (container.minValue == container.maxValue && container.maxValue == movingSprite.maxValue)
        )

        
        
        //print("spriteName: \(containerColorIndex), containerName: \(spriteColorIndex)")
        if OK  {
            push(container, status: .HitcounterChanged)
            push(movingSprite, status: .Removed)
            if container.maxValue < movingSprite.minValue {
                container.maxValue = movingSprite.maxValue
            } else {
                container.minValue = movingSprite.minValue
                if container.maxValue == NoColor {
                    container.maxValue = movingSprite.maxValue
                }
            }
            container.reload()
            //gameArray[movingSprite.column][movingSprite.row] = false
            movingSprite.removeFromParent()
            playSound("Container", volume: GV.soundVolume)
            countMovingSprites = 0
            
            updateSpriteCount(-1)
            
            collisionActive = false
            //movingSprite.removeFromParent()
            gameArray[movingSprite.column][movingSprite.row] = false
            checkGameFinished()
        } else {
            updateSpriteCount(-1)
            movingSprite.removeFromParent()
            countMovingSprites = 0
            push(movingSprite, status: .Removed)
            pull()
        }
        
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
            updateSpriteCount(-1)
//            spriteCount--
       } else {

            updateSpriteCount(-1)
            movingSprite.removeFromParent()
            countMovingSprites = 0
            push(movingSprite, status: .Removed)
            pull()
            
        }
        checkGameFinished()
    }

    override func checkGameFinished() {
        
        
        let usedCellCount = checkGameArray()
        let containersOK = checkContainers()
        
        if usedCellCount == 0 && containersOK { // Level completed, start a new game
            
            stopTimer()
            playMusic("Winner", volume: GV.musicVolume, loops: 0)
            let playerName = GV.globalParam.aktName == GV.dummyName ? "!" : " " + GV.globalParam.aktName + "!"
            let alert = UIAlertController(title: GV.language.getText(.TCLevelComplete),
                message: GV.language.getText(TextConstants.TCCongratulations) + playerName,
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
            if containers[index].mySKNode.minValue != FirstCardValue && containers[index].mySKNode.maxValue % MaxCardValue != LastCardValue {
                return false
            }
        }
        return true

    }
    
    override func prepareContainers() {
        
        colorTab.removeAll(keepCapacity: false)
        var spriteName = 10000
        
        for _ in 0..<countSpritesProContainer! {
            for containerIndex in 0..<countContainers {
                let colorTabLine = ColorTabLine(colorIndex: containerIndex, spriteName: "\(spriteName++)", spriteValue: generateValue(containerIndex) - 1)
                colorTab.append(colorTabLine)
            }
        }
        
        let xDelta = size.width / CGFloat(countContainers)
        for index in 0..<countContainers {
            let centerX = (size.width / CGFloat(countContainers)) * CGFloat(index) + xDelta / 2
            let centerY = size.height * containersPosCorr.y
            let cont: Container
//            cont = Container(mySKNode: MySKNode(texture: getTexture(index), type: .ContainerType, value: getValueForContainer()), label: SKLabelNode(), countHits: 0)
            cont = Container(mySKNode: MySKNode(texture: getTexture(NoColor), type: .ContainerType, value: NoColor)) // getValueForContainer()))
            containers.append(cont)
            containers[index].mySKNode.name = "\(index)"
            containers[index].mySKNode.position = CGPoint(x: centerX, y: centerY)
            containers[index].mySKNode.size = CGSizeMake(containerSize.width, containerSize.height)
//            containers[index].mySKNode.size.width = containerSize.width
//            containers[index].mySKNode.size.height = containerSize.height
            
            containers[index].mySKNode.colorIndex = NoValue
            containers[index].mySKNode.physicsBody = SKPhysicsBody(circleOfRadius: containers[index].mySKNode.size.width / 3) // 1
            containers[index].mySKNode.physicsBody?.dynamic = true // 2
            containers[index].mySKNode.physicsBody?.categoryBitMask = PhysicsCategory.Container
            containers[index].mySKNode.physicsBody?.contactTestBitMask = PhysicsCategory.MovingSprite
            containers[index].mySKNode.physicsBody?.collisionBitMask = PhysicsCategory.None
            countColorsProContainer.append(countSpritesProContainer!)
            addChild(containers[index].mySKNode)
            containers[index].mySKNode.reload()
        }
    }

    override func pull() {
        let duration = 0.2
        var actionMoveArray = [SKAction]()
        if let savedSprite = stack.pull() {
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
                    let sprite = MySKNode(texture: spriteTexture, type: .SpriteType, value: savedSpriteInCycle.minValue) //NoValue)
                    
                    
                    sprite.colorIndex = savedSpriteInCycle.colorIndex
                    sprite.position = savedSpriteInCycle.endPosition
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    sprite.size = savedSpriteInCycle.size
                    sprite.column = savedSpriteInCycle.column
                    sprite.row = savedSpriteInCycle.row
                    sprite.minValue = savedSpriteInCycle.minValue
                    sprite.maxValue = savedSpriteInCycle.maxValue
                    sprite.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    sprite.name = savedSpriteInCycle.name
                    gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row] = true
                    addPhysicsBody(sprite)
                    self.addChild(sprite)
                    updateSpriteCount(1)
                    sprite.reload()
                    
                case .Unification:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.size = savedSpriteInCycle.size
                    sprite.minValue = savedSpriteInCycle.minValue
                    sprite.maxValue = savedSpriteInCycle.maxValue
                    sprite.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    //sprite.hitLabel.text = "\(sprite.hitCounter)"
                    sprite.reload()
                    
                case .HitcounterChanged:
                    
                    let container = containers[findIndex(savedSpriteInCycle.colorIndex)].mySKNode
                    container.minValue = savedSpriteInCycle.minValue
                    container.maxValue = savedSpriteInCycle.maxValue
                    container.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    container.reload()
                    showScore()
                    
                case .FirstCardAdded:
                    let container = containers[findIndex(savedSpriteInCycle.colorIndex)].mySKNode
                    container.minValue = savedSpriteInCycle.minValue
                    container.maxValue = savedSpriteInCycle.maxValue
                    container.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    container.colorIndex = NoColor
                    container.reload()
                    
                    
                case .MovingStarted:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    sprite.minValue = savedSpriteInCycle.minValue
                    sprite.maxValue = savedSpriteInCycle.maxValue
                    sprite.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                    sprite.runAction(SKAction.sequence(actionMoveArray))
                    sprite.reload()
                    
                case .FallingMovingSprite:
//                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                    
                case .FallingSprite:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    let moveFallingSprite = SKAction.moveTo(savedSpriteInCycle.startPosition, duration: duration)
                    sprite.runAction(SKAction.sequence([moveFallingSprite]))
                    
                case .Mirrored:
                    //var sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                case .Exchanged:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    let savedSprite = stack.pull()
                    let sprite1 = self.childNodeWithName(savedSprite!.name)! as! MySKNode
                    
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    sprite.minValue = savedSpriteInCycle.minValue
                    sprite.maxValue = savedSpriteInCycle.maxValue
                    sprite.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    
                    sprite1.startPosition = savedSprite!.startPosition
                    sprite1.minValue = savedSprite!.minValue
                    sprite1.maxValue = savedSprite!.maxValue
                    sprite1.BGPictureAdded = savedSprite!.BGPictureAdded

                    let action = SKAction.moveTo(sprite.startPosition, duration: 1.0)
                    let action1 = SKAction.moveTo(sprite1.startPosition, duration: 1.0)

                    sprite.runAction(SKAction.sequence([action]))
                    sprite1.runAction(SKAction.sequence([action1]))
                    
                    sprite.reload()
                    sprite1.reload()
                    savedSpriteInCycle = savedSprite!
                    stopSoon = true
                case .Nothing: break
                }
                if let savedSprite = stack.pull() {
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
    
    func findIndex(colorIndex: Int)->Int {
        for index in 0..<countContainers {
            if containers[index].mySKNode.colorIndex == colorIndex {
                return index
            }
        }
        return NoColor
    }
    
    override func readNextLevel() -> Int {
        return levelsForPlay.getNextLevel()
    }

}
