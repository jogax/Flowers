//
//  CreateGamePredefiniton.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 09/06/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//
import GameplayKit
import RealmSwift

class CreateGamePredefinition {
    init(countGames: Int) {
        let maxGameNumber = realm.objects(GameModel).count
        if maxGameNumber < countGames {
            for index in maxGameNumber..<countGames {
                let random = GKARC4RandomSource()
                let game = GameModel()
                game.seedData = random.seed
                game.gameNumber = index
                try! realm.write({
                    realm.add(game)
                })
            }
        }
        let gameRecords = realm.objects(GameModel).filter("stored = false")
        print("\(gameRecords.count) records to save")
        for record in gameRecords {
//            if !record.stored {
//                GV.cloudStore.saveRecord(record.gameNumber, seed: record.seedData!)
//                sleep(0.05)
//            }
        }
    }
}
