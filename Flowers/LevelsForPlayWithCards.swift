//
//  LevelsForPlayWithCards.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 12. 28..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import SpriteKit


class LevelsForPlayWithCards {

    /*
    enum LevelParamsType: Int {
        CountPackages = 0,
        CountColumns = 1,
        CountRows = 2,
        MinProzent = 3,
        MaxProzent = 4,
        SpriteSize = 5,
        //TargetScoreKorr = 9//,
        //TimeLimitKorr = 10
    }
    */
    var CardPlay = false
    var level: Int
    var aktLevel: LevelParam
    var levelChanges = [
        "1,0,0,0,0,0,0,0,0", //,2",//0",    // 5 times CountSpritesProContainer += 10
    ]
    private var levelContent = [
        1: "1,4,4,70,70,40",
        2: "1,5,5,70,70,37",
        3: "1,6,6,60,70,32",
        4: "1,7,7,60,70,31",
        5: "1,8,8,60,70,28",
        6: "1,9,9,80,100,25",
        7: "1,10,10,80,100,22",
        8: "2,11,11,80,100,19",
        9: "2,12,12,90,100,16",
    ]
    var levelParam = [LevelParam]()
    
    init () {
        level = 0
        
        //let sizeMultiplier: CGFloat = 1.0 //UIDevice.currentDevice().modelConstants[GV.deviceType] //GV.onIpad ? 1.0 : 0.6
        for index in 1..<levelContent.count + 1 {
            let paramString = levelContent[index]
            let paramArr = paramString!.componentsSeparatedByString(",")
            var aktLevelParam: LevelParam = LevelParam()
            aktLevelParam.countContainers = 4
            aktLevelParam.countPackages = Int(paramArr[0])!
            aktLevelParam.countColumns = Int(paramArr[1])!
            aktLevelParam.countRows = Int(paramArr[2])!
            aktLevelParam.minProzent = Int(paramArr[3])!
            aktLevelParam.maxProzent = Int(paramArr[4])!
            aktLevelParam.spriteSize = Int(paramArr[5])!
            levelParam.append(aktLevelParam)
        }
        aktLevel = levelParam[0]
    }
    
    func setAktLevel(level: Int) {
        self.level = level
        aktLevel = levelParam[level]
    }
    
    func getNextLevel() -> Int {
        if level < levelParam.count {
            level++
        }
        aktLevel = levelParam[level]
        return level
    }
    func getPrevLevel() -> Int {
        if level > 0 {
            level--
        }
        aktLevel = levelParam[level]
        return level
    }
    
}