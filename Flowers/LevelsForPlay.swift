//
//  LevelsForPlay.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2016. 01. 05..
//  Copyright © 2016. Jozsef Romhanyi. All rights reserved.
//

import SpriteKit


class LevelsForPlay {
    
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
        "10,0,0,0,0,0,0,0,0", //,2",//0",    // 5 times CountSpritesProContainer += 10
    ]
    private var levelContent = [
        1: "-1,4,13,4,4,30,90", //,50,35", //,1",//,20", // first param (levelCount) say, how many levels to make for this Line, if -1, than all levels according levelchanges
        2: "-1,4,13,5,5,30,90", //,60,35", //,3",//,3",
        3: "-1,4,20,6,6,30,90", //,50,30", //,3",//,3",
        4: "-1,4,20,7,7,30,90", //,50,30", //,2",//,3",
        5: "-1,4,20,8,8,30,90", //,40,25", //,2",//,3",
        6: "-1,4,20,9,9,30,90", //,40,25", //,2",//,3",
        7: "-1,4,30,10,10,30,90", //,40,25", //,2",//,3"
    ]
    var levelParam = [LevelParam]()
    
    init () {
        level = 0
        
        //let sizeMultiplier: CGFloat = 1.0 //UIDevice.currentDevice().modelConstants[GV.deviceType] //GV.onIpad ? 1.0 : 0.6
        for index in 1..<levelContent.count + 1 {
            let paramString = levelContent[index]
            let paramArr = paramString!.componentsSeparatedByString(",")
            var aktLevelParam: LevelParam = LevelParam()
            let levelCount = Int(paramArr[0]) >= 0 ? Int(paramArr[0]) : 1000
            aktLevelParam.countContainers = Int(paramArr[1])!
            aktLevelParam.countSpritesProContainer = Int(paramArr[2])!
            aktLevelParam.countColumns = Int(paramArr[3])!
            aktLevelParam.countRows = Int(paramArr[4])!
            aktLevelParam.minProzent = Int(paramArr[5])!
            aktLevelParam.maxProzent = Int(paramArr[6])!
            //            aktLevelParam.containerSize = CGFloat(Int(paramArr[7])!) * sizeMultiplier
            //            aktLevelParam.spriteSize = CGFloat(Int(paramArr[8])!) * sizeMultiplier
            //aktLevelParam.targetScoreKorr = Int(paramArr[9])!
            //aktLevelParam.timeLimitKorr = Int(paramArr[10])!
            levelParam.append(aktLevelParam)
            
            let aktIndex = levelParam.count - 1
            for levelChangeIndex in 0..<levelChanges.count {
                let levelChangeArr = levelChanges[levelChangeIndex].componentsSeparatedByString(",")
                let loopValue = Int(levelChangeArr[LevelParamsType.LevelCount.rawValue])
                for _ in 0..<loopValue! {
                    aktLevelParam.countContainers = levelParam.last!.countContainers + Int(levelChangeArr[LevelParamsType.CountContainers.rawValue])!
                    aktLevelParam.countSpritesProContainer = levelParam.last!.countSpritesProContainer + Int(levelChangeArr[LevelParamsType.CountSpritesProContainer.rawValue])!
                    aktLevelParam.countColumns = levelParam.last!.countColumns + Int(levelChangeArr[LevelParamsType.CountColumns.rawValue])!
                    aktLevelParam.countRows = levelParam.last!.countRows + Int(levelChangeArr[LevelParamsType.CountRows.rawValue])!
                    aktLevelParam.minProzent = levelParam.last!.minProzent + Int(levelChangeArr[LevelParamsType.MinProzent.rawValue])!
                    aktLevelParam.maxProzent = levelParam.last!.maxProzent + Int(levelChangeArr[LevelParamsType.MaxProzent.rawValue])!
                    //                    aktLevelParam.containerSize = levelParam.last!.containerSize + CGFloat(Int(levelChangeArr[LevelParamsType.ContainerSize.rawValue])!)
                    //                    aktLevelParam.spriteSize = levelParam.last!.spriteSize + CGFloat(Int(levelChangeArr[LevelParamsType.SpriteSize.rawValue])!)
                    //aktLevelParam.targetScoreKorr = levelParam.last!.targetScoreKorr + Int(levelChangeArr[LevelParamsType.TargetScoreKorr.rawValue])!
                    //aktLevelParam.timeLimitKorr = levelParam.last!.timeLimitKorr + Int(levelChangeArr[LevelParamsType.TimeLimitKorr.rawValue])!
                    levelParam.append(aktLevelParam)
                    if levelParam.count - aktIndex > levelCount! {
                        break
                    }
                }
                if levelParam.count - aktIndex > levelCount! {
                    break
                }
            }
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
    
}
