
//  CardGameScene.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 11. 26..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import AVFoundation
import MultipeerConnectivity

class CardGameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate, PeerToPeerServiceManagerDelegate { //,  JGXLineDelegate { //MyGameScene {

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
    
    struct Opponent {
        var peerIndex: Int = 0
        var ID = 0
        var name: String = ""
        var score: Int = 0
        var cardCount: Int = 0
        var hasFinished: Bool = false
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
    
    let answerYes = "YES"
    let answerNo = "NO"
    
    let showTippSleepTime = 30.0
    let doCountUpSleepTime = 1.0
    let showTippsFreeCount = 3
    let freeAmount = 3
    let penalty = 25
    
    var scoreFactor: Double = 0
    var scoreTime: Double = 0 // Minutes
    
//    let showTippSelector = "showTipp"
    let doCountUpSelector = "showTime"
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
//    var showTippAtTimer: NSTimer?
    var dummy = 0
    
    var labelFontSize = CGFloat(0)
    var labelYPosProcent = CGFloat(0)
    var labelHeight = CGFloat(0)
    
    var tremblingSprites: [MySKNode] = []
    var random: MyRandom?
    // Values from json File
    var params = ""
    var countCardsProContainer: Int?
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
    
    var scoreModifyer = 0
    var showTippCounter = 0
//    var mirroredScore = 0
    
    var touchesBeganAt: NSDate?
    
    let containerSizeOrig: CGFloat = 40
    let spriteSizeOrig: CGFloat = 35
    
    var showFingerNode = false
    var countMovingSprites = 0
    var countCheckCounts = 0
    var freeUndoCounter = 0
    var freeTippCounter = 0
    
    
    
    //let timeLimitKorr = 5 // sec for pro Sprite
    //    var startTime: NSDate?
    //    var startTimeOrig: NSDate?
    var timer: NSTimer?
    var countUp: NSTimer?
    var greenLineTimer: NSTimer?
    var waitForSKActionEnded: NSTimer?
    var lastMirrored = ""
    var musicPlayer: AVAudioPlayer?
    var soundPlayer: AVAudioPlayer?
    var soundPlayerArray = [AVAudioPlayer?](count: 3, repeatedValue: nil)
    var myView = SKView()
    var levelIndex = GV.player!.levelID
    var stack:Stack<SavedSprite> = Stack()
    //var gameArray = [[Bool]]() // true if Cell used
    var gameArray = [[GameArrayPositions]]()
    var containers = [MySKNode]()
    var colorTab = [ColorTabLine]()
    let containersPosCorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.85 : 0.85)
    var levelPosKorr = CGPointMake(GV.onIpad ? 0.7 : 0.7, GV.onIpad ? 0.97 : 0.97)
    let playerPosKorr = CGPointMake(0.7 * GV.deviceConstants.sizeMultiplier, 0.5 * GV.deviceConstants.sizeMultiplier)
    let countUpPosKorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.95 : 0.94)
    var countColorsProContainer = [Int]()
    var labelBackground = SKSpriteNode()
    var levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var gameNumberLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var showTimeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var playerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var cardCountLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var showScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var opponentLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var opponentScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    
    
//    var gameScore = GV.player!.gameScore
    var levelScore: Int = 0 {
        didSet {
            showLevelScore()
            if multiPlayer {
                GV.peerToPeerService!.sendInfo(.MyScoreHasChanged, message: [String(levelScore), String(cardCount)], toPeerIndex: opponent.peerIndex)
            }
        }
    }
    
    var timeCount: Int = 0  { // seconds
        didSet {
            showLevelScore()
        }
    }
    var movedFromNode: MySKNode!
    var settingsButton: MySKButton?
    var undoButton: MySKButton?
    var restartButton: MySKButton?
    var exchangeButton: MySKButton?
    var nextLevelButton: MySKButton?
    var targetScore = 0
    var cardCount = 0 {
        didSet {
            if multiPlayer {
                GV.peerToPeerService!.sendInfo(.MyScoreHasChanged, message: [String(levelScore), String(cardCount)], toPeerIndex: opponent.peerIndex)
            }
        }
    }


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
//    var parentViewController: UIViewController?
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
    
    var panel: MySKPanel?
    var countUpAdder = 0
    
//    var actGame: GameModel?
    var actGame: GameModel?
    
    var multiPlayer = false
    var opponent = Opponent()
    var startGetNextPlayArt = false
    var restartGame: Bool = false
    var inSettings: Bool = false
    var receivedMessage: [String] = []

    
    var stopCreateTippsInBackground = false {
        didSet {
            if stopCreateTippsInBackground {
                if !generatingTipps {
                    stopCreateTippsInBackground = false
                } else {
                    let startWaiting = NSDate()
                    while generatingTipps && stopCreateTippsInBackground {
                        
                         _ = 0
                    }
                    print ("waiting for Stop Creating Tipps:", NSDate().timeIntervalSinceDate(startWaiting).nDecimals(5))
                    stopCreateTippsInBackground = false

                }
            }
        }
    }
        
    var gameArrayChanged = false {
        didSet {
//            print("in gameArrayChanged: bevor stopCreateTippsInBackground var generatingTipps = ", generatingTipps)
            stopCreateTippsInBackground = true
//            print("in gameArrayChanged: after stopCreateTippsInBackground var generatingTipps = ", generatingTipps)
            startCreateTippsInBackground()

//            switch (oldValue, gameArrayChanged, generatingTipps) {
//                case (false, true, false):
//                    startCreateTippsInBackground()
//                case (true, true, true):
//                    stopCreateTippsInBackground = true
//                    startCreateTippsInBackground()
//                case (true, true, false):
//                    startCreateTippsInBackground()
//
//                default: break
//            }
        }
    }
    
    var tapLocation: CGPoint?
    let qualityOfServiceClass = QOS_CLASS_BACKGROUND
    let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
    let playMusicForever = -1
    
    override func didMoveToView(view: SKView) {
        
        if !settingsSceneStarted {
            
            myView = view
            
            GV.peerToPeerService!.delegate = self
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
            self.name = "CardGameScene"
            
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
        specialPrepareFuncFirst()
        freeUndoCounter = freeAmount
        freeTippCounter = freeAmount
        scoreModifyer = 0
        levelScore = 0
        showTippCounter = showTippsFreeCount

//        GV.statistic = GV.realm.objects(StatisticModel).filter("playerID = %d and levelID = %d", GV.player!.ID, GV.player!.levelID).first
        self.removeAllChildren()
        

        playMusic("MyMusic", volume: GV.player!.musicVolume, loops: playMusicForever)
        stack = Stack()
        timeCount = 0
        if newGame {
            gameNumber = -1
            let allGames = realm.objects(GameModel).filter("levelID = %d", levelIndex) //search all games on this level
            for game in allGames {
                if realm.objects(GameModel).filter("gameNumber = %d and levelID = %d and playerID = %d", game.gameNumber, levelIndex, GV.player!.ID).count == 0 {
                    gameNumber = game.gameNumber  // founded a game not played by actPlayer
                    createGameRecord(gameNumber)
                    break
                }
            }
            
            if gameNumber == -1 {
                if allGames.count > 0 {
                    gameNumber = randomGameNumber()
                    if gameNumber == realm.objects(GamePredefinitionModel).count {  // all Plays played
                        // search plays with score = 0
                    }
                } else {
                    gameNumber = 0
                }
                createGameRecord(gameNumber)
            }
        } else {
            createGameRecord(gameNumber)
        }
        
        random = MyRandom(gameNumber: gameNumber)
        
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
//                    print("column:", column, "row:",row, "calculated:", columnRow, column != columnRow.column || row != columnRow.row ? "Error" : "")
                    dummy = 0
                }
            }
        }


        
        
        prepareContainers()
        
        //        self.addChild(labelBackground)
        
        let tippsTexture = SKTexture(image: images.getTipp())
        tippsButton = MySKButton(texture: tippsTexture, frame: CGRectMake(buttonXPosNormalized * 7.5, buttonYPos, buttonSize, buttonSize))
        tippsButton!.name = "tipps"
        addChild(tippsButton!)
        
        let cardSize = CGSizeMake(buttonSize * sizeMultiplier.width * 0.8, buttonSize * sizeMultiplier.height * 0.8)
        let cardPackageButtonTexture = SKTexture(image: images.getCardPackage())
        cardPackage = MySKButton(texture: cardPackageButtonTexture, frame: CGRectMake(buttonXPosNormalized * 4.0, buttonYPos, cardSize.width, cardSize.height), makePicture: false)
        cardPackage!.name = "cardPackege"
        addChild(cardPackage!)
        
        showCardFromStack = nil
        
//        let cardPlaceTexture = SKTexture(imageNamed: "emptycard")
//        cardPlaceButton = MySKButton(texture: cardPlaceTexture, frame: CGRectMake(buttonXPosNormalized * 6.0, buttonYPos, cardSize.width, cardSize.height), makePicture: false)
//        cardPlaceButton!.name = "cardPlace"
//        addChild(cardPlaceButton!)
//        cardPlaceButton!.alpha = 0.3
//        cardPlaceButtonAddedToParent = true


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
        cardCount = Int(CGFloat(countContainers * countCardsProContainer!))
        let cardCountText: String = String(cardStack.count(.MySKNodeType))
        let tippCountText: String = "\(tippArray.count)"
        let showScoreText: String = GV.language.getText(.TCGameScore, values: "\(levelScore)")
        let name = GV.player!.name == GV.language.getText(.TCAnonym) ? GV.language.getText(.TCGuest) : GV.player!.name
        
        createLabels(showTimeLabel, text: "", column: 1, row: 1)
        createLabels(gameNumberLabel, text: GV.language.getText(.TCGameNumber) + " \(gameNumber + 1)", column: 2, row: 1)
        createLabels(levelLabel, text: GV.language.getText(TextConstants.TCLevel) + ": \(levelIndex + 1)", column: 4, row: 1)
        
        createLabels(playerLabel, text: GV.language.getText(TextConstants.TCPlayer) + ": \(name)", column: 1, row: 2)
        createLabels(showScoreLabel, text: showScoreText, column: 1, row: 3)
        
        createLabels(opponentLabel, text: GV.language.getText(.TCOpponent), column: 3, row: 2)
        createLabels(opponentScoreLabel, text: "", column: 3, row: 3)
        opponentLabel.hidden = true
        opponentScoreLabel.hidden = true
        
        createLabels(cardCountLabel, text: cardCountText, column: 1, row: 5)
        createLabels(tippCountLabel, text: tippCountText, column: 2, row: 5)

    }
    
    func createGameRecord(gameNumber: Int) {
        let gameNew = GameModel()
        gameNew.ID = GV.createNewRecordID(.GameModel)
        gameNew.gameNumber = gameNumber
        gameNew.levelID = levelIndex
        gameNew.playerID = GV.player!.ID
        gameNew.played = false
        try! realm.write() {
            realm.add(gameNew)
        }
        actGame = gameNew
    }
    
    func createLabels(label: SKLabelNode, text: String, column: Int, row: Int) {
        label.text = text
        var xPos = CGFloat(0)
        var horAlignment = SKLabelHorizontalAlignmentMode.Left
        if row < 5 {
            switch column {
            case 1:
                xPos = self.position.x + self.size.width * 0.1
                horAlignment = .Left
            case 2:
                xPos = self.position.x + self.size.width * 0.4
            case 3:
                xPos = self.position.x + self.size.width * 0.65
            case 4:
                xPos = self.position.x + self.size.width * 0.8
            case 5:
                xPos = self.cardPackage!.position.x
            default: break
            }
            let yPos = CGFloat(self.size.height * labelYPosProcent / 100) + CGFloat((5 - row)) * labelHeight
            label.position = CGPointMake(xPos, yPos)
            label.fontSize = labelFontSize;
            label.horizontalAlignmentMode = horAlignment
        } else {
            label.position = (column == 1 ? self.cardPackage!.position : self.tippsButton!.position)
            label.fontSize = labelFontSize * 1.5
            label.zPosition = 5
            label.horizontalAlignmentMode = .Center
        }
        label.fontColor = SKColor.blackColor()
        label.verticalAlignmentMode = .Center
        label.color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.addChild(label)
    }
    
    
    
    func showLevelScore(showOpponent: Bool = false, opponentScore: Int = 0) {
        switch showOpponent {
        case false:
            showScoreLabel.text = GV.language.getText(.TCGameScore, values: "\(levelScore)", "\(cardCount)")
        case true:
            opponentScoreLabel.text = GV.language.getText(.TCGameScore, values: "\(opponent.score)", "\(opponent.cardCount)")
        }
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
        

        countContainers = GV.levelsForPlay.aktLevel.countContainers
        countPackages = GV.levelsForPlay.aktLevel.countPackages
        countCardsProContainer = MaxCardValue //levelsForPlay.aktLevel.countSpritesProContainer
        countColumns = GV.levelsForPlay.aktLevel.countColumns
        countRows = GV.levelsForPlay.aktLevel.countRows
        minUsedCells = GV.levelsForPlay.aktLevel.minProzent * countColumns * countRows / 100
        maxUsedCells = GV.levelsForPlay.aktLevel.maxProzent * countColumns * countRows / 100
        containerSize = CGSizeMake(CGFloat(containerSizeOrig) * sizeMultiplier.width, CGFloat(containerSizeOrig) * sizeMultiplier.height)
        spriteSize = CGSizeMake(CGFloat(GV.levelsForPlay.aktLevel.spriteSize) * sizeMultiplier.width, CGFloat(GV.levelsForPlay.aktLevel.spriteSize) * sizeMultiplier.height )
        scoreFactor = GV.levelsForPlay.aktLevel.scoreFactor
        scoreTime = GV.levelsForPlay.aktLevel.scoreTime
        //gameArrayPositions.removeAll(keepCapacity: false)
        tableCellSize = spriteTabRect.width / CGFloat(countColumns)
        
        for _ in 0..<countContainers {
            var hilfsArray: [GenerateCard] = []
            for cardIndex in 0..<countCardsProContainer! * countPackages {
                var card = GenerateCard()
                card.cardValue = cardIndex % countCardsProContainer!
                card.packageNr = cardIndex / countCardsProContainer!
                
                hilfsArray.append(card)
            }
            cardArray.append(hilfsArray)
        }
    }
    
    func updateSpriteCount(adder: Int) {
        cardCount += adder
        showCardCount()
    }
    
    func showCardCount() {
        cardCountLabel.text = String(cardStack.count(.MySKNodeType))
    }

    
    func changeLanguage()->Bool {
        let name = GV.player!.name == GV.language.getText(.TCAnonym) ? GV.language.getText(.TCGuest) : GV.player!.name
        playerLabel.text = GV.language.getText(.TCPlayer) + ": \(name)"
        levelLabel.text = GV.language.getText(.TCLevel) + ": \(levelIndex + 1)"
        gameNumberLabel.text = GV.language.getText(.TCGameNumber) + "\(gameNumber + 1)"

        showCardCount()
        showTippCount()
        showLevelScore()
        showTimeLeft()
        return true
    }
    
    func showTippCount() {
        tippCountLabel.text = String(tippArray.count)
        if tippArray.count > 9 {
            tippCountLabel.fontSize = labelFontSize
        } else {
            tippCountLabel.fontSize = labelFontSize * 1.5
        }
    }

    func setBGImageNode()->SKSpriteNode {
        return SKSpriteNode(imageNamed: "cardBackground.png")
    }

    
    func spezialPrepareFunc() {
//        valueTab.removeAll()
    }

    func getValueForContainer()->Int {
        return countCardsProContainer!// + 1
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
//        print(positionsTab.count)
        
        while cardStack.count(.MySKNodeType) > 0 && (checkGameArray() < maxUsedCells || (generateSpecial && positionsTab.count > 0)) {
            var sprite: MySKNode = cardStack.pull()!
//            var sprite: MySKNode?
//            sprite = cardStack.random(random)
            
            if generateSpecial {
                while true {
                    if findPairForSprite(sprite.colorIndex, minValue: sprite.minValue, maxValue: sprite.maxValue) {
                        break
                        // checkPath
                    }
//                    sprite = cardStack.random(random)!
                    cardStack.pushLast(sprite)
                    sprite = cardStack.pull()!
                    
                }
                generateSpecial = false
            }
            showCardCount()
//            cardStack.removeAtLastRandomIndex()
            let index = random!.getRandomInt(0, max: positionsTab.count - 1)
            let (actColumn, actRow) = positionsTab[index]
            
            let zielPosition = gameArray[actColumn][actRow].position
            sprite.position = cardPackage!.position
            sprite.startPosition = zielPosition
            

            positionsTab.removeAtIndex(index)
            
            sprite.column = actColumn
            sprite.row = actRow
            
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
                self.deleteEmptySprite(actColumn, row: actRow)
//                sprite.zPosition = 0
                
            })
            sprite.runAction(SKAction.sequence([zPositionPlus, actionMove, zPositionMinus, actionHideEmptyCard]))
            if cardStack.count(.MySKNodeType) == 0 {
                cardPackage!.changeButtonPicture(SKTexture(imageNamed: "emptycard"))
                cardPackage!.alpha = 0.3
            }

        }
        
        
//        print("Count Columns:", countColumns)
//        printGameArrayInhalt("after generateSprites")
        
        if generatingType != .Special {
            gameArrayChanged = true
        }
        if generatingType == .First {
            countUp = NSTimer.scheduledTimerWithTimeInterval(doCountUpSleepTime, target: self, selector: Selector(doCountUpSelector), userInfo: nil, repeats: true)
            countUpAdder = 1
        }
        stopped = false
    }
    
    func printGameArrayInhalt(calledFrom: String) {
        print(calledFrom, NSDate())
        var string: String
        for row in 0..<countRows {
            let rowIndex = countRows - row - 1
            string = ""
            for column in 0..<countColumns {
                let color = gameArray[column][rowIndex].colorIndex
                if gameArray[column][rowIndex].used {
                    let minInt = gameArray[column][rowIndex].minValue + 1
                    let maxInt = gameArray[column][rowIndex].maxValue + 1
                    string += " (" + String(color) + ")" +
                    (minInt < 10 ? "0" : "") + String(minInt) + "-" +
                    (maxInt < 10 ? "0" : "") + String(maxInt)
                } else {
                    string += " (N)" + "xx-xx"
                }
            }
            print(string)
        }
    }
    
    
    func startCreateTippsInBackground() {
        {
            self.generatingTipps = true
//            self.stopTimer(&self.showTippAtTimer)
            self.createTipps()
            
            repeat {
                if self.tippArray.count <= 2 && self.checkGameArray() > 2 {
                    self.generateSprites(.Special)
                    self.createTipps()
                }
            } while !(self.tippArray.count > 2 || self.countColumns * self.countRows - self.checkGameArray() == 0 || self.checkGameArray() < 2)
            
            if self.tippArray.count == 0 && self.cardCount > 0{
                
                print ("You have lost!")
            }
            self.generatingTipps = false
        } ~>
        {
            self.generatingTipps = false
        }
    }
    
//    func showTipp() {
//        getTipps()
//    }
    
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
//        if buttonName == "cardPackege" {
//            if cardStack.count(.MySKNodeType) > 0 {
//                if showCard != nil {
//                    showCardStack.push(showCard!)
//                    showCard?.removeFromParent()
//                }
//                showCard = cardStack.pull()!
//                showCard!.position = (cardPlaceButton?.position)!
//                showCard!.size = (cardPlaceButton?.size)!
//                showCard!.type = .ShowCardType
//                cardPlaceButton?.removeFromParent()
//                cardPlaceButtonAddedToParent = false
//                addChild(showCard!)
//                if cardStack.count(.MySKNodeType) == 0 {
//                    cardPackage!.changeButtonPicture(SKTexture(imageNamed: "emptycard"))
//                    cardPackage!.alpha = 0.3
//                }
//            }
//        }
        if buttonName == "tipps" {
            if !generatingTipps {
                getTipps()
                if showTippCounter > 0 {
                    showTippCounter -= 1
                } else {
                    freeTippCounter -= 1
                    let modifyer = freeTippCounter > 0 ? 0 : freeTippCounter > -freeAmount ? penalty : 2 * penalty
                    scoreModifyer -= modifyer
                    levelScore -= modifyer
                    if modifyer > 0 {
                        self.addChild(showCountScore("-\(modifyer)", position: undoButton!.position))
                    }
                }
            }
        }
        startTippTimer()
    }
    
    func startTippTimer(){
//        stopTimer(&showTippAtTimer)
//        showTippAtTimer = NSTimer.scheduledTimerWithTimeInterval(showTippSleepTime, target: self, selector: Selector(showTippSelector), userInfo: nil, repeats: true)
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
//        printGameArrayInhalt("from createTipps")
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

//        let startCheckTime = NSDate()
        for ind in 0..<pairsToCheck.count {
            checkPathToFoundedCards(pairsToCheck[ind])
            if stopCreateTippsInBackground {
                stopCreateTippsInBackground = false
                return false
            }
        }

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
//        let tippCountText: String = GV.language.getText(.TCTippCount)
//        print("Tippcount:", tippArray.count, tippArray)
        showTippCount()
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
        let multiplierForSearch = CGFloat(3.0)
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

        if distanceToLine.between(0, max: firstValue - 0.1) {
            
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
        
        if foundedPoint.distanceToP0 == foundedPoint.maxDistance {
            return color
        }
        
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
        let arrowLength = spriteSize.width * 0.30
    
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
        
        let p1 = GV.pointOfCircle(arrowLength, center: points.last!, angle: angleR - (150 * GV.oneGrad))
        let p2 = GV.pointOfCircle(arrowLength, center: points.last!, angle: angleR + (150 * GV.oneGrad))
        
        
        
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
            
            let p1 = GV.pointOfCircle(arrowLength, center: points.first!, angle: angleR - (150 * GV.oneGrad))
            let p2 = GV.pointOfCircle(arrowLength, center: points.first!, angle: angleR + (150 * GV.oneGrad))
            
            
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
        if restartGame {
            restartGame = false
            newGame(false)
        }
        if multiPlayer {
            opponentLabel.text = GV.language.getText(.TCOpponent, values: "(", opponent.name, ")")
            opponentLabel.hidden = false
            opponentScoreLabel.hidden = false
            showLevelScore(true, opponentScore: opponent.score)
        }
        
        if startGetNextPlayArt {
            startGetNextPlayArt = false
            let alert = getNextPlayArt(false)
            GV.mainViewController!.showAlert(alert)
        }
        
        if opponent.hasFinished {
            opponent.hasFinished = false
            let statistic = realm.objects(StatisticModel).filter("playerID = %d AND levelID = %d", GV.player!.ID, GV.player!.levelID).first!
            saveStatisticAndGame(statistic)
        }
        
    }
    
    func spriteDidCollideWithContainer(node1:MySKNode, node2:MySKNode) {
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
//            let adder = movingSprite.maxValue * (movingSprite.maxValue - movingSprite.minValue + 1)
            if container.maxValue < movingSprite.minValue {
                container.maxValue = movingSprite.maxValue
            } else {
                container.minValue = movingSprite.minValue
                if container.maxValue == NoColor {
                    container.maxValue = movingSprite.maxValue
                }
            }

            self.addChild(showCountScore("+\(movingSprite.countScore)", position: movingSprite.position))
            
//            movingSprite.countScore += mirroredScore
            levelScore += movingSprite.countScore
            levelScore += movingSprite.getMirroredScore()
            
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
            
//            for adder in movingSprite.minValue + 1...movingSprite.maxValue + 1 {
//                movingSprite.countScore += adder
//                levelScore += adder
//            }
            
            self.addChild(showCountScore("+\(movingSprite.countScore)", position: movingSprite.position))
            levelScore += movingSprite.countScore
            levelScore += movingSprite.getMirroredScore()

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
    
    func showCountScore(text: String, position: CGPoint)->SKLabelNode {
        let score = SKLabelNode()
        score.position = position
        score.text = text
        score.fontColor = UIColor.redColor()
        score.fontName = "Helvetica Bold"
        score.fontSize = 30
        score.zPosition = 1000
        let showAction = SKAction.moveToY(position.y + 1000, duration: 10.0)
        let hideAction = SKAction.sequence([SKAction.fadeOutWithDuration(3.0), SKAction.removeFromParent()])
        let scoreActions = SKAction.group([showAction, hideAction])
        score.runAction(scoreActions)
        return score
    }

    func checkGameFinished() {
        
        
        let usedCellCount = checkGameArray()
        let containersOK = checkContainers()
        
        let finishGame = cardCount == 0 //< 50
        
        if (usedCellCount <= 1 && containersOK) || finishGame { // Level completed, start a new game
            
            stopTimer(&countUp)
            playMusic("Winner", volume: GV.player!.musicVolume, loops: 0)
            if multiPlayer {
                GV.peerToPeerService?.sendInfo(.GameIsFinished, message: [String(levelScore)], toPeerIndex: opponent.peerIndex)
            }
            
            
            if realm.objects(StatisticModel).filter("playerID = %d AND levelID = %d", GV.player!.ID, GV.player!.levelID).count == 0 {
                // create a new Statistic record if required
                let statistic = StatisticModel()
                statistic.ID = GV.createNewRecordID(.StatisticModel)
                statistic.playerID = GV.player!.ID
                statistic.levelID = GV.player!.levelID
                try! realm.write({
                    realm.add(statistic)
                })
            } 
            // get && modify the statistic record
            
            let statistic = realm.objects(StatisticModel).filter("playerID = %d AND levelID = %d", GV.player!.ID, GV.player!.levelID).first!
            saveStatisticAndGame(statistic)
            if multiPlayer {
                alertIHaveGameFinished()
            } else {
                let alert = getNextPlayArt(true, statistic: statistic)
                GV.mainViewController!.showAlert(alert)
            }
        } else if usedCellCount <= minUsedCells && usedCellCount > 1 { //  && spriteCount > maxUsedCells {
            generateSprites(.Normal)  // Nachgenerierung
        } else {
            if cardCount > 0 /*&& cardStack.count(.MySKNodeType) > 0*/ {
                gameArrayChanged = true
            }
        }
    }
    
    func saveStatisticAndGame (statistic: StatisticModel) {
        
        realm.beginWrite()
        statistic.actTime = timeCount
        statistic.allTime += timeCount
        
        if statistic.bestTime == 0 || timeCount < statistic.bestTime {
            statistic.bestTime = timeCount
        }
        
        
        statistic.actScore = levelScore
        statistic.levelScore += levelScore
        if statistic.bestScore < levelScore {
            statistic.bestScore = levelScore
        }
        
        if statistic.bestScore < levelScore {
            statistic.bestScore = levelScore
        }
        
        actGame!.time = timeCount
        actGame!.playerScore = levelScore
        actGame!.played = true
        if multiPlayer {
            actGame!.multiPlay = true
            actGame!.opponentName = opponent.name
            actGame!.opponentScore = opponent.score
            statistic.countMultiPlays += 1
            if opponent.score > levelScore {
                statistic.defeats += 1
            } else {
                statistic.victorys += 1
            }
        } else {
            statistic.countPlays += 1
        }
        try! realm.commitWrite()

    }
    
    func restartButtonPressed() {
        let alert = getNextPlayArt(false)
        GV.mainViewController!.showAlert(alert)
    }
    
    func choosePartner() {
        let partnerNames = GV.peerToPeerService!.getPartnerName()
        if GV.peerToPeerService!.countPartners() > 1 {
            let alert = UIAlertController(title: GV.language.getText(.TCChoosePartner),
                                          message: "",
                                          preferredStyle: .Alert)
            for index in 0..<partnerNames.count {
                let identity = partnerNames[index]
                let nameAction = UIAlertAction(title: identity, style: .Default,
                                                handler: {(paramAction:UIAlertAction!) in
                                                    self.opponent.name = identity
                                                    self.opponent.peerIndex = index
                                                    self.opponent.score = 0
                                                    self.callPartner(index, identity: identity)
                })
                alert.addAction(nameAction)
            }
            GV.mainViewController!.showAlert(alert)
        } else if GV.peerToPeerService!.countPartners() > 0 {
            let identity = partnerNames[0]
            callPartner(0, identity: identity )
        }
    }
    
    func callPartner(index: Int, identity: String) {
        let gameNumber = randomGameNumber()
        opponent.peerIndex = index
        let myName = GV.player!.name == GV.language.getText(.TCAnonym) ? GV.language.getText(.TCGuest) : GV.player!.name
        var answer = GV.peerToPeerService!.sendMessage(.IWantToPlayWithYou, message: [myName, String(levelIndex), String(gameNumber)], toPeerIndex: index)
        switch answer[0] {
        case answerYes:
            self.multiPlayer = true
            self.gameNumber = gameNumber
            self.opponent.name = identity
            self.opponent.score = 0
            self.restartGame = true
        case answerNo, GV.IAmBusy, GV.timeOut:
            alertOpponentDoesNotWantPlay()
            self.opponent = Opponent()
            self.multiPlayer = false
        default:
            break
        }
    }
    
    func alertOpponentDoesNotWantPlay() {
        let alert = UIAlertController(title: GV.language.getText(.TCOpponentNotPlay, values: String(opponent.name)),
            message: "",
            preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: GV.language.getText(.TCOK), style: .Default,
                                        handler: {(paramAction:UIAlertAction!) in
                                            
        })
        alert.addAction(OKAction)

        
        GV.mainViewController!.showAlert(alert, delay: 5)
        
    }

    
    func randomGameNumber()->Int {
        var freeGameNumbers = [Int]()
        let gameNumberSet = realm.objects(GamePredefinitionModel)
        for index in 0..<gameNumberSet.count {
            if realm.objects(GameModel).filter("gameNumber = %d and levelID = %d and played = true", gameNumberSet[index].gameNumber, levelIndex).count == 0 {
                freeGameNumbers.append(gameNumberSet[index].gameNumber)
            }
        }
        if freeGameNumbers.count > 0 {
            let foundedGameNumber = freeGameNumbers[GV.randomNumber(freeGameNumbers.count)]
            return foundedGameNumber
        }
        return 0
    }
    
    func chooseGameNumber () {
        let _ = ChooseGamePanel(
            view: view!,
            frame: CGRectMake(self.frame.midX, self.frame.midY, self.frame.width * 0.5, self.frame.height * 0.5),
            parent: self,
            callBack: callBackFromMySKTextField
        )
    }
    
    func callBackFromMySKTextField(gameNumber: Int) {
        self.gameNumber = gameNumber
        self.userInteractionEnabled = true
        newGame(false)
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

//    func timeFactor()->Double {
//        
//        let y: Double = scoreTime * 60 / (scoreFactor - 1)
//        let x: Double = y * scoreFactor
//        
//        
//        return Double(x / (y + Double(timeCount)))
//    }

    func getNextPlayArt(congratulations: Bool, statistic: StatisticModel...)->UIAlertController {
        let playerName = GV.player!.name + "!"
        let statisticsTxt = ""
        var congratulationsTxt = ""
        
        
        if congratulations {
            
            if multiPlayer {
            }
            let actGames = realm.objects(GameModel).filter("levelID = %d and gameNumber = %d", levelIndex, actGame!.gameNumber)
            
            let bestGameScore: Int = actGames.max("playerScore")!
            let bestScorePlayerID = actGames.filter("playerScore = %d", bestGameScore).first!.playerID
            let bestScorePlayerName = realm.objects(PlayerModel).filter("ID = %d",bestScorePlayerID).first!.name
            
            tippCountLabel.text = String(0)

            congratulationsTxt = GV.language.getText(.TCLevel, values: " \(levelIndex + 1)")
            congratulationsTxt += "\r\n" + GV.language.getText(.TCGameComplete, values: String(gameNumber + 1))
            congratulationsTxt += "\r\n" + GV.language.getText(TextConstants.TCCongratulations) + playerName
            congratulationsTxt += "\r\n ============== \r\n"
            
            if actGames.count > 1 {
                if bestScorePlayerName != GV.player!.name {
                    congratulationsTxt += "\r\n" + GV.language.getText(.TCYourScore, values: String(levelScore))
                    congratulationsTxt += "\r\n" + GV.language.getText(.TCBestScoreOfGame, values: String(bestGameScore), bestScorePlayerName)
                } else {
                    congratulationsTxt += "\r\n" + GV.language.getText(.TCYouAreTheBest, values: String(bestGameScore))
                }
            } else {
                congratulationsTxt += "\r\n" + GV.language.getText(.TCLevelScore, values: " \(bestGameScore)")
            }
            congratulationsTxt += "\r\n" + GV.language.getText(.TCActTime) + String(statistic[0].actTime.dayHourMinSec)
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
        
        let chooseGameAction = UIAlertAction(title: GV.language.getText(.TCChooseGameNumber), style: .Default,
                                          handler: {(paramAction:UIAlertAction!) in
                                            self.chooseGameNumber()
                                            //self.gameArrayChanged = true
                                            
        })
        alert.addAction(chooseGameAction)
        
        if levelIndex > 0 {
            let easierAction = UIAlertAction(title: GV.language.getText(.TCPreviousLevel), style: .Default,
                handler: {(paramAction:UIAlertAction!) in
//                    print("newGame from set Previous Level")
                    self.setLevel(self.previousLevel)
                    self.newGame(true)
            })
            alert.addAction(easierAction)
        }
        
        if GV.peerToPeerService!.hasOtherPlayers() {
            let competitionAction = UIAlertAction(title: GV.language.getText(.TCCompetition), style: .Default,
                                                 handler: {(paramAction:UIAlertAction!) in
                                                    self.choosePartner()
                                                    //self.gameArrayChanged = true
                                                    
            })
            alert.addAction(competitionAction)
            
        }

        if levelIndex < GV.levelsForPlay.levelParam.count - 1 {
            let complexerAction = UIAlertAction(title: GV.language.getText(TextConstants.TCNextLevel), style: .Default,
                handler: {(paramAction:UIAlertAction!) in
//                    print("newGame from set Next Level")
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
//                    self.startTimer(&self.showTippAtTimer, sleepTime: self.showTippSleepTime, selector: self.showTippSelector, repeats: true)
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
        try! realm.write({
            GV.player!.levelID = levelIndex
            realm.add(GV.player!, update: true)
        })
        
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
        
        for cardIndex in 0..<countCardsProContainer! * countPackages {
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
            containers.append(MySKNode(texture: getTexture(NoColor), type: .ContainerType, value: NoColor))
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
            countColorsProContainer.append(countCardsProContainer!)
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
                    levelScore = savedSpriteInCycle.countScore
 
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
        
//        stopTimer(&showTippAtTimer)
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
            } else if movedFromNode != aktNode {
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
                            if lastRedPair != nil && lastGreenPair!.fixed && lastGreenPair!.pair ==  actFromToColumnRow && lastGreenPair!.points.count == myPoints.count {
                                lineWidthMultiplier = lineWidthMultiplierSpecial
                                drawHelpLinesSpec()
                                lastRedPair = nil
                            } else {
                                lineWidthMultiplier = lineWidthMultiplierNormal
                                drawHelpLinesSpec()
                                lastGreenPair = PairStatus(pair: actFromToColumnRow, founded: foundedPoint!, startTime: NSDate(), points: myPoints)
                                lastRedPair = nil
                                greenLineTimer = startTimer(&greenLineTimer, sleepTime: 0.5, selector: checkGreenLineSelector, repeats: false) // set linewidth on Special after 0.5 second
                            }
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
                            if lastGreenPair!.duration == 0 || lastRedPair == nil { // first time Red
                                lastGreenPair!.setEndDuration() // get duration of Green
                                lastRedPair = PairStatus(pair: actFromToColumnRow, founded: foundedPoint!, startTime: NSDate(), points: myPoints)
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
            case MyNodeTypes.LabelNode: aktNode = testNode.parent as? MySKNode
            case MyNodeTypes.SpriteNode: aktNode = testNode as? MySKNode
            case MyNodeTypes.ButtonNode:
                aktNode = (testNode as! MySKNode).parent as? MySKNode
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
            
            if startNode.type == .SpriteType && (aktNode == nil || aktNode! != movedFromNode) {
                let sprite = movedFromNode// as! SKSpriteNode
                let movedFrom = ColumnRow(column: movedFromNode.column, row: movedFromNode.row)
                var (foundedPoint, myPoints) = createHelpLines(movedFrom, toPoint: touchLocation, inFrame: self.frame, lineSize: movedFromNode.size.width, showLines: false)
                var actFromToColumnRow = FromToColumnRow()
                actFromToColumnRow.fromColumnRow = movedFrom
                actFromToColumnRow.toColumnRow.column = foundedPoint!.column
                actFromToColumnRow.toColumnRow.row = foundedPoint!.row
                
                var color = calculateLineColor(foundedPoint!, movedFrom: movedFrom)
                if color == .Red && lastGreenPair != nil {
                    if lastRedPair != nil {
                        lastRedPair!.setEndDuration()
////                        if lastRedPair!.duration < 1.0 && lastGreenPair!.duration > 1.0 {
                        if lastGreenPair!.fixed && lastRedPair!.duration < 1.0 {
                            actFromToColumnRow.toColumnRow.column = lastGreenPair!.pair.toColumnRow.column
                            actFromToColumnRow.toColumnRow.row = lastGreenPair!.pair.toColumnRow.row
                            myPoints = lastGreenPair!.points // set Back to last green line
                            color = .Green
//                            print("==============correctur made! lastRedPair!.duration: ", lastRedPair!.duration.nDecimals(3), "==========")
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

//                var mirroredScore = 0
                
                var actionArray = [SKAction]()
                actionArray.append(actionEmpty)
                actionArray.append(SKAction.moveTo(myPoints[1], duration: Double((myPoints[1] - myPoints[0]).length() * speed)))
                
                let soundArray = ["Mirror1", "Mirror2", "Mirror3"]
                for pointsIndex in 2...4 {
                    if myPoints.count > pointsIndex {
                        if color == .Green {
                            actionArray.append(SKAction.runBlock({
                                self.movedFromNode.mirrored += 1
                                self.addChild(self.showCountScore("+\(self.movedFromNode.countScore)", position: sprite.position))
                                self.playSound(soundArray[pointsIndex - 2], volume: GV.player!.soundVolume, soundPlayerIndex: pointsIndex - 2)
                            }))
                        }
                        
                        actionArray.append(countAndPushAction)
                        actionArray.append(SKAction.moveTo(myPoints[pointsIndex], duration: Double((myPoints[pointsIndex] - myPoints[pointsIndex - 1]).length() * speed)))
                    }
                }
                var collisionAction: SKAction
                if actFromToColumnRow.toColumnRow.row == NoValue {
                    let containerNode = self.childNodeWithName(containers[actFromToColumnRow.toColumnRow.column].name!) as! MySKNode
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
    
    func createActionsForMirroring(sprite: MySKNode, adder: Int, color: MyColors, fromPoint: CGPoint, toPoint: CGPoint)->[SKAction] {
        var actions = [SKAction]()
        if color == .Green {
            actions.append(SKAction.runBlock({
                self.addChild(self.showCountScore("+\(adder)", position: sprite.position))
                self.push(sprite, status: .Mirrored)
            }))
        }
        
//        actionArray.append(countAndPushAction)
        actions.append(SKAction.moveTo(toPoint, duration: Double((toPoint - fromPoint).length() * speed)))

        return actions
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
    
    func playSound(fileName: String, volume: Float, soundPlayerIndex: Int) {
        
        let url = NSURL.fileURLWithPath(
            NSBundle.mainBundle().pathForResource(fileName, ofType: "m4a")!)
        
        do {
            try soundPlayerArray[soundPlayerIndex] = AVAudioPlayer(contentsOfURL: url)
            soundPlayerArray[soundPlayerIndex]!.delegate = self
            soundPlayerArray[soundPlayerIndex]!.prepareToPlay()
            soundPlayerArray[soundPlayerIndex]!.volume = 0.001 * volume
            soundPlayerArray[soundPlayerIndex]!.numberOfLoops = 0
            soundPlayerArray[soundPlayerIndex]!.play()
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
        savedSprite.countScore = levelScore
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
        inSettings = true
        panel = MySKPanel(view: view!, frame: CGRectMake(self.frame.midX, self.frame.midY, self.frame.width * 0.5, self.frame.height * 0.5), type: .Settings, parent: self, callBack: comeBackFromSettings )
        panel = nil
        
    }
    
    func comeBackFromSettings(restart: Bool) {
        inSettings = false
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
        freeUndoCounter -= 1
        let modifyer = freeUndoCounter > 0 ? 0 : freeUndoCounter > -freeAmount ? penalty : 2 * penalty
        scoreModifyer -= modifyer
        levelScore -= modifyer
        if modifyer > 0 {
            self.addChild(showCountScore("-\(modifyer)", position: undoButton!.position))
        }
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
    
    func showTime() {
        
        timeCount += countUpAdder
        let countUpText = GV.language.getText(.TCTime, values: timeCount.dayHourMinSec)
        showTimeLabel.text = countUpText
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
    
    func connectedDevicesChanged(manager : PeerToPeerServiceManager, connectedDevices: [String]) {
        
    }
    func messageReceived(fromPeerIndex : Int, command: PeerToPeerCommands, message: [String], messageNr:Int) {
        switch command {
        case .MyNameIs: break
        case .IWantToPlayWithYou:
            if inSettings {
                GV.peerToPeerService!.sendAnswer(messageNr, answer: [GV.IAmBusy])
            } else {
                alertStartMultiPlay(fromPeerIndex, message: message, messageNr: messageNr)
            }
        case .MyScoreHasChanged:
            opponent.score = Int(message[0])!
            opponent.cardCount = Int(message[1])!
        case .GameIsFinished:
            opponent.score = Int(message[0])!
            opponent.hasFinished = true // save in update!!!
            alertOpponentHasGameFinished()
        default:
            return
        }
        print("message received - command: \(command), message: \(message)")
    }
    
    func alertOpponentHasGameFinished() {
        let bonus = opponent.score / 10
        let hisScore = opponent.score + bonus
        let opponentWon = hisScore > levelScore
        let wonText = opponentWon ? GV.language.getText(.TCHeWon, values: self.opponent.name, String(hisScore), String(levelScore)) : GV.language.getText(.TCYouWon, values: String(levelScore), String(hisScore))
        let alert = UIAlertController(title: GV.language.getText(.TCOpponentHasFinished,
            values: self.opponent.name,
                    String(gameNumber),
                    String(bonus),
                    String(self.opponent.score),
                    String(levelScore)) +
            "\r\n" +
            "\r\n" +
            wonText,
            message: "",
            preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: GV.language.getText(.TCOK), style: .Default,
                                    handler: {(paramAction:UIAlertAction!) in
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.startGetNextPlayArt = true
                                    }
        })
        alert.addAction(OKAction)
        
        dispatch_async(dispatch_get_main_queue(), {
            GV.mainViewController!.showAlert(alert, delay: 20)
        })

    }
    
    func calculateWinner()->(bonus:Int, myScore:Int, IWon: Bool){
        let bonus = levelScore / 10
        let myScore = levelScore + bonus
        let IWon = myScore > opponent.score
        return(bonus, myScore, IWon)
    }
    
    func alertIHaveGameFinished() {
//        let bonus = levelScore / 10
//        let myScore = levelScore + bonus
//        let IWon = myScore > opponent.score
        let (bonus, myScore, IWon) = calculateWinner()
        let wonText = IWon ? GV.language.getText(.TCYouWon, values: String(myScore), String(opponent.score)) : GV.language.getText(.TCHeWon, values: opponent.name, String(opponent.score), String(myScore) )
        let alert = UIAlertController(title: GV.language.getText(.TCYouHaveFinished,
            values: String(gameNumber),
            String(bonus),
            String(levelScore),
            opponent.name,
            String(self.opponent.score)) +
            "\r\n" +
            "\r\n" +
            wonText,
          message: "",
          preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: GV.language.getText(.TCOK), style: .Default,
                                     handler: {(paramAction:UIAlertAction!) in
                                        dispatch_async(dispatch_get_main_queue()) {
                                            self.startGetNextPlayArt = true
                                        }
        })
        alert.addAction(OKAction)
        GV.mainViewController!.showAlert(alert, delay: 20)
        
    }
    

    func alertStartMultiPlay(fromPeerIndex: Int, message: [String], messageNr: Int) {
        let alert = UIAlertController(title: GV.language.getText(.TCWantToPlayWithYou, values: message[0]),
                                      message: "",
                                      preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: GV.language.getText(.TCOK), style: .Default,
                                     handler: {(paramAction:UIAlertAction!) in
                                        dispatch_async(dispatch_get_main_queue()) {
                                            self.multiPlayer = true
                                            self.opponent.name = message[0]
                                            self.opponent.peerIndex = fromPeerIndex
                                            self.opponent.score = 0
                                            self.levelIndex = Int(message[1])!
                                            self.gameNumber = Int(message[2])!
                                            self.restartGame = true
                                            print("sendAnswer YES to messageNe: \(messageNr)")
                                            GV.peerToPeerService!.sendAnswer(messageNr, answer: [self.answerYes])
                                        }
        })
        alert.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: GV.language.getText(.TCCancel), style: .Default,
                                         handler: {(paramAction:UIAlertAction!) in
                                            GV.peerToPeerService!.sendAnswer(messageNr, answer: [self.answerNo])
        })
        alert.addAction(cancelAction)
        dispatch_async(dispatch_get_main_queue(), {
            GV.mainViewController!.showAlert(alert, delay: 20)
        })
        
    }
    

    func sendAlertToUser(fromPeerIndex: Int) {
        
    }

    
    func setMyDeviceConstants() {
        
        switch GV.deviceConstants.type {
        case .iPadPro12_9:
            labelFontSize = 20
            labelYPosProcent = 92
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
