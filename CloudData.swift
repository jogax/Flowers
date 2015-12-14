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
        seedDataRecord.setValue(NSNumber(longLong: seedData.gameDifficulty), forKey: "gameName")
        seedDataRecord.setValue(NSNumber(longLong: seedData.gameNumber), forKey: "gameNumber")
        seedDataRecord.setValue(seedData.seed, forKey: "countLines")
        privatDB.saveRecord(seedDataRecord, completionHandler: { returnRecord, error in
            if let err = error {
                print("error: \(err)")
            }
        })
    }
    
    func readRecord(gameDifficulty: Int16, gameNumber: Int64) {
        let p1 = NSPredicate(format: "gameDifficulty = %ld", gameDifficulty)
        let p2 = NSPredicate(format: "gameNumber = %ld", gameNumber)
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [p1, p2])
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
