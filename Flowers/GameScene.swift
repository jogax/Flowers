//
//  GameScene.swift
//  JSprites
//
//  Created by Jozsef Romhanyi on 11.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import AVFoundation

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
    static let GameScene:       UInt32 = 0b1        // 1
    static let LabelNode:       UInt32 = 0b10       // 2
    static let SpriteNode:      UInt32 = 0b100      // 4
    static let ContainerNode:   UInt32 = 0b1000     // 8
    static let ButtonNode:      UInt32 = 0b10000    // 16
}

struct Container {
    let mySKNode: MySKNode
    var label: SKLabelNode
    var countHits: Int
}
enum SpriteStatus: Int, CustomStringConvertible {
    case Added = 0, MovingStarted, SizeChanged, Mirrored, FallingMovingSprite, FallingSprite, HitcounterChanged, Removed

    var statusName: String {
        let statusNames = [
            "Added",
            "MovingStarted",
            "SizeChanged",
            "Mirrored",
            "FallingMovingSprite",
            "FallingSprite",
            "HitcounterChanged",
            "Removed"
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
    var startPosition: CGPoint = CGPointMake(0, 0)
    var endPosition: CGPoint = CGPointMake(0, 0)
    var colorIndex: Int = 0
    var size: CGSize = CGSizeMake(0, 0)
    var hitCounter: Int = 0
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

class GameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate {

    struct ColorTabLine {
        var colorIndex: Int
        var spriteName: String
        init(colorIndex: Int, spriteName: String){
            self.colorIndex = colorIndex
            self.spriteName = spriteName
        }
    }

    // Values from json File
    var params = ""
    var countSpritesProContainer: Int?
    var countColumns = 0
    var countRows = 0
    var countContainers = 0
    var targetScoreKorr: Int = 0
    var tableCellSize: CGFloat = 0
    var containerSize:CGFloat = 0
    var spriteSize:CGFloat = 0
    var minUsedCells = 0
    var maxUsedCells = 0
    
    var showFingerNode = false
    var countMovingSprites = 0
    var countCheckCounts = 0
    
    let timeLimitKorr = 5 // sec for pro Sprite
    var timeLimit = 0 // seconds

    var timer: NSTimer?
    var countDown: NSTimer?
    var waitForSKActionEnded: NSTimer?
    var lastMirrored = ""
    var audioPlayer: AVAudioPlayer?
    var soundPlayer: AVAudioPlayer?
    var parentViewController: UIViewController?
    var myView = SKView()
    var levelsForPlayWithSprites = LevelsForPlayWithSprites()
    var levelIndex = Int(GV.spriteGameData.spriteLevelIndex)
    var stack:Stack<SavedSprite> = Stack()
    var gameArray = [[Bool]]() // true if Cell used
    var containers = [Container]()
    var colorTab = [ColorTabLine]()
    let containersPosCorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.85 : 0.85)
    let levelPosKorr = CGPointMake(GV.onIpad ? 0.5 : 0.5, GV.onIpad ? 0.97 : 0.97)
    let gameScorePosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.95 : 0.94)
    let levelScorePosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.93 : 0.92)
    let spriteCountPosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.91 : 0.90)
    let countdownPosKorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.95 : 0.94)
    let targetPosKorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.93 : 0.92)
    let atlas = SKTextureAtlas(named: "sprites")
    var countColorsProContainer = [Int]()
    var labelBackground = SKSpriteNode()
    var levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var spriteCountLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var gameScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var levelScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var countdownLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var targetScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var gameScore = Int(GV.spriteGameData.spriteGameScore)
    var levelScore = 0
    var movedFromNode: MySKNode!
    var restartButton: MySKNode?
    var undoButton: MySKNode?
    var targetScore = 0
    var spriteCount = 0
    var restartCount = 0
    var stopped = true
    var collisionActive = false
    var bgImage: SKSpriteNode?
    var bgAdder: CGFloat = 0
    let showHelpLines = 2
    var undoCount = 0
    var inFirstGenerateSprites = true
    var lastShownNode: MySKNode?

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
    

/*
    var packageOfLevels: Dictionary<String, AnyObject>?
    var json: JSON?
    //var packageName: AnyObject

    override init(size: CGSize) {
        
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

*/
    override func didMoveToView(view: SKView) {



        myView = view
        levelsForPlayWithSprites.setAktLevel(levelIndex)

        restartCount = 3
        prepareNextGame()
        generateSprites()

       
    }
    
    func prepareNextGame() {
        stack = Stack()
        if countDown != nil {
            countDown!.invalidate()
            countDown = nil
        }

//        buttonField = SKSpriteNode(texture: nil)
//        //buttonField!.color = SKColor.blueColor()
//        buttonField!.position = CGPointMake(self.position.x + self.size.width / 2, self.position.y)
//        buttonField!.size = CGSizeMake(self.size.width, self.size.height * 0.2)
//        self.addChild(buttonField!)

        countContainers = levelsForPlayWithSprites.aktLevel.countContainers
        countSpritesProContainer = levelsForPlayWithSprites.aktLevel.countSpritesProContainer
        targetScoreKorr = levelsForPlayWithSprites.aktLevel.targetScoreKorr
        countColumns = levelsForPlayWithSprites.aktLevel.countColumns
        countRows = levelsForPlayWithSprites.aktLevel.countRows
        minUsedCells = levelsForPlayWithSprites.aktLevel.minProzent * countColumns * countRows / 100
        maxUsedCells = levelsForPlayWithSprites.aktLevel.maxProzent * countColumns * countRows / 100
        containerSize = CGFloat(levelsForPlayWithSprites.aktLevel.containerSize)
        spriteSize = CGFloat(levelsForPlayWithSprites.aktLevel.spriteSize)

        timeLimit = countContainers * countSpritesProContainer! * levelsForPlayWithSprites.aktLevel.timeLimitKorr
        //print("timeLimit: \(timeLimit)")
        
        gameArray.removeAll(keepCapacity: false)
        containers.removeAll(keepCapacity: false)
        undoCount = 3

        for _ in 0..<countRows {
            gameArray.append(Array(count: countRows, repeatedValue:false))
        }
        
        colorTab.removeAll(keepCapacity: false)
        var spriteName = 10000
        for containerIndex in 0..<countContainers {
            for _ in 0..<countSpritesProContainer! {
                let colorTabLine = ColorTabLine(colorIndex: containerIndex, spriteName: "\(spriteName++)")
                colorTab.append(colorTabLine)
            }
        }
        
        let xDelta = size.width / CGFloat(countContainers)
        tableCellSize = size.width / CGFloat(countColumns)
        for index in 0..<countContainers {
            _ = GV.colorSets[GV.colorSetIndex][index + 1].CGColor
            //let containerTexture = SKTexture(image: GV.drawCircle(CGSizeMake(containerSize, containerSize), imageColor: aktColor))
            let centerX = (size.width / CGFloat(countContainers)) * CGFloat(index) + xDelta / 2
            let centerY = size.height * containersPosCorr.y
            let cont: Container
            //if index == 0 {
            //cont = Container(mySKNode: MySKNode(texture: SKTexture(imageNamed:"sprite\(index)"), type: .ContainerType), label: SKLabelNode(), countHits: 0)
            cont = Container(mySKNode: MySKNode(texture: atlas.textureNamed("sprite\(index)"), type: .ContainerType), label: SKLabelNode(), countHits: 0)
/*
        } else {
                cont = Container(mySKNode: MySKNode(texture: containerTexture, type: .ContainerType), label: SKLabelNode(), countHits: 0)
            }
*/
            containers.append(cont)
            containers[index].mySKNode.name = "\(index)"
            containers[index].mySKNode.position = CGPoint(x: centerX, y: centerY)
            containers[index].mySKNode.size.width = containerSize
            containers[index].mySKNode.size.height = containerSize
            
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
        
        labelBackground.color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        labelBackground.size = CGSizeMake(self.size.width, self.size.height / 5)
        labelBackground.position = CGPointMake(self.size.width / 2, self.position.y + self.size.height)
        
        self.addChild(labelBackground)
        levelLabel.text = GV.language.getText(TextConstants.TCLevel) + ": \(levelIndex + 1)"
        levelLabel.position = CGPointMake(self.position.x + self.size.width * levelPosKorr.x, self.position.y + self.size.height * levelPosKorr.y)
        levelLabel.fontColor = SKColor.blackColor()
        levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        levelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        levelLabel.fontSize = 15;
        levelLabel.color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        //levelLabel.fontName = "ArielBold"
        self.addChild(levelLabel)
        
        let gameScoreText: String = GV.language.getText(.TCGameScore)
        gameScoreLabel.text = "\(gameScoreText) \(gameScore)"
        gameScoreLabel.position = CGPointMake(self.position.x + self.size.width * gameScorePosKorr.x, self.position.y + self.size.height * gameScorePosKorr.y)
        gameScoreLabel.fontColor = SKColor.blackColor()
        gameScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        gameScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        gameScoreLabel.fontSize = 15;
        //gameScoreLabel.fontName = "ArielBold"
        self.addChild(gameScoreLabel)
        
        levelScoreLabel.position = CGPointMake(self.position.x + self.size.width * levelScorePosKorr.x, self.position.y + self.size.height * levelScorePosKorr.y)
        levelScoreLabel.fontColor = SKColor.blackColor()
        levelScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        levelScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        levelScoreLabel.fontSize = 15;
        //levelScoreLabel.fontName = "ArielBold"
        self.addChild(levelScoreLabel)
        showScore()
        
        countdownLabel.position = CGPointMake(self.position.x + self.size.width * countdownPosKorr.x, self.position.y + self.size.height * countdownPosKorr.y)
        countdownLabel.fontColor = SKColor.blackColor()
        countdownLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        countdownLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        countdownLabel.fontSize = 15;
        self.addChild(countdownLabel)
        showTimeLeft()

        spriteCountLabel.position = CGPointMake(self.position.x + self.size.width * spriteCountPosKorr.x, self.position.y + self.size.height * spriteCountPosKorr.y)
        spriteCountLabel.fontColor = SKColor.blackColor()
        spriteCountLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        spriteCountLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        spriteCountLabel.fontSize = 15;
        spriteCount = Int(CGFloat(countContainers * countSpritesProContainer!))
        let spriteCountText: String = GV.language.getText(.TCSpriteCount)
        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
        self.addChild(spriteCountLabel)

        
        targetScoreLabel.position = CGPointMake(self.position.x + self.size.width * targetPosKorr.x, self.position.y + self.size.height * targetPosKorr.y)
        targetScoreLabel.fontColor = SKColor.blackColor()
        targetScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        targetScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        targetScoreLabel.fontSize = 15;
        targetScore = countContainers * countSpritesProContainer! * targetScoreKorr
        let targetScoreText: String = GV.language.getText(.TCTargetScore)
        targetScoreLabel.text = "\(targetScoreText) \(targetScore)"
        self.addChild(targetScoreLabel)
        
        bgImage = SKSpriteNode(imageNamed: "bgImage.png")
        //print("ImageSize: \(bgImage?.size)")
        bgAdder = 0.1
        
        bgImage!.anchorPoint = CGPointZero
        bgImage!.position = CGPointMake(0, 0)
        bgImage!.zPosition = -15
        self.addChild(bgImage!)
        

        //let restartTextureNormal = SKTexture(imageNamed: "restart")
        let restartTextureNormal = atlas.textureNamed("restart")
        
        restartButton = MySKNode(texture: restartTextureNormal, type: MySKNodeType.ButtonType)
        //restartButton = SKButton(normalTexture: restartTextureNormal, selectedTexture: restartTextureSelected, disabledTexture: restartTextureNormal)
        restartButton!.position = CGPointMake(myView.frame.width / 2, myView.frame.height * 0.05)
        restartButton!.size = CGSizeMake(myView.frame.width / 10, myView.frame.width / 10)
        //restartButton!.setButtonAction(self, triggerEvent: .TouchUpInside, action:"restartButtonPressed")
        restartButton!.name = "restart"
        restartButton!.hitLabel.text = "\(restartCount)"
        addChild(restartButton!)
        
        //let undoTextureNormal = SKTexture(imageNamed: "undo")
        let undoTextureNormal = atlas.textureNamed("undo")
        
        //undoButton = SKButton(normalTexture: undoTextureNormal, selectedTexture: undoTextureSelected, disabledTexture: undoTextureNormal)
        undoButton = MySKNode(texture: undoTextureNormal, type: MySKNodeType.ButtonType)
        undoButton!.position = CGPointMake(myView.frame.width / 3, myView.frame.height * 0.05)
        undoButton!.size = CGSizeMake(myView.frame.width / 10, myView.frame.width / 10)
        //undoButton!.setButtonAction(self, triggerEvent: .TouchUpInside, action:"undoButtonPressed")
        undoButton!.name = "undo"
        undoButton!.hitLabel.text = "\(undoCount)"
        addChild(undoButton!)
        
        backgroundColor = UIColor.whiteColor() //SKColor.whiteColor()
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
//        self.countDown = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("doCountDown"), userInfo: nil, repeats: true)
//        GV.currentTime = NSDate()
//        GV.elapsedTime = GV.currentTime.timeIntervalSinceDate(GV.startTime) //* 1000
        //print("prepareNextGame Laufzeit: \(GV.elapsedTime)")
        makeLineAroundGameboard(.UpperHorizontal)
        makeLineAroundGameboard(.RightVertical)
        makeLineAroundGameboard(.BottomHorizontal)
        makeLineAroundGameboard(.LeftVertical)
        self.inFirstGenerateSprites = true
    }
    

    func restartButtonPressed() {
        if restartCount > 0 {
            let restartButton = self.childNodeWithName("restart") as! MySKNode
            restartCount--
            playMusic("NoSound", volume: 0.01, loops: 0)
            restartButton.hitLabel.text = "\(restartCount)"
            newGame(false)
        }
    }
    
    func undoButtonPressed() {
        let undoButton = self.childNodeWithName("undo")! as! MySKNode
        if undoButton.hitCounter > 0 {
            pull()
            undoButton.hitCounter--
            undoButton.hitLabel.text = "\(undoButton.hitCounter)"
        }
    }
    

    
    func analyzeNode (node: AnyObject) -> UInt32 {
        let testNode = node as! SKNode
        switch node  {
        case is GameScene: return MyNodeTypes.GameScene
        case is SKLabelNode: return MyNodeTypes.LabelNode
        case is MySKNode:
            switch (testNode as! MySKNode).type {
            case .ContainerType: return MyNodeTypes.ContainerNode
            case .SpriteType: return MyNodeTypes.SpriteNode
            case .ButtonType: return MyNodeTypes.ButtonNode
            default: return MyNodeTypes.none
            }
        default: return MyNodeTypes.none
        }
    }
    
    func newGame(next: Bool) {
        stopped = true
        if next {

            levelIndex = levelsForPlayWithSprites.getNextLevel()
            gameScore += levelScore
            restartCount = 3
            let restartButton = self.childNodeWithName("restart") as! MySKNode
            restartButton.hitLabel.text = "\(restartCount)"
            var spriteData = SpriteGameData()
            spriteData.spriteLevelIndex = Int64(levelIndex)
            spriteData.spriteGameScore = Int64(gameScore)
            GV.dataStore.createSpriteGameRecord(spriteData)
            let gameScoreText: String = GV.language.getText(.TCGameScore)
            gameScoreLabel.text = "\(gameScoreText) \(gameScore)"
        }
        //self.children.removeAll(keepCapacity: false)
        for _ in 0..<self.children.count {
            let testNode = children[self.children.count - 1]
            testNode.removeFromParent()
        }
        
        if countDown != nil {
            countDown!.invalidate()
            countDown = nil
        }
        prepareNextGame()
        generateSprites()
    }

    func generateSprites() {
        var first = inFirstGenerateSprites
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
            let colorTabIndex = GV.random(0, max: colorTab.count - 1)
            let colorIndex = colorTab[colorTabIndex].colorIndex
            let spriteName = colorTab[colorTabIndex].spriteName
            colorTab.removeAtIndex(colorTabIndex)
            
            //let aktColor = GV.colorSets[GV.colorSetIndex][colorIndex + 1].CGColor
            var spriteTexture = SKTexture()
//            if colorIndex == 0 {
                spriteTexture = atlas.textureNamed("sprite\(colorIndex)")
                //spriteTexture = SKTexture(imageNamed: "sprite\(colorIndex)")
//            } else {
//                containerTexture = SKTexture(image: GV.drawCircle(CGSizeMake(spriteSize,spriteSize), imageColor: aktColor))
//            }
            let sprite = MySKNode(texture: spriteTexture, type: .SpriteType)
            sprite.size.width = spriteSize
            sprite.size.height = spriteSize
//            let yKorr1: CGFloat = GV.onIpad ? 0.9 : 0.8
//            let yKorr2: CGFloat = GV.onIpad ? 1.8 : 2.0
            let yKorr1: CGFloat = GV.onIpad ? 0.8 : 1.0
            let yKorr2: CGFloat = GV.onIpad ? 0.8 : 1.0

            let index = GV.random(0, max: positionsTab.count - 1)
            let (aktColumn, aktRow) = positionsTab[index]
            let xPosition = CGFloat(aktColumn) * tableCellSize + tableCellSize / 2
            let yPosition = CGFloat(aktRow) * tableCellSize * yKorr1 + tableCellSize * yKorr2
            sprite.position = CGPoint(x: xPosition, y: yPosition)
            sprite.startPosition = sprite.position
            gameArray[aktColumn][aktRow] = true
            positionsTab.removeAtIndex(index)
            
            sprite.column = aktColumn
            sprite.row = aktRow
            sprite.name = spriteName
            sprite.colorIndex = colorIndex
            if first {
                lastShownNode = sprite
                first = false
            } else if inFirstGenerateSprites {
                sprite.hidden = true
            }
            addPhysicsBody(sprite)
            push(sprite, status: .Added)
            addChild(sprite)
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
                (testNode as! MySKNode).texture = atlas.textureNamed("\(testNode.name!)Pressed")
            default: movedFromNode = nil
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if inFirstGenerateSprites {
            return
        }
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
                case MyNodeTypes.ButtonNode: self.nodeAtPoint(touchLocation) as! MySKNode
                default: aktNode = nil
            }
            if movedFromNode != aktNode {
                if movedFromNode.type == .ButtonType {
                    //movedFromNode.texture = SKTexture(imageNamed: "\(movedFromNode.name!)")
                    movedFromNode.texture = atlas.textureNamed("\(movedFromNode.name!)")
                } else {
                    let line = JGXLine(fromPoint: movedFromNode.position, toPoint: touchLocation, inFrame: self.frame, lineSize: movedFromNode.size.width)
                    let pointOnTheWall = line.line.toPoint
                    makeHelpLine(movedFromNode.position, toPoint: pointOnTheWall, lineWidth: movedFromNode.size.width, numberOfLine: 1)

//                    let intersectNode = MySKNode(texture: movedFromNode.texture!, type: .SpriteType)
//                    intersectNode.name = "nodeOnTheWall"
//                    intersectNode.position = line.line.toPoint
//                    intersectNode.size = movedFromNode.size
//                    self.addChild(intersectNode)
//                    
//                    
//                    let nodeOnTheWall = MySKNode(texture: movedFromNode.texture!, type: .SpriteType)
//                    nodeOnTheWall.name = "nodeOnTheWall"
//                    nodeOnTheWall.position = pointOnTheWall
//                    nodeOnTheWall.size = movedFromNode.size
//                    self.addChild(nodeOnTheWall)
                    
                    

                    
                    
                    let mirroredLine = line.createMirroredLine()
                    makeHelpLine(mirroredLine.line.fromPoint, toPoint: mirroredLine.line.toPoint, lineWidth: movedFromNode.size.width, numberOfLine: 2)

//                    let pointOnTheWall1 = mirroredLine.line.toPoint
                    
//                    let pointOnTheWall = findPointOnTheWall(movedFromNode.position, pointTo: touchLocation, nodeSize: movedFromNode.size)
//                    let nodeOnTheWall1 = MySKNode(texture: movedFromNode.texture!, type: .SpriteType)
//                    nodeOnTheWall1.name = "nodeOnTheWall"
//                    nodeOnTheWall1.position = pointOnTheWall1
//                    nodeOnTheWall1.size = movedFromNode.size
//                    self.addChild(nodeOnTheWall1)

                    let mirroredLine2 = mirroredLine.createMirroredLine()
                    makeHelpLine(mirroredLine2.line.fromPoint, toPoint: mirroredLine2.line.toPoint, lineWidth: movedFromNode.size.width, numberOfLine: 3)
                    
//                    let pointOnTheWall2 = mirroredLine.line.toPoint
//                    let pointOnTheWall = findPointOnTheWall(movedFromNode.position, pointTo: touchLocation, nodeSize: movedFromNode.size)
//                    let nodeOnTheWall2 = MySKNode(texture: movedFromNode.texture!, type: .SpriteType)
//                    nodeOnTheWall2.name = "nodeOnTheWall"
//                    nodeOnTheWall2.position = pointOnTheWall2
//                    nodeOnTheWall2.size = movedFromNode.size
//                    self.addChild(nodeOnTheWall2)
 
                    let mirroredLine3 = mirroredLine2.createMirroredLine()
                    makeHelpLine(mirroredLine3.line.fromPoint, toPoint: mirroredLine3.line.toPoint, lineWidth: movedFromNode.size.width, numberOfLine: 4)

//                    var bummTexture = SKTexture()
//                    bummTexture = SKTexture(imageNamed: "bumm")
//                    let pointOnTheWall3 = mirroredLine3.line.toPoint
//                    let nodeOnTheWall3 = MySKNode(texture: bummTexture, type: .SpriteType)
//                    nodeOnTheWall3.name = "nodeOnTheWall"
//                    nodeOnTheWall3.position = pointOnTheWall3
//                    nodeOnTheWall3.size = movedFromNode.size
//                    self.addChild(nodeOnTheWall3)
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
        if self.inFirstGenerateSprites {
            switch aktNodeType {
                case MyNodeTypes.LabelNode, MyNodeTypes.SpriteNode: showNextSprite(touchLocation)
                default: return
            }
            return
        }
        if movedFromNode != nil && !stopped {
            //let countTouches = touches.count
            var aktNode: SKNode? = nil

            let startNode = movedFromNode
            switch aktNodeType {
                case MyNodeTypes.LabelNode: aktNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
                case MyNodeTypes.SpriteNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
                case MyNodeTypes.ButtonNode:
                    //(testNode as! MySKNode).texture = SKTexture(imageNamed: "\(testNode.name!)")
                    (testNode as! MySKNode).texture = atlas.textureNamed("\(testNode.name!)")
                    aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
                default: aktNode = nil
            }

            if showFingerNode {
                
                if let fingerNode = self.childNodeWithName("finger")! as? SKSpriteNode {
                    fingerNode.removeFromParent()
                }
                
            }

            if aktNode != nil && (aktNode as! MySKNode).type == .ButtonType && startNode.type == .ButtonType  {
                switch (aktNode as! MySKNode).name! {
                    case "restart": restartButtonPressed()
                    case "undo": undoButtonPressed()
                    default: undoButtonPressed()
                }
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

                let actionMove3 = SKAction.moveTo(pointOnTheWall3, duration: mirroredLine2.duration)
               
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
                    self.playSound("Drop", volume: 0.03)
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
        if showHelpLines >= numberOfLine {
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
        }
    }
    
    func showNextSprite(touchLocation:  CGPoint) {
        let aktNode = self.nodeAtPoint(touchLocation)
        if aktNode.name == lastShownNode!.name {
            undoCount++
            for index in 0..<self.children.count {
                if self.children[index].hidden {
                    //SKAction.playSoundFileNamed("Do_1", waitForCompletion: false)
                    self.playSound("Do_1", volume: 0.25)
                    lastShownNode = self.children[index] as? MySKNode
                    self.children[index].hidden = false
                    let undoButton = self.childNodeWithName("undo")! as! MySKNode
                    undoButton.hitCounter++
                   //(self.childNodeWithName("undo")! as! MySKNode).hitCounter++
                    undoButton.hitLabel.text = "\(undoButton.hitCounter)"
                    //print("undoButton.hitLabel.text: \(undoButton.hitLabel.text)")
                    return
                }
            }
            inFirstGenerateSprites = false
        } else {
            inFirstGenerateSprites = false
            for index in 0..<self.children.count {
                if self.children[index].hidden {
                    self.children[index].hidden = false
                }
            }
        }

        var three_two_one_go = [SKTexture]()
        three_two_one_go.append(atlas.textureNamed("3"))
        three_two_one_go.append(atlas.textureNamed("2"))
        three_two_one_go.append(atlas.textureNamed("1"))
        three_two_one_go.append(atlas.textureNamed("goText"))
        
        let firstFrame = three_two_one_go[0]
        let go = SKSpriteNode(texture: firstFrame)
        self.addChild(go)
        

        go.position = CGPointMake(self.frame.midX, self.frame.midY)
        if GV.onIpad {
            go.size = CGSizeMake(600, 600)
        } else {
            go.size = CGSizeMake(400, 400)
        }
        go.zPosition = 100
        
        
        let goAction = SKAction.repeatAction(
                SKAction.sequence([
                    //SKAction.playSoundFileNamed("Do_1", waitForCompletion:false),
                    SKAction.runBlock({self.playSound("Go321", volume: 0.2)}),
                    SKAction.animateWithTextures(three_two_one_go, timePerFrame: 1.2, resize: false, restore: false)
                ]),
            count: 1)
        //let waitAction = SKAction.waitForDuration(8)
        let removeAction = SKAction.removeFromParent()
        let startCounterAction = SKAction.runBlock({self.countDown = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("doCountDown"), userInfo: nil, repeats: true)})

        
        go.runAction(SKAction.sequence([goAction, removeAction, startCounterAction, SKAction.runBlock({self.playMusic("MyMusic", volume: 0.03, loops: -1)})]))
        


    }
    
    override func update(currentTime: NSTimeInterval) {
        backgroudScrollUpdate()
    }

    func backgroudScrollUpdate(){
        
        bgImage!.position = CGPointMake(bgImage!.position.x - bgAdder, bgImage!.position.y)
        
        if bgImage!.position.x <= -bgImage!.size.width + self.size.width  || bgImage!.position.x >= 0 {
            bgAdder = -bgAdder
        }
    }

    func showScore() {
        levelScore = 0
        for index in 0..<containers.count {
            levelScore += containers[index].mySKNode.hitCounter
            containers[index].label.text = "\(containers[index].mySKNode.hitCounter)"
        }
        let levelScoreText: String = GV.language.getText(.TCLevelScore)
        levelScoreLabel.text = "\(levelScoreText) \(levelScore)"

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
            audioPlayer?.volume = 0.03
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
            soundPlayer?.volume = 0.03
            soundPlayer?.numberOfLoops = 0
            soundPlayer?.play()
        } catch {
            print("soundPlayer error")
        }
        

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
            showScore()
            playSound("Container", volume: 0.03)
        } else {
            container.hitCounter -= movingSprite.hitCounter
            showScore()
            playSound("Funk_Bot", volume: 0.03)
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
    
    
    func spriteDidCollideWithMovingSprite(node1:MySKNode, node2:MySKNode) {
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
            playSound("Sprite1", volume: 0.03)
            
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
            
            movingSprite.runAction(SKAction.sequence([movingSpriteAction, actionMoveDone]), completion: {countMovingSprites--})
            
            
            let spriteDest = CGPointMake(sprite.position.x * 1.5, 0)
            sprite.startPosition = sprite.position
            sprite.position = spriteDest
            push(sprite, status: .Removed)
            

            let actionMove2 = SKAction.moveTo(spriteDest, duration: 1.5)
            sprite.runAction(SKAction.sequence([actionMove2, actionMoveDone]), completion: {countMovingSprites--})
            gameArray[movingSprite.column][movingSprite.row] = false
            gameArray[sprite.column][sprite.row] = false
            spriteCount--
            playSound("Drop", volume: 0.03)
            showScore()
        }
        spriteCount--
        let spriteCountText: String = GV.language.getText(.TCSpriteCount)
        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
        checkGameFinished()
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
            playSound("Mirror", volume: 0.03)
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
            if countDown != nil {
                countDown!.invalidate()
                countDown = nil
                //playMusic("Winner", volume: 0.03)
            }
            
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
                
                playMusic("Winner", volume: 0.2, loops: 0)
                
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
        }
        if usedCellCount < minUsedCells {
            generateSprites()
        }
    }
    
    func doCountDown() {

        timeLimit--
        showTimeLeft()
        if timeLimit == 0 {
            stopped = true
            countLostGames++
            playSound("Timeout", volume: 0.03)
            countDown!.invalidate()
            countDown = nil
            let alert = UIAlertController(title: GV.language.getText(TextConstants.TCTimeout),
                message: GV.language.getText(.TCGameOver),
                preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: GV.language.getText(.TCReturn), style: .Cancel, handler: nil)
            let againAction = UIAlertAction(title: GV.language.getText(TextConstants.TCGameAgain), style: .Default,
                handler: {(paramAction:UIAlertAction!) in
                    self.newGame(false)
                })
            alert.addAction(cancelAction)
            alert.addAction(againAction)
            parentViewController!.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func showTimeLeft() {
        let countdownText = GV.language.getText(.TCTimeLeft)
        let minutes = Int(timeLimit / 60)
        var seconds = "\(Int(timeLimit % 60))"
        seconds = Int(seconds) < 10 ? "0\(seconds)" : "\(seconds)"
        countdownLabel.text = "\(countdownText) \(minutes):\(seconds)"
    }
/*
    func printGameArray() {
        for column in 0..<countColumns {
            for row in 0..<countRows {
                print(gameArray[row][countColumns - 1 - column] ? "T " : "F ")
            }
            //print()
        }
    }
*/
    func push(sprite: MySKNode, status: SpriteStatus) {
        var savedSprite = SavedSprite()
        savedSprite.name = sprite.name!
        savedSprite.status = status
        savedSprite.startPosition = sprite.startPosition
        savedSprite.endPosition = sprite.position
        savedSprite.colorIndex = sprite.colorIndex
        savedSprite.size = sprite.size
        savedSprite.hitCounter = sprite.hitCounter
        savedSprite.column = sprite.column
        savedSprite.row = sprite.row
        if savedSprite.status != .Added {
//            print("push -> status: \(savedSprite.status), name: \(savedSprite.name), sPos: \(savedSprite.startPosition), ePos: \(savedSprite.endPosition)" )
        }
        stack.push(savedSprite)
    }
    
    func pull() {
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
                        let colorTabLine = ColorTabLine(colorIndex: colorIndex, spriteName: spriteName)
                        colorTab.append(colorTabLine)
                        gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row] = false
                    }
                case .Removed:
                    //let spriteTexture = SKTexture(imageNamed: "sprite\(savedSpriteInCycle.colorIndex)")
                    let spriteTexture = atlas.textureNamed("sprite\(savedSpriteInCycle.colorIndex)")
                    let sprite = MySKNode(texture: spriteTexture, type: .SpriteType)
                    sprite.colorIndex = savedSpriteInCycle.colorIndex
                    sprite.position = savedSpriteInCycle.endPosition
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    sprite.size = savedSpriteInCycle.size
                    sprite.column = savedSpriteInCycle.column
                    sprite.row = savedSpriteInCycle.row
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    sprite.hitLabel.text = "\(sprite.hitCounter)"
                    sprite.name = savedSpriteInCycle.name
                    gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row] = true
                    addPhysicsBody(sprite)
                    self.addChild(sprite)
                    spriteCount++
                    let spriteCountText: String = GV.language.getText(.TCSpriteCount)
                    spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
                    
                case .SizeChanged:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    sprite.size = savedSpriteInCycle.size
                    sprite.hitLabel.text = "\(sprite.hitCounter)"

                case .HitcounterChanged:
                    containers[savedSpriteInCycle.colorIndex].mySKNode.hitCounter = savedSpriteInCycle.hitCounter
                    showScore()
                    
                case .MovingStarted:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    sprite.hitLabel.text = "\(sprite.hitCounter)"
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                    sprite.runAction(SKAction.sequence(actionMoveArray))

                case .FallingMovingSprite:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    containers[savedSpriteInCycle.colorIndex].mySKNode.hitCounter += sprite.hitCounter
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                    
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
                    
                //default: run = false
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


    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfullyflag: Bool) {
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer) {
    }
  


}


