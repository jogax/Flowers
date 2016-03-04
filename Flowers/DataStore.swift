//
//  DataStore.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 15.04.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import CoreData
import CloudKit


let GameModusFlowers = 0
let GameModusCards = 1


class DataStore {
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    var error: NSError?
    var spriteGameEntity: SpriteGame?
    var globalParamEntity: GlobalParam?
    var seedDataEntity: SeedData?
    var gameStatisticsEntity: GameStatistics?
    
    //var appVariables: AppVariables?
    var exists: Bool = true
    var spriteGameDescription:NSEntityDescription?
    var globalParamDescription:NSEntityDescription?
    var seedDataDescription:NSEntityDescription?
    var gameStatisticsDescription:NSEntityDescription?
    
    init() {
        
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //_ = appDelegate.managedObjectContext
        spriteGameDescription = NSEntityDescription.entityForName("SpriteGame", inManagedObjectContext:managedObjectContext)
        globalParamDescription = NSEntityDescription.entityForName("GlobalParam", inManagedObjectContext:managedObjectContext)
        seedDataDescription = NSEntityDescription.entityForName("SeedData", inManagedObjectContext:managedObjectContext)
        gameStatisticsDescription = NSEntityDescription.entityForName("GameStatistics", inManagedObjectContext:managedObjectContext)
 
    }
 
    func saveGameStatisticsRecord(gameStatistics: GameStatisticsStruct) {
        
        gameStatisticsEntity = GameStatistics(entity:gameStatisticsDescription!, insertIntoManagedObjectContext: managedObjectContext)
        gameStatisticsEntity!.name = gameStatistics.name
        gameStatisticsEntity!.level = gameStatistics.level
        gameStatisticsEntity!.countPlays = gameStatistics.countPlays
        gameStatisticsEntity!.actScore = gameStatistics.actScore
        gameStatisticsEntity!.levelScore = gameStatistics.levelScore
        gameStatisticsEntity!.bestScore = gameStatistics.bestScore
        gameStatisticsEntity!.bestTime = gameStatistics.bestTime
        gameStatisticsEntity!.allTime = gameStatistics.allTime
        gameStatisticsEntity!.actTime = gameStatistics.actTime
        
        do {
            try self.managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func readGameStatisticsRecord(gameStatisticsIndex: GameStatisticsStruct)->GameStatisticsStruct {
        let request = NSFetchRequest()
        var gameStatisticsStruct = GameStatisticsStruct()
//        var exists: Bool
        request.entity = self.gameStatisticsDescription
        let p1 = NSPredicate(format: "name = %@", gameStatisticsIndex.name)
        let p2 = NSPredicate(format: "level = %d", gameStatisticsIndex.level)
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [p1, p2])

        gameStatisticsStruct.name = gameStatisticsIndex.name
        gameStatisticsStruct.level = gameStatisticsIndex.level
        
        request.predicate = predicate
        do {
            let results = try managedObjectContext.executeFetchRequest(request)
            if let match = results.first as? NSManagedObject {
                
                gameStatisticsStruct.countPlays = match.valueForKey("countPlays") as! NSInteger
                gameStatisticsStruct.actScore = match.valueForKey("actScore") as! NSInteger
                gameStatisticsStruct.bestScore = match.valueForKey("bestScore") as! NSInteger
                gameStatisticsStruct.levelScore = match.valueForKey("levelScore") as! NSInteger
                gameStatisticsStruct.bestTime = match.valueForKey("bestTime") as! NSInteger
                gameStatisticsStruct.allTime = match.valueForKey("allTime") as! NSInteger
                gameStatisticsStruct.actTime = match.valueForKey("actTime") as! NSInteger

//                exists = true
//            } else {
//                exists = false
            }
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        return gameStatisticsStruct
        
    }
    
    func saveSeedDataRecord(seedData: SeedDataStruct) {
        
        seedDataEntity = SeedData(entity:seedDataDescription!, insertIntoManagedObjectContext: managedObjectContext)
        seedDataEntity!.gameDifficulty = NSNumber(longLong: seedData.gameDifficulty)
        seedDataEntity!.gameNumber = NSNumber(longLong: seedData.gameNumber)
        seedDataEntity!.gameType = NSNumber(longLong: seedData.gameType)
        seedDataEntity!.seed = seedData.seed
        
        do {
            try self.managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }

    func readSeedDataRecord(seedIndex: SeedIndex)->(SeedDataStruct, Bool) {
        let request = NSFetchRequest()
        var seedDataStruct: SeedDataStruct
        var exists: Bool
        request.entity = self.seedDataDescription
        let p1 = NSPredicate(format: "gameType = %d", seedIndex.gameType)
        let p2 = NSPredicate(format: "gameDifficulty = %d", seedIndex.gameDifficulty)
        let p3 = NSPredicate(format: "gameNumber = %d", seedIndex.gameNumber)
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [p1, p2, p3])
        request.predicate = predicate
        do {
            let results = try managedObjectContext.executeFetchRequest(request)
            if let match = results.first as? NSManagedObject {
                let gameType = match.valueForKey("gameType") as! NSInteger
                let gameDifficulty = match.valueForKey("gameDifficulty") as! NSInteger
                let gameNumber = match.valueForKey("gameNumber") as! NSInteger
                let seed = match.valueForKey("seed") as! NSData
                seedDataStruct = SeedDataStruct(gameType: Int64(gameType), gameDifficulty: Int64(gameDifficulty), gameNumber: Int64(gameNumber), seed: seed)
                exists = true
            } else {
                seedDataStruct = SeedDataStruct(gameType: seedIndex.gameType, gameDifficulty: seedIndex.gameDifficulty, gameNumber: seedIndex.gameNumber, seed: NSData())
                exists = false
            }
       } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        return (seedDataStruct, exists)
        
    }

    
    
    func saveSpriteGameRecord() {
        deleteRecords(spriteGameDescription)
        
        for index in 0..<GV.spriteGameDataArray.count {
            
            spriteGameEntity = SpriteGame(entity:spriteGameDescription!, insertIntoManagedObjectContext: managedObjectContext)
            spriteGameEntity!.name = GV.spriteGameDataArray[index].name
            spriteGameEntity!.allParams = coder(GV.spriteGameDataArray[index])
            
            do {
                try self.managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func coder(spriteGameData: SpriteGameData)->String {
        var allParams = ""
        allParams = spriteGameData.aktLanguageKey + "/°/"
        allParams += String(spriteGameData.showHelpLines) + "/°/"
        allParams += String(spriteGameData.spriteGameScore) + "/°/"
        allParams += String(spriteGameData.spriteLevelIndex) + "/°/"
        allParams += String(spriteGameData.gameModus) + "/°/"
        allParams += String(spriteGameData.soundVolume) + "/°/"
        allParams += String(spriteGameData.musicVolume)
        return allParams
    }
    
    func decoder(allParams: String)->SpriteGameData {
        var spriteGameData = SpriteGameData()
        var components = allParams.componentsSeparatedByString("/°/")
        spriteGameData.aktLanguageKey = components[0]
        if components.count > 1 {spriteGameData.showHelpLines = Int(components[1])!}
        if components.count > 2 {spriteGameData.spriteGameScore = Int(components[2])!}
        if components.count > 3 {spriteGameData.spriteLevelIndex = Int(components[3])!}
        if components.count > 4 {spriteGameData.gameModus = Int(components[4])!}
        if components.count > 5 {spriteGameData.soundVolume = Float(components[5])!}
        if components.count > 6 {spriteGameData.musicVolume = Float(components[6])!}
        return spriteGameData
    }
    
    func getSpriteData()->[SpriteGameData] {
        var dataArray: [SpriteGameData] = []
        
        let request = NSFetchRequest()
        
        request.entity = self.spriteGameDescription
        
        
        do {
            let results = try managedObjectContext.executeFetchRequest(request)
            
            
            for (_, result) in results.enumerate() {
                let match = result as! NSManagedObject
                let allParams = match.valueForKey("allParams")! as! String
                var gameData = decoder(allParams)
                gameData.name = match.valueForKey("name")! as! String
                dataArray.append(gameData)
            }

            if dataArray.count == 0 {
                let gameData = SpriteGameData()
                dataArray.append(gameData)
            }
            // success ...
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }

        return dataArray
    }

    func saveGlobalParamRecord() {
        deleteRecords(globalParamDescription)
        
        globalParamEntity = GlobalParam(entity:globalParamDescription!, insertIntoManagedObjectContext: managedObjectContext)
        globalParamEntity!.aktName = GV.globalParam.aktName

        do {
            try self.managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }

    
    func getGlobalParam()->GlobalParamData {
        var globalData = GlobalParamData()
        
        let request = NSFetchRequest()
        
        request.entity = self.globalParamDescription
        
        
        //var results = managedObjectContext!.executeFetchRequest(request, error: &error)
        do {
            let results = try managedObjectContext.executeFetchRequest(request)
            if let match = results.first as? NSManagedObject {
                globalData.aktName = match.valueForKey("aktName") as! String!
            } else {
                globalData.aktName = GV.dummyName
            }
            // success ...
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        return globalData
    }

    func deleteRecords(description: NSEntityDescription?) {
        let request = NSFetchRequest()
        
        request.entity = description
        
        do {
            let results = try managedObjectContext.executeFetchRequest(request)
            for (_,result) in results.enumerate() {
                managedObjectContext.deleteObject(result as! NSManagedObject)
            }
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
    }



    
    
}