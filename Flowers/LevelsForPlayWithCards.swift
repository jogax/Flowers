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
        ScoreFactor = 6
        ScoreTime = 7
    }
    */
    var CardPlay = false
    var level: Int
    var aktLevel: LevelParam
    private var levelContent = [
        1: "1,4,4,40,60,40, 2.0, 30.0",
        2: "2,4,4,40,60,40, 2.0, 60.0",
        3: "1,5,5,40,60,35, 2.5, 30.0",
        4: "1,6,6,40,60,32, 2.5, 30.0",
        5: "1,7,7,40,60,31, 2.5, 30.0",
        6: "1,8,8,50,60,28, 3.0, 25.0",
        7: "1,9,9,80,100,25, 3.0, 25.0",
        8: "1,10,10,80,100,22, 4.0, 20",
        9: "1,11,11,80,100,19, 4.0, 30",
        10: "1,12,12,90,100,16, 5.0, 40",
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
            aktLevelParam.scoreFactor = (paramArr[6] as NSString).doubleValue
            aktLevelParam.scoreTime = (paramArr[7] as NSString).doubleValue
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
            level += 1
        }
        aktLevel = levelParam[level]
        return level
    }
    func getPrevLevel() -> Int {
        if level > 0 {
            level -= 1
        }
        aktLevel = levelParam[level]
        return level
    }
    
    func count()->Int {
        return levelContent.count
    }
    
}