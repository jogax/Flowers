//
//  CloadData.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 12. 12..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//


import Foundation
import CloudKit

class CloudData {
    var container: CKContainer
    var privatDB: CKDatabase
    var publicDB: CKDatabase
    var wait = true
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privatDB = container.privateCloudDatabase
    }
    
    func saveRecord(seedData: SeedDataStruct) {
        let seedDataRecord = CKRecord(recordType: "SeedData")
        seedDataRecord.setValue(NSNumber(longLong: seedData.gameType), forKey: "gameType")
        seedDataRecord.setValue(NSNumber(longLong: seedData.gameDifficulty), forKey: "gameDifficulty")
        seedDataRecord.setValue(NSNumber(longLong: seedData.gameNumber), forKey: "gameNumber")
        seedDataRecord.setValue(seedData.seed, forKey: "seed")
        publicDB.saveRecord(seedDataRecord, completionHandler: { returnRecord, error in
            if let err = error {
                print("error: \(err)")
            }
        })
    }
    
    func readRecord(gameType: Int64, gameDifficulty: Int64, gameNumber: Int64) {
        let p1 = NSPredicate(format: "gameDifficulty = %d", gameDifficulty)
        let p2 = NSPredicate(format: "gameNumber = %d", gameNumber)
        let p3 = NSPredicate(format: "gameType = %d", gameNumber)
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [p1, p2, p3])
        let query = CKQuery(recordType: "SeedData", predicate: predicate)
        privatDB.performQuery(query, inZoneWithID: nil) {
            results, error in
            if error != nil {
                
            } else {
                //println("results:\(results.count)")
                self.wait = false
            }
        }
        
    }
    
}
