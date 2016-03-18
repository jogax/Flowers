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
    var gameParamEntity: GameParam?
    var gameStatisticsEntity: GameStatistics?
    var seedDataEntity: SeedData?
    
    //var appVariables: AppVariables?
    var exists: Bool = true
    var gameParamDescription:NSEntityDescription?
    var gameStatisticsDescription:NSEntityDescription?
    var seedDataDescription:NSEntityDescription?
    
    init() {
        
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //_ = appDelegate.managedObjectContext
        gameParamDescription = NSEntityDescription.entityForName("GameParam", inManagedObjectContext:managedObjectContext)
        seedDataDescription = NSEntityDescription.entityForName("SeedData", inManagedObjectContext:managedObjectContext)
        gameStatisticsDescription = NSEntityDescription.entityForName("GameStatistics", inManagedObjectContext:managedObjectContext)
 
    }
 
    func saveGameStatisticsRecord(gameStatistics: GameStatisticsStruct) {
        let request = NSFetchRequest()
        var gameStatisticsStruct = GameStatisticsStruct()
        //        var exists: Bool
        request.entity = self.gameStatisticsDescription
        let p1 = NSPredicate(format: "nameID = %d", gameStatistics.nameID)
        let p2 = NSPredicate(format: "level = %d", gameStatistics.level)
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [p1, p2])
        
        gameStatisticsStruct.nameID = gameStatistics.nameID
        gameStatisticsStruct.level = gameStatistics.level
        
        request.predicate = predicate
        do {
            let results = try managedObjectContext.executeFetchRequest(request)
            if let managedObject = results.first as? NSManagedObject {
                managedObject.setValue(gameStatistics.countPlays, forKey: "countPlays")
                managedObject.setValue(gameStatistics.actScore, forKey: "actScore")
                managedObject.setValue(gameStatistics.levelScore, forKey: "levelScore")
                managedObject.setValue(gameStatistics.bestScore, forKey: "bestScore")
                managedObject.setValue(gameStatistics.bestTime, forKey: "bestTime")
                managedObject.setValue(gameStatistics.allTime, forKey: "allTime")
                managedObject.setValue(gameStatistics.actTime, forKey: "actTime")
            } else {
                gameStatisticsEntity = GameStatistics(entity:gameStatisticsDescription!, insertIntoManagedObjectContext: managedObjectContext)
                gameStatisticsEntity!.nameID = gameStatistics.nameID
                gameStatisticsEntity!.level = gameStatistics.level
                gameStatisticsEntity!.countPlays = gameStatistics.countPlays
                gameStatisticsEntity!.actScore = gameStatistics.actScore
                gameStatisticsEntity!.levelScore = gameStatistics.levelScore
                gameStatisticsEntity!.bestScore = gameStatistics.bestScore
                gameStatisticsEntity!.bestTime = gameStatistics.bestTime
                gameStatisticsEntity!.allTime = gameStatistics.allTime
                gameStatisticsEntity!.actTime = gameStatistics.actTime
        
            }
            do {
                try self.managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error by save \(nserror), \(nserror.userInfo)")
                abort()
            }
            
            
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error by fetch \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        
    }
    
    func readGameStatisticsRecord(nameID: Int, levelID: Int)->GameStatisticsStruct {
        let request = NSFetchRequest()
        var gameStatisticsStruct = GameStatisticsStruct()
//        var exists: Bool
        request.entity = self.gameStatisticsDescription
        let p1 = NSPredicate(format: "nameID = %d", nameID)
        let p2 = NSPredicate(format: "level = %d", levelID)
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [p1, p2])

        gameStatisticsStruct.nameID = nameID
        gameStatisticsStruct.level = levelID
        
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


    func deleteGameParamRecord(gameParam: GameParamStruct) {
    }
    
    func saveGameParamRecord(gameParam: GameParamStruct) {

        let request = NSFetchRequest()
        var gameParamStruct = GameParamStruct()
        request.entity = self.gameParamDescription
        let predicate = NSPredicate(format: "nameID = %d", gameParam.nameID)
        
        gameParamStruct.nameID = gameParam.nameID
        
        request.predicate = predicate
        do {
            let results = try managedObjectContext.executeFetchRequest(request)
            if let managedObject = results.first as? NSManagedObject {
                managedObject.setValue(gameParam.name, forKey: "name")
                managedObject.setValue(gameParam.isActPlayer, forKey: "isActPlayer")
                managedObject.setValue(coder(gameParam), forKey: "allParams")
            } else {
                gameParamEntity = GameParam(entity:gameParamDescription!, insertIntoManagedObjectContext: managedObjectContext)
                gameParamEntity!.nameID = gameParam.nameID
                gameParamEntity!.isActPlayer = gameParam.isActPlayer
                gameParamEntity!.allParams = coder(gameParam)
                
            }
            do {
                try self.managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error by save \(nserror), \(nserror.userInfo)")
                abort()
            }
        
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func coder(gameParam: GameParamStruct)->String {
        var allParams = ""
        allParams = gameParam.aktLanguageKey + "/°/"
//        allParams += String(gameParam.showHelpLines) + "/°/"
        allParams += String(gameParam.gameScore) + "/°/"
        allParams += String(gameParam.levelIndex) + "/°/"
        allParams += String(gameParam.gameModus) + "/°/"
        allParams += String(gameParam.soundVolume) + "/°/"
        allParams += String(gameParam.musicVolume)
        return allParams
    }
    
    func decoder(allParams: String)->GameParamStruct {
        var gameParam = GameParamStruct()
        var components = allParams.componentsSeparatedByString("/°/")
        gameParam.aktLanguageKey = components[0]
        if components.count > 2 {gameParam.gameScore = Int(components[1])!}
        if components.count > 3 {gameParam.levelIndex = Int(components[2])!}
        if components.count > 4 {gameParam.gameModus = Int(components[3])!}
        if components.count > 5 {gameParam.soundVolume = Float(components[4])!}
        if components.count > 6 {gameParam.musicVolume = Float(components[5])!}
        return gameParam
    }
    
    
    func readNamesFromGameParamRecord()->[Names] {
        let request = NSFetchRequest()
        request.entity = self.gameParamDescription
        var names: [Names] = []
        
        
        do {
            let results = try managedObjectContext.executeFetchRequest(request)
            for (_, result) in results.enumerate() {
                let match = result as! NSManagedObject
                var name = Names()
                name.name = match.valueForKey("name")! as! String
                name.isActPlayer = match.valueForKey("isActPlayer")! as! Bool
                names.append(name)
            }

        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
       
        return names
    }
    
    func readGameParamRecord(nameID: Int)->GameParamStruct {
        let request = NSFetchRequest()

        request.entity = self.gameStatisticsDescription
        let predicate = NSPredicate(format: "nameID = %d", nameID)
//        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [p1])
        var gameParamStruct = GameParamStruct()
        
        
        request.predicate = predicate
        do {
            let results = try managedObjectContext.executeFetchRequest(request)
            if let match = results.first as? NSManagedObject {
                
                gameParamStruct = decoder(match.valueForKey("allParams")! as! String)
                gameParamStruct.nameID = nameID
                gameParamStruct.isActPlayer = match.valueForKey("isActPlayer") as! Bool
                
            }
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        return gameParamStruct
        
    }

    func readActGameParamRecord()->GameParamStruct {
        let request = NSFetchRequest()
        
        request.entity = self.gameParamDescription
        let predicate = NSPredicate(format: "isActPlayer = true")
        var gameParamStruct = GameParamStruct()
        
        request.predicate = predicate
        do {
            let results = try managedObjectContext.executeFetchRequest(request)
            if let match = results.first as? NSManagedObject {
                
                gameParamStruct = decoder(match.valueForKey("allParams")! as! String)
                gameParamStruct.nameID = match.valueForKey("nameID") as! Int
                gameParamStruct.isActPlayer = match.valueForKey("isActPlayer") as! Bool
                gameParamStruct.name = match.valueForKey("name") as! String
                
            }
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        return gameParamStruct
        
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