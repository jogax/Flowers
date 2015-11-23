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

//    static var gameControll = GameControll.Finger
//    static var joyStickRadius: CGFloat = 0.0
//    static var rectSize: CGFloat = 0 // rectSize in Choose Table
//    static var gameRectSize: CGFloat = 0 // rectSize in gameboard

    static let language = Language()
    static var showHelpLines = 0
    static var globalParam = GlobalParamData()
    static let dummyName = "dummy"
    static var initName = false

    static let dataStore = DataStore()

    static var spriteGameData = SpriteGameData()
//    static var sublayer = CALayer()
    static var spriteGameDataArray: [SpriteGameData] = []
    // Constraints
    // static let myDevice = MyDevice()
    
    static func random(min: Int, max: Int) -> Int {
        let randomInt = min + Int(arc4random_uniform(UInt32(max + 1 - min)))
        return randomInt
    }


    
}


struct GlobalParamData {
    var aktName: String
    init() {
        aktName = GV.dummyName
    }
}

struct SpriteGameData {
    var name: String
    var aktLanguageKey: String
    var showHelpLines: Int64
    var spriteLevelIndex: Int64
    var spriteGameScore: Int64
    
    init() {
        name = GV.globalParam.aktName
        aktLanguageKey = GV.language.getAktLanguageKey()
        showHelpLines = 0
        spriteLevelIndex = 0
        spriteGameScore = 0
    }
    
}

struct LevelParam {
    
    var countContainers: Int
    var countSpritesProContainer: Int
    var countColumns: Int
    var countRows: Int
    var minProzent: Int
    var maxProzent: Int
    var containerSize: Int
    var spriteSize: Int
    var targetScoreKorr: Int
    var timeLimitKorr: Int
    
    init()
    {
        self.countContainers = 0
        self.countSpritesProContainer = 0
        self.countColumns = 0
        self.countRows = 0
        self.minProzent = 0
        self.maxProzent = 0
        self.containerSize = 0
        self.spriteSize = 0
        self.targetScoreKorr = 0
        self.timeLimitKorr = 0
    }
    
}

struct Level {
    var countContainers: Int
    var countSpritesProContainer: Int
    var targetScoreKorr: Double
    var countColumns: Int
    var countRows: Int
    var minProzent: Int
    var maxProzent: Int
    var containerSize: Int
    var spriteSize: Int
    
    init() {
        countContainers = 0
        countSpritesProContainer = 0
        targetScoreKorr = 0
        countColumns = 0
        countRows = 0
        minProzent = 0
        maxProzent = 0
        containerSize = 0
        spriteSize = 0
    }
}


