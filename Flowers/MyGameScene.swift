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

/*

class MyGameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate {

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
    
    func doubleTapped() {
    }
    
    func prepareNextGame(newGame: Bool) {
        specialPrepareFuncFirst()
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
    
//    func exchangeButtonPressed() {
//        if !exchangeModus {
//            exchangeButton!.origSize = exchangeButton!.size
//            exchangeButton!.tremblingType = .ChangeSize
//            tremblingSprites.append(exchangeButton!)
//            exchangeModus = true
//        } else {
//            exchangeButton!.size = exchangeButton!.origSize
//            exchangeButton!.tremblingType = .NoTrembling
//            tremblingSprites.removeAll()
//            exchangeModus = false
//        }
//    }
    
    func restartButtonPressed() {
        newGame(false)
    }
    
    func specialButtonPressed(buttonName: String) {
        
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
    
    

    
    func getNextPlayArt(congratulations: Bool)->UIAlertController {
        return UIAlertController()
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
    
    func restartGame() {
        
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
    
    func generateSprites(first: Bool) {
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
            if movedFromNode != aktNode && !exchangeModus {
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
    
    
    func makeEmptyCard(column:Int, row: Int) {
    }
    
    func makeHelpLine(movedFrom: (column: Int, row: Int), fromPoint: CGPoint, toPoint: CGPoint, lineWidth: CGFloat, showLines: Bool)->(pointFounded:Bool, line: SKShapeNode?, foundedPoint: Founded?) {
//        if GV.showHelpLines >= numberOfLine {
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
//            let texture = numberOfLine < maxHelpLinesCount ? movedFromNode.texture! : SKTexture(imageNamed: "bumm")
//            let texture = movedFromNode.texture!
//            let nodeOnTheWall = MySKNode(texture: texture, type: .SpriteType, value: NoValue)
//            nodeOnTheWall.name = "nodeOnTheWall"
//            nodeOnTheWall.position = toPoint
//            nodeOnTheWall.size = movedFromNode.size
//            self.addChild(nodeOnTheWall)
//        }
        return (false, myLine, Founded())
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
    
//    func wallAroundDidCollideWithMovingSprite(node1: MySKNode, node2: SKNode) {
//        let movingSprite = node1
//        let lineAround = node2
//        
//        if spriteGameLastPosition != movingSprite.position && lineAround.name != lastMirrored {
//            lastMirrored = lineAround.name!
//            spriteGameLastPosition = movingSprite.position
//            
//            let originalPosition = movingSprite.startPosition
//            _ = movingSprite.position - originalPosition
//            
//            let dX = movingSprite.startPosition.x - movingSprite.position.x
//            let dY = movingSprite.startPosition.y - movingSprite.position.y
//            
//            
//            
//            var zielPosition = CGPointZero
//            switch lineAround.name! {
//            case "BH": zielPosition = CGPointMake(movingSprite.position.x - dX, originalPosition.y)
//            case "LV": zielPosition = CGPointMake(originalPosition.x, movingSprite.position.y - dY)
//            case "UH": zielPosition = CGPointMake(movingSprite.position.x - dX, originalPosition.y)
//            case "RV": zielPosition = CGPointMake(originalPosition.x, movingSprite.position.y - dY)
//            default: break
//            }
//            //            print("case: \(lineAround.name!), aktX: \(movingSprite.position.x), aktY: \(movingSprite.position.y), origX:\(movingSprite.startPosition.x), origY:\(movingSprite.startPosition.y), zielX: \(zielPosition.x), zielY: \(zielPosition.y)")
//            
//            let offsetNew = zielPosition - movingSprite.position
//            let direction = offsetNew.normalized()
//            
//            let shootAmount = direction * 1200
//            let realDest = shootAmount + movingSprite.position
//            
//            //print("offsetNew: \(offsetNew), direction: \(direction), shootAmount: \(shootAmount), realDest: \(realDest)")
//            
//            movingSprite.startPosition = movingSprite.position
//            movingSprite.hitCounter = Int(CGFloat(movingSprite.hitCounter) * 1.5)
//            push(movingSprite, status: .Mirrored)
//            
//            let actionMove = SKAction.moveTo(realDest, duration: 1.0)
//            collisionActive = true
//            movingSprite.runAction(SKAction.sequence([actionMove]))//, actionMoveDone]))
//            playSound("Mirror", volume: GV.soundVolume)
//            checkGameFinished()
//        }
//    }
    
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

    
    func push(sprite1: MySKNode, sprite2: MySKNode) {
        push(sprite1, status: .Exchanged)
        push(sprite2, status: .Exchanged)
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
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfullyflag: Bool) {
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer) {
    }
    
    
    
    // FUNCTIONS FOR OVERRIDE
    
    func pull(createTipps: Bool) {
    }
    
    func updateSpriteCount(adder: Int) {
        
    }
    
    func getTexture(index: Int)->SKTexture {
        return atlas.textureNamed ("sprite\(index)")
    }
    
    func makeSpezialThings(first: Bool) {
        
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
    
    func readNextLevel()->Int {
        return 0
    }
    
    func specialPrepareFuncFirst() {
        
    }
    
}

*/
