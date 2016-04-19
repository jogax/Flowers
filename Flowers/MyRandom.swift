//
//  MyRandom.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 12. 12..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import GameplayKit


//struct SeedIndex: Hashable {
//    var gameNumber: Int64
//    var hashValue: Int {
//        get {
//            let hash = gameNumber
//            return Int(hash)
//        }
//    }
//    
//}
//
//func == (lhs: SeedIndex, rhs: SeedIndex) -> Bool {
//    return lhs.hashValue == rhs.hashValue
//}
//
class MyRandom {
//    static var seedLibrary = [SeedIndex:NSData]()
    var random: GKARC4RandomSource
    //var seed: NSData
    init(gameID: Int, levelID: Int) {
        
//        let (seedDataStruct, exists) = GV.dataStore.readSeedDataRecord(seedIndex)
        if let gameData = GV.realm.objects(GameModel).filter("ID = %d", gameID).first {
            random = GKARC4RandomSource(seed: gameData.seedData)
            random.dropValuesWithCount(2048)
        }
        else {
            GV.realm.beginWrite()
            random = GKARC4RandomSource()
            let gameData = GameModel()
            gameData.seedData = random.seed
            gameData.ID = gameID
            gameData.levelID = levelID
            GV.realm.add(gameData)
            try! GV.realm.commitWrite()
            random.dropValuesWithCount(2048)
        }
    }
    
    func getRandomInt(min: Int, max: Int) -> Int {
         return min + random.nextIntWithUpperBound((max + 1 - min))
    }

    
}
