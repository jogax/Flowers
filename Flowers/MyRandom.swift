//
//  MyRandom.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 12. 12..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import GameplayKit


struct SeedIndex: Hashable {
    var gameType: Int64
    var gameDifficulty: Int64
    var gameNumber: Int64
    var hashValue: Int {
        get {
            let hash = gameDifficulty * gameNumber
            return Int(hash)
        }
    }
    
}

func == (lhs: SeedIndex, rhs: SeedIndex) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class MyRandom {
    static var seedLibrary = [SeedIndex:NSData]()
    var random: GKARC4RandomSource
    //var seed: NSData
    init(seedIndex: SeedIndex) {
        let (seedDataStruct, exists) = GV.dataStore.readSeedDataRecord(seedIndex)
        if exists {
            random = GKARC4RandomSource(seed: seedDataStruct.seed)
            random.dropValuesWithCount(1024)
        }
        else {
            random = GKARC4RandomSource()
            let seedData = SeedDataStruct(gameType: seedIndex.gameType, gameDifficulty: seedIndex.gameDifficulty, gameNumber: seedIndex.gameNumber, seed: random.seed)
            GV.dataStore.saveSeedDataRecord(seedData)
            GV.cloudStore.saveRecord(seedData)
            random.dropValuesWithCount(1024)
        }
    }
    
    func getRandomInt(min: Int, max: Int) -> Int {
 //       let randomInt = min + Int(arc4random_uniform(UInt32(max + 1 - min)))
        return min + random.nextIntWithUpperBound((max + 1 - min))
        //return randomInt
    }

    
}
