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
        1: "1,4,4,70,70,40", //,50,35", //,1",//,20",
        2: "1,5,5,70,70,37", //,60,35", //,3",//,3",
        3: "1,6,6,30,70,32", //,50,30", //,3",//,3",
        4: "1,7,7,30,70,31", //,50,30", //,2",//,3",
        5: "1,8,8,30,70,28", //,40,25", //,2",//,3",
        6: "1,9,9,0,100,25", //,40,25", //,2",//,3",
        7: "1,10,10,0,100,22", //,40,25", //,2",//,3"
        8: "2,11,11,0,100,19", //,40,25", //,2",//,3"
        9: "2,4,4,0,70,40", //,50,35", //,1",//,20",
        10: "2,5,5,0,70,37", //,60,35", //,3",//,3",
        11: "2,6,6,0,70,32", //,50,30", //,3",//,3",
        12: "2,7,7,0,70,31", //,50,30", //,2",//,3",
        13: "2,8,8,0,70,28", //,40,25", //,2",//,3",
        14: "2,9,9,0,70,25", //,40,25", //,2",//,3",
        15: "2,10,10,0,70,22", //,40,25", //,2",//,3"
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
        level++
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