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
    let levelChanges = [
        "5,0,1,0,0,0,0,0,0", //,2",//0",    // 5 times CountSpritesProContainer += 10
        "1,0,1,1,1,0,0,0,0", //,2",//-1",     // 1 time CountColumns += 1, CountRows += 1, TargetScoreCorr += 1
        "5,0,1,0,0,5,0,0,0", //,2",//,0",     // 5 times CountSpritesProContainer += 5, MinProzent += 5, TargetScoreCorr += 1
        "1,0,0,1,1,0,0,0,0", //,1",//,-1",     // 1 time CountColumns += 1, CountRows += 1, TargetScoreCorr += 1
        "5,0,1,0,0,0,5,0,0", //,0",//,0",     // 5 times MinProzent -= 3, MaxProzent += 5
        "2,0,1,0,0,0,0,0,0", //,0",//,0",    // 2 times CountSpritesProContainer += 5
        "1,0,0,1,1,0,0,0,0", //,1",//,0",     // 1 time CountColumns += 1, CountRows += 1, TargetScoreCorr += 1
        "5,0,10,0,0,0,0,0,0", //,1",//,0",     // 5 times CountSpritesProContainer + 5, TargetScoreCorr += 1
        "1,0,5,0,0,0,0,0,0", //,0",//,0",    // 2 times TimeLimitKorr -= 1
        "1,0,0,1,1,0,0,0,0", //,1",//,0",     // 1 time CountColumns += 1, CountRows += 1, TargetScoreCorr += 1
        "5,0,10,0,0,0,0,0,0", //,0",//,0"     // 5 times CountSpritesProContainer += 10
    ]
    private var levelContent = [
        1: "-1,4,10,5,5,30,70,50,35", //,1",//,20", // first param (levelCount) say, how many levels to make for this Line, if -1, than all levels according levelchanges
        2: "-1,4,20,5,5,30,70,60,35", //,3",//,3",
        3: "-1,4,20,5,5,30,70,50,30", //,3",//,3",
        4: "-1,4,20,5,5,30,70,50,30", //,2",//,3",
        5: "-1,4,20,5,5,30,70,40,25", //,2",//,3",
        6: "-1,4,20,5,5,30,70,40,25", //,2",//,3",
        7: "-1,4,30,5,5,30,70,40,25", //,2",//,3"
    ]
    var levelParam = [LevelParam]()
    
    init () {
        level = 0
        
        let sizeMultiplier: CGFloat = UIDevice.currentDevice().modelSizeConstant //GV.onIpad ? 1.0 : 0.6
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
            aktLevelParam.containerSize = CGFloat(Int(paramArr[7])!) * sizeMultiplier
            aktLevelParam.spriteSize = CGFloat(Int(paramArr[8])!) * sizeMultiplier
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
                    aktLevelParam.containerSize = levelParam.last!.containerSize + CGFloat(Int(levelChangeArr[LevelParamsType.ContainerSize.rawValue])!)
                    aktLevelParam.spriteSize = levelParam.last!.spriteSize + CGFloat(Int(levelChangeArr[LevelParamsType.SpriteSize.rawValue])!)
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