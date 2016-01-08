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
        case LevelCount = 0,
        CountContainers = 1,
        CountSpritesProContainer = 2,
        CountColumns = 3,
        CountRows = 4,
        MinProzent = 5,
        MaxProzent = 6,
        ContainerSize = 7,
        SpriteSize = 8,
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
        1: "13,4,4,0,100,40", //,50,35", //,1",//,20",
        2: "13,5,5,0,100,37", //,60,35", //,3",//,3",
        3: "13,6,6,0,100,32", //,50,30", //,3",//,3",
        4: "13,7,7,30,80,31", //,50,30", //,2",//,3",
        5: "13,8,8,0,100,28", //,40,25", //,2",//,3",
        6: "13,9,9,0,100,25", //,40,25", //,2",//,3",
        7: "13,10,10,0,100,22", //,40,25", //,2",//,3"
        8: "26,4,4,0,100,40", //,50,35", //,1",//,20",
        9: "26,5,5,0,100,37", //,60,35", //,3",//,3",
        10: "26,6,6,0,100,32", //,50,30", //,3",//,3",
        11: "26,7,7,0,100,31", //,50,30", //,2",//,3",
        12: "26,8,8,0,100,28", //,40,25", //,2",//,3",
        13: "26,9,9,0,100,25", //,40,25", //,2",//,3",
        14: "26,10,10,0,100,22", //,40,25", //,2",//,3"
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
            aktLevelParam.countSpritesProContainer = Int(paramArr[0])!
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