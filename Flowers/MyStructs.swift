//
//  MyStructs.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 18.04.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

//import Foundation
import UIKit

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
    static let dummyName = "dummy"
    static var initName = false

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

struct DeviceConstants {
    var sizeMultiplier: CGFloat
    
    init(deviceType: String) {
        switch deviceType {
        case "iPad Pro":
            sizeMultiplier = 2.2
            case "iPad 2", "iPad 3", "iPad 4", "iPad Air", "iPad Air 2":
                sizeMultiplier = 1.8
            case "iPad Mini", "iPad Mini 2", "iPad Mini 3", "iPad Mini 4":
                sizeMultiplier = 1.3
            case "iPhone 6 Plus", "iPhone 6s Plus":
                sizeMultiplier = 1.0
            case "iPhone 6", "iPhone 6s":
                sizeMultiplier = 0.9
            case "iPhone 5s", "iPhone 5", "iPhone 5c":
                sizeMultiplier = 0.8
            case "iPhone 4s", "iPhone 4":
                sizeMultiplier = 0.7
           default:
                sizeMultiplier = 1.0
        }
        
    }
    
}

struct LevelParam {
    
    var countContainers: Int
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

//struct Level {
//    var countContainers: Int
//    var countSpritesProContainer: Int
//    var targetScoreKorr: Double
//    var countColumns: Int
//    var countRows: Int
//    var minProzent: Int
//    var maxProzent: Int
//    var containerSize: Int
//    var spriteSize: Int
//    
//    init() {
//        countContainers = 0
//        countSpritesProContainer = 0
//        targetScoreKorr = 0
//        countColumns = 0
//        countRows = 0
//        minProzent = 0
//        maxProzent = 0
//        containerSize = 0
//        spriteSize = 0
//    }
//}


