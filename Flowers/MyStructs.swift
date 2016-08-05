//
//  MyStructs.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 18.04.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import GameKit
import RealmSwift
import AVFoundation


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
    static let freeGameCount = 250
    static var peerToPeerService: PeerToPeerServiceManager?

    static var dX: CGFloat = 0
    static var speed: CGSize = CGSizeZero
    static var touchPoint = CGPointZero
    static var gameSize = 5
    static var gameNr = 0
    static var gameSizeMultiplier: CGFloat = 1.0
    static let onIpad = UIDevice.currentDevice().model.hasSuffix("iPad")
    static var ipadKorrektur: CGFloat = 0
    static var levelsForPlay = LevelsForPlayWithCards()
    static var mainViewController: UIViewController?
    static let language = Language()
    static var showHelpLines = 0
//    static var soundVolume: Float = 0
//    static var musicVolume: Float = 0
//    static var globalParam = GlobalParamData()
    static var dummyName = GV.language.getText(.TCGuest)
    static var initName = false
    static let oneGrad:CGFloat = CGFloat(M_PI) / 180
    static let timeOut = "TimeOut"
    static let IAmBusy = "Busy"

//    static let dataStore = DataStore()
//    static let cloudStore = CloudData()
    
    static let deviceType = UIDevice.currentDevice().modelName
    
    
    
    static let deviceConstants = DeviceConstants(deviceType: UIDevice.currentDevice().modelName)

    static var countPlayers: Int = 1

    static var player: PlayerModel?
    
    static func pointOfCircle(radius: CGFloat, center: CGPoint, angle: CGFloat) -> CGPoint {
        let pointOfCircle = CGPoint (x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
        return pointOfCircle
    }
    
    enum RealmRecordType: Int {
        case GameModel, PlayerModel, OpponentModel, StatisticModel
    }
    
    static func createNewRecordID(recordType: RealmRecordType)->Int {
        var recordID: RecordIDModel
        var ID = 0
        let inWrite = realm.inWriteTransaction
        if !inWrite {
            realm.beginWrite()
        }
        if realm.objects(RecordIDModel).count == 0 {
            recordID = RecordIDModel()
            realm.add(recordID)
        } else  {
            recordID = realm.objects(RecordIDModel).first!
        }
        switch recordType {
        case .GameModel:
            ID = recordID.gameModelID
            recordID.gameModelID += 1
        case .PlayerModel:
            ID = recordID.playerModelID
            recordID.playerModelID += 1
        case .OpponentModel:
            ID = recordID.opponentModelID
            recordID.opponentModelID += 1
        case .StatisticModel:
            ID = recordID.statisticModelID
            recordID.statisticModelID += 1
        }
        if !inWrite {
            try! realm.commitWrite()
        }
        return ID
    }
    
    static func createNewPlayer(isActPlayer: Bool...)->Int {
//        let newID = GV.playerID.getNewID()!
        let newID = GV.createNewRecordID(.PlayerModel)
//        if newID != 0 {
            let newPlayer = PlayerModel()
            newPlayer.aktLanguageKey = GV.language.getPreferredLanguage()
            newPlayer.name = GV.language.getText(.TCAnonym)
            newPlayer.isActPlayer = isActPlayer.count == 0 ? false : isActPlayer[0]
            newPlayer.ID = newID
            try! realm.write({
                realm.add(newPlayer)
            })
//        }
        return newID
    }
    
    static func randomNumber(max: Int)->Int
    {
        let randomNumber = Int(arc4random_uniform(UInt32(max)))
        return randomNumber
    }

}

struct Names {
    var name: String
    var isActPlayer: Bool
    init() {
        name = ""
        isActPlayer = false
    }
    init(name:String, isActPlayer: Bool){
        self.name = name
        self.isActPlayer = isActPlayer
    }
}


struct GameParamStruct {
    var isActPlayer: Bool
    var nameID: Int
    var name: String
    var aktLanguageKey: String
    var levelIndex: Int
    var gameScore: Int
    var gameModus: Int
    var soundVolume: Float
    var musicVolume: Float
    
    init() {
        nameID = GV.countPlayers
        isActPlayer = false
        name = GV.dummyName
        aktLanguageKey = GV.language.getAktLanguageKey()
        levelIndex = 0
        gameScore = 0
        gameModus = GameModusCards
        soundVolume = 0.1
        musicVolume = 0.1
    }
    
}


enum DeviceTypes: Int {
    case iPadPro12_9 = 0, iPad2, iPadMini, iPhone6Plus, iPhone6, iPhone5, iPhone4, none
}


struct DeviceConstants {
    var sizeMultiplier: CGFloat
    var buttonSizeMultiplier: CGFloat
    var cardPositionMultiplier: CGFloat
    var fontSizeMultiplier: CGFloat
    var imageSizeMultiplier: CGFloat
    var type: DeviceTypes
    
    init(deviceType: String) {
        switch deviceType {
            case "iPad Pro":
                sizeMultiplier = 2.2
                buttonSizeMultiplier = 0.9
                cardPositionMultiplier = 1.0
                fontSizeMultiplier = 0.10
                imageSizeMultiplier = 1.0
                type = .iPadPro12_9
            case "iPad 2", "iPad 3", "iPad 4", "iPad Air", "iPad Air 2":
                sizeMultiplier = 1.6
                buttonSizeMultiplier = 1.2
                cardPositionMultiplier = 1.0
                fontSizeMultiplier = 0.20
                imageSizeMultiplier = 1.3
                type = .iPad2
            case "iPad Mini", "iPad Mini 2", "iPad Mini 3", "iPad Mini 4":
                sizeMultiplier = 1.3
                buttonSizeMultiplier = 1.3
                cardPositionMultiplier = 1.5
                fontSizeMultiplier = 0.10
                imageSizeMultiplier = 1.0
                type = .iPadMini
            case "iPhone 6 Plus", "iPhone 6s Plus":
                sizeMultiplier = 1.0
                buttonSizeMultiplier = 1.8
                cardPositionMultiplier = 1.4
                fontSizeMultiplier = 0.20
                imageSizeMultiplier = 1.0
                type = .iPhone6Plus
            case "iPhone 6", "iPhone 6s":
                sizeMultiplier = 1.0
                buttonSizeMultiplier = 2.0
                cardPositionMultiplier = 1.4
                fontSizeMultiplier = 0.20
                imageSizeMultiplier = 0.8
                type = .iPhone6
            case "iPhone 5s", "iPhone 5", "iPhone 5c":
                sizeMultiplier = 0.8
                buttonSizeMultiplier = 2.1
                cardPositionMultiplier = 1.3
                fontSizeMultiplier = 0.20
                imageSizeMultiplier = 0.7
                type = .iPhone5
            case "iPhone 4s", "iPhone 4":
                sizeMultiplier = 0.8
                buttonSizeMultiplier = 2.0
                cardPositionMultiplier = 1.1
                fontSizeMultiplier = 0.10
                imageSizeMultiplier = 0.7
                type = .iPhone4
           default:
                sizeMultiplier = 1.0
                buttonSizeMultiplier = 1.0
                cardPositionMultiplier = 1.0
                fontSizeMultiplier = 1.0
                imageSizeMultiplier = 1.0
                type = .none
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
    var scoreFactor: Double
    var scoreTime: Double
    
    init()
    {
        self.countContainers = 0
        self.countPackages = 1
        self.countSpritesProContainer = 0
        self.countColumns = 0
        self.countRows = 0
        self.minProzent = 0
        self.maxProzent = 0
        self.spriteSize = 0
        self.scoreTime = 0
        self.scoreFactor = 0
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
    return !(left == right)
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
    case Added = 0, AddedFromCardStack, AddedFromShowCard, MovingStarted, Unification, Mirrored, FallingMovingSprite, FallingSprite, HitcounterChanged, FirstCardAdded, Removed, StopCycle, Nothing
    
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

enum PeerToPeerCommands: Int {
    case ErrorValue = 0,
    MyNameIs,
            //          
            //      parameters: 1 - myName
    MyNameIsChanged,
    //
    //      parameters: 1 - myName
    //                  2 - oldName
    //                  2 - deviceName
    IWantToPlayWithYou, //sendMessage
            //
            //      parameters: 1 - myName
            //                  2 - levelID
            //                  3 - gameNumber to play
            //      answer: "OK" - play starts
            //              "Cancel" - opponent will not play
    MyScoreHasChanged, // sendInfo
            //
            //      parameters: 1 - Score
            //                  2 - Count Cards
    GameIsFinished, //sendInfo
            //
            //      parameters: 1: Score
    DidEnterBackGround, // sendInfo
            //
            //      parameter:  
    MaxValue
    
    var commandName: String {
        return String(self.rawValue)
    }
    
    static func decodeCommand(commandName: String)->PeerToPeerCommands {
        if let command = Int(commandName) {
            if command < PeerToPeerCommands.MaxValue.rawValue && command > PeerToPeerCommands.ErrorValue.rawValue {
                return PeerToPeerCommands(rawValue: command)!
            } else {
                return ErrorValue
            }
        } else {
            return ErrorValue
        }
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
    var countScore: Int = 0 // Score of Game 
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

func sleep(sleepTime: Double) {
    var count = 0
    let actTime = NSDate()
    while NSDate().timeIntervalSinceDate(actTime) < sleepTime {
        count += 1
    }
}

func stringArrayToNSData(array: [String]) -> NSData {
    let data = NSMutableData()
    let terminator = [0]
    for string in array {
        if let encodedString = string.dataUsingEncoding(NSUTF8StringEncoding) {
            data.appendData(encodedString)
            data.appendBytes(terminator, length: 1)
        }
        else {
            NSLog("Cannot encode string \"\(string)\"")
        }
    }
    return data
}

func nsDataToStringArray(data: NSData) -> [String] {
    var decodedStrings = [String]()
    
    var stringTerminatorPositions = [Int]()
    
    var currentPosition = 0
    data.enumerateByteRangesUsingBlock() {
        buffer, range, stop in
        
        let bytes = UnsafePointer<UInt8>(buffer)
        for i in 0..<range.length {
            if bytes[i] == 0 {
                stringTerminatorPositions.append(currentPosition)
            }
            currentPosition += 1
        }
    }
    
    var stringStartPosition = 0
    for stringTerminatorPosition in stringTerminatorPositions {
        let encodedString = data.subdataWithRange(NSMakeRange(stringStartPosition, stringTerminatorPosition - stringStartPosition))
        let decodedString =  NSString(data: encodedString, encoding: NSUTF8StringEncoding) as! String
        decodedStrings.append(decodedString)
        stringStartPosition = stringTerminatorPosition + 1
    }
    
    return decodedStrings
}


let atlas = SKTextureAtlas(named: "sprites")

@objc protocol SettingsDelegate {
    func settingsDelegateFunc()
}

//protocol JGXLineDelegate {
//    func findColumnRowDelegateFunc(fromPoint:CGPoint, toPoint:CGPoint)->FromToColumnRow
//}
