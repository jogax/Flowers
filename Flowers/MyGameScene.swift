//
//  GameScene.swift
//  JSprites
//
//  Created by Jozsef Romhanyi on 11.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import GameKit
import AVFoundation

func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

func * (point: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: point.width * scalar, height: point.height * scalar)
}

func / (point: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: point.width / scalar, height: point.height / scalar)
}



func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif


extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct PhysicsCategory {
    static let None         : UInt32 = 0
    static let All          : UInt32 = UInt32.max
    static let Sprite       : UInt32 = 0b1      // 1
    static let Container    : UInt32 = 0b10       // 2
    static let MovingSprite : UInt32 = 0b100     // 4
    static let WallAround   : UInt32 = 0b1000     // 8
}

struct MyNodeTypes {
    static let none:            UInt32 = 0
    static let MyGameScene:     UInt32 = 0b1        // 1
    static let LabelNode:       UInt32 = 0b10       // 2
    static let SpriteNode:      UInt32 = 0b100      // 4
    static let ContainerNode:   UInt32 = 0b1000     // 8
    static let ButtonNode:      UInt32 = 0b10000    // 16
}

struct Container {
    let mySKNode: MySKNode
//    var label: SKLabelNode
//    var countHits: Int
}

enum SpriteStatus: Int, CustomStringConvertible {
    case Added = 0, MovingStarted, Unification, Mirrored, FallingMovingSprite, FallingSprite, HitcounterChanged, Removed, Nothing
    
    var statusName: String {
        let statusNames = [
            "Added",
            "MovingStarted",
            "Unification",
            "Mirrored",
            "FallingMovingSprite",
            "FallingSprite",
            "HitcounterChanged",
            "Removed",
            "Nothing"
        ]
        
        return statusNames[rawValue]
    }
    
    var description: String {
        return statusName
    }
    
}

struct SavedSprite {
    var status: SpriteStatus = .Added
    var name: String = ""
//    var type: MySKNodeType
    var startPosition: CGPoint = CGPointMake(0, 0)
    var endPosition: CGPoint = CGPointMake(0, 0)
    var colorIndex: Int = 0
    var size: CGSize = CGSizeMake(0, 0)
    var hitCounter: Int = 0
    var minValue: Int = NoValue
    var maxValue: Int = NoValue
    var BGPictureAdded = false
    var column: Int = 0
    var row: Int = 0
}


enum LinePosition: Int, CustomStringConvertible {
    case UpperHorizontal = 0, RightVertical, BottomHorizontal, LeftVertical
    var linePositionName: String {
        let linePositionNames = [
            "UH",
            "RV",
            "BH",
            "LV"
        ]
        return linePositionNames[rawValue]
    }
    
    var description: String {
        return linePositionName
    }
    
}

let atlas = SKTextureAtlas(named: "sprites")

@objc protocol SettingsDelegate {
    func settingsDelegateFunc()
}

class MyGameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate {
    
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
    var containerSize:CGSize = CGSizeMake(0, 0)
    var spriteSize:CGSize = CGSizeMake(0, 0)
    var minUsedCells = 0
    var maxUsedCells = 0
    
    var showFingerNode = false
    var countMovingSprites = 0
    var countCheckCounts = 0
    var exchangeModus = false
    
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
    var levelsForPlayWithSprites = LevelsForPlayWithSprites()
    var levelIndex = Int(GV.spriteGameDataArray[GV.getAktNameIndex()].spriteLevelIndex)
    var stack:Stack<SavedSprite> = Stack()
    var gameArray = [[Bool]]() // true if Cell used
    var containers = [Container]()
    var colorTab = [ColorTabLine]()
    let containersPosCorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.85 : 0.85)
    var levelPosKorr = CGPointMake(GV.onIpad ? 0.7 : 0.7, GV.onIpad ? 0.97 : 0.97)
    let playerPosKorr = CGPointMake(GV.onIpad ? 0.3 : 0.3, GV.onIpad ? 0.97 : 0.97)
    let countUpPosKorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.95 : 0.94)
    var countColorsProContainer = [Int]()
    var labelBackground = SKSpriteNode()
    var levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var spriteCountLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var countUpLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var playerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    
    var gameScore = Int(GV.spriteGameDataArray[GV.getAktNameIndex()].spriteGameScore)
    var levelScore = 0
    var movedFromNode: MySKNode!
    var settingsButton: MySKButton?
    var undoButton: MySKButton?
    var exchangeButton: MySKButton?
    var previousLevelButton: MySKButton?
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
    
    
    
    let scoreAddCorrected = [1:1, 2:2, 3:3, 4:4, 5:5, 6:7, 7:8, 8:10, 9:11, 10:13, 11:14, 12:16,13:17,14:19, 15:20, 16:22, 17:23, 18:24, 19:25, 20:27, 21:28, 22:30, 23:31, 24:33, 25:34, 26:36, 27:37, 28:39, 29:40, 30:42, 31:43, 32:45, 33:46, 34:47, 35:48, 36:50, 37:51, 38:53, 39:54, 40:54, 41:53, 42:53, 43:52, 44:52, 45:51, 46:51, 47:51, 48:50, 49:50, 50:50, 51:51, 52:52, 53:53, 54:54, 55:55, 56:56, 57:57, 58:58, 59:59, 60:60, 61:61, 62:62, 63:63, 64:64, 65:65, 66:66, 67:67, 68:68, 69:69, 70:70, 71:71, 72:72, 73:73, 74:74, 75:75, 76:76, 77:77, 78:78, 79:79, 80:80, 81:81, 82:82, 83:83, 84:84, 85:85, 86:86, 87:87, 88:88, 89:89, 90:90, 91:91, 92:92, 93:93, 94:94, 95:95, 96:96, 97:97, 98:98, 99:99, 100:100]
    
    
    override func didMoveToView(view: SKView) {
        
        if !settingsSceneStarted {
            
            myView = view
            levelsForPlayWithSprites.setAktLevel(levelIndex)
            
            makeSpezialThings()
            prepareNextGame()
            generateSprites(true)
        } else {
            playMusic("MyMusic", volume: GV.musicVolume, loops: 0)
            
        }
    }
    
    func prepareNextGame() {
        playMusic("MyMusic", volume: GV.musicVolume, loops: 0)
        stack = Stack()
        timeCount = 0
        let seedIndex = SeedIndex(gameType: Int64(GV.spriteGameDataArray[GV.getAktNameIndex()].gameModus), gameDifficulty: 0, gameNumber: Int64(levelIndex))
        random = MyRandom(seedIndex: seedIndex)
        stopTimer()
//        if countUp != nil {
//            countUp!.invalidate()
//            countUp = nil
//        }
        
        //        buttonField = SKSpriteNode(texture: nil)
        //        //buttonField!.color = SKColor.blueColor()
        //        buttonField!.position = CGPointMake(self.position.x + self.size.width / 2, self.position.y)
        //        buttonField!.size = CGSizeMake(self.size.width, self.size.height * 0.2)
        //        self.addChild(buttonField!)
        
        spriteTabRect.origin = CGPointMake(self.frame.midX, self.frame.midY * 0.9)
        spriteTabRect.size = CGSizeMake(self.frame.size.width * 0.90, self.frame.size.width * 0.90)
        
        countContainers = levelsForPlayWithSprites.aktLevel.countContainers
        countSpritesProContainer = levelsForPlayWithSprites.aktLevel.countSpritesProContainer
        targetScoreKorr = levelsForPlayWithSprites.aktLevel.targetScoreKorr
        countColumns = levelsForPlayWithSprites.aktLevel.countColumns
        countRows = levelsForPlayWithSprites.aktLevel.countRows
        minUsedCells = levelsForPlayWithSprites.aktLevel.minProzent * countColumns * countRows / 100
        maxUsedCells = levelsForPlayWithSprites.aktLevel.maxProzent * countColumns * countRows / 100
        containerSize = CGSizeMake(CGFloat(levelsForPlayWithSprites.aktLevel.containerSize) * sizeMultiplier.width, CGFloat(levelsForPlayWithSprites.aktLevel.containerSize) * sizeMultiplier.height)
        spriteSize = CGSizeMake(CGFloat(levelsForPlayWithSprites.aktLevel.spriteSize) * sizeMultiplier.width, CGFloat(levelsForPlayWithSprites.aktLevel.spriteSize) * sizeMultiplier.height )
        
        //timeLimit = countContainers * countSpritesProContainer! * levelsForPlayWithSprites.aktLevel.timeLimitKorr
        //print("timeLimit: \(timeLimit)")
        
        gameArray.removeAll(keepCapacity: false)
        containers.removeAll(keepCapacity: false)
        //undoCount = 3
        
        for _ in 0..<countRows {
            gameArray.append(Array(count: countRows, repeatedValue:false))
        }
        
        
        labelBackground.color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        labelBackground.size = CGSizeMake(self.size.width, self.size.height / 5)
        labelBackground.position = CGPointMake(self.size.width / 2, self.position.y + self.size.height)

        prepareContainers()

        self.addChild(labelBackground)
        
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
        
        let buttonSize = myView.frame.width / 15
        let buttonYPos = myView.frame.height * 0.05
        let buttonXPosNormalized = myView.frame.width / 10
        let images = DrawImages()
        
        let settingsTexture = SKTexture(image: images.getSettings())
        settingsButton = MySKButton(texture: settingsTexture, frame: CGRectMake(buttonXPosNormalized * 3, buttonYPos, buttonSize, buttonSize))
        settingsButton!.name = "settings"
        addChild(settingsButton!)
        
        let undoTexture = SKTexture(image: images.getUndo())
        undoButton = MySKButton(texture: undoTexture, frame: CGRectMake(buttonXPosNormalized * 6, buttonYPos, buttonSize, buttonSize))
        undoButton!.name = "undo"
        addChild(undoButton!)
        
        let previousLevelButtonTexture = SKTexture(image: images.getPfeillinks())
        previousLevelButton = MySKButton(texture: previousLevelButtonTexture, frame: CGRectMake(buttonXPosNormalized * 1, buttonYPos, buttonSize, buttonSize))
        previousLevelButton!.name = "pfeilLinks"
        addChild(previousLevelButton!)
        
        let exchangeButtonTexture = SKTexture(image: images.getExchange())
        exchangeButton = MySKButton(texture: exchangeButtonTexture, frame: CGRectMake(buttonXPosNormalized * 9, buttonYPos, buttonSize, buttonSize))
        exchangeButton!.name = "exchange"
        addChild(exchangeButton!)
        
        
        let sparkles = SKTexture(imageNamed: "bumm") //reusing the bird texture for now
        let burstEmitter = SKEmitterNode()
        burstEmitter.particleTexture = sparkles
        burstEmitter.particleSize = CGSizeMake(5, 5)
        burstEmitter.position = CGPointMake(0, 0)
        burstEmitter.particleBirthRate = 20
        burstEmitter.numParticlesToEmit = 1000;
        burstEmitter.particleLifetime = 3.0
        burstEmitter.particleSpeed = 10.0
        burstEmitter.xAcceleration = 100
        burstEmitter.yAcceleration = 50
        //timer.addChild(burstEmitter)
        
        
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
        pull()
    }
    
    func exchangeButtonPressed() {
        exchangeModus = true
    }
    
    func stopTimer() {
        if countUp != nil {
            countUp?.invalidate()
            countUp = nil
        }
    }
    
    
    
    func analyzeNode (node: AnyObject) -> UInt32 {
        let testNode = node as! SKNode
        switch node  {
        case is MyGameScene: return MyNodeTypes.MyGameScene
        case is SKLabelNode:
            switch testNode.parent {
            case is MyGameScene: return MyNodeTypes.MyGameScene
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
            case .SpriteType: return MyNodeTypes.SpriteNode
            case .ButtonType:
                if mySKNode.name == buttonName {
                    mySKNode = mySKNode.parent as! MySKNode
                }
                return MyNodeTypes.ButtonNode
            }
        default: return MyNodeTypes.none
        }
    }
    
    func restartGame() {
        
    }
    
    func newGame(next: Bool) {
        stopped = true
        if next {
            
            levelIndex = levelsForPlayWithSprites.getNextLevel()
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
        
        prepareNextGame()
        generateSprites(true)
    }
    
    func generateSprites(first: Bool) {
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
            sprite.size.width = spriteSize.width
            sprite.size.height = spriteSize.height
            //            let yKorr1: CGFloat = GV.onIpad ? 0.9 : 0.8
            //            let yKorr2: CGFloat = GV.onIpad ? 1.8 : 2.0
            //let yKorr1: CGFloat = GV.onIpad ? 0.8 : 1.0
            //let yKorr2: CGFloat = GV.onIpad ? 0.8 : 1.0
            
            let index = random?.getRandomInt(0, max: positionsTab.count - 1)
            let (aktColumn, aktRow) = positionsTab[index!]
            tableCellSize = spriteTabRect.width / CGFloat(countColumns)
            
            let xPosition = spriteTabRect.origin.x - spriteTabRect.size.width / 2 + CGFloat(aktColumn) * tableCellSize + tableCellSize / 2
            let yPosition = spriteTabRect.origin.y - spriteTabRect.size.height / 2 + tableCellSize / 2 + CGFloat(aktRow) * tableCellSize
            
            sprite.position = CGPoint(x: xPosition, y: yPosition)
            sprite.startPosition = sprite.position
            gameArray[aktColumn][aktRow] = true
            positionsTab.removeAtIndex(index!)
            
            sprite.column = aktColumn
            sprite.row = aktRow
            sprite.name = spriteName
            sprite.colorIndex = colorIndex

            addPhysicsBody(sprite)
            push(sprite, status: .Added)
            addChild(sprite)
        }
        if first {
            countUp = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("doCountUp"), userInfo: nil, repeats: true)
        }
        
        stopped = false
    }
    
    func waitForTap() -> Bool {
        return true
    }
    
    func addPhysicsBody(sprite: MySKNode) {
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        sprite.physicsBody?.dynamic = true
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.Sprite
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.MovingSprite
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.None
        sprite.physicsBody?.usesPreciseCollisionDetection = true
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if inFirstGenerateSprites {
            return
        }
        //let countTouches = touches.count
        let firstTouch = touches.first
        let touchLocation = firstTouch!.locationInNode(self)
        
        let testNode = self.nodeAtPoint(touchLocation)
        
        let aktNodeType = analyzeNode(testNode)
        switch aktNodeType {
        case MyNodeTypes.LabelNode: movedFromNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
        case MyNodeTypes.SpriteNode:
            movedFromNode = self.nodeAtPoint(touchLocation) as! MySKNode
            
            if showFingerNode {
                let fingerNode = SKSpriteNode(imageNamed: "finger.png")
                fingerNode.name = "finger"
                fingerNode.position = touchLocation
                fingerNode.size = CGSizeMake(25,25)
                addChild(fingerNode)
            }
            
        case MyNodeTypes.ContainerNode:
            movedFromNode = nil
            
        case MyNodeTypes.ButtonNode:
            movedFromNode = self.nodeAtPoint(touchLocation) as! MySKNode
            //let textureName = "\(testNode.name!)Pressed"
            //let textureSelected = SKTexture(imageNamed: textureName)
            //(testNode as! MySKNode).texture = textureSelected
            //(testNode as! MySKNode).texture = atlas.textureNamed("\(testNode.name!)Pressed")
        default: movedFromNode = nil
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
            switch aktNodeType {
            case MyNodeTypes.LabelNode: aktNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
            case MyNodeTypes.SpriteNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
            case MyNodeTypes.ButtonNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
            default: aktNode = nil
            }
            if movedFromNode != aktNode && !exchangeModus {
                if movedFromNode.type == .ButtonType {
                    //movedFromNode.texture = atlas.textureNamed("\(movedFromNode.name!)")
                } else {
                    let line = JGXLine(fromPoint: movedFromNode.position, toPoint: touchLocation, inFrame: self.frame, lineSize: movedFromNode.size.width)
                    let pointOnTheWall = line.line.toPoint
                    makeHelpLine(movedFromNode.position, toPoint: pointOnTheWall, lineWidth: movedFromNode.size.width, numberOfLine: 1)
                    
                    
                    if GV.showHelpLines > 1 {
                        let mirroredLine1 = line.createMirroredLine()
                        makeHelpLine(mirroredLine1.line.fromPoint, toPoint: mirroredLine1.line.toPoint, lineWidth: movedFromNode.size.width, numberOfLine: 2)
                        
                        if GV.showHelpLines > 2 {
                            let mirroredLine2 = mirroredLine1.createMirroredLine()
                            makeHelpLine(mirroredLine2.line.fromPoint, toPoint: mirroredLine2.line.toPoint, lineWidth: movedFromNode.size.width, numberOfLine: 3)
                            
                            if GV.showHelpLines > 3 {
                                let mirroredLine3 = mirroredLine2.createMirroredLine()
                                makeHelpLine(mirroredLine3.line.fromPoint, toPoint: mirroredLine3.line.toPoint, lineWidth: movedFromNode.size.width, numberOfLine: 4)
                            }
                        }
                    }
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
                case "exchange": exchangeButtonPressed()
                default: undoButtonPressed()
                }
                return
            }
            
            if exchangeModus {
                if startNode != nil && startNode != aktNode && aktNode is MySKNode {
                    let actionMove1 = SKAction.moveTo(startNode.position, duration: 1.0)
                    aktNode!.runAction(SKAction.sequence([actionMove1]))
                    let actionMove2 = SKAction.moveTo(aktNode!.position, duration: 1.0)
                    startNode.runAction(SKAction.sequence([actionMove2]))
                }
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
                
                let actionMove1 = SKAction.moveTo(pointOnTheWall1, duration: mirroredLine1.duration)
                
                let actionMove2 = SKAction.moveTo(pointOnTheWall2, duration: mirroredLine2.duration)
                
                let actionMove3 = SKAction.moveTo(pointOnTheWall3, duration: mirroredLine3.duration)
                
                
                let waitSparkAction = SKAction.runBlock({
                    sprite.hidden = true
                    sleep(0)
                    sprite.removeFromParent()
                })
                
                let actionMoveStopped =  SKAction.runBlock({
                    self.push(sprite, status: .Removed)
                    sprite.hidden = true
                    self.gameArray[sprite.column][sprite.row] = false
                    //sprite.size = CGSizeMake(sprite.size.width / 3, sprite.size.height / 3)
                    sprite.colorBlendFactor = 4
                    self.playSound("Drop", volume: GV.soundVolume)
                    let sparkEmitter = SKEmitterNode(fileNamed: "MyParticle.sks")
                    sparkEmitter?.position = sprite.position
                    sparkEmitter?.zPosition = 1
                    sparkEmitter?.particleLifetime = 1
                    let emitterDuration = CGFloat(sparkEmitter!.numParticlesToEmit) * sparkEmitter!.particleLifetime
                    
                    let wait = SKAction.waitForDuration(NSTimeInterval(emitterDuration))
                    
                    let remove = SKAction.runBlock({sparkEmitter!.removeFromParent()/*; print("Emitter removed")*/})
                    sparkEmitter!.runAction(SKAction.sequence([wait, remove]))
                    self.addChild(sparkEmitter!)
                    self.userInteractionEnabled = true
                    
                    
                })
                
                
                
                
                //let actionMoveDone = SKAction.removeFromParent()
                collisionActive = true
                lastMirrored = ""
                
                self.userInteractionEnabled = false  // userInteraction forbidden!
                countMovingSprites = 1
                self.waitForSKActionEnded = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("checkCountMovingSprites"), userInfo: nil, repeats: false) // start timer for check
                
                movedFromNode.runAction(SKAction.sequence([actionMove, countAndPushAction, actionMove1, countAndPushAction, actionMove2, countAndPushAction, actionMove3, actionMoveStopped,
                    waitSparkAction]))
                //actionMoveDone]))
            }
            
        }
    }
    
    
    func makeHelpLine(fromPoint: CGPoint, toPoint: CGPoint, lineWidth: CGFloat, numberOfLine: Int) {
        if GV.showHelpLines >= numberOfLine {
            //print("makeHelpLine: fromPoint: \(fromPoint), toPoint: \(toPoint)")
            let offset = toPoint - fromPoint
            let direction = offset.normalized()
            let shootAmount = direction * 1200
            let realDest = shootAmount + fromPoint
            
            let pathToDraw:CGMutablePathRef = CGPathCreateMutable()
            let myLine:SKShapeNode = SKShapeNode(path:pathToDraw)
            myLine.lineWidth = lineWidth
            
            myLine.name = "myLine"
            CGPathMoveToPoint(pathToDraw, nil, fromPoint.x, fromPoint.y)
            CGPathAddLineToPoint(pathToDraw, nil, realDest.x, realDest.y)
            
            myLine.path = pathToDraw
            //let name = fromPoint.name!
            //let colorIndex = name.toInt()! - 100
            //let colorIndex = fromPoint.colorIndex
            
            myLine.strokeColor = SKColor(red: 1.0, green: 0, blue: 0, alpha: 0.15) // GV.colorSets[GV.colorSetIndex][colorIndex + 1]
            
            
            self.addChild(myLine)
            let texture = numberOfLine < maxHelpLinesCount ? movedFromNode.texture! : SKTexture(imageNamed: "bumm")
            let nodeOnTheWall = MySKNode(texture: texture, type: .SpriteType, value: NoValue)
            nodeOnTheWall.name = "nodeOnTheWall"
            nodeOnTheWall.position = toPoint
            nodeOnTheWall.size = movedFromNode.size
            self.addChild(nodeOnTheWall)
            
        }
    }
    
//    func showNextSprite(touchLocation:  CGPoint) {
//        let aktNode = self.nodeAtPoint(touchLocation)
//        if aktNode.name == lastShownNode!.name {
//            undoCount++
//            for index in 0..<self.children.count {
//                if self.children[index].hidden {
//                    //SKAction.playSoundFileNamed("Do_1", waitForCompletion: false)
//                    self.playSound("Do_1", volume: GV.soundVolume)
//                    lastShownNode = self.children[index] as? MySKNode
//                    self.children[index].hidden = false
//                    let undoButton = self.childNodeWithName("undo")! as! MySKNode
//                    undoButton.hitCounter++
//                    //(self.childNodeWithName("undo")! as! MySKNode).hitCounter++
//                    undoButton.hitLabel.text = "\(undoButton.hitCounter)"
//                    //print("undoButton.hitLabel.text: \(undoButton.hitLabel.text)")
//                    return
//                }
//            }
//            inFirstGenerateSprites = false
//        } else {
//            inFirstGenerateSprites = false
//            for index in 0..<self.children.count {
//                if self.children[index].hidden {
//                    self.children[index].hidden = false
//                }
//            }
//        }
//        
//        var three_two_one_go = [SKTexture]()
//        three_two_one_go.append(atlas.textureNamed("3"))
//        three_two_one_go.append(atlas.textureNamed("2"))
//        three_two_one_go.append(atlas.textureNamed("1"))
//        three_two_one_go.append(atlas.textureNamed("goText"))
//        
//        let firstFrame = three_two_one_go[0]
//        let go = SKSpriteNode(texture: firstFrame)
//        self.addChild(go)
//        
//        
//        go.position = CGPointMake(self.frame.midX, self.frame.midY)
//        if GV.onIpad {
//            go.size = CGSizeMake(600, 600)
//        } else {
//            go.size = CGSizeMake(400, 400)
//        }
//        go.zPosition = 100
//        
//        
//        let goAction = SKAction.repeatAction(
//            SKAction.sequence([
//                //SKAction.playSoundFileNamed("Do_1", waitForCompletion:false),
//                SKAction.runBlock({self.playSound("Go321", volume: GV.soundVolume)}),
//                SKAction.animateWithTextures(three_two_one_go, timePerFrame: 1.2, resize: false, restore: false)
//                ]),
//            count: 1)
//        //let waitAction = SKAction.waitForDuration(8)
//        let removeAction = SKAction.removeFromParent()
//        let startCounterAction = SKAction.runBlock({self.countUp = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("doCountUp"), userInfo: nil, repeats: true)})
//        
//        
//        go.runAction(SKAction.sequence([goAction, removeAction, startCounterAction, SKAction.runBlock({self.playMusic("MyMusic", volume: GV.musicVolume, loops: -1)})]))
//        
//        
//        
//    }
//    
    override func update(currentTime: NSTimeInterval) {
        backgroudScrollUpdate()
    }
    
    func backgroudScrollUpdate(){
        
        bgImage!.position = CGPointMake(bgImage!.position.x - bgAdder, bgImage!.position.y)
        
        if bgImage!.position.x <= -bgImage!.size.width + self.size.width  || bgImage!.position.x >= 0 {
            bgAdder = -bgAdder
        }
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
    
    func spriteDidCollideWithContainer(node1:MySKNode, node2:MySKNode) { // must be overriden
    }
    
    func spriteDidCollideWithMovingSprite(node1:MySKNode, node2:MySKNode) { // must be overriden
    }
    
    func checkCountMovingSprites() {
        if  countMovingSprites > 0 && countCheckCounts++ < 80 {
            self.waitForSKActionEnded = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("checkCountMovingSprites"), userInfo: nil, repeats: false)
        } else {
            countCheckCounts = 0
            self.userInteractionEnabled = true
        }
    }
    
    func wallAroundDidCollideWithMovingSprite(node1: MySKNode, node2: SKNode) {
        let movingSprite = node1
        let lineAround = node2
        
        if spriteGameLastPosition != movingSprite.position && lineAround.name != lastMirrored {
            lastMirrored = lineAround.name!
            spriteGameLastPosition = movingSprite.position
            
            let originalPosition = movingSprite.startPosition
            _ = movingSprite.position - originalPosition
            
            let dX = movingSprite.startPosition.x - movingSprite.position.x
            let dY = movingSprite.startPosition.y - movingSprite.position.y
            
            
            
            var zielPosition = CGPointZero
            switch lineAround.name! {
            case "BH": zielPosition = CGPointMake(movingSprite.position.x - dX, originalPosition.y)
            case "LV": zielPosition = CGPointMake(originalPosition.x, movingSprite.position.y - dY)
            case "UH": zielPosition = CGPointMake(movingSprite.position.x - dX, originalPosition.y)
            case "RV": zielPosition = CGPointMake(originalPosition.x, movingSprite.position.y - dY)
            default: break
            }
            //            print("case: \(lineAround.name!), aktX: \(movingSprite.position.x), aktY: \(movingSprite.position.y), origX:\(movingSprite.startPosition.x), origY:\(movingSprite.startPosition.y), zielX: \(zielPosition.x), zielY: \(zielPosition.y)")
            
            let offsetNew = zielPosition - movingSprite.position
            let direction = offsetNew.normalized()
            
            let shootAmount = direction * 1200
            let realDest = shootAmount + movingSprite.position
            
            //print("offsetNew: \(offsetNew), direction: \(direction), shootAmount: \(shootAmount), realDest: \(realDest)")
            
            movingSprite.startPosition = movingSprite.position
            movingSprite.hitCounter = Int(CGFloat(movingSprite.hitCounter) * 1.5)
            push(movingSprite, status: .Mirrored)
            
            let actionMove = SKAction.moveTo(realDest, duration: 1.0)
            collisionActive = true
            movingSprite.runAction(SKAction.sequence([actionMove]))//, actionMoveDone]))
            playSound("Mirror", volume: GV.soundVolume)
            checkGameFinished()
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
    
    func checkGameArray() -> Int {
        var usedCellCount = 0
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if gameArray[column][row] {
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
    
    func doCountUp() {
        
        timeCount++
         let countUpText = GV.language.getText(.TCTimeLeft)
        let minutes = Int(timeCount / 60)
        var seconds = "\(Int(timeCount % 60))"
        seconds = Int(seconds) < 10 ? "0\(seconds)" : "\(seconds)"
        countUpLabel.text = "\(countUpText) \(minutes):\(seconds)"
    }
    
    func startTimer() {
        if countUp == nil {
            countUp = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("doCountUp"), userInfo: nil, repeats: true)
        }
    }
    
    func showTimeLeft() {
    }
    
    func push(sprite: MySKNode, status: SpriteStatus) {
        var savedSprite = SavedSprite()
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
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfullyflag: Bool) {
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer) {
    }
    
    
    
    // FUNCTIONS FOR OVERRIDE
    
    func pull() {
    }
    
    func updateSpriteCount(adder: Int) {
        
    }
    
    func getTexture(index: Int)->SKTexture {
        return atlas.textureNamed ("sprite\(index)")
    }
    
    func makeSpezialThings() {
        
    }
    
    func setBGImageNode()->SKSpriteNode {
        return SKSpriteNode(imageNamed: "bgImage.png")
    }
    
    func generateValue(colorIndex:Int)->Int {
        return NoValue
    }

    func spezialPrepareFunc() {
        
    }
    
    func getValueForContainer()->Int {
        return NoValue
    }

    func showScore() {
    }

    func changeLanguage()->Bool {
        return true
    }

    func prepareContainers() {
    }
}


