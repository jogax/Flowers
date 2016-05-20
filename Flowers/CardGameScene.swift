
//  CardGameScene.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 11. 26..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import AVFoundation

class CardGameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate { //,  JGXLineDelegate { //MyGameScene {

    struct PairStatus {
        var pair: FromToColumnRow
        var startTime: NSDate
        var duration: Double
        var founded: Founded
        var fixed: Bool
        var points: [CGPoint]
        init(pair: FromToColumnRow, founded: Founded, startTime: NSDate, points: [CGPoint]) {
            self.pair = pair
            self.founded = founded
            self.startTime = startTime
            self.duration = 0
            self.fixed = false
            self.points = points
        }
        
        mutating func setEndDuration() {
            duration = NSDate().timeIntervalSinceDate(self.startTime)
        }
        
        func getActDuration() -> NSTimeInterval{
            return NSDate().timeIntervalSinceDate(startTime)
        }
    }
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
    

    enum MyColors: Int {
        case Red = 0, Green
    }
    
    enum SpriteGeneratingType: Int {
        case First = 0, Normal, Special
    }

    struct GenerateCard {
        var cardValue: Int
        var packageNr: Int
        var used: Bool
        init() {
            cardValue = 0
            packageNr = 0
            used      = false
        }
    }
    
    struct Tipps {
        var removed: Bool
        var fromColumn: Int
        var fromRow: Int
        var toColumn: Int
        var toRow: Int
        var twoArrows: Bool
        var points:[CGPoint]
        var lineLength: CGFloat
        
        init() {
            removed = false
            fromColumn = 0
            fromRow = 0
            toColumn = 0
            toRow = 0
            points = [CGPoint]()
            twoArrows = false
            lineLength = 0
        }
    }
    
    struct DrawHelpLinesParameters {
        var points: [CGPoint]
        var lineWidth: CGFloat
        var twoArrows: Bool
        var color: MyColors
        
        init() {
            points = [CGPoint]()
            lineWidth = 0
            twoArrows = false
            color = .Red
        }
    }
    
    let showTippSleepTime = 30.0
    let doCountUpSleepTime = 1.0
    
    let showTippSelector = "showTipp"
    let doCountUpSelector = "doCountUp"
    let checkGreenLineSelector = "setGreenLineSize"
    let myLineName = "myLine"
    
    let emptySpriteTxt = "emptySprite"
    
    var cardStack:Stack<MySKNode> = Stack()
    var showCardStack:Stack<MySKNode> = Stack()
    var tippCountLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    
    var cardPackage: MySKButton?
    var cardPlaceButton: MySKButton?
    var tippsButton: MySKButton?
    
    var cardPlaceButtonAddedToParent = false
    var cardToChange: MySKNode?
    
    var showCard: MySKNode?
    var showCardFromStack: MySKNode?
    var showCardFromStackAddedToParent = false
    var backGroundOperation = NSOperation()


    var lastCollisionsTime = NSDate()
    var cardArray: [[GenerateCard]] = []
//    var valueTab = [Int]()
    let spriteCountPosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.96 : 0.96)
    let tippCountPosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.94 : 0.94)
    var countPackages = 0
    let nextLevel = true
    let previousLevel = false
    var lastUpdateSec = 0
    var lastNextPoint: Founded?
    var generatingTipps = false
    var tippArray = [Tipps]()
    var tippIndex = 0
    var showTippAtTimer: NSTimer?
    var dummy = 0
    
    var labelFontSize = CGFloat(0)
    var labelYPosProcent = CGFloat(0)
    var labelHeight = CGFloat(0)
    
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
    
    let containerSizeOrig: CGFloat = 40
    let spriteSizeOrig: CGFloat = 35
    
    var showFingerNode = false
    var countMovingSprites = 0
    var countCheckCounts = 0
    var exchangeModus = false
    
    //let timeLimitKorr = 5 // sec for pro Sprite
    var timeCount: Int = 0 // seconds
    //    var startTime: NSDate?
    //    var startTimeOrig: NSDate?
    var timer: NSTimer?
    var countUp: NSTimer?
    var greenLineTimer: NSTimer?
    var waitForSKActionEnded: NSTimer?
    var lastMirrored = ""
    var musicPlayer: AVAudioPlayer?
    var soundPlayer: AVAudioPlayer?
    var myView = SKView()
    var levelIndex = GV.player!.levelID
    var stack:Stack<SavedSprite> = Stack()
    //var gameArray = [[Bool]]() // true if Cell used
    var gameArray = [[GameArrayPositions]]()
    var containers = [MyContainer]()
    var colorTab = [ColorTabLine]()
    let containersPosCorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.85 : 0.85)
    var levelPosKorr = CGPointMake(GV.onIpad ? 0.7 : 0.7, GV.onIpad ? 0.97 : 0.97)
    let playerPosKorr = CGPointMake(0.7 * GV.deviceConstants.sizeMultiplier, 0.5 * GV.deviceConstants.sizeMultiplier)
    let countUpPosKorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.95 : 0.94)
    var countColorsProContainer = [Int]()
    var labelBackground = SKSpriteNode()
    var levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var countUpLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var playerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var spriteCountLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    
//    var gameScore = GV.player!.gameScore
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
    
    var lastGreenPair: PairStatus?
    var lastRedPair: PairStatus?
    
    var lastDrawHelpLinesParameters = DrawHelpLinesParameters()

    
    var lineWidthMultiplierNormal = CGFloat(0.04) //(0.0625)
    let lineWidthMultiplierSpecial = CGFloat(0.125)
    
    var lineWidthMultiplier: CGFloat?
    var actPair: PairStatus?
    var oldFromToColumnRow: FromToColumnRow?
    
    var spriteGameLastPosition = CGPointZero
    
    var buttonSize = CGFloat(0)
    var buttonYPos = CGFloat(0)
    var buttonXPosNormalized = CGFloat(0)
    let images = DrawImages()
    
    var stop = false
    
    var panel: MySKPanel?
    var countUpAdder = 0
    
    
    var stopCreateTippsInBackground = false {
        didSet {
            if stopCreateTippsInBackground {
                if !generatingTipps {
                    stopCreateTippsInBackground = false
                } else {
                    let startWaiting = NSDate()
                    while generatingTipps && stopCreateTippsInBackground {
                        
                         dummy = 0
                    }
                    print ("waiting for Stop Creating Tipps:", NSDate().timeIntervalSinceDate(startWaiting).nDecimals(5))
                    stopCreateTippsInBackground = false

                }
            }
        }
    }
        
    var gameArrayChanged = false {
        didSet {
            switch (oldValue, gameArrayChanged, generatingTipps) {
                case (false, true, false):
                    startCreateTippsInBackground()
                case (true, true, true):
                    stopCreateTippsInBackground = true
                    startCreateTippsInBackground()
                case (true, true, false):
                    startCreateTippsInBackground()

                default: dummy = 0
            }
        }
    }
    
    var tapLocation: CGPoint?
    let qualityOfServiceClass = QOS_CLASS_BACKGROUND
    let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
    let playMusicForever = -1
    
    override func didMoveToView(view: SKView) {
        
        if !settingsSceneStarted {
            
            myView = view
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            print(documentsPath)
            
            spriteTabRect.origin = CGPointMake(self.frame.midX, self.frame.midY * 0.85)
            spriteTabRect.size = CGSizeMake(self.frame.size.width * 0.80, self.frame.size.height * 0.80)
            
            let width:CGFloat = 64.0
            let height: CGFloat = 89.0
            sizeMultiplier = CGSizeMake(GV.deviceConstants.sizeMultiplier, GV.deviceConstants.sizeMultiplier * height / width)
            buttonSizeMultiplier = CGSizeMake(GV.deviceConstants.buttonSizeMultiplier, GV.deviceConstants.buttonSizeMultiplier * height / width)
            levelIndex = GV.player!.levelID
            GV.levelsForPlay.setAktLevel(levelIndex)
            
            buttonSize = (myView.frame.width / 15) * buttonSizeMultiplier.width
            buttonYPos = myView.frame.height * 0.07
            buttonXPosNormalized = myView.frame.width / 10
            
            prepareNextGame(true)
            generateSprites(.First)
        } else {
            playMusic("MyMusic", volume: GV.player!.musicVolume, loops: playMusicForever)
            
        }
    }
    
    func prepareNextGame(newGame: Bool) {
        
        setMyDeviceConstants()
        levelIndex = GV.player!.levelID
        GV.levelsForPlay.setAktLevel(levelIndex)

//        GV.statistic = GV.realm.objects(StatisticModel).filter("playerID = %d and levelID = %d", GV.player!.ID, GV.player!.levelID).first
        self.removeAllChildren()

        specialPrepareFuncFirst()
        playMusic("MyMusic", volume: GV.player!.musicVolume, loops: playMusicForever)
        stack = Stack()
        timeCount = 0
        if newGame {
            if let actGame = GV.realm.objects(GameModel).filter("ID = %d", gameNumber).first {
                if actGame.bestScore == 0 {
                    GV.realm.beginWrite()
                    GV.realm.delete(actGame) // Game delete if not used!
                    try! GV.realm.commitWrite()
                }
            }
            gameNumber = Int(arc4random_uniform(999999))
        }
        random = MyRandom(gameID: gameNumber, levelID: levelIndex)
        
        stopTimer(&countUp)
        
        gameArray.removeAll(keepCapacity: false)
        containers.removeAll(keepCapacity: false)
        //undoCount = 3
        
        // fill gameArray
        for _ in 0..<countColumns {
            gameArray.append(Array(count: countRows, repeatedValue:GameArrayPositions()))
        }
        
        // calvulate Sprite Positions
        
        for column in 0..<countColumns {
            for row in 0..<countRows {
                gameArray[column][row].position = calculateSpritePosition(column, row: row)
            }
        }
        
        for column in 0..<countColumns {
            for row in 0..<countRows {
                let columnRow = calculateColumnRowFromPosition(gameArray[column][row].position)
                if column != columnRow.column || row != columnRow.row {
                    print("column:", column, "row:",row, "calculated:", columnRow, column != columnRow.column || row != columnRow.row ? "Error" : "")
                    dummy = 0
                }
            }
        }


        
        
        prepareContainers()
        
        //        self.addChild(labelBackground)
        
        
        showTimeLeft()
        
        
        bgImage = setBGImageNode()
        //print("ImageSize: \(bgImage?.size)")
        bgAdder = 0.1
        
        bgImage!.anchorPoint = CGPointZero
//        bgImage!.position = self.position //CGPointMake(0, 0)
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
        spriteCount = Int(CGFloat(countContainers * countSpritesProContainer!))
        let spriteCountText: String = GV.language.getText(.TCCardCount) + " \(spriteCount)"
        let tippCountText: String = GV.language.getText(.TCTippCount) + " \(tippArray.count)"
        let name = GV.player!.name == GV.language.getText(.TCAnonym) ? GV.language.getText(.TCGuest) : GV.player!.name
        createLabels(playerLabel, text: GV.language.getText(TextConstants.TCPlayer) + ": \(name)", column: 2, row: 1)
        createLabels(levelLabel, text: GV.language.getText(TextConstants.TCLevel) + ": \(levelIndex + 1)", column: 3, row: 1)
        createLabels(countUpLabel, text: "", column: 4, row: 2)
        createLabels(spriteCountLabel, text: spriteCountText, column: 1, row: 2)
        createLabels(tippCountLabel, text: tippCountText, column: 1, row: 3)

    }
    
    func createLabels(label: SKLabelNode, text: String, column: Int, row: Int) {
        label.text = text
        var xPos = CGFloat(0)
        var horAlignment = SKLabelHorizontalAlignmentMode.Center
        switch column {
        case 1:
            xPos = self.position.x + self.size.width * 0.1
            horAlignment = .Left
        case 2:
            xPos = self.position.x + self.size.width * 0.3
        case 3:
            xPos = self.position.x + self.size.width * 0.7
        case 4:
            xPos = self.position.x + self.size.width * 0.8
        default: break
        }
        let yPos = CGFloat(self.size.height * labelYPosProcent / 100) + CGFloat((5 - row)) * labelHeight
        
        label.position = CGPointMake(xPos, yPos)
        label.fontColor = SKColor.blackColor()
        label.horizontalAlignmentMode = horAlignment
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        label.fontSize = labelFontSize;
        label.color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.addChild(label)
    }
    
    
    


    func getTexture(index: Int)->SKTexture {
        if index == NoColor {
            return atlas.textureNamed("emptycard")
        } else {
            return atlas.textureNamed ("card\(index)")
        }
    }
    
    func specialPrepareFuncFirst() {
//        print("stopCreateTippsInBackground from specialPrepareFuncFirst")
        stopCreateTippsInBackground = true
        let cardSize = CGSizeMake(buttonSize * sizeMultiplier.width * 0.8, buttonSize * sizeMultiplier.height * 0.8)
        let cardPackageButtonTexture = SKTexture(image: images.getCardPackage())
        cardPackage = MySKButton(texture: cardPackageButtonTexture, frame: CGRectMake(buttonXPosNormalized * 4.0, buttonYPos, cardSize.width, cardSize.height), makePicture: false)
        cardPackage!.name = "cardPackege"
        addChild(cardPackage!)
        
        showCardFromStack = nil
        
        let cardPlaceTexture = SKTexture(imageNamed: "emptycard")
        cardPlaceButton = MySKButton(texture: cardPlaceTexture, frame: CGRectMake(buttonXPosNormalized * 6.0, buttonYPos, cardSize.width, cardSize.height), makePicture: false)
        cardPlaceButton!.name = "cardPlace"
        addChild(cardPlaceButton!)
        cardPlaceButton!.alpha = 0.3
        cardPlaceButtonAddedToParent = true
        
        let tippsTexture = SKTexture(image: images.getTipp())
        tippsButton = MySKButton(texture: tippsTexture, frame: CGRectMake(buttonXPosNormalized * 7.5, buttonYPos, buttonSize, buttonSize))
        tippsButton!.name = "tipps"
        addChild(tippsButton!)
        

        countContainers = GV.levelsForPlay.aktLevel.countContainers
        countPackages = GV.levelsForPlay.aktLevel.countPackages
        countSpritesProContainer = MaxCardValue //levelsForPlay.aktLevel.countSpritesProContainer
        countColumns = GV.levelsForPlay.aktLevel.countColumns
        countRows = GV.levelsForPlay.aktLevel.countRows
        minUsedCells = GV.levelsForPlay.aktLevel.minProzent * countColumns * countRows / 100
        maxUsedCells = GV.levelsForPlay.aktLevel.maxProzent * countColumns * countRows / 100
        containerSize = CGSizeMake(CGFloat(containerSizeOrig) * sizeMultiplier.width, CGFloat(containerSizeOrig) * sizeMultiplier.height)
        spriteSize = CGSizeMake(CGFloat(GV.levelsForPlay.aktLevel.spriteSize) * sizeMultiplier.width, CGFloat(GV.levelsForPlay.aktLevel.spriteSize) * sizeMultiplier.height )
        //gameArrayPositions.removeAll(keepCapacity: false)
        tableCellSize = spriteTabRect.width / CGFloat(countColumns)
        
        for _ in 0..<countContainers {
            var hilfsArray: [GenerateCard] = []
            for cardIndex in 0..<countSpritesProContainer! * countPackages {
                var card = GenerateCard()
                card.cardValue = cardIndex % countSpritesProContainer!
                card.packageNr = cardIndex / countSpritesProContainer!
                
                hilfsArray.append(card)
            }
            cardArray.append(hilfsArray)
        }
    }
    
    func updateSpriteCount(adder: Int) {
        spriteCount += adder
        let spriteCountText: String = GV.language.getText(.TCCardCount)
        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
    }

    
    func changeLanguage()->Bool {
        let name = GV.player!.name == GV.language.getText(.TCAnonym) ? GV.language.getText(.TCGuest) : GV.player!.name
        playerLabel.text = GV.language.getText(.TCPlayer) + ": \(name)"
        levelLabel.text = GV.language.getText(.TCLevel) + ": \(levelIndex + 1)"
        spriteCountLabel.text = GV.language.getText(.TCCardCount) + " \(spriteCount)"
        tippCountLabel.text = GV.language.getText(.TCTippCount) + " \(tippArray.count)"
        showTimeLeft()
        return true
    }

    func setBGImageNode()->SKSpriteNode {
        return SKSpriteNode(imageNamed: "cardBackground.png")
    }

    
    func spezialPrepareFunc() {
//        valueTab.removeAll()
    }

    func getValueForContainer()->Int {
        return countSpritesProContainer!// + 1
    }
 
    func createSpriteStack() {
        cardStack.removeAll(.MySKNodeType)
        showCardStack.removeAll(.MySKNodeType)
        while colorTab.count > 0 && checkGameArray() < maxUsedCells {
            let colorTabIndex = random!.getRandomInt(0, max: colorTab.count - 1)//colorTab.count - 1 //
            let colorIndex = colorTab[colorTabIndex].colorIndex
            let spriteName = colorTab[colorTabIndex].spriteName
            let value = colorTab[colorTabIndex].spriteValue
            colorTab.removeAtIndex(colorTabIndex)
            let sprite = MySKNode(texture: getTexture(colorIndex), type: .SpriteType, value:value)
            sprite.name = spriteName
            sprite.colorIndex = colorIndex
            cardStack.push(sprite)
        }
    }
    
    func fillEmptySprites() {
        for column in 0..<countColumns {
            for row in 0..<countRows {
                makeEmptyCard(column, row: row)
            }
        }
    }

    func generateSprites(generatingType: SpriteGeneratingType) {
//        print("generateSprites:", generatingType)
        var generateSpecial = generatingType ==  .Special
        var positionsTab = [(Int, Int)]() // search all available Positions
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if !gameArray[column][row].used {
                    let appendValue = (column, row)
                    positionsTab.append(appendValue)
                }
            }
        }
        
        while (cardStack.count(.MySKNodeType) > 0 && checkGameArray() < maxUsedCells) || generateSpecial {
            var sprite: MySKNode = cardStack.pull()!
            
            if generateSpecial {
                while true {
                    if findPairForSprite(sprite.colorIndex, minValue: sprite.minValue, maxValue: sprite.maxValue) {
                        break
                    }
                    cardStack.pushLast(sprite)
                    sprite = cardStack.pull()!
                }
                generateSpecial = false
            }
            
            let index = random!.getRandomInt(0, max: positionsTab.count - 1)
            let (aktColumn, aktRow) = positionsTab[index]
            
            let zielPosition = gameArray[aktColumn][aktRow].position
            sprite.position = cardPackage!.position
            sprite.startPosition = zielPosition
            

            positionsTab.removeAtIndex(index)
            
            sprite.column = aktColumn
            sprite.row = aktRow
            
            sprite.size = CGSizeMake(spriteSize.width, spriteSize.height)
//            sprite.zPosition = 10
            updateGameArrayCell(sprite)

//            addPhysicsBody(sprite)
            push(sprite, status: .AddedFromCardStack)
            addChild(sprite)
            let duration:Double = Double((zielPosition - cardPackage!.position).length()) / 500
            let actionMove = SKAction.moveTo(zielPosition, duration: duration)
            
            let zPositionPlus = SKAction.runBlock({
                sprite.zPosition += 100
            })

            let zPositionMinus = SKAction.runBlock({
                sprite.zPosition -= 100
            })

            let actionHideEmptyCard = SKAction.runBlock({
                self.deleteEmptySprite(aktColumn, row: aktRow)
//                sprite.zPosition = 0
                
            })
            sprite.runAction(SKAction.sequence([zPositionPlus, actionMove, zPositionMinus, actionHideEmptyCard]))
            if cardStack.count(.MySKNodeType) == 0 {
                cardPackage!.changeButtonPicture(SKTexture(imageNamed: "emptycard"))
                cardPackage!.alpha = 0.3
            }

        }
//        print("Count Columns:", countColumns)
        if generatingType != .Special {
            gameArrayChanged = true
        }
        if generatingType == .First {
            countUp = NSTimer.scheduledTimerWithTimeInterval(doCountUpSleepTime, target: self, selector: Selector(doCountUpSelector), userInfo: nil, repeats: true)
            countUpAdder = 1
        }
        
        stopped = false
    }
    
    
    func startCreateTippsInBackground() {
        {
            self.generatingTipps = true
            self.stopTimer(&self.showTippAtTimer)
//            let startTime = NSDate()
            var countCreating = self.countColumns * self.countRows - self.checkGameArray()
            while countCreating > 0 && self.spriteCount > 0 {
                _ = self.createTipps()
//                print("tippsCreated:", tippsCreated, " in ", NSDate().timeIntervalSinceDate(startTime).threeDecimals, " seconds")
                if self.tippArray.count <= 1 || self.stop  {
//                    print(" ==========> generate special Sprite - countCreating:", countCreating)
                    self.generateSprites(.Special)
                    countCreating -= 1
                } else {
                    countCreating = 0
                }
            }
            if self.tippArray.count == 0 && self.spriteCount > 0{
                print ("You have lost!")
            }
        } ~>
        {
            self.generatingTipps = false
        }
/*
        if !generatingTipps {
            dispatch_async(backgroundQueue) { //(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.generatingTipps = true
                var tippsCreated = false
//                while !tippsCreated {
                    self.stopTimer(self.showTippAtTimer)
//                    self.stopCreateTippsInBackground = false
                    let startTime = NSDate()
                    tippsCreated = self.createTipps()
                    print("tippsCreated:", tippsCreated, " ", self.tippArray.count,  " Tipps in ", NSDate().timeIntervalSinceDate(startTime).threeDecimals, "seconds")
//                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.generatingTipps = false
                    self.startTippTimer()
                })
            }
        }
*/

    }
    
    
    func showTipp() {
        getTipps()
    }
    
    func deleteEmptySprite(column: Int, row: Int) {
        let searchName = "\(emptySpriteTxt)-\(column)-\(row)"
        if self.childNodeWithName(searchName) != nil {
            self.childNodeWithName(searchName)!.removeFromParent()
        }

    
    }
    
    func makeEmptyCard(column:Int, row: Int) {
        let searchName = "\(emptySpriteTxt)-\(column)-\(row)"
        if self.childNodeWithName(searchName) == nil {
//            let xPosition = spriteTabRect.origin.x - spriteTabRect.size.width / 2 + CGFloat(column) * tableCellSize + tableCellSize / 2
//            let yPosition = spriteTabRect.origin.y - spriteTabRect.size.height / 2 + tableCellSize * 1.10 / 2 + CGFloat(row) * tableCellSize * 1.10
            let emptySprite = MySKNode(texture: getTexture(NoColor), type: .EmptyCardType, value: NoColor)
            emptySprite.position = gameArray[column][row].position
            emptySprite.size = CGSizeMake(spriteSize.width, spriteSize.height)
            emptySprite.name = "\(emptySpriteTxt)-\(column)-\(row)"
            emptySprite.column = column
            emptySprite.row = row
            gameArray[column][row].used = false
            gameArray[column][row].colorIndex = NoColor
            gameArray[column][row].name = searchName
            addChild(emptySprite)
        }
    }

    func specialButtonPressed(buttonName: String) {
        if buttonName == "cardPackege" {
            if cardStack.count(.MySKNodeType) > 0 {
                if showCard != nil {
                    showCardStack.push(showCard!)
                    showCard?.removeFromParent()
                }
                showCard = cardStack.pull()!
                showCard!.position = (cardPlaceButton?.position)!
                showCard!.size = (cardPlaceButton?.size)!
                showCard!.type = .ShowCardType
                cardPlaceButton?.removeFromParent()
                cardPlaceButtonAddedToParent = false
                addChild(showCard!)
                if cardStack.count(.MySKNodeType) == 0 {
                    cardPackage!.changeButtonPicture(SKTexture(imageNamed: "emptycard"))
                    cardPackage!.alpha = 0.3
                }
            }
        }
        if buttonName == "tipps" {
            if !generatingTipps {
                getTipps()
            }
        }
        startTippTimer()
    }
    
    func startTippTimer(){
        stopTimer(&showTippAtTimer)
        showTippAtTimer = NSTimer.scheduledTimerWithTimeInterval(showTippSleepTime, target: self, selector: Selector(showTippSelector), userInfo: nil, repeats: true)
    }
    
    func getTipps() {
        if tippArray.count > 0 && !generatingTipps {
                stopTrembling()
                drawHelpLines(tippArray[tippIndex].points, lineWidth: spriteSize.width, twoArrows: tippArray[tippIndex].twoArrows, color: .Green)
                var position = CGPointZero
                if tippArray[tippIndex].fromRow == NoValue {
                    position = containers[tippArray[tippIndex].fromColumn].position
                } else {
                    position = gameArray[tippArray[tippIndex].fromColumn][tippArray[tippIndex].fromRow].position
                }
                addSpriteToTremblingSprites(position)
                if tippArray[tippIndex].toRow == NoValue {
                    position = containers[tippArray[tippIndex].toColumn].position
                } else {
                    position = gameArray[tippArray[tippIndex].toColumn][tippArray[tippIndex].toRow].position
                }
                addSpriteToTremblingSprites(position)
//            }
            tippIndex += 1
            tippIndex %= tippArray.count
        }
        
    }
    
    func createTipps()->Bool {
        tippArray.removeAll()
//        while gameArray.count < countColumns * countRows {
//            sleep(1) //wait until gameArray is filled!!
//        }
        tippsButton!.activateButton(false)
        var pairsToCheck = [FromToColumnRow]()
        for column1 in 0..<countColumns {
            for row1 in 0..<countRows {
                if gameArray[column1][row1].used {
                    for column2 in 0..<countColumns {
                        for row2 in 0..<countRows {
                            if stopCreateTippsInBackground {
                                print("stopped while searching pairs")
                                stopCreateTippsInBackground = false
                                return false
                            }
                            if (column1 != column2 || row1 != row2) && gameArray[column2][row2].colorIndex == gameArray[column1][row1].colorIndex &&
                                (gameArray[column2][row2].minValue == gameArray[column1][row1].maxValue + 1 ||
                                    gameArray[column2][row2].maxValue == gameArray[column1][row1].minValue - 1) {
                                        let aktPair = FromToColumnRow(fromColumnRow: ColumnRow(column: column1, row: row1), toColumnRow: ColumnRow(column: column2, row: row2))
                                        if !pairExists(pairsToCheck, aktPair: aktPair) {
                                            pairsToCheck.append(aktPair)
                                            pairsToCheck.append(FromToColumnRow(fromColumnRow: aktPair.toColumnRow, toColumnRow: aktPair.fromColumnRow))
                                        }
                            }
                        }
                    }
                    for index in 0..<containers.count {
                        if containers[index].minValue == NoColor && gameArray[column1][row1].maxValue == LastCardValue {
                            let actContainerPair = FromToColumnRow(fromColumnRow: ColumnRow(column: column1, row: row1), toColumnRow: ColumnRow(column: index, row: NoValue))
                            pairsToCheck.append(actContainerPair)
                        }
                        if containers[index].colorIndex == gameArray[column1][row1].colorIndex &&
                         containers[index].minValue == gameArray[column1][row1].maxValue + 1 {
                            let actContainerPair = FromToColumnRow(fromColumnRow: ColumnRow(column: column1, row: row1), toColumnRow: ColumnRow(column: index, row: NoValue))
                            pairsToCheck.append(actContainerPair)
                        }
                    }
                }
            }
        }

//        print("gameArray Size:", gameArray.count)
//        print("pairsToCheck.count:", pairsToCheck.count)
//        let pairsToCheckCount = pairsToCheck.count
        let startCheckTime = NSDate()
        for ind in 0..<pairsToCheck.count {
//            print("pairsToCheck:", pairsToCheck[ind])
            checkPathToFoundedCards(pairsToCheck[ind])
            //tippsButton!.showProgress(ind, maxValue: pairsToCheckCount)
//            print ("ind:", ind)
            if stopCreateTippsInBackground {
//                print("stopped while checking pairs")
                stopCreateTippsInBackground = false
                return false
            }
        }

//        let checkTime = NSDate().timeIntervalSinceDate(startCheckTime)
//        print("for ", countColumns, " columns the avarageTime is:", checkTime / Double(pairsToCheckCount).threeDecimals, "sec / pair")
        var removeIndex = [Int]()
        if tippArray.count > 0 {
            for ind in 0..<tippArray.count - 1 {
                if !tippArray[ind].removed {
                    let fromColumn = tippArray[ind].fromColumn
                    let toColumn = tippArray[ind].toColumn
                    let fromRow = tippArray[ind].fromRow
                    let toRow = tippArray[ind].toRow
                    if fromColumn == tippArray[ind + 1].toColumn &&
                       fromRow == tippArray[ind + 1].toRow &&
                       toColumn == tippArray[ind + 1].fromColumn  &&
                       toRow == tippArray[ind + 1].fromRow {
                            switch tippArray[ind].points.count {
                            case 2:
                                tippArray[ind].twoArrows = true
                                removeIndex.insert(ind + 1, atIndex: 0)
                            case 3:
                                if (tippArray[ind].points[1] - tippArray[ind + 1].points[1]).length() < spriteSize.height{
                                    tippArray[ind].twoArrows = true
                                    removeIndex.insert(ind + 1, atIndex: 0)
                                }
                            case 4:
                                if tippArray[ind + 1].points.count == 4 && (tippArray[ind].points[1] - tippArray[ind + 1].points[2]).length() < spriteSize.height && (tippArray[ind].points[2] - tippArray[ind + 1].points[1]).length() < spriteSize.height
                                {
                                    tippArray[ind].twoArrows = true
                                    removeIndex.insert(ind + 1, atIndex: 0)
                                }
                            default:
                                tippArray[ind].twoArrows = false
                            }
                    }
                    if gameArray[fromColumn][fromRow].maxValue == LastCardValue && toRow == NoValue && containers[toColumn].minValue == NoColor {
                        // King to empty Container
                        var index = 1
                        while (ind + index) < tippArray.count && index < 4 {
                            let fromColumn1 = tippArray[ind + index].fromColumn
                            let toColumn1 = tippArray[ind + index].toColumn
                            let fromRow1 = tippArray[ind + index].fromRow
                            let toRow1 = tippArray[ind + index].toRow
                            
                            if fromColumn == fromColumn1 && fromRow == fromRow1 && toRow1 == NoValue && containers[toColumn1].minValue == NoColor
                                && toColumn != toColumn1 {
                                if tippArray[ind].lineLength > tippArray[ind + index].lineLength {
                                    let tippArchiv = tippArray[ind]
                                    tippArray[ind] = tippArray[ind + index]
                                    tippArray[ind + index] = tippArchiv
                                }
                                tippArray[ind + index].removed = true
                                removeIndex.insert(ind + index, atIndex: 0)
                            }
                            index += 1
                        }
                        dummy = 0
                    }
                }
            }
            
            
            for ind in 0..<removeIndex.count {
                tippArray.removeAtIndex(removeIndex[ind])
            }
            
            
            if stopCreateTippsInBackground {
//                print("stopped before sorting Tipp pairs")

                stopCreateTippsInBackground = false
                return false
            }
            tippArray.sortInPlace({checkForSort($0, t1: $1) })
            
        }
        let tippCountText: String = GV.language.getText(.TCTippCount)
        tippCountLabel.text = "\(tippCountText) \(tippArray.count)"
        if tippArray.count > 0 {
            tippsButton!.activateButton(true)
        }

        tippIndex = 0  // set tipps to first
        return true
     }
    
    func findPairForSprite (colorIndex: Int, minValue: Int, maxValue: Int)->Bool {
        var founded = false
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if gameArray[column][row].colorIndex == colorIndex &&
                    (gameArray[column][row].minValue == maxValue + 1 ||
                    gameArray[column][row].maxValue == minValue - 1) {
                        founded = true
                        break
                }
            }
        }
        if !founded {
            for index in 0..<containers.count {
                if (containers[index].minValue == NoColor && maxValue == LastCardValue) ||
                    (containers[index].colorIndex == colorIndex && containers[index].minValue == maxValue + 1){
                        founded = true
                        break
                }
            }
        }
        return founded
    }
    
    func checkForSort(t0: Tipps, t1:Tipps)->Bool {
        let returnValue = gameArray[t0.fromColumn][t0.fromRow].colorIndex < gameArray[t1.fromColumn][t1.fromRow].colorIndex
            || (gameArray[t0.fromColumn][t0.fromRow].colorIndex == gameArray[t1.fromColumn][t1.fromRow].colorIndex &&
                (gameArray[t0.fromColumn][t0.fromRow].maxValue < gameArray[t1.fromColumn][t1.fromRow].minValue
            || (t0.toRow != NoValue && t1.toRow != NoValue && gameArray[t0.toColumn][t0.toRow].maxValue < gameArray[t1.toColumn][t1.toRow].minValue)))
        return returnValue
    }
    
    func pairExists(pairsToCheck:[FromToColumnRow], aktPair: FromToColumnRow)->Bool {
        for index in 0..<pairsToCheck.count {
            let aktPairToCheck = pairsToCheck[index]
            if aktPairToCheck.fromColumnRow.column == aktPair.fromColumnRow.column && aktPairToCheck.fromColumnRow.row == aktPair.fromColumnRow.row && aktPairToCheck.toColumnRow.column == aktPair.toColumnRow.column && aktPairToCheck.toColumnRow.row == aktPair.toColumnRow.row {
                return true
            }
        }
        return false
    }

    
    func checkPathToFoundedCards(actPair:FromToColumnRow) {
        var targetPoint = CGPointZero
        var myTipp = Tipps()
        let firstValue: CGFloat = 10000
        var distanceToLine = firstValue
       let startPoint = gameArray[actPair.fromColumnRow.column][actPair.fromColumnRow.row].position
//        let name = gameArray[index.card1.column][index.card1.row].name
        if actPair.toColumnRow.row == NoValue {
            targetPoint = containers[actPair.toColumnRow.column].position
        } else {
            targetPoint = gameArray[actPair.toColumnRow.column][actPair.toColumnRow.row].position
        }
        let startAngle = calculateAngle(startPoint, point2: targetPoint).angleRadian - GV.oneGrad
        let stopAngle = startAngle + 360 * GV.oneGrad // + 360°
//        let startNode = self.childNodeWithName(name)! as! MySKNode
        var founded = false
        var angle = startAngle
        let multiplierForSearch = CGFloat(5.0)
//        let fineMultiplier = CGFloat(1.0)
        let multiplier:CGFloat = multiplierForSearch
        while angle <= stopAngle && !founded {
            let toPoint = GV.pointOfCircle(1.0, center: startPoint, angle: angle)
            let (foundedPoint, myPoints) = createHelpLines(actPair.fromColumnRow, toPoint: toPoint, inFrame: self.frame, lineSize: spriteSize.width, showLines: false)
            if foundedPoint != nil {
                if foundedPoint!.foundContainer && actPair.toColumnRow.row == NoValue && foundedPoint!.column == actPair.toColumnRow.column ||
                    (foundedPoint!.column == actPair.toColumnRow.column && foundedPoint!.row == actPair.toColumnRow.row) {
                    if distanceToLine == firstValue ||
                    myPoints.count < myTipp.points.count ||
                    (myTipp.points.count == myPoints.count && foundedPoint!.distanceToP0 < distanceToLine) {
                        myTipp.fromColumn = actPair.fromColumnRow.column
                        myTipp.fromRow = actPair.fromColumnRow.row
                        myTipp.toColumn = actPair.toColumnRow.column
                        myTipp.toRow = actPair.toColumnRow.row
                        myTipp.points = myPoints
                        distanceToLine = foundedPoint!.distanceToP0
                        
                    }
                    if distanceToLine != firstValue && distanceToLine < foundedPoint!.distanceToP0 && myTipp.points.count == 2 {
                        founded = true
                    }
                }
            } else {
                print("in else zweig von checkPathToFoundedCards !")
            }
            angle += GV.oneGrad * multiplier
        }

        if distanceToLine != firstValue {
            
            for ind in 0..<myTipp.points.count - 1 {
                myTipp.lineLength += (myTipp.points[ind] - myTipp.points[ind + 1]).length()
            }
            tippArray.append(myTipp)
        }
     }
    
    
    func createHelpLines(movedFrom: ColumnRow, toPoint: CGPoint, inFrame: CGRect, lineSize: CGFloat, showLines: Bool)->(foundedPoint: Founded?, [CGPoint]) {
        var pointArray = [CGPoint]()
        var foundedPoint: Founded?
        var founded = false
        //        var myLine: SKShapeNode?
        let fromPosition = gameArray[movedFrom.column][movedFrom.row].position
        let line = JGXLine(fromPoint: fromPosition, toPoint: toPoint, inFrame: inFrame, lineSize: lineSize) //, delegate: self)
        let pointOnTheWall = line.line.toPoint
        pointArray.append(fromPosition)
        (founded, foundedPoint) = findEndPoint(movedFrom, fromPoint: fromPosition, toPoint: pointOnTheWall, lineWidth: lineSize, showLines: showLines)
        //        linesArray.append(myLine)
        //        if showLines {self.addChild(myLine)}
        if founded {
            pointArray.append(foundedPoint!.point)
        } else {
            pointArray.append(pointOnTheWall)
            let mirroredLine1 = line.createMirroredLine()
            (founded, foundedPoint) = findEndPoint(movedFrom, fromPoint: mirroredLine1.line.fromPoint, toPoint: mirroredLine1.line.toPoint, lineWidth: lineSize, showLines: showLines)
            
            //            linesArray.append(myLine)
            //            if showLines {self.addChild(myLine)}
            if founded {
                pointArray.append(foundedPoint!.point)
            } else {
                pointArray.append(mirroredLine1.line.toPoint)
                let mirroredLine2 = mirroredLine1.createMirroredLine()
                (founded, foundedPoint) = findEndPoint(movedFrom, fromPoint: mirroredLine2.line.fromPoint, toPoint: mirroredLine2.line.toPoint, lineWidth: lineSize, showLines: showLines)
                //                linesArray.append(myLine)
                //                if showLines {self.addChild(myLine)}
                if founded {
                    pointArray.append(foundedPoint!.point)
                } else {
                    pointArray.append(mirroredLine2.line.toPoint)
                    let mirroredLine3 = mirroredLine2.createMirroredLine()
                    (founded, foundedPoint) = findEndPoint(movedFrom, fromPoint: mirroredLine3.line.fromPoint, toPoint: mirroredLine3.line.toPoint, lineWidth: lineSize, showLines: showLines)
                    //                    linesArray.append(myLine)
                    //                    if showLines {self.addChild(myLine)}
                    if founded {
                        pointArray.append(foundedPoint!.point)
                    } else {
                        pointArray.append(mirroredLine3.line.toPoint)
                    }
                    
                }
            }
        }
        
        if showLines {
            let color = calculateLineColor(foundedPoint!, movedFrom:  movedFrom)
            drawHelpLines(pointArray, lineWidth: lineSize, twoArrows: false, color: color)
        }
        return (foundedPoint, pointArray)
    }
    
    func calculateLineColor(foundedPoint: Founded, movedFrom: ColumnRow) -> MyColors {
        
        var color = MyColors.Red
        var foundedColorIndex: Int
        var foundedMinValue: Int
        var foundedMaxValue: Int
        
        if foundedPoint.foundContainer {
            foundedColorIndex = containers[foundedPoint.column].colorIndex
            foundedMaxValue = containers[foundedPoint.column].maxValue
            foundedMinValue = containers[foundedPoint.column].minValue
        } else {
            foundedColorIndex = gameArray[foundedPoint.column][foundedPoint.row].colorIndex
            foundedMaxValue = gameArray[foundedPoint.column][foundedPoint.row].maxValue
            foundedMinValue = gameArray[foundedPoint.column][foundedPoint.row].minValue
        }
        if (gameArray[movedFrom.column][movedFrom.row].colorIndex == foundedColorIndex &&
            (gameArray[movedFrom.column][movedFrom.row].maxValue == foundedMinValue - 1 ||
                gameArray[movedFrom.column][movedFrom.row].minValue == foundedMaxValue + 1)) ||
            (foundedMinValue == NoColor && gameArray[movedFrom.column][movedFrom.row].maxValue == LastCardValue) {
                color = .Green
        }
        return color
    }
    
//    func findColumnRowDelegateFunc(fromPoint:CGPoint, toPoint:CGPoint)->FromToColumnRow {
//        let fromToColumnRow = FromToColumnRow()
//        return fromToColumnRow
//    }
    
    func findEndPoint(movedFrom: ColumnRow, fromPoint: CGPoint, toPoint: CGPoint, lineWidth: CGFloat, showLines: Bool)->(pointFounded:Bool, closestPoint: Founded?) {
        var foundedPoint = Founded()
        let toPoint = toPoint
        var pointFounded = false
//        var closestCardfast = Founded()
        if let closestCard = fastFindClosestPoint(fromPoint, P2: toPoint, lineWidth: lineWidth, movedFrom: movedFrom) {
            if showLines {
                makeTrembling(closestCard)
            }
           foundedPoint = closestCard
            pointFounded = true
        }
        return (pointFounded, foundedPoint)
    }
    
    func findClosestPoint(P1: CGPoint, P2: CGPoint, lineWidth: CGFloat, movedFrom: ColumnRow) -> Founded? {
        
        /*
        Ax+By=C  - Equation of a line
        Line is given with 2 Points (x1, y1) and (x2, y2)
        A = y2-y1
        B = x1-x2
        C = A*x1+B*y1
        */
        //let offset = P1 - P2
        var founded = Founded()
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if gameArray[column][row].used {
                    let P0 = gameArray[column][row].position
                    //                    if (P0 - P1).length() > lineWidth { // check all others but not me!!!
                    if !(movedFrom.column == column && movedFrom.row == row) {
                        let intersectionPoint = findIntersectionPoint(P1, b:P2, c:P0)
                        
                        let distanceToP0 = (intersectionPoint - P0).length()
                        let distanceToP1 = (intersectionPoint - P1).length()
                        let distanceToP2 = (intersectionPoint - P2).length()
                        let lengthOfLineSegment = (P1 - P2).length()
                        
                        if distanceToP0 < lineWidth && distanceToP2 < lengthOfLineSegment {
                            if founded.distanceToP1 > distanceToP1 {
                                founded.point = intersectionPoint
                                founded.distanceToP1 = distanceToP1
                                founded.distanceToP0 = distanceToP0
                                founded.column = column
                                founded.row = row
                                founded.foundContainer = false
                            }
                        }
                    }
                }
            }
        }
        
        for index in 0..<countContainers {
            let P0 = containers[index].position
            if (P0 - P1).length() > lineWidth { // check all others but not me!!!
                let intersectionPoint = findIntersectionPoint(P1, b:P2, c:P0)
                
                let distanceToP0 = (intersectionPoint - P0).length()
                let distanceToP1 = (intersectionPoint - P1).length()
                let distanceToP2 = (intersectionPoint - P2).length()
                let lengthOfLineSegment = (P1 - P2).length()
                
                if distanceToP0 < lineWidth && distanceToP2 < lengthOfLineSegment {
                    if founded.distanceToP1 > distanceToP1 {
                        founded.point = intersectionPoint
                        founded.distanceToP1 = distanceToP1
                        founded.distanceToP0 = distanceToP0
                        founded.column = index
                        founded.row = NoValue
                        founded.foundContainer = true
                    }
                }
            }
            
        }
        if founded.distanceToP1 != founded.maxDistance {
            return founded
        } else {
            return nil
        }
    }
    func fastFindClosestPoint(P1: CGPoint, P2: CGPoint, lineWidth: CGFloat, movedFrom: ColumnRow) -> Founded? {
        
        /*
        Ax+By=C  - Equation of a line
        Line is given with 2 Points (x1, y1) and (x2, y2)
        A = y2-y1
        B = x1-x2
        C = A*x1+B*y1
        */
        //let offset = P1 - P2
        
        var fromToColumnRowFirst = FromToColumnRow()
        var fromToColumnRow = FromToColumnRow()
        var fromWall = false
        
        fromToColumnRowFirst.fromColumnRow = calculateColumnRowFromPosition(P1)
        fromToColumnRowFirst.toColumnRow = calculateColumnRowFromPosition(P2)
        fromToColumnRow = calculateColumnRowWhenPointOnTheWall(fromToColumnRowFirst)
        
        fromWall = !(fromToColumnRowFirst == fromToColumnRow)
            
        var actColumnRow = fromToColumnRow.fromColumnRow
        var founded = Founded()
        var stopCycle = false
        while !stopCycle {
            if fromWall {
                (actColumnRow, stopCycle) = (actColumnRow, false)
                fromWall = false
            } else {
                (actColumnRow, stopCycle) = findNextPointToCheck(actColumnRow, fromToColumnRow: fromToColumnRow)
            }
            if gameArray[actColumnRow.column][actColumnRow.row].used {
                let P0 = gameArray[actColumnRow.column][actColumnRow.row].position
                //                    if (P0 - P1).length() > lineWidth { // check all others but not me!!!
                if !(movedFrom.column == actColumnRow.column && movedFrom.row == actColumnRow.row) {
                    let intersectionPoint = findIntersectionPoint(P1, b:P2, c:P0)
                    
                    let distanceToP0 = (intersectionPoint - P0).length()
                    let distanceToP1 = (intersectionPoint - P1).length()
                    let distanceToP2 = (intersectionPoint - P2).length()
                    let lengthOfLineSegment = (P1 - P2).length()
                    
                    if distanceToP0 < lineWidth && distanceToP2 < lengthOfLineSegment {
                        if founded.distanceToP1 > distanceToP1 {
                            founded.point = intersectionPoint
                            founded.distanceToP1 = distanceToP1
                            founded.distanceToP0 = distanceToP0
                            founded.column = actColumnRow.column
                            founded.row = actColumnRow.row
                            founded.foundContainer = false
                        }
                    }
                }
            }
        }
        for index in 0..<countContainers {
            let P0 = containers[index].position
            if (P0 - P1).length() > lineWidth { // check all others but not me!!!
                let intersectionPoint = findIntersectionPoint(P1, b:P2, c:P0)
                
                let distanceToP0 = (intersectionPoint - P0).length()
                let distanceToP1 = (intersectionPoint - P1).length()
                let distanceToP2 = (intersectionPoint - P2).length()
                let lengthOfLineSegment = (P1 - P2).length()
                
                if distanceToP0 < lineWidth && distanceToP2 < lengthOfLineSegment {
                    if founded.distanceToP1 > distanceToP1 {
                        founded.point = intersectionPoint
                        founded.distanceToP1 = distanceToP1
                        founded.distanceToP0 = distanceToP0
                        founded.column = index
                        founded.row = NoValue
                        founded.foundContainer = true
                    }
                }
            }
            
        }
        if founded.distanceToP1 != founded.maxDistance {
            return founded
        } else {
            return nil
        }
    }
    
    func calculateColumnRowWhenPointOnTheWall(fromToColumnRow: FromToColumnRow)->FromToColumnRow {
        var myFromToColumnRow = fromToColumnRow
        if fromToColumnRow.fromColumnRow.column <= NoValue {
           myFromToColumnRow.fromColumnRow.column = 0
        }
        if fromToColumnRow.fromColumnRow.row <= NoValue {
            myFromToColumnRow.fromColumnRow.row = 0
        }
        if fromToColumnRow.fromColumnRow.column >= countColumns {
            myFromToColumnRow.fromColumnRow.column = countColumns - 1
        }
        if fromToColumnRow.fromColumnRow.row >= countRows {
            myFromToColumnRow.fromColumnRow.row = countRows - 1
        }
        if fromToColumnRow.toColumnRow.column <= NoValue {
            myFromToColumnRow.toColumnRow.column = 0
        }
        if fromToColumnRow.toColumnRow.row <= NoValue {
            myFromToColumnRow.toColumnRow.row = 0
        }
        if fromToColumnRow.toColumnRow.column >= countColumns {
            myFromToColumnRow.toColumnRow.column = countColumns - 1
        }
        if fromToColumnRow.toColumnRow.row >= countRows {
            myFromToColumnRow.toColumnRow.row = countRows - 1
        }
        
        return myFromToColumnRow
    }
    
    func findNextPointToCheck(actColumnRow: ColumnRow, fromToColumnRow: FromToColumnRow)->(ColumnRow, Bool) {

        var myActColumnRow = actColumnRow
        let columnAdder = fromToColumnRow.fromColumnRow.column < fromToColumnRow.toColumnRow.column ? 1 : -1
        let rowAdder = fromToColumnRow.fromColumnRow.row < fromToColumnRow.toColumnRow.row ? 1 : -1
        
        if myActColumnRow.column != fromToColumnRow.toColumnRow.column {
            myActColumnRow.column += columnAdder
        } else {
            myActColumnRow.column = fromToColumnRow.fromColumnRow.column
            if myActColumnRow.row != fromToColumnRow.toColumnRow.row {
                myActColumnRow.row += rowAdder
            }
        }
            

        if myActColumnRow == fromToColumnRow.toColumnRow {
            return (myActColumnRow, true) // toPoint reached
        }
        return (myActColumnRow, false)
    }
    
    func findIntersectionPoint(a:CGPoint, b:CGPoint, c:CGPoint) ->CGPoint {
        let x1 = a.x
        let y1 = a.y
        let x2 = b.x
        let y2 = b.y
        let x3 = c.x
        let y3 = c.y
        let px = x2-x1
        let py = y2-y1
        let dAB = px * px + py * py
        let u = ((x3 - x1) * px + (y3 - y1) * py) / dAB
        let x = x1 + u * px
        let y = y1 + u * py
        return CGPointMake(x, y)
    }
    
    
    

    
    func drawHelpLines(points: [CGPoint], lineWidth: CGFloat, twoArrows: Bool, color: MyColors) {
        lastDrawHelpLinesParameters.points = points
        lastDrawHelpLinesParameters.lineWidth = lineWidth
        lastDrawHelpLinesParameters.twoArrows = twoArrows
        lastDrawHelpLinesParameters.color = color
        drawHelpLinesSpec()
    }
    
    func drawHelpLinesSpec() {
        let points = lastDrawHelpLinesParameters.points
        let lineWidth = lastDrawHelpLinesParameters.lineWidth
        let twoArrows = lastDrawHelpLinesParameters.twoArrows
        let color = lastDrawHelpLinesParameters.color
    
        let pathToDraw:CGMutablePathRef = CGPathCreateMutable()
        let myLine:SKShapeNode = SKShapeNode(path:pathToDraw)
        removeNodesWithName(myLineName)
        myLine.lineWidth = lineWidth * lineWidthMultiplier!
        myLine.name = myLineName
        
        // check if valid data
        for index in 0..<points.count {
            if points[index].x.isNaN || points[index].y.isNaN {
                print("isNan")
                return
            }
        }
        
        CGPathMoveToPoint(pathToDraw, nil, points[0].x, points[0].y)
        for index in 1..<points.count {
            CGPathAddLineToPoint(pathToDraw, nil, points[index].x, points[index].y)
        }
        
        let lastButOneIndex = points.count - 2
        
        let offset = points.last! - points[lastButOneIndex]
        var angleR:CGFloat = 0.0
        
        if offset.x > 0 {
            angleR = asin(offset.y / offset.length())
        } else {
            if offset.y > 0 {
                angleR = acos(offset.x / offset.length())
            } else {
                angleR = -acos(offset.x / offset.length())
                
            }
        }
        
        let p1 = GV.pointOfCircle(20.0, center: points.last!, angle: angleR - (150 * GV.oneGrad))
        let p2 = GV.pointOfCircle(20.0, center: points.last!, angle: angleR + (150 * GV.oneGrad))
        
        
        
        CGPathAddLineToPoint(pathToDraw, nil, p1.x, p1.y)
        CGPathMoveToPoint(pathToDraw, nil, points.last!.x, points.last!.y)
        CGPathAddLineToPoint(pathToDraw, nil, p2.x, p2.y)
        
        
        if twoArrows {
            let offset = points.first! - points[1]
            var angleR:CGFloat = 0.0
            
            if offset.x > 0 {
                angleR = asin(offset.y / offset.length())
            } else {
                if offset.y > 0 {
                    angleR = acos(offset.x / offset.length())
                } else {
                    angleR = -acos(offset.x / offset.length())
                    
                }
            }
            
            let p1 = GV.pointOfCircle(20.0, center: points.first!, angle: angleR - (150 * GV.oneGrad))
            let p2 = GV.pointOfCircle(20.0, center: points.first!, angle: angleR + (150 * GV.oneGrad))
            
            
            CGPathMoveToPoint(pathToDraw, nil, points[0].x, points[0].y)
            CGPathAddLineToPoint(pathToDraw, nil, p1.x, p1.y)
            CGPathMoveToPoint(pathToDraw, nil, points[0].x, points[0].y)
            CGPathAddLineToPoint(pathToDraw, nil, p2.x, p2.y)
            
        }
        
        myLine.path = pathToDraw
        
        if color == .Red {
            myLine.strokeColor = SKColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.8) // GV.colorSets[GV.colorSetIndex][colorIndex + 1]
        } else {
            myLine.strokeColor = SKColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.8) // GV.colorSets[GV.colorSetIndex][colorIndex + 1]
        }
        myLine.zPosition = 100
        myLine.lineCap = .Round
        
        self.addChild(myLine)
        
    }
    
    func makeTrembling(nextPoint: Founded) {
        var tremblingCardPosition = CGPointZero
        if lastNextPoint != nil && ((lastNextPoint!.column != nextPoint.column) ||  (lastNextPoint!.row != nextPoint.row)) {
            if lastNextPoint!.foundContainer {
                tremblingCardPosition = containers[lastNextPoint!.column].position
            } else {
                tremblingCardPosition = gameArray[lastNextPoint!.column][lastNextPoint!.row].position
            }
            let nodes = nodesAtPoint(tremblingCardPosition)
            
            for index in 0..<nodes.count {
                if nodes[index] is MySKNode {
                    (nodes[index] as! MySKNode).tremblingType = .NoTrembling

                    tremblingSprites.removeAll()
                }
            }
            lastNextPoint = nil
        }

//        stopTrembling()
        if lastNextPoint == nil {
            if nextPoint.foundContainer {
                tremblingCardPosition = containers[nextPoint.column].position
            } else {
                tremblingCardPosition = gameArray[nextPoint.column][nextPoint.row].position
            }
            addSpriteToTremblingSprites(tremblingCardPosition)
            lastNextPoint = nextPoint
        }
        
    }
    
    func addSpriteToTremblingSprites(position: CGPoint) {
        let nodes = nodesAtPoint(position)
        for index in 0..<nodes.count {
            if nodes[index] is MySKNode {
                tremblingSprites.append(nodes[index] as! MySKNode)
                (nodes[index] as! MySKNode).tremblingType = .ChangeSize
            }
        }
        
    }
    
    func calculateAngle(point1: CGPoint, point2: CGPoint) -> (angleRadian:CGFloat, angleDegree: CGFloat) {
        //        let pointOfCircle = CGPoint (x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
        let offset = point2 - point1
        let length = offset.length()
        let sinAlpha = offset.y / length
        let angleRadian = asin(sinAlpha);
        let angleDegree = angleRadian * 180.0 / CGFloat(M_PI)
        return (angleRadian, angleDegree)
    }

//    func pointOfCircle(radius: CGFloat, center: CGPoint, angle: CGFloat) -> CGPoint {
//        let pointOfCircle = CGPoint (x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
//        return pointOfCircle
//    }


    override func update(currentTime: NSTimeInterval) {
        let sec10: Int = Int(currentTime * 10) % 3
        if sec10 != lastUpdateSec && sec10 == 0 {
            let adder:CGFloat = 5
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
                    case .ChangeSizeOnce:
                        if aktSprite.size == aktSprite.origSize {
                            aktSprite.size.width += adder
                            aktSprite.size.height += adder
                        }
                }
            }

        }
        lastUpdateSec = sec10
    }
    
    func spriteDidCollideWithContainer(node1:MySKNode, node2:MyContainer) {
        let movingSprite = node1
        let container = node2
        
        var containerColorIndex = container.colorIndex
        let movingSpriteColorIndex = movingSprite.colorIndex
        
        
        if container.minValue == container.maxValue && container.maxValue == NoColor && movingSprite.maxValue == LastCardValue {
            var containerNotFound = true
            for index in 0..<countContainers {
                if containers[index].colorIndex == movingSpriteColorIndex {
                    containerNotFound = false
                }
            }
            if containerNotFound {
                containerColorIndex = movingSpriteColorIndex
                container.colorIndex = containerColorIndex
                container.texture = getTexture(containerColorIndex)
                push(container, status: .FirstCardAdded)
            }
        }
        
        let OK = movingSpriteColorIndex == containerColorIndex &&
        (
            container.minValue == NoColor ||
            movingSprite.maxValue + 1 == container.minValue ||
            movingSprite.minValue - 1 == container.maxValue ||
            (container.maxValue == LastCardValue && container.minValue == FirstCardValue && movingSprite.maxValue == LastCardValue)         )

        
        
        if OK  {
            push(container, status: .HitcounterChanged)
            push(movingSprite, status: .Removed)
            let adder = movingSprite.maxValue * (movingSprite.maxValue - movingSprite.minValue + 1)
            if container.maxValue < movingSprite.minValue {
                container.maxValue = movingSprite.maxValue
            } else {
                container.minValue = movingSprite.minValue
                if container.maxValue == NoColor {
                    container.maxValue = movingSprite.maxValue
                }
            }
            container.countScore += adder
            container.reload()
            //gameArray[movingSprite.column][movingSprite.row] = false
            resetGameArrayCell(movingSprite)
            movingSprite.removeFromParent()
            playSound("Container", volume: GV.player!.soundVolume)
            countMovingSprites = 0
            
            updateSpriteCount(-1)
            
            collisionActive = false
            //movingSprite.removeFromParent()
            checkGameFinished()
        } else {
            updateSpriteCount(-1)
            movingSprite.removeFromParent()
            countMovingSprites = 0
            push(movingSprite, status: .Removed)
            pull(false) // no createTipps
            startTippTimer()
            tippsButton!.activateButton(true)

        }
        
     }
    
    func resetGameArrayCell(sprite:MySKNode) {
        gameArray[sprite.column][sprite.row].used = false
        gameArray[sprite.column][sprite.row].colorIndex = NoColor
        gameArray[sprite.column][sprite.row].minValue = NoValue
        gameArray[sprite.column][sprite.row].maxValue = NoValue
    }
    
    func updateGameArrayCell(sprite:MySKNode) {
        gameArray[sprite.column][sprite.row].used = true
        gameArray[sprite.column][sprite.row].name = sprite.name!
        gameArray[sprite.column][sprite.row].colorIndex = sprite.colorIndex
        gameArray[sprite.column][sprite.row].minValue = sprite.minValue
        gameArray[sprite.column][sprite.row].maxValue = sprite.maxValue
    }

    func spriteDidCollideWithMovingSprite(node1:MySKNode, node2:MySKNode) {
//        let collisionsTime = NSDate()
//        let timeInterval: Double = collisionsTime.timeIntervalSinceDate(lastCollisionsTime); // <<<<< Difference in seconds (double)
//
//        if timeInterval < 1 {
//            return
//        }
//        lastCollisionsTime = collisionsTime
        let movingSprite = node1
        let sprite = node2
        let movingSpriteColorIndex = movingSprite.colorIndex
        let spriteColorIndex = sprite.colorIndex
        
        //let aktColor = GV.colorSets[GV.colorSetIndex][sprite.colorIndex + 1].CGColor
        collisionActive = false
        
        let OK = movingSpriteColorIndex == spriteColorIndex &&
        (
            movingSprite.maxValue + 1 == sprite.minValue ||
            movingSprite.minValue - 1 == sprite.maxValue //||
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
            
            playSound("OK", volume: GV.player!.soundVolume)
        
            updateGameArrayCell(sprite)
            resetGameArrayCell(movingSprite)
            
            movingSprite.removeFromParent()
            countMovingSprites = 0
            updateSpriteCount(-1)
            checkGameFinished()
       } else {

            updateSpriteCount(-1)
            movingSprite.removeFromParent()
            countMovingSprites = 0
            push(movingSprite, status: .Removed)
            pull(false) // no createTipps
            startTippTimer()
            tippsButton!.activateButton(true)
            
        }
    }

    func checkGameFinished() {
        
        
        let usedCellCount = checkGameArray()
        let containersOK = checkContainers()
        
        if usedCellCount <= 1 && containersOK { // Level completed, start a new game
            
            stopTimer(&countUp)
            playMusic("Winner", volume: GV.player!.musicVolume, loops: 0)
            
            GV.realm.beginWrite()
            
            if GV.realm.objects(StatisticModel).filter("playerID = %d AND levelID = %d", GV.player!.ID, GV.player!.levelID).count == 0 {
                GV.statistic = StatisticModel()
                GV.statistic!.ID = GV.getNewStatisticID()
                GV.statistic!.playerID = GV.player!.ID
                GV.statistic!.levelID = GV.player!.levelID
            } else {
                GV.statistic = GV.realm.objects(StatisticModel).filter("playerID = %d AND levelID = %d", GV.player!.ID, GV.player!.levelID).first!
            }
            
            GV.statistic = GV.realm.objects(StatisticModel).filter("playerID = %d AND levelID = %d", GV.player!.ID, GV.player!.levelID).first
            let actGame = GV.realm.objects(GameModel).filter("ID = %d", gameNumber).first
            
            GV.statistic!.countPlays += 1
            GV.statistic!.actTime = timeCount
            GV.statistic!.allTime += timeCount
            
            if GV.statistic!.bestTime == 0 || timeCount < GV.statistic!.bestTime {
                GV.statistic!.bestTime = timeCount
            }
            if  actGame!.bestTime == 0 || timeCount < actGame!.bestTime {
                actGame!.bestTime = timeCount
            }
            
            var actScore: Int = 0
            for index in 0..<containers.count {
                actScore += containers[index].countScore
            }
            actScore *= 10000
            actScore /= (5000 + timeCount)
            
//            GV.gameStatistics.actScore = actScore
//            GV.gameStatistics.levelScore += actScore
            
            GV.statistic!.actScore = actScore
            GV.statistic!.levelScore += actScore
            if GV.statistic!.bestScore < actScore {
               GV.statistic!.bestScore = actScore
            }
           
            if GV.statistic!.bestScore < actScore {
                GV.statistic!.bestScore = actScore
            }
            if actGame!.bestScore < actScore {
                actGame!.bestScore = actScore
            }
            
            GV.realm.add(GV.statistic!, update: true)
            GV.realm.add(actGame!, update: true)
            
            try! GV.realm.commitWrite()
            let alert = getNextPlayArt(true)
            parentViewController!.presentViewController(alert, animated: true, completion: nil)
        } else if usedCellCount <= minUsedCells && usedCellCount > 1 { //  && spriteCount > maxUsedCells {
            generateSprites(.Normal)  // Nachgenerierung
        } else {
            if spriteCount > 0 && cardStack.count(.MySKNodeType) > 0 {
                gameArrayChanged = true
            }
        }
    }
    
    func restartButtonPressed() {
        let alert = getNextPlayArt(false)
        parentViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    func newGame(next: Bool) {
        stopped = true
        if next {
            
            
            lastNextPoint = nil
        }
        stopCreateTippsInBackground = true
        for _ in 0..<self.children.count {
            let childNode = children[self.children.count - 1]
            childNode.removeFromParent()
        }
        
        stopTimer(&countUp)
//        print("stopCreateTippsInBackground from newGame")
//
        prepareNextGame(next)
        generateSprites(.First)
    }

    
    func getNextPlayArt(congratulations: Bool)->UIAlertController {
        let playerName = GV.player!.name + "!"
        var statisticsTxt = ""
        var congratulationsTxt = ""
        if congratulations {
            
            statisticsTxt += "\r\n" + GV.language.getText(.TCCountPlaysForLevel, values: String(GV.statistic!.countPlays))
            statisticsTxt += "\r\n" + GV.language.getText(.TCActScore) + String(GV.statistic!.actScore)
            statisticsTxt += "\r\n" + GV.language.getText(.TCBestScore) + ": " + String(GV.statistic!.bestScore)
            statisticsTxt += "\r\n" + GV.language.getText(.TCActTime) + String(GV.statistic!.actTime.dayHourMinSec)
            statisticsTxt += "\r\n" + GV.language.getText(.TCAllTimeForLevel) + String(GV.statistic!.allTime.dayHourMinSec)
            statisticsTxt += "\r\n" + GV.language.getText(.TCBestTimeForLevel) + String(GV.statistic!.bestTime.dayHourMinSec)
            
            if GV.statistic!.bestScore == GV.statistic!.actScore {
                congratulationsTxt = GV.language.getText(.TCGameCompleteWithBestScore, values: String(levelIndex + 1))
                
            } else if GV.statistic!.bestTime == GV.statistic!.actTime {
                congratulationsTxt = GV.language.getText(.TCGameCompleteWithBestTime, values: String(levelIndex + 1))
            } else {
                congratulationsTxt = GV.language.getText(.TCGameComplete)
            }
            congratulationsTxt += "\r\n" + GV.language.getText(TextConstants.TCCongratulations) + playerName
            congratulationsTxt += "\r\n\r\n" + GV.language.getText(.TCStatistics, values: String(levelIndex + 1))
            congratulationsTxt += "\r\n === === ==="

        }
        let alert = UIAlertController(title: congratulations ? congratulationsTxt : GV.language.getText(.TCChooseGame),
            message: statisticsTxt,
            preferredStyle: .Alert)
        let againAction = UIAlertAction(title: GV.language.getText(.TCGameAgain), style: .Default,
            handler: {(paramAction:UIAlertAction!) in
                self.newGame(false)
        })
        alert.addAction(againAction)
        let newGameAction = UIAlertAction(title: GV.language.getText(TextConstants.TCNewGame), style: .Default,
            handler: {(paramAction:UIAlertAction!) in
                self.newGame(true)
                //self.gameArrayChanged = true

        })
        alert.addAction(newGameAction)
        if levelIndex > 0 {
            let easierAction = UIAlertAction(title: GV.language.getText(.TCPreviousLevel), style: .Default,
                handler: {(paramAction:UIAlertAction!) in
                    print("newGame from set Previous Level")
                    self.setLevel(self.previousLevel)
                    self.newGame(true)
            })
            alert.addAction(easierAction)
        }
        if levelIndex < GV.levelsForPlay.levelParam.count - 1 {
            let complexerAction = UIAlertAction(title: GV.language.getText(TextConstants.TCNextLevel), style: .Default,
                handler: {(paramAction:UIAlertAction!) in
                    print("newGame from set Next Level")
                    self.setLevel(self.nextLevel)
                    self.newGame(true)
            })
            alert.addAction(complexerAction)
        }
        if !congratulations {
            let cancelAction = UIAlertAction(title: GV.language.getText(TextConstants.TCCancel), style: .Default,
                handler: {(paramAction:UIAlertAction!) in
//                    self.setLevel(self.nextLevel)
//                    self.newGame(true)
                    self.startTimer(&self.showTippAtTimer, sleepTime: self.showTippSleepTime, selector: self.showTippSelector, repeats: true)
            })
            alert.addAction(cancelAction)
        }
        return alert
    }
    
    func setLevel(next: Bool) {
        if next {
            levelIndex = GV.levelsForPlay.getNextLevel()
        } else {
            levelIndex = GV.levelsForPlay.getPrevLevel()
        }
        try! GV.realm.write({
            GV.player!.levelID = levelIndex
            GV.realm.add(GV.player!, update: true)
        })
        if GV.realm.objects(StatisticModel).filter("playerID = %d AND levelID = %d", GV.player!.ID, GV.player!.levelID).count == 0 {
            GV.statistic = StatisticModel()
            GV.statistic!.ID = GV.realm.objects(StatisticModel).count
            GV.statistic!.playerID = GV.player!.ID
            GV.statistic!.levelID = GV.player!.levelID
            try! GV.realm.write({
               GV.realm.add(GV.statistic!)
            })
        }
    }

    func checkContainers()->Bool {
        for index in 0..<containers.count {
            if containers[index].minValue != FirstCardValue || containers[index].maxValue % MaxCardValue != LastCardValue {
                return false
            }
            
        }
        return true

    }
    
    func prepareContainers() {
       
        colorTab.removeAll(keepCapacity: false)
        var spriteName = 10000
        
        for cardIndex in 0..<countSpritesProContainer! * countPackages {
            for containerIndex in 0..<countContainers {
                let colorTabLine = ColorTabLine(colorIndex: containerIndex, spriteName: "\(spriteName)",
                    spriteValue: cardArray[containerIndex][cardIndex % MaxCardValue].cardValue) //generateValue(containerIndex) - 1)
                colorTab.append(colorTabLine)
                spriteName += 1
            }
        }
        
        createSpriteStack()
        fillEmptySprites()

        
        let xDelta = size.width / CGFloat(countContainers)
        for index in 0..<countContainers {
            let centerX = (size.width / CGFloat(countContainers)) * CGFloat(index) + xDelta / 2
            let centerY = size.height * containersPosCorr.y
            containers.append(MyContainer(texture: getTexture(NoColor)))
            containers[index].name = "\(index)"
            containers[index].position = CGPoint(x: centerX, y: centerY)
            containers[index].size = CGSizeMake(containerSize.width, containerSize.height)
//            containers[index].size.width = containerSize.width
//            containers[index].size.height = containerSize.height
            
            containers[index].colorIndex = NoValue
            containers[index].physicsBody = SKPhysicsBody(circleOfRadius: containers[index].size.width / 3) // 1
            containers[index].physicsBody?.dynamic = true // 2
            containers[index].physicsBody?.categoryBitMask = PhysicsCategory.Container
            containers[index].physicsBody?.contactTestBitMask = PhysicsCategory.MovingSprite
            containers[index].physicsBody?.collisionBitMask = PhysicsCategory.None
            countColorsProContainer.append(countSpritesProContainer!)
            addChild(containers[index])
            containers[index].reload()
        }
    }
    
    


    func pull(createTipps: Bool) {
        let duration = 0.2
        var actionMoveArray = [SKAction]()
        if let savedSprite:SavedSprite  = stack.pull() {
            var savedSpriteInCycle = savedSprite
            var run = true
            var stopSoon = false
            
            repeat {
                
                switch savedSpriteInCycle.status {
                case .Added: break
                case .AddedFromCardStack:
                    if stack.countChangesInStack() > 0 {
                        let spriteName = savedSpriteInCycle.name
//                        let colorIndex = savedSpriteInCycle.colorIndex
                        let searchName = "\(spriteName)"
                        let cardToPush = self.childNodeWithName(searchName)! as! MySKNode
                        cardToPush.zPosition = 20
                        cardStack.push(cardToPush)
                        
//                        let colorTabLine = ColorTabLine(colorIndex: colorIndex, spriteName: spriteName, spriteValue: savedSpriteInCycle.minValue)
//                        colorTab.append(colorTabLine)
                        gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row].used = false
                        makeEmptyCard(savedSpriteInCycle.column, row: savedSpriteInCycle.row)
                        let aktPosition = gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row].position
                        let duration = Double((cardPackage!.position - aktPosition).length()) / 500.0
                        let actionMove = SKAction.moveTo(cardPackage!.position, duration: duration)
                        let removeOldCard = SKAction.runBlock({
                            self.childNodeWithName(searchName)!.removeFromParent()
                        })
                        cardToPush.runAction(SKAction.sequence([actionMove, removeOldCard]))
                    }
                case .AddedFromShowCard:
                    if cardPlaceButtonAddedToParent {
                        cardPlaceButton?.removeFromParent()
                        cardPlaceButtonAddedToParent = false
                    }
                    let oldShowCardExists = showCard != nil
                    var removeOldShowCard = SKAction()
                    if oldShowCardExists {
                        var oldShowCard = showCard
                        showCardStack.push(showCard!)
                        removeOldShowCard = SKAction.runBlock({
                            oldShowCard!.removeFromParent()
                            oldShowCard = nil
                        })
                    }
                    let spriteName = savedSpriteInCycle.name
                    let searchName = "\(spriteName)"
                    showCard = self.childNodeWithName(searchName)! as? MySKNode
                    showCard!.position = savedSpriteInCycle.endPosition //(cardPlaceButton?.position)!
                    showCard!.size = (cardPlaceButton?.size)!
                    showCard!.type = .ShowCardType
                    self.childNodeWithName(searchName)!.removeFromParent()
                    self.addChild(showCard!)
                    gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row].used = false
                    makeEmptyCard(savedSpriteInCycle.column, row: savedSpriteInCycle.row)
                    let actionMove = SKAction.moveTo(cardPlaceButton!.position, duration: 0.5)
                    if oldShowCardExists {
                        showCard!.runAction(SKAction.sequence([actionMove, removeOldShowCard]))
                    } else {
                        showCard!.runAction(actionMove)
                    }
                case .Removed:
                    //let spriteTexture = SKTexture(imageNamed: "sprite\(savedSpriteInCycle.colorIndex)")
                    let spriteTexture = getTexture(savedSpriteInCycle.colorIndex)
                    let type = savedSpriteInCycle.type
                    let sprite = MySKNode(texture: spriteTexture, type: type, value: savedSpriteInCycle.minValue) //NoValue)
                    
                    
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
 
                    updateGameArrayCell(sprite)
//                    gameArray[sprite.column][sprite.row].colorIndex = sprite.colorIndex
//                    gameArray[sprite.column][sprite.row].minValue = sprite.minValue
//                    gameArray[sprite.column][sprite.row].maxValue = sprite.maxValue
                    
//                    gameArray[sprite.column][sprite.row].used = true
//                    addPhysicsBody(sprite)
                    self.addChild(sprite)
                    updateSpriteCount(1)
                    sprite.reload()
                    
                case .Unification:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.size = savedSpriteInCycle.size
                    sprite.minValue = savedSpriteInCycle.minValue
                    sprite.maxValue = savedSpriteInCycle.maxValue
                    sprite.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    updateGameArrayCell(sprite)
                    //sprite.hitLabel.text = "\(sprite.hitCounter)"
                    sprite.reload()
                    
                case .HitcounterChanged:
                    
                    let container = containers[findIndex(savedSpriteInCycle.colorIndex)]
                    container.minValue = savedSpriteInCycle.minValue
                    container.maxValue = savedSpriteInCycle.maxValue
                    container.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    container.reload()
                    showScore()
                    
                case .FirstCardAdded:
                    let container = containers[findIndex(savedSpriteInCycle.colorIndex)]
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

                    updateGameArrayCell(sprite)
//                    gameArray[sprite.column][sprite.row].colorIndex = sprite.colorIndex
//                    gameArray[sprite.column][sprite.row].minValue = sprite.minValue
//                    gameArray[sprite.column][sprite.row].maxValue = sprite.maxValue
//                    
                    sprite.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                    actionMoveArray.append(SKAction.runBlock({
                    self.removeNodesWithName("\(self.emptySpriteTxt)-\(sprite.column)-\(sprite.row)")
//                        if self.childNodeWithName("\(self.emptySpriteTxt)-\(sprite.column)-\(sprite.row)") != nil {
//                            self.childNodeWithName("\(self.emptySpriteTxt)-\(sprite.column)-\(sprite.row)")!.removeFromParent()
//                        }
                    }))
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
                    let savedSprite:SavedSprite = stack.pull()!
                    let sprite1 = self.childNodeWithName(savedSprite.name) as! MySKNode
                    
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    sprite.minValue = savedSpriteInCycle.minValue
                    sprite.maxValue = savedSpriteInCycle.maxValue
                    sprite.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    
                    sprite1.startPosition = savedSprite.startPosition
                    sprite1.minValue = savedSprite.minValue
                    sprite1.maxValue = savedSprite.maxValue
                    sprite1.BGPictureAdded = savedSprite.BGPictureAdded

                    let action = SKAction.moveTo(sprite.startPosition, duration: 1.0)
                    let action1 = SKAction.moveTo(sprite1.startPosition, duration: 1.0)

                    gameArray[sprite.column][sprite.row].colorIndex = sprite.colorIndex
                    gameArray[sprite.column][sprite.row].minValue = sprite.minValue
                    gameArray[sprite.column][sprite.row].maxValue = sprite.maxValue
                    
                    gameArray[sprite1.column][sprite1.row].colorIndex = sprite1.colorIndex
                    gameArray[sprite1.column][sprite1.row].minValue = sprite1.minValue
                    gameArray[sprite1.column][sprite1.row].maxValue = sprite1.maxValue
                    
                    sprite.runAction(SKAction.sequence([action]))
                    sprite1.runAction(SKAction.sequence([action1]))
                    
                    sprite.reload()
                    sprite1.reload()
                    savedSpriteInCycle = savedSprite
                    stopSoon = true
                case .StopCycle: break
                case .Nothing: break
                }
                if let savedSprite:SavedSprite = stack.pull() {
                    savedSpriteInCycle = savedSprite
                    if ((savedSpriteInCycle.status == .AddedFromCardStack || savedSpriteInCycle.status == .AddedFromShowCard) && stack.countChangesInStack() == 0) || stopSoon  || savedSpriteInCycle.status == .StopCycle {
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
        
        if createTipps {
            gameArrayChanged = true
        }

    }
    
    func findIndex(colorIndex: Int)->Int {
        for index in 0..<countContainers {
            if containers[index].colorIndex == colorIndex {
                return index
            }
        }
        return NoColor
    }
    
    func readNextLevel() -> Int {
        return GV.levelsForPlay.getNextLevel()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        //        if inFirstGenerateSprites {
        //            return
        //        }
        //let countTouches = touches.count
        lineWidthMultiplier = lineWidthMultiplierNormal
        
        stopTimer(&showTippAtTimer)
        oldFromToColumnRow = FromToColumnRow()
        lastGreenPair = nil
        lastRedPair = nil
        touchesBeganAt = NSDate()
        let firstTouch = touches.first
        let touchLocation = firstTouch!.locationInNode(self)
        
//        let testNode = self.nodeAtPoint(touchLocation)
        movedFromNode = nil
        let nodes = nodesAtPoint(touchLocation)
        for nodesIndex in 0..<nodes.count {
            switch nodes[nodesIndex]  {
                case is MySKButton:
                    movedFromNode = (nodes[nodesIndex] as! MySKButton) as MySKNode
                    break
                case is MySKNode:
                    if (nodes[nodesIndex] as! MySKNode).type == .SpriteType ||
                       (nodes[nodesIndex] as! MySKNode).type == .ShowCardType ||
                       (nodes[nodesIndex] as! MySKNode).type == .EmptyCardType
                    {
                        movedFromNode = (nodes[nodesIndex] as! MySKNode)
                        if showFingerNode {
                            let fingerNode = SKSpriteNode(imageNamed: "finger.png")
                            fingerNode.name = "finger"
                            fingerNode.position = touchLocation
                            fingerNode.size = CGSizeMake(25,25)
                            fingerNode.zPosition = 50
                            addChild(fingerNode)
                        }
                    }
                    break
                default:
                    dummy = 0
            }
        }
        
        
        if movedFromNode != nil {
            movedFromNode.zPosition = 50
        }
        
        if tremblingSprites.count > 0 {
            stopTrembling()
            removeNodesWithName(myLineName)
        }
    }
    

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //        if inFirstGenerateSprites {
        //            return
        //        }
        if movedFromNode != nil {
            removeNodesWithName(myLineName)

            //let countTouches = touches.count
            let firstTouch = touches.first
            let touchLocation = firstTouch!.locationInNode(self)
            
            var aktNode: SKNode? = movedFromNode
            
            let testNode = self.nodeAtPoint(touchLocation)
            let aktNodeType = analyzeNode(testNode)
//            var myLine: SKShapeNode = SKShapeNode()
            switch aktNodeType {
                case MyNodeTypes.LabelNode: aktNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
                case MyNodeTypes.SpriteNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
                case MyNodeTypes.ButtonNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
                default: aktNode = nil
            }
            if movedFromNode.type == .ShowCardType {
                movedFromNode.position = touchLocation
                if showCardStack.count(.MySKNodeType) > 0 {
                    if !showCardFromStackAddedToParent {
                        showCardFromStackAddedToParent = true
                        showCardFromStack = showCardStack.last()
                        showCardFromStack!.position = cardPlaceButton!.position
                        showCardFromStack!.size = cardPlaceButton!.size
                        addChild(showCardFromStack!)
                    }
                } else if !cardPlaceButtonAddedToParent {
                    cardPlaceButtonAddedToParent = true
                    addChild(cardPlaceButton!)
                }
            }  else if movedFromNode == aktNode && tremblingSprites.count > 0 { // stop trembling
                
                stopTrembling()
                lastNextPoint = nil
            } else if movedFromNode != aktNode && !exchangeModus {
                if movedFromNode.type == .ButtonType {
                    //movedFromNode.texture = atlas.textureNamed("\(movedFromNode.name!)")
                } else if movedFromNode.type == .EmptyCardType {
                    
                } else {
                    var movedFrom = ColumnRow()
                    movedFrom.column = movedFromNode.column
                    movedFrom.row = movedFromNode.row
                    
                    let (foundedPoint, myPoints) = createHelpLines(movedFrom, toPoint: touchLocation, inFrame: self.frame, lineSize: movedFromNode.size.width, showLines: true)
                    var actFromToColumnRow = FromToColumnRow()
                    actFromToColumnRow.fromColumnRow = movedFrom
                    actFromToColumnRow.toColumnRow.column = foundedPoint!.column
                    actFromToColumnRow.toColumnRow.row = foundedPoint!.row
                    let color = calculateLineColor(foundedPoint!, movedFrom: movedFrom)
                    switch color {
                    case .Green:
                        if lastGreenPair == nil || lastGreenPair!.pair !=  actFromToColumnRow || lastRedPair != nil {
                            lineWidthMultiplier = lineWidthMultiplierNormal
                            drawHelpLinesSpec()
                            lastGreenPair = PairStatus(pair: actFromToColumnRow, founded: foundedPoint!, startTime: NSDate(), points: myPoints)
                            lastRedPair = nil
                            greenLineTimer = startTimer(&greenLineTimer, sleepTime: 0.5, selector: checkGreenLineSelector, repeats: false) // set linewidth on Special after 0.5 second
                        } else {
                            lastGreenPair!.points = myPoints
                        }
                    case .Red:
                        lineWidthMultiplier = lineWidthMultiplierNormal
                        drawHelpLinesSpec()
                        if lastGreenPair != nil {
                            if !lastGreenPair!.fixed {
                                stopTimer(&greenLineTimer)
                            }
                            if lastGreenPair!.duration == 0 { // first time Red
                                lastGreenPair!.setEndDuration() // get duration of Green
                                lastRedPair = PairStatus(pair: actFromToColumnRow, founded: foundedPoint!, startTime: NSDate(), points: myPoints)
//                            } else if lastRedPair!.pair != actFromToColumnRow {
//                                lastRedPair = nil
//                                lastGreenPair = nil
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
    
    func setGreenLineSize() {
//        print("setGreenLineSize")
        lineWidthMultiplier = lineWidthMultiplierSpecial
        drawHelpLinesSpec()
        lastGreenPair!.fixed = true
        
        stopTimer(&greenLineTimer)
    }

    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        lineWidthMultiplier = lineWidthMultiplierNormal
        stopTimer(&greenLineTimer)
        stopTrembling()
        let firstTouch = touches.first
        let touchLocation = firstTouch!.locationInNode(self)
        
        removeNodesWithName(myLineName)
        let testNode = self.nodeAtPoint(touchLocation)
        
        let aktNodeType = analyzeNode(testNode)
        if movedFromNode != nil && !stopped {
            //let countTouches = touches.count
            var aktNode: MySKNode?
            
            movedFromNode.zPosition = 0
            let startNode = movedFromNode
            
            switch aktNodeType {
            case MyNodeTypes.LabelNode: aktNode = self.nodeAtPoint(touchLocation).parent as? MySKNode
            case MyNodeTypes.SpriteNode: aktNode = self.nodeAtPoint(touchLocation) as? MySKNode
            case MyNodeTypes.ButtonNode:
                //(testNode as! MySKNode).texture = SKTexture(imageNamed: "\(testNode.name!)")
                //(testNode as! MySKNode).texture = atlas.textureNamed("\(testNode.name!)")
                aktNode = (self.nodeAtPoint(touchLocation) as! MySKNode).parent as? MySKNode
            default: aktNode = nil
            }
            
            if showFingerNode {
                
                if let fingerNode = self.childNodeWithName("finger")! as? SKSpriteNode {
                    fingerNode.removeFromParent()
                }
                
            }
            if aktNode != nil && aktNode!.type == .ButtonType && startNode.type == .ButtonType && aktNode!.name == movedFromNode.name {
                //            if aktNode != nil && mySKNode.type == .ButtonType && startNode.type == .ButtonType  {
                var mySKNode = aktNode!
                
                //                var name = (aktNode as! MySKNode).parent!.name
                if mySKNode.name == buttonName {
                    mySKNode = (mySKNode.parent) as! MySKNode
                }
                //switch (aktNode as! MySKNode).name! {
                switch mySKNode.name! {
                    case "settings": settingsButtonPressed()
                    case "undo": undoButtonPressed()
                    case "restart": restartButtonPressed()
                    default: specialButtonPressed(mySKNode.name!)
                }
                return
            }
            
            let touchesEndedAt = NSDate()
            
            let downTime = touchesEndedAt.timeIntervalSinceDate(touchesBeganAt!)
//            if downTime < 0.3 && aktNode == movedFromNode {
//                tapLocation = touchLocation
//                doubleTapped()
//                return
//            }

            if exchangeModus {
                exchangeModus = false
                stopTrembling()
            }
            
            if startNode.type == .SpriteType && (aktNode == nil || aktNode! != movedFromNode) {
                let sprite = movedFromNode// as! SKSpriteNode
                let movedFrom = ColumnRow(column: movedFromNode.column, row: movedFromNode.row)
                var (foundedPoint, myPoints) = createHelpLines(movedFrom, toPoint: touchLocation, inFrame: self.frame, lineSize: movedFromNode.size.width, showLines: false)
                var actFromToColumnRow = FromToColumnRow()
                actFromToColumnRow.fromColumnRow = movedFrom
                actFromToColumnRow.toColumnRow.column = foundedPoint!.column
                actFromToColumnRow.toColumnRow.row = foundedPoint!.row
                
                let color = calculateLineColor(foundedPoint!, movedFrom: movedFrom)
                if color == .Red && lastGreenPair != nil {
                    if lastRedPair != nil {
                        lastRedPair!.setEndDuration()
////                        if lastRedPair!.duration < 1.0 && lastGreenPair!.duration > 1.0 {
                        if lastGreenPair!.fixed && lastRedPair!.duration < 2.0 {
                            actFromToColumnRow.toColumnRow.column = lastGreenPair!.pair.toColumnRow.column
                            actFromToColumnRow.toColumnRow.row = lastGreenPair!.pair.toColumnRow.row
                            myPoints = lastGreenPair!.points // set Back to last green line
                            print("==============correctur made! lastRedPair!.duration: ", lastRedPair!.duration.nDecimals(3), "==========")
                        }
                    }
                }
                
                push(sprite, status: .MovingStarted)
                
                
                let countAndPushAction = SKAction.runBlock({
                    self.push(sprite, status: .Mirrored)
                })
                
                let actionEmpty = SKAction.runBlock({
                    self.makeEmptyCard(sprite.column, row: sprite.row)
                })

                let speed: CGFloat = 0.001
                
                sprite.zPosition += 5

                
                
                var actionArray = [SKAction]()
                actionArray.append(actionEmpty)
                actionArray.append(SKAction.moveTo(myPoints[1], duration: Double((myPoints[1] - myPoints[0]).length() * speed)))
                
                if myPoints.count > 2 {
                    actionArray.append(countAndPushAction)
                    actionArray.append(SKAction.moveTo(myPoints[2], duration: Double((myPoints[2] - myPoints[1]).length() * speed)))
                    if myPoints.count > 3 {
                        actionArray.append(countAndPushAction)
                        actionArray.append(SKAction.moveTo(myPoints[3], duration: Double((myPoints[3] - myPoints[2]).length() * speed)))
                        if myPoints.count > 4 {
                            actionArray.append(countAndPushAction)
                            actionArray.append(SKAction.moveTo(myPoints[4], duration: Double((myPoints[4] - myPoints[3]).length() * speed)))
                        }
                    }
                }
//                var targetNode: MySKNode
                var collisionAction: SKAction
                if actFromToColumnRow.toColumnRow.row == NoValue {
                    let containerNode = self.childNodeWithName(containers[actFromToColumnRow.toColumnRow.column].name!) as! MyContainer
                    collisionAction = SKAction.runBlock({
                        self.spriteDidCollideWithContainer(self.movedFromNode, node2: containerNode)
                    })
                } else {
                    let cardNode = self.childNodeWithName(gameArray[actFromToColumnRow.toColumnRow.column][actFromToColumnRow.toColumnRow.row].name) as! MySKNode
                    collisionAction = SKAction.runBlock({
                        self.spriteDidCollideWithMovingSprite(self.movedFromNode, node2: cardNode)
                    })
                }
                let userInteractionEnablingAction = SKAction.runBlock({self.userInteractionEnabled = true})
                actionArray.append(collisionAction)
                actionArray.append(userInteractionEnablingAction)
                
                tippsButton!.activateButton(false)
                
                
                
                
                //let actionMoveDone = SKAction.removeFromParent()
                collisionActive = true
                lastMirrored = ""
                
                self.userInteractionEnabled = false  // userInteraction forbidden!
                countMovingSprites = 1
                self.waitForSKActionEnded = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(CardGameScene.checkCountMovingSprites), userInfo: nil, repeats: false) // start timer for check
                
                movedFromNode.runAction(SKAction.sequence(actionArray))
                
            } else if startNode.type == .SpriteType && aktNode == movedFromNode {
                startTippTimer()
            } else if startNode.type == .ShowCardType {
                var foundedCard: MySKNode?
                let nodes = self.nodesAtPoint(touchLocation)
                var founded = false
                for index in 0..<nodes.count {
                    foundedCard = nodes[index] as? MySKNode
                   if nodes[index] is MySKNode && foundedCard!.type == .EmptyCardType {
                        startNode.column = foundedCard!.column
                        startNode.row = foundedCard!.row
                        push(startNode, status: .StopCycle)
                        push(startNode, status: .AddedFromShowCard)
                        startNode.size = foundedCard!.size
                        startNode.position = foundedCard!.position
                        startNode.type = .SpriteType
//                        addPhysicsBody(startNode)
                        foundedCard!.removeFromParent()
                        founded = true
                        updateGameArrayCell(startNode)
                        pullShowCard()
                        gameArrayChanged = true

                        break
                    } else if nodes[index] is MySKNode && foundedCard!.type == .SpriteType && startNode.colorIndex == foundedCard!.colorIndex &&
                        (foundedCard!.maxValue + 1 == startNode.minValue ||
                         foundedCard!.minValue - 1 == startNode.maxValue) {
                            push(startNode, status: .StopCycle)
                            push(foundedCard!, status: .Unification)
                            push(startNode, status: .AddedFromShowCard)
                            
                            if foundedCard!.maxValue < startNode.minValue {
                                foundedCard!.maxValue = startNode.maxValue
                            } else {
                                foundedCard!.minValue = startNode.minValue
                            }
                            foundedCard!.reload()
                            push(startNode, status: .Removed)
                            gameArray[startNode.column][startNode.row].minValue = foundedCard!.minValue
                            gameArray[startNode.column][startNode.row].maxValue = foundedCard!.maxValue
                            startNode.removeFromParent()
                            pullShowCard()
                            founded = true
                            gameArrayChanged = true

                            break
                   }
                }
                if !founded {
                    let actionMove = SKAction.moveTo(cardPlaceButton!.position, duration: 0.5)
                    let actionDropShowCardFromStack = SKAction.runBlock({
                        self.removeShowCardFromStack()
                        startNode.zPosition = 0
                    })
                    startNode.zPosition = 50
                    startNode.runAction(SKAction.sequence([actionMove, actionDropShowCardFromStack]))
                }
            } else {
                startTippTimer()
            }
            
        } else {
            startTippTimer()
        }
        
    }
    
    func stopTrembling() {
        for index in 0..<tremblingSprites.count {
            tremblingSprites[index].tremblingType = .NoTrembling
        }
        tremblingSprites.removeAll()
    }
    func pullShowCard() {
        showCard = nil
        if showCardStack.count(.MySKNodeType) > 0 {
            removeShowCardFromStack()
            showCard = showCardStack.pull()
            self.addChild(showCard!)
        } else if !cardPlaceButtonAddedToParent {
            addChild(cardPlaceButton!)
            cardPlaceButtonAddedToParent = true
        }
    }
    
    func removeShowCardFromStack() {
        if showCardFromStackAddedToParent {
            showCardFromStack!.removeFromParent()
            showCardFromStack = nil
            showCardFromStackAddedToParent = false
        }
        if cardPlaceButtonAddedToParent {
            cardPlaceButton!.removeFromParent()
            cardPlaceButtonAddedToParent = false
        }
    }

//    func doubleTapped() {
//        //let location = tapLocation
//        let realLocation = tapLocation //CGPointMake(location!.x, self.view!.frame.size.height - location!.y)
//        let nodes = nodesAtPoint(realLocation!)
//        for index in 0..<nodes.count {
//            if nodes[index] is MySKNode {
//                let aktSprite = nodes[index] as! MySKNode
//                if aktSprite.type == .SpriteType {
//                    if exchangeModus {
//                        push(aktSprite, status: .Exchanged)
//                        push(cardToChange!, status: .Exchanged)
//                        exchangeModus = false
//                        createAndRunAction(cardToChange!, card2: aktSprite)
//                        createAndRunAction(aktSprite, card2: cardToChange!)
//                        
//                        let column = aktSprite.column
//                        let row = aktSprite.row
//                        let startPosition = aktSprite.startPosition
//                        
//                        aktSprite.column = cardToChange!.column
//                        aktSprite.row = cardToChange!.row
//                        aktSprite.startPosition = cardToChange!.startPosition
//                        
//                        cardToChange!.column = column
//                        cardToChange!.row = row
//                        cardToChange!.startPosition = startPosition
//
//                        stopTrembling()
//                        cardToChange = nil
//                        gameArrayChanged = true
//
//                    } else {
//                        exchangeModus = true
//                        tremblingSprites.append(aktSprite)
//                        aktSprite.tremblingType = .ChangeSize
//                        cardToChange = aktSprite
//                    }
//                }
//            }
//        }
//    }

//    func createAndRunAction(card1: MySKNode, card2: MySKNode) {
//        let actionShowEmptyCard = SKAction.runBlock({
//            self.makeEmptyCard(card1.column, row: card1.row)
//        })
//        let actionMove = SKAction.moveTo(card2.position, duration: 0.5)
//        
//        let actionDeleteEmptyCard = SKAction.runBlock({
//            self.deleteEmptySprite(card1.column, row: card1.row)
//        })
//        card1.runAction(SKAction.sequence([actionShowEmptyCard, actionMove, actionDeleteEmptyCard]))
//        
//    }
    
    func playMusic(fileName: String, volume: Float, loops: Int) {
        //levelArray = GV.cloudData.readLevelDataArray()
        let url = NSURL.fileURLWithPath(
            NSBundle.mainBundle().pathForResource(fileName, ofType: "m4a")!)
        //backgroundColor = SKColor(patternImage: UIImage(named: "aquarium.png")!)
        
        do {
            try musicPlayer = AVAudioPlayer(contentsOfURL: url)
            musicPlayer?.delegate = self
            musicPlayer?.prepareToPlay()
            musicPlayer?.volume = 0.001 * volume
            musicPlayer?.numberOfLoops = loops
            musicPlayer?.play()
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
    
    func showTimeLeft() {
    }
    
    func calculateSpritePosition(column: Int, row: Int) -> CGPoint {
        let cardPositionMultiplier = GV.deviceConstants.cardPositionMultiplier
        let point = CGPointMake(
            spriteTabRect.origin.x - spriteTabRect.size.width / 2 + CGFloat(column) * tableCellSize + tableCellSize / 2,
            spriteTabRect.origin.y - spriteTabRect.size.height / 3.0 + tableCellSize * cardPositionMultiplier / 2 + CGFloat(row) * tableCellSize * cardPositionMultiplier
        )
        return point
    }
    func calculateColumnRowFromPosition(position: CGPoint)->ColumnRow {
        var columnRow  = ColumnRow()
        let offsetToFirstPosition = position - gameArray[0][0].position
        let tableCellSize = gameArray[1][1].position - gameArray[0][0].position
        
        
        columnRow.column = Int(round(Double(offsetToFirstPosition.x / tableCellSize.x)))
        columnRow.row = Int(round(Double(offsetToFirstPosition.y / tableCellSize.y)))
//        print("pos11:", gameArray[1][1].position, "pos00:",  gameArray[0][0].position, "tableCellSize:", tableCellSize,"offsetToFirstPosition:", offsetToFirstPosition, "columnRow:", columnRow)
        return columnRow
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
    
    func checkGameArray() -> Int {
        var usedCellCount = 0
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if gameArray[column][row].used {
                    usedCellCount += 1
                }
            }
        }
        return usedCellCount
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
    
    func showScore() {
    }
    
    
    func analyzeNode (node: AnyObject) -> UInt32 {
        let testNode = node as! SKNode
        switch node  {
        case is CardGameScene: return MyNodeTypes.MyGameScene
        case is SKLabelNode:
            switch testNode.parent {
            case is CardGameScene: return MyNodeTypes.MyGameScene
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
    
    func settingsButtonPressed() {
        playMusic("NoSound", volume: GV.player!.musicVolume, loops: 0)
        countUpAdder = 0
        panel = MySKPanel(view: view!, frame: CGRectMake(self.frame.midX, self.frame.midY, self.frame.width * 0.5, self.frame.height * 0.5), type: .Settings, parent: self, callBack: comeBackFromSettings )
        panel = nil
        
    }
    
    func comeBackFromSettings(restart: Bool) {
        if restart {
            prepareNextGame(true)
            generateSprites(.First)
        } else {
            playMusic("MyMusic", volume: GV.player!.musicVolume, loops: playMusicForever)
            let name = GV.player!.name == GV.language.getText(.TCAnonym) ? GV.language.getText(.TCGuest) : GV.player!.name
            playerLabel.text = GV.language.getText(TextConstants.TCPlayer) + ": \(name)"
            countUpAdder = 1
        }
    }
    
    func undoButtonPressed() {
        pull(true)
    }

    
    func startDoCountUpTimer() {
        startTimer(&countUp, sleepTime: doCountUpSleepTime, selector: doCountUpSelector, repeats: true)
        countUpAdder = 1
    }
    
    func stopTimer(inout timer: NSTimer?) {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    


    func startTimer(inout timer: NSTimer?, sleepTime: Double, selector: String, repeats: Bool)->NSTimer {
        stopTimer(&timer)
        let myTimer = NSTimer.scheduledTimerWithTimeInterval(sleepTime, target: self, selector: Selector(selector), userInfo: nil, repeats: repeats)
        
        return myTimer
    }
    
    func doCountUp() {
        
        timeCount += countUpAdder
        let countUpText = GV.language.getText(.TCTimeLeft)
        let minutes = Int(timeCount / 60)
        var seconds = "\(Int(timeCount % 60))"
        seconds = Int(seconds) < 10 ? "0\(seconds)" : "\(seconds)"
        countUpLabel.text = "\(countUpText) \(minutes):\(seconds)"
    }
    
    func checkCountMovingSprites() {
        if  countMovingSprites > 0 && countCheckCounts < 80 {
            countCheckCounts += 1
            self.waitForSKActionEnded = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(CardGameScene.checkCountMovingSprites), userInfo: nil, repeats: false)
        } else {
            countCheckCounts = 0
            self.userInteractionEnabled = true
        }
    }

    func removeNodesWithName(name: String) {
        while self.childNodeWithName(name) != nil {
            self.childNodeWithName(name)!.removeFromParent()
        }
    }
    
    func setMyDeviceConstants() {
        
        switch GV.deviceConstants.type {
        case .iPadPro12_9:
            labelFontSize = 20
            labelYPosProcent = 90
            labelHeight = 20
        case .iPad2:
            labelFontSize = 17
            labelYPosProcent = 90
            labelHeight = 18
        case .iPadMini:
            labelFontSize = 17
            labelYPosProcent = 90
            labelHeight = 18
        case .iPhone6Plus:
            labelFontSize = 14
            labelYPosProcent = 88
            labelHeight = 15
        case .iPhone6:
            labelFontSize = 12
            labelYPosProcent = 88
            labelHeight = 13
        case .iPhone5:
            labelFontSize = 10
            labelYPosProcent = 87
            labelHeight = 12
        case .iPhone4:
            labelFontSize = 10
            labelYPosProcent = 87
            labelHeight = 10
        default:
            break
        }
        
    }
    


    

}
