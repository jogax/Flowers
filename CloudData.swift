//
//  CloadData.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 12. 12..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//


import CloudKit
import RealmSwift


class CloudData {
    var container: CKContainer
//    var privatDB: CKDatabase
    var publicDB: CKDatabase
    var wait = true
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
//        privatDB = container.privateCloudDatabase
    }
    
    func saveRecord(gameNumber: Int, seed: NSData) {
        let SeedDataRecord = CKRecord(recordType: "SeedData")
        SeedDataRecord.setValue(NSNumber(longLong: Int64(gameNumber)), forKey: "gameNumber")
        SeedDataRecord.setValue(seed, forKey: "seed")
        publicDB.saveRecord(SeedDataRecord, completionHandler: { (returnRecord, error) in
            if let _ = error {
                print("error by save: \(gameNumber)", error)
            } else {
                print("OK, check now:", gameNumber)
                let predicate = NSPredicate(format: "gameNumber = %d", gameNumber)
                let query = CKQuery(recordType: "SeedData", predicate: predicate)
                self.publicDB.performQuery(query, inZoneWithID: nil) {
                    results, error in
                    if let _  = error {
                        print("error by check \(gameNumber)", error)
                    } else {
                        print("OK by check \(gameNumber)")
                        let realm: Realm = try! Realm()
                        try! realm.write({
                            realm.objects(GameModel).filter("gameNumber = %d", gameNumber).first!.played = true
                        })
                    }
                }

            }
            
        })
    }
    
    
    
    func readRecord(gameNumber: Int) {
        let predicate = NSPredicate(format: "gameNumber = %d", gameNumber)
        let query = CKQuery(recordType: "SeedData", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) {
            results, error in
            if error != nil {
                print("error by load \(gameNumber)", error)
            } else {
                //println("results:\(results.count)")
                let record = results![0]
//                seed = record.objectForKey("seed") as? NSData
                print("OK by load \(gameNumber)")
                let gameModel = GameModel()
                gameModel.gameNumber = gameNumber
                gameModel.seedData = (record.objectForKey("seed") as? NSData)!
                let realm: Realm = try! Realm()
                try! realm.write({
                    realm.add(gameModel)
                })
            }
        }
        
    }
}
