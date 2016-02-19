//
//  GameScene.swift
//  JSprites
//
//  Created by Jozsef Romhanyi on 11.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import AVFoundation

class FlowerGameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate { //MyGameScene {
    let levelScorePosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.93 : 0.92)
    let gameScorePosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.95 : 0.94)
    let spriteCountPosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.91 : 0.90)
    let targetPosKorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.93 : 0.92)
    
    var gameScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var levelScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var targetScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    var levelsForPlay = LevelsForPlayWithSprites()

    struct GameArrayPositions {
        var used: Bool
        var position: CGPoint
        var colorIndex: Int
        var name: String
        var minValue: Int
        var maxValue: Int
        init() {
            self.used = false
            self.position = CGPointMake(0, 0)
            self.colorIndex = NoColor
            self.name = ""
            self.minValue = NoValue
            self.maxValue = NoValue
        }
    }
    
    struct ColorTabLine {
        var colorIndex: Int
        var spriteName: String
        var spriteValue: Int
        init(colorIndex: Int, spriteName: String){
            self.colorIndex = colorIndex
            self.spriteName = spriteName
            self.spriteValue = 0
        }
        init(colorIndex: Int, spriteName: String, spriteValue: Int){
            self.colorIndex = colorIndex
            self.spriteName = spriteName
            self.spriteValue = spriteValue
        }
    }
    
    struct Founded {
        let maxDistance: CGFloat = 100000.0
        var point: CGPoint
        var column: Int
        var row: Int
        var foundContainer: Bool
        var distanceToP1: CGFloat
        var distanceToP0: CGFloat
        init(column: Int, row: Int, foundContainer: Bool, point: CGPoint, distanceToP1: CGFloat, distanceToP0: CGFloat) {
            self.distanceToP1 = distanceToP1
            self.distanceToP0 = distanceToP0
            self.column = column
            self.row = row
            self.foundContainer = foundContainer
            self.point = point
        }
        init() {
            self.distanceToP1 = maxDistance
            self.distanceToP0 = maxDistance
            self.point = CGPointMake(0, 0)
            self.column = 0
            self.row = 0
            self.foundContainer = false
        }
    }
    
    
    var tremblingSprites: [MySKNode] = []
    var random: MyRandom?
    // Values from json File
    var params = ""
    var countSpritesProContainer: Int?
    var countColumns = 0
    var countRows = 0
    var countContainers = 0
    var targetScoreKorr: Int = 0
    var tableCellSize: CGFloat = 0
    var sizeMultiplier: CGSize = CGSizeMake(1, 1)
    var buttonSizeMultiplier: CGSize = CGSizeMake(1, 1)
    var containerSize:CGSize = CGSizeMake(0, 0)
    var spriteSize:CGSize = CGSizeMake(0, 0)
    var minUsedCells = 0
    var maxUsedCells = 0
    var gameNumber = 0
    
    var touchesBeganAt: NSDate?
    
    let containerSizeOrig: CGFloat = 50
    let spriteSizeOrig: CGFloat = 35
    
    var showFingerNode = false
    var countMovingSprites = 0
    var countCheckCounts = 0
    
    //let timeLimitKorr = 5 // sec for pro Sprite
    var timeCount = 0 // seconds
    //    var startTime: NSDate?
    //    var startTimeOrig: NSDate?
    var timer: NSTimer?
    var countUp: NSTimer?
    var waitForSKActionEnded: NSTimer?
    var lastMirrored = ""
    var audioPlayer: AVAudioPlayer?
    var soundPlayer: AVAudioPlayer?
    var myView = SKView()
    var levelIndex = Int(GV.spriteGameDataArray[GV.getAktNameIndex()].spriteLevelIndex)
    var stack:Stack<SavedSprite> = Stack()
    //var gameArray = [[Bool]]() // true if Cell used
    var gameArray = [[GameArrayPositions]]()
    var containers = [Container]()
    var colorTab = [ColorTabLine]()
    let containersPosCorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.85 : 0.85)
    var levelPosKorr = CGPointMake(GV.onIpad ? 0.7 : 0.7, GV.onIpad ? 0.97 : 0.97)
    let playerPosKorr = CGPointMake(0.3 * GV.deviceConstants.sizeMultiplier, 0.97 * GV.deviceConstants.sizeMultiplier)
    let countUpPosKorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.95 : 0.94)
    var countColorsProContainer = [Int]()
    var labelBackground = SKSpriteNode()
    var levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var countUpLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var playerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var spriteCountLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    
    var gameScore = Int(GV.spriteGameDataArray[GV.getAktNameIndex()].spriteGameScore)
    var levelScore = 0
    var movedFromNode: MySKNode!
    var settingsButton: MySKButton?
    var undoButton: MySKButton?
    var restartButton: MySKButton?
    var exchangeButton: MySKButton?
    var nextLevelButton: MySKButton?
    var targetScore = 0
    var spriteCount = 0
    //var restartCount = 0
    var stopped = true
    var collisionActive = false
    var bgImage: SKSpriteNode?
    var bgAdder: CGFloat = 0
    //let showHelpLines = 4
    let maxHelpLinesCount = 4
    //    var undoCount = 0
    var inFirstGenerateSprites = false
    var lastShownNode: MySKNode?
    var parentViewController: UIViewController?
    var settingsSceneStarted = false
    var settingsDelegate: SettingsDelegate?
    //var settingsNode = SettingsNode()
    var gameDifficulty: Int = 0
    var spriteTabRect = CGRectZero
    
    //    let deviceIndex = GV.onIpad ? 0 : 1
    var buttonField: SKSpriteNode?
    //var levelArray = [Level]()
    var countLostGames = 0
    var lineUH: JGXLine?
    var lineLV: JGXLine?
    var lineRV: JGXLine?
    var lineBH: JGXLine?
    
    var spriteGameLastPosition = CGPointZero
    
    var buttonSize = CGFloat(0)
    var buttonYPos = CGFloat(0)
    var buttonXPosNormalized = CGFloat(0)
    let images = DrawImages()
    
    var tap: UITapGestureRecognizer?
    var dummy = 0
    
    
    
    let scoreAddCorrected = [1:1, 2:2, 3:3, 4:4, 5:5, 6:7, 7:8, 8:10, 9:11, 10:13, 11:14, 12:16,13:17,14:19, 15:20, 16:22, 17:23, 18:24, 19:25, 20:27, 21:28, 22:30, 23:31, 24:33, 25:34, 26:36, 27:37, 28:39, 29:40, 30:42, 31:43, 32:45, 33:46, 34:47, 35:48, 36:50, 37:51, 38:53, 39:54, 40:54, 41:53, 42:53, 43:52, 44:52, 45:51, 46:51, 47:51, 48:50, 49:50, 50:50, 51:51, 52:52, 53:53, 54:54, 55:55, 56:56, 57:57, 58:58, 59:59, 60:60, 61:61, 62:62, 63:63, 64:64, 65:65, 66:66, 67:67, 68:68, 69:69, 70:70, 71:71, 72:72, 73:73, 74:74, 75:75, 76:76, 77:77, 78:78, 79:79, 80:80, 81:81, 82:82, 83:83, 84:84, 85:85, 86:86, 87:87, 88:88, 89:89, 90:90, 91:91, 92:92, 93:93, 94:94, 95:95, 96:96, 97:97, 98:98, 99:99, 100:100]
    
    
    override func didMoveToView(view: SKView) {
        
        if !settingsSceneStarted {
            
            //            tap = UITapGestureRecognizer(target: self, action: "doubleTapped")
            //            tap!.numberOfTapsRequired = 1
            //            view.addGestureRecognizer(tap!)
            
            myView = view
            
            
            spriteTabRect.origin = CGPointMake(self.frame.midX, self.frame.midY * 0.85)
            spriteTabRect.size = CGSizeMake(self.frame.size.width * 0.80, self.frame.size.height * 0.80)
            
            makeSpezialThings(true)
            
            buttonSize = (myView.frame.width / 15) * buttonSizeMultiplier.width
            buttonYPos = myView.frame.height * 0.07
            buttonXPosNormalized = myView.frame.width / 10
            
            prepareNextGame(true)
            generateSprites(true)
        } else {
            playMusic("MyMusic", volume: GV.musicVolume, loops: 0)
            
        }
    }
    

    func getTexture(index: Int)->SKTexture {
        return atlas.textureNamed ("sprite\(index)")
    }
    
    func updateSpriteCount(adder: Int) {
        spriteCount += adder
        let spriteCountText: String = GV.language.getText(.TCSpriteCount)
        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
    }

    func generateSprites(first: Bool) {
        var positionsTab = [(Int, Int)]() // all available Positions
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if !gameArray[column][row].used {
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
            gameArray[aktColumn][aktRow].used = true
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

    func makeSpezialThings(first: Bool) {
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
    func setBGImageNode()->SKSpriteNode {
        return SKSpriteNode(imageNamed: "bgImage.png")
    }

    func showScore() {
        levelScore = 0
        for index in 0..<containers.count {
            levelScore += containers[index].mySKNode.hitCounter
//            containers[index].label.text = "\(containers[index].mySKNode.hitCounter)"
        }
        let levelScoreText: String = GV.language.getText(.TCLevelScore)
        levelScoreLabel.text = "\(levelScoreText) \(levelScore)"
        
    }
    
    func changeLanguage()->Bool {
        playerLabel.text = GV.language.getText(TextConstants.TCGamer) + ": \(GV.globalParam.aktName)"
        levelLabel.text = GV.language.getText(TextConstants.TCLevel) + ": \(levelIndex + 1)"
        gameScoreLabel.text = "\(GV.language.getText(.TCGameScore)) \(gameScore)"
        spriteCountLabel.text = "\(GV.language.getText(.TCSpriteCount)) \(spriteCount)"
        targetScoreLabel.text = "\(GV.language.getText(.TCTargetScore)) \(targetScore)"
        showScore()
        showTimeLeft()
        return true
    }

    func spezialPrepareFunc() {
        
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
    
    func spriteDidCollideWithMovingSprite(node1:MySKNode, node2:MySKNode) {
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
            
            gameArray[movingSprite.column][movingSprite.row].used = false
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
            gameArray[movingSprite.column][movingSprite.row].used = false
            gameArray[sprite.column][sprite.row].used = false
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

    func spriteDidCollideWithContainer(node1:MySKNode, node2:MySKNode) {
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
        gameArray[movingSprite.column][movingSprite.row].used = false
        checkGameFinished()
    }
    func prepareContainers() {
        
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

    func pull(createTipps: Bool) {
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
                        gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row].used = false
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
                    gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row].used = true
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

    
    func readNextLevel() -> Int {
        return levelsForPlay.getNextLevel()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        //        if inFirstGenerateSprites {
        //            return
        //        }
        //let countTouches = touches.count
        
        touchesBeganAt = NSDate()
        let firstTouch = touches.first
        let touchLocation = firstTouch!.locationInNode(self)
        
        let testNode = self.nodeAtPoint(touchLocation)
        
        let aktNodeType = analyzeNode(testNode)
        switch aktNodeType {
        case MyNodeTypes.LabelNode: movedFromNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
        case MyNodeTypes.SpriteNode:
            movedFromNode = self.nodeAtPoint(touchLocation) as! MySKNode
            //            if exchangeModus {
            //                movedFromNode.origSize = movedFromNode.size
            //                movedFromNode.tremblingType = .ChangeDirection
            //                tremblingSprites.append(movedFromNode)
            //            }
            if showFingerNode {
                let fingerNode = SKSpriteNode(imageNamed: "finger.png")
                fingerNode.name = "finger"
                fingerNode.position = touchLocation
                fingerNode.size = CGSizeMake(25,25)
                fingerNode.zPosition = 50
                addChild(fingerNode)
            }
            
        case MyNodeTypes.ContainerNode:
            movedFromNode = nil
            
        case MyNodeTypes.ButtonNode:
            movedFromNode = (self.nodeAtPoint(touchLocation) as! MySKNode).parent as! MySKNode
            //let textureName = "\(testNode.name!)Pressed"
            //let textureSelected = SKTexture(imageNamed: textureName)
            //(testNode as! MySKNode).texture = textureSelected
            //(testNode as! MySKNode).texture = atlas.textureNamed("\(testNode.name!)Pressed")
        default: movedFromNode = nil
        }
        if movedFromNode != nil {
            movedFromNode.zPosition = 50
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //        if inFirstGenerateSprites {
        //            return
        //        }
        if movedFromNode != nil {
            while self.childNodeWithName("myLine") != nil {
                self.childNodeWithName("myLine")!.removeFromParent()
            }
            while self.childNodeWithName("nodeOnTheWall") != nil {
                self.childNodeWithName("nodeOnTheWall")!.removeFromParent()
            }
            //let countTouches = touches.count
            let firstTouch = touches.first
            let touchLocation = firstTouch!.locationInNode(self)
            let testNode = self.nodeAtPoint(touchLocation)
            let aktNodeType = analyzeNode(testNode)
            var aktNode: SKNode? = movedFromNode
            //            var showLine = SKShapeNode()
            //            var foundedPoint: Founded?
            switch aktNodeType {
            case MyNodeTypes.LabelNode: aktNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
            case MyNodeTypes.SpriteNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
            case MyNodeTypes.ButtonNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
            default: aktNode = nil
            }
            if movedFromNode != aktNode {
                if movedFromNode.type == .ButtonType {
                    //movedFromNode.texture = atlas.textureNamed("\(movedFromNode.name!)")
                } else {
                    //
                    //                    var founded = false
                    //                    let line = JGXLine(fromPoint: movedFromNode.position, toPoint: touchLocation, inFrame: self.frame, lineSize: movedFromNode.size.width)
                    //                    let pointOnTheWall = line.line.toPoint
                    //                    (founded, foundedPoint) = makeHelpLine((movedFromNode.column, movedFromNode.row), fromPoint: movedFromNode.position, toPoint: pointOnTheWall, lineWidth: movedFromNode.size.width, showLines: true)
                    //
                    //
                    //                    if !founded && GV.showHelpLines > 1 {
                    //                        let mirroredLine1 = line.createMirroredLine()
                    //                        (founded, showLine, foundedPoint) = makeHelpLine((movedFromNode.column, movedFromNode.row), fromPoint: mirroredLine1.line.fromPoint, toPoint: mirroredLine1.line.toPoint, lineWidth: movedFromNode.size.width, showLines: true)
                    //
                    //                        if !founded && GV.showHelpLines > 2 {
                    //                            let mirroredLine2 = mirroredLine1.createMirroredLine()
                    //                            (founded, showLine, foundedPoint) = makeHelpLine((movedFromNode.column, movedFromNode.row), fromPoint: mirroredLine2.line.fromPoint, toPoint: mirroredLine2.line.toPoint, lineWidth: movedFromNode.size.width, showLines: true)
                    //
                    //                            if !founded && GV.showHelpLines > 3 {
                    //                                let mirroredLine3 = mirroredLine2.createMirroredLine()
                    //                                (founded, showLine, foundedPoint) = makeHelpLine((movedFromNode.column, movedFromNode.row), fromPoint: mirroredLine3.line.fromPoint, toPoint: mirroredLine3.line.toPoint, lineWidth: movedFromNode.size.width, showLines: true)
                    //                            }
                    //                        }
                    //                    }
                }
            }
            
            if showFingerNode {
                
                if let fingerNode = self.childNodeWithName("finger")! as? SKSpriteNode {
                    fingerNode.position = touchLocation
                }
                
            }
        }
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
                    case "restart": restartButtonPressed()
                    default: dummy = 0
                }
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
                let line = JGXLine(fromPoint: movedFromNode.position, toPoint: touchLocation, inFrame: self.frame, lineSize: movedFromNode.size.width, delegate: nil)
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
                    self.gameArray[sprite.column][sprite.row].used = false
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
                    self.pull(false)
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
    func prepareNextGame(newGame: Bool) {
        playMusic("MyMusic", volume: GV.musicVolume, loops: 0)
        stack = Stack()
        timeCount = 0
        if newGame {
            gameNumber = Int(arc4random_uniform(999999))
        }
        let seedIndex = SeedIndex(gameType: Int64(GV.spriteGameDataArray[GV.getAktNameIndex()].gameModus), gameDifficulty: 0, gameNumber: Int64(gameNumber))
        random = MyRandom(seedIndex: seedIndex)
        stopTimer()
        
        gameArray.removeAll(keepCapacity: false)
        containers.removeAll(keepCapacity: false)
        //undoCount = 3
        
        //        for _ in 0..<countRows {
        //            gameArray.append(Array(count: countRows, repeatedValue:false))
        //        }
        
        for _ in 0..<countColumns {
            gameArray.append(Array(count: countRows, repeatedValue:GameArrayPositions()))
        }
        
        for column in 0..<countColumns {
            for row in 0..<countRows {
                gameArray[column][row].position = calculateOfSpritePosition(column, row: row)
            }
        }
        
        
        
        //        labelBackground.color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        //        labelBackground.size = CGSizeMake(self.size.width, self.size.height / 5)
        //        labelBackground.position = CGPointMake(self.size.width / 2, self.position.y + self.size.height)
        
        prepareContainers()
        
        //        self.addChild(labelBackground)
        
        if GV.globalParam.aktName != GV.dummyName {
            createLabels(playerLabel, text: GV.language.getText(TextConstants.TCGamer) + "\(GV.globalParam.aktName)", position: CGPointMake(self.position.x + self.size.width * playerPosKorr.x, self.position.y + self.size.height * playerPosKorr.y))
        } else {
            levelPosKorr.x = 0.5
        }
        createLabels(levelLabel, text: GV.language.getText(TextConstants.TCLevel) + ": \(levelIndex + 1)", position: CGPointMake(self.position.x + self.size.width * levelPosKorr.x, self.position.y + self.size.height * levelPosKorr.y) )
        createLabels(countUpLabel, text: "", position: CGPointMake(self.position.x + self.size.width * countUpPosKorr.x, self.position.y + self.size.height * countUpPosKorr.y), horAlignment: .Right )
        
        showTimeLeft()
        
        
        bgImage = setBGImageNode()
        //print("ImageSize: \(bgImage?.size)")
        bgAdder = 0.1
        
        bgImage!.anchorPoint = CGPointZero
        bgImage!.position = CGPointMake(0, 0)
        bgImage!.zPosition = -15
        self.addChild(bgImage!)
        
        let settingsTexture = SKTexture(image: images.getSettings())
        settingsButton = MySKButton(texture: settingsTexture, frame: CGRectMake(buttonXPosNormalized * 1, buttonYPos, buttonSize, buttonSize))
        settingsButton!.name = "settings"
        addChild(settingsButton!)
        
        let restartTexture = SKTexture(image: images.getRestart())
        restartButton = MySKButton(texture: restartTexture, frame: CGRectMake(buttonXPosNormalized * 2.5, buttonYPos, buttonSize, buttonSize))
        restartButton!.name = "restart"
        addChild(restartButton!)
        
        let undoTexture = SKTexture(image: images.getUndo())
        undoButton = MySKButton(texture: undoTexture, frame: CGRectMake(buttonXPosNormalized * 9.0, buttonYPos, buttonSize, buttonSize))
        undoButton!.name = "undo"
        addChild(undoButton!)
        
        
        
        backgroundColor = UIColor.whiteColor() //SKColor.whiteColor()
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        makeLineAroundGameboard(.UpperHorizontal)
        makeLineAroundGameboard(.RightVertical)
        makeLineAroundGameboard(.BottomHorizontal)
        makeLineAroundGameboard(.LeftVertical)
        //        self.inFirstGenerateSprites = false
        spezialPrepareFunc()
    }
    
    func createLabels(label: SKLabelNode, text: String, position: CGPoint) {
        label.text = text
        label.position = position
        label.fontColor = SKColor.blackColor()
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        label.fontSize = 15;
        label.color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.addChild(label)
    }
    
    func createLabels(label: SKLabelNode, text: String, position: CGPoint, horAlignment: SKLabelHorizontalAlignmentMode) {
        createLabels(label, text: text, position: position)
        label.horizontalAlignmentMode = horAlignment
    }
    
    
    func settingsButtonPressed() {
        playMusic("NoSound", volume: GV.musicVolume, loops: 0)
        stopTimer()
        settingsDelegate?.settingsDelegateFunc()
    }
    
    func undoButtonPressed() {
        pull(true)
    }
    
    func makeLineAroundGameboard(linePosition: LinePosition) {
        //        var point1: CGPoint
        //        var point2: CGPoint
        var myWallRect: CGRect
        
        //var width: CGFloat = 4
        //var length: CGFloat = 0
        let yKorrBottom: CGFloat = size.height * 0.0
        switch linePosition {
        case .BottomHorizontal:  myWallRect = CGRectMake(position.x, position.y + yKorrBottom, size.width, 3)
        case .RightVertical:    myWallRect = CGRectMake(position.x + size.width, position.y + yKorrBottom,  3, size.height)
        case .UpperHorizontal: myWallRect = CGRectMake(position.x, position.y + size.height,  size.width, 3)
        case .LeftVertical:     myWallRect = CGRectMake(position.x, position.y + yKorrBottom,  3, size.height)
            //default:                myWallRect = CGRectZero
        }
        
        let myWall = SKNode()
        
        let pathToDraw:CGMutablePathRef = CGPathCreateMutable()
        let myWallLine:SKShapeNode = SKShapeNode(path:pathToDraw)
        myWallLine.lineWidth = 3
        
        myWallLine.name = linePosition.linePositionName
        CGPathMoveToPoint(pathToDraw, nil, myWallRect.origin.x, myWallRect.origin.y)
        CGPathAddLineToPoint(pathToDraw, nil, myWallRect.origin.x + myWallRect.width, myWallRect.origin.y + myWallRect.height)
        
        myWallLine.path = pathToDraw
        
        myWallLine.strokeColor = SKColor(red: 1, green: 1, blue: 1, alpha: 1.0) // GV.colorSets[GV.colorSetIndex][colorIndex + 1]
        
        myWall.name = linePosition.linePositionName
        myWall.physicsBody = SKPhysicsBody(edgeLoopFromRect: myWallRect)
        myWall.physicsBody?.dynamic = true
        myWall.physicsBody?.categoryBitMask = PhysicsCategory.WallAround
        myWall.physicsBody?.contactTestBitMask = PhysicsCategory.MovingSprite
        myWall.physicsBody?.collisionBitMask = PhysicsCategory.None
        myWall.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(myWall)
        self.addChild(myWallLine)
    }
    
    func playMusic(fileName: String, volume: Float, loops: Int) {
        //levelArray = GV.cloudData.readLevelDataArray()
        let url = NSURL.fileURLWithPath(
            NSBundle.mainBundle().pathForResource(fileName, ofType: "m4a")!)
        //backgroundColor = SKColor(patternImage: UIImage(named: "aquarium.png")!)
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 0.001 * volume
            audioPlayer?.numberOfLoops = loops
            audioPlayer?.play()
        } catch {
            print("audioPlayer error")
        }
    }
    
    func playSound(fileName: String, volume: Float) {
        let url = NSURL.fileURLWithPath(
            NSBundle.mainBundle().pathForResource(fileName, ofType: "m4a")!)
        
        do {
            try soundPlayer = AVAudioPlayer(contentsOfURL: url)
            soundPlayer?.delegate = self
            soundPlayer?.prepareToPlay()
            soundPlayer?.volume = 0.001 * volume
            soundPlayer?.numberOfLoops = 0
            soundPlayer?.play()
        } catch {
            print("soundPlayer error")
        }
        
        
    }
    
    func checkGameArray() -> Int {
        var usedCellCount = 0
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if gameArray[column][row].used {
                    usedCellCount++
                }
            }
        }
        return usedCellCount
    }
    
    
    func checkGameFinished() {
        
        
        let usedCellCount = checkGameArray()
        
        if usedCellCount == 0 || levelScore > targetScore { // Level completed, start a new game
            //            if countUp != nil {
            //                countUp!.invalidate()
            //                countUp = nil
            //                //playMusic("Winner", volume: GV.soundVolume)
            //            }
            
            stopTimer()
            if levelScore < targetScore {
                countLostGames++
                let lost3Times = countLostGames > 2 && levelIndex > 1
                let alert = UIAlertController(title: GV.language.getText(lost3Times ? .TCGameLost3: .TCGameLost),
                    message: GV.language.getText(.TCTargetNotReached),
                    preferredStyle: .Alert)
                if lost3Times {
                    countLostGames = 0
                    levelIndex -= 2
                }
                let cancelAction = UIAlertAction(title: GV.language.getText(.TCReturn), style: .Cancel, handler: nil)
                let againAction = UIAlertAction(title: GV.language.getText(.TCOK), style: .Default,
                    handler: {(paramAction:UIAlertAction!) in
                        self.newGame(lost3Times)
                })
                alert.addAction(cancelAction)
                alert.addAction(againAction)
                parentViewController!.presentViewController(alert, animated: true, completion: nil)
            } else {
                
                playMusic("Winner", volume: GV.musicVolume, loops: 0)
                
                let alert = UIAlertController(title: GV.language.getText(.TCLevelComplete),
                    message: GV.language.getText(TextConstants.TCCongratulations) + GV.globalParam.aktName == GV.dummyName ? "" : " " + GV.globalParam.aktName,
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
        }
        if usedCellCount < minUsedCells {
            generateSprites(false)  // Nachgenerierung
        }
    }
    
    func addPhysicsBody(sprite: MySKNode) {
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        sprite.physicsBody?.dynamic = true
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.Sprite
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.MovingSprite
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.None
        sprite.physicsBody?.usesPreciseCollisionDetection = true
    }
    

    func push(sprite: MySKNode, status: SpriteStatus) {
        var savedSprite = SavedSprite()
        savedSprite.type = sprite.type
        savedSprite.name = sprite.name!
        savedSprite.status = status
        savedSprite.startPosition = sprite.startPosition
        savedSprite.endPosition = sprite.position
        savedSprite.colorIndex = sprite.colorIndex
        savedSprite.size = sprite.size
        savedSprite.hitCounter = sprite.hitCounter
        savedSprite.minValue = sprite.minValue
        savedSprite.maxValue = sprite.maxValue
        savedSprite.column = sprite.column
        savedSprite.row = sprite.row
        stack.push(savedSprite)
    }
    
    func showTimeLeft() {
    }

    func generateValue(colorIndex:Int)->Int {
        return NoValue
    }
    
    func getValueForContainer()->Int {
        return NoValue
    }
    
    func analyzeNode (node: AnyObject) -> UInt32 {
        let testNode = node as! SKNode
        switch node  {
        case is FlowerGameScene: return MyNodeTypes.MyGameScene
        case is SKLabelNode:
            switch testNode.parent {
            case is FlowerGameScene: return MyNodeTypes.MyGameScene
            case is SKSpriteNode: return MyNodeTypes.none
            default: break
            }
            //            if testNode.parent is MyGameScene {
            //                return MyNodeTypes.MyGameScene
            //            }
            return MyNodeTypes.LabelNode
        case is MySKNode:
            var mySKNode: MySKNode = (testNode as! MySKNode)
            switch mySKNode.type {
            case .ContainerType: return MyNodeTypes.ContainerNode
            case .SpriteType, .EmptyCardType, .ShowCardType: return MyNodeTypes.SpriteNode
            case .ButtonType:
                if mySKNode.name == buttonName {
                    mySKNode = mySKNode.parent as! MySKNode
                }
                return MyNodeTypes.ButtonNode
            }
        default: return MyNodeTypes.none
        }
    }
    
    func restartButtonPressed() {
        newGame(false)
    }

    func stopTimer() {
        if countUp != nil {
            countUp?.invalidate()
            countUp = nil
        }
    }
    
    func calculateOfSpritePosition(column: Int, row: Int) -> CGPoint {
        let cardPositionMultiplier = GV.deviceConstants.cardPositionMultiplier
        return CGPointMake(
            spriteTabRect.origin.x - spriteTabRect.size.width / 2 + CGFloat(column) * tableCellSize + tableCellSize / 2,
            spriteTabRect.origin.y - spriteTabRect.size.height / 3.0 + tableCellSize * cardPositionMultiplier / 2 + CGFloat(row) * tableCellSize * cardPositionMultiplier
        )
    }
    
    func newGame(next: Bool) {
        stopped = true
        if next {
            
            
            //levelIndex = readNextLevel()
            gameScore += levelScore
            
            for index in 0..<GV.spriteGameDataArray.count {
                if GV.spriteGameDataArray[index].name == GV.globalParam.aktName {
                    GV.spriteGameDataArray[index] = SpriteGameData()
                    GV.spriteGameDataArray[index].spriteLevelIndex = levelIndex
                    GV.spriteGameDataArray[index].spriteGameScore = gameScore
                    GV.spriteGameDataArray[index].aktLanguageKey = GV.language.getAktLanguageKey()
                    GV.spriteGameDataArray[index].showHelpLines = GV.showHelpLines
                    break
                }
            }
            GV.dataStore.saveSpriteGameRecord()
        }
        //self.children.removeAll(keepCapacity: false)
        for _ in 0..<self.children.count {
            let testNode = children[self.children.count - 1]
            testNode.removeFromParent()
        }
        
        stopTimer()
        
        prepareNextGame(next)
        generateSprites(true)
    }
    
    func startTimer() {
        if countUp == nil {
            countUp = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("doCountUp"), userInfo: nil, repeats: true)
        }
    }
    
    func doCountUp() {
        
        timeCount++
        let countUpText = GV.language.getText(.TCTimeLeft)
        let minutes = Int(timeCount / 60)
        var seconds = "\(Int(timeCount % 60))"
        seconds = Int(seconds) < 10 ? "0\(seconds)" : "\(seconds)"
        countUpLabel.text = "\(countUpText) \(minutes):\(seconds)"
    }
    
    func checkCountMovingSprites() {
        if  countMovingSprites > 0 && countCheckCounts++ < 80 {
            self.waitForSKActionEnded = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("checkCountMovingSprites"), userInfo: nil, repeats: false)
        } else {
            countCheckCounts = 0
            self.userInteractionEnabled = true
        }
    }

    func didBeginContact(contact: SKPhysicsContact) {
        
        var movingSprite: SKPhysicsBody
        var partner: SKPhysicsBody
        
        switch (contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask) {
        case (PhysicsCategory.Sprite, PhysicsCategory.MovingSprite):
            movingSprite = contact.bodyB
            partner = contact.bodyA
            spriteDidCollideWithMovingSprite(movingSprite.node as! MySKNode, node2: partner.node as! MySKNode)
            
        case (PhysicsCategory.MovingSprite, PhysicsCategory.Sprite):
            movingSprite = contact.bodyA
            partner = contact.bodyB
            spriteDidCollideWithMovingSprite(movingSprite.node as! MySKNode, node2: partner.node as! MySKNode)
            
        case (PhysicsCategory.Container, PhysicsCategory.MovingSprite):
            movingSprite = contact.bodyB
            partner = contact.bodyA
            spriteDidCollideWithContainer(movingSprite.node as! MySKNode, node2: partner.node as! MySKNode)
            
        case (PhysicsCategory.MovingSprite, PhysicsCategory.Container):
            movingSprite = contact.bodyA
            partner = contact.bodyB
            spriteDidCollideWithContainer(movingSprite.node as! MySKNode, node2: partner.node as! MySKNode)
            /*
            case (PhysicsCategory.WallAround, PhysicsCategory.MovingSprite):
            movingSprite = contact.bodyB
            partner = contact.bodyA
            wallAroundDidCollideWithMovingSprite(movingSprite.node as! MySKNode, node2: partner.node!)
            
            case (PhysicsCategory.MovingSprite, PhysicsCategory.WallAround):
            movingSprite = contact.bodyA
            partner = contact.bodyB
            wallAroundDidCollideWithMovingSprite(movingSprite.node as! MySKNode, node2: partner.node!)
            */
        default: _ = 0
        }
    }
    


}