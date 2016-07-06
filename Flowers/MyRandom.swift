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
    var game: GameModel
    //var seed: NSData
    init(gameNumber: Int, levelID: Int) {
        
//        let (seedDataStruct, exists) = GV.dataStore.readSeedDataRecord(seedIndex)
        if let gameData = realm.objects(GameModel).filter("gameNumber = %d and levelID = %d", gameNumber, levelID).first {
            game = gameData
            random = GKARC4RandomSource(seed: gameData.seedData)
            random.dropValuesWithCount(2048)
        }
        else {
//            random = GKARC4RandomSource()
            let foundedGame = realm.objects(GameModel).filter("gameNumber = %d", gameNumber).first!
            random = GKARC4RandomSource(seed: foundedGame.seedData)
            game = GameModel()
            game.seedData = random.seed
            game.levelID = levelID
            game.ID = gameNumber
            try! realm.write({
                realm.add(game)
                foundedGame.played = true
            })
            random.dropValuesWithCount(2048)
        }
    }
    
    func getRandomInt(min: Int, max: Int) -> Int {
         return min + random.nextIntWithUpperBound((max + 1 - min))
    }

    
}
