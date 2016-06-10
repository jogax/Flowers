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
        let realm: Realm
        try! realm = Realm()
        try! realm.write({
            realm.delete(realm.objects(GamePredefinitionModel))
        })
        for index in 0..<countGames {
            let random = GKARC4RandomSource()
            let game = GamePredefinitionModel()
            game.seedData = random.seed
            game.gameNumber = index
            try! realm.write({
                realm.add(game)
            })
        }
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let url = NSURL(fileURLWithPath: documentsPath + "/MyDB.realm")
        try! realm.writeCopyToURL(url, encryptionKey: nil)
        
    }
    
}
