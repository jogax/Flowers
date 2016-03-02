//
//  MyStructs.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 18.04.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import GameKit


//enum Choosed: Int{
//    case Unknown = 0, Right, Left, Settings, Restart
//}
//enum GameControll: Int {
//    case Finger = 0, JoyStick, Accelerometer, PipeLine
//}
//
struct GV {
    static var vBounds = CGRect(x: 0, y: 0, width: 0, height: 0)
    static var notificationCenter = NSNotificationCenter.defaultCenter()
//    static let notificationGameControllChanged = "gameModusChanged"
//    static let notificationMadeMove = "MadeMove"
//    static let notificationJoystickMoved = "joystickMoved"
//    static let notificationColorChanged = "colorChanged"
    static var dX: CGFloat = 0
    static var speed: CGSize = CGSizeZero
    static var touchPoint = CGPointZero
    static var gameSize = 5
    static var gameNr = 0
    static var gameSizeMultiplier: CGFloat = 1.0
    static let onIpad = UIDevice.currentDevice().model.hasSuffix("iPad")
    static var ipadKorrektur: CGFloat = 0

    static let language = Language()
    static var showHelpLines = 0
    static var soundVolume: Float = 0
    static var musicVolume: Float = 0
    static var globalParam = GlobalParamData()
    static var gameStatistics = GameStatisticsStruct()
    static let dummyName = "dummy"
    static var initName = false
    static let oneGrad:CGFloat = CGFloat(M_PI) / 180


    static let dataStore = DataStore()
    static let cloudStore = CloudData()
    
    static let deviceType = UIDevice.currentDevice().modelName
    
    
    
    static let deviceConstants = DeviceConstants(deviceType: UIDevice.currentDevice().modelName)


    static var spriteGameDataArray: [SpriteGameData] = []
    // Constraints
    // static let myDevice = MyDevice()

    static func getAktNameIndex()->Int {
        for index in 0..<GV.spriteGameDataArray.count {
            if GV.spriteGameDataArray[index].name == GV.globalParam.aktName {
                return index
            }
        }
        return 0
    }
    
    static func pointOfCircle(radius: CGFloat, center: CGPoint, angle: CGFloat) -> CGPoint {
        let pointOfCircle = CGPoint (x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
        return pointOfCircle
    }

    
//    static func getAktSpriteGameData()->SpriteGameData {
//        for index in 0..<GV.spriteGameDataArray.count {
//            if GV.spriteGameDataArray[index].name == GV.globalParam.aktName {
//                return GV.spriteGameDataArray[index]
//            }
//        }
//        return GV.spriteGameDataArray[0]
//    }
    
//    static func random(min: Int, max: Int) -> Int {
//        let randomInt = min + Int(arc4random_uniform(UInt32(max + 1 - min)))
//        return randomInt
//    }
    
}


struct GlobalParamData {
    var aktName: String
    init() {
        aktName = GV.dummyName
    }
}

struct SeedDataStruct {
    var gameType: Int64
    var gameDifficulty: Int64
    var gameNumber: Int64
    var seed: NSData
    init(gameType: Int64, gameDifficulty:Int64, gameNumber: Int64, seed: NSData) {
        self.gameType = gameType
        self.gameDifficulty = gameDifficulty
        self.gameNumber = gameNumber
        self.seed = seed
    }
}

struct SpriteGameData {
    var name: String
    var aktLanguageKey: String
    var showHelpLines: Int
    var spriteLevelIndex: Int
    var spriteGameScore: Int
    var gameModus: Int
    var soundVolume: Float
    var musicVolume: Float
    
    init() {
        name = GV.globalParam.aktName
        aktLanguageKey = GV.language.getAktLanguageKey()
        showHelpLines = 0
        spriteLevelIndex = 0
        spriteGameScore = 0
        gameModus = GameModusCards
        soundVolume = 0.1
        musicVolume = 0.1
    }
    
}

struct GameStatisticsStruct {
    var name: String
    var level: Int
    var countPlays: Int
    var actScore: Int
    var levelScore: Int
    var bestScore: Int
    var bestTime: Int
    var allTime: Int
    var actTime: Int
    init() {
        name = GV.globalParam.aktName
        level = 0
        countPlays = 0
        actScore = 0
        bestScore = 0
        levelScore = 0
        allTime = 0
        actTime = 0
        bestTime = 10000
    }
    
}

struct DeviceConstants {
    var sizeMultiplier: CGFloat
    var buttonSizeMultiplier: CGFloat
    var cardPositionMultiplier: CGFloat
    
    init(deviceType: String) {
        switch deviceType {
            case "iPad Pro":
                sizeMultiplier = 2.2
                buttonSizeMultiplier = 0.9
                cardPositionMultiplier = 1.0
            case "iPad 2", "iPad 3", "iPad 4", "iPad Air", "iPad Air 2":
                sizeMultiplier = 1.6
                buttonSizeMultiplier = 1.2
                cardPositionMultiplier = 1.0
            case "iPad Mini", "iPad Mini 2", "iPad Mini 3", "iPad Mini 4":
                sizeMultiplier = 1.3
                buttonSizeMultiplier = 1.3
                cardPositionMultiplier = 1.5
            case "iPhone 6 Plus", "iPhone 6s Plus":
                sizeMultiplier = 1.2
                buttonSizeMultiplier = 1.8
                cardPositionMultiplier = 1.4
            case "iPhone 6", "iPhone 6s":
                sizeMultiplier = 1.0
                buttonSizeMultiplier = 2.0
                cardPositionMultiplier = 1.4
            case "iPhone 5s", "iPhone 5", "iPhone 5c":
                sizeMultiplier = 0.8
                buttonSizeMultiplier = 2.1
                cardPositionMultiplier = 1.3
            case "iPhone 4s", "iPhone 4":
                sizeMultiplier = 0.8
                buttonSizeMultiplier = 2.0
                cardPositionMultiplier = 1.1
           default:
                sizeMultiplier = 1.0
                buttonSizeMultiplier = 1.0
                cardPositionMultiplier = 1.0
        }
        
    }
    
}

struct LevelParam {
    
    var countContainers: Int
    var countPackages: Int
    var countSpritesProContainer: Int
    var countColumns: Int
    var countRows: Int
    var minProzent: Int
    var maxProzent: Int
    var spriteSize: Int
    var targetScoreKorr: Int
    
    init()
    {
        self.countContainers = 0
        self.countPackages = 1
        self.countSpritesProContainer = 0
        self.countColumns = 0
        self.countRows = 0
        self.minProzent = 0
        self.maxProzent = 0
//        self.containerSize = 0
        self.spriteSize = 0
        self.targetScoreKorr = 0
        //self.timeLimitKorr = 0
    }
    
}

struct ColumnRow {
    var column: Int
    var row: Int
    init () {
        column = NoValue
        row = NoValue
    }
    init(column: Int, row:Int) {
        self.column = column
        self.row = row
        
    }
}
struct FromToColumnRow {
    var fromColumnRow: ColumnRow
    var toColumnRow: ColumnRow
    
    init() {
        fromColumnRow = ColumnRow()
        toColumnRow = ColumnRow()
    }
    init(fromColumnRow: ColumnRow, toColumnRow: ColumnRow ) {
        self.fromColumnRow = fromColumnRow
        self.toColumnRow = toColumnRow
    }
}
func == (left: ColumnRow, right: ColumnRow)->Bool {
    return left.column == right.column && left.row == right.row
}
func == (left: FromToColumnRow, right: FromToColumnRow)->Bool {
    return left.fromColumnRow == right.fromColumnRow && left.toColumnRow == right.toColumnRow
}

func != (left: FromToColumnRow, right: FromToColumnRow)->Bool {
    return !(left.fromColumnRow == right.fromColumnRow && left.toColumnRow == right.toColumnRow)
}





infix operator ~> {}
private let queue = dispatch_queue_create("serial-worker", DISPATCH_QUEUE_SERIAL)

func ~> (backgroundClosure: () -> (),
    mainClosure: () -> ())
    
{
    dispatch_async(queue) {
        backgroundClosure()
        dispatch_async(dispatch_get_main_queue(), mainClosure)
        
    }
}

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
    case Added = 0, AddedFromCardStack, AddedFromShowCard, MovingStarted, Unification, Mirrored, FallingMovingSprite, FallingSprite, HitcounterChanged, FirstCardAdded, Removed, Exchanged, StopCycle, Nothing
    
    var statusName: String {
        let statusNames = [
            "Added",
            "AddedFromCardStack",
            "AddedFromShowCard",
            "MovingStarted",
            "Unification",
            "Mirrored",
            "FallingMovingSprite",
            "FallingSprite",
            "HitcounterChanged",
            "Removed",
            "Exchanged",
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
    var type: MySKNodeType = .SpriteType
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

//protocol JGXLineDelegate {
//    func findColumnRowDelegateFunc(fromPoint:CGPoint, toPoint:CGPoint)->FromToColumnRow
//}
