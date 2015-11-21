//
//  DataStore.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 15.04.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit





class DataStore {
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    //let request = NSFetchRequest()
    var error: NSError?
//    var gameEntity: GameStatus?
//    var appVariablesEntity: AppVariables?
    var spriteGameEntity: SpriteGame?
    var globalParamEntity: GlobalParam?
    //var appVariables: AppVariables?
    var exists: Bool = true
    //var gameStatusDescription:NSEntityDescription?
    //var appVariablesDescription:NSEntityDescription?
    var spriteGameDescription:NSEntityDescription?
    var globalParamDescription:NSEntityDescription?
    
    init() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        _ = appDelegate.managedObjectContext
        //gameStatusDescription = NSEntityDescription.entityForName("GameStatus", inManagedObjectContext:managedObjectContext)
        //appVariablesDescription = NSEntityDescription.entityForName("AppVariables", inManagedObjectContext:managedObjectContext)
        spriteGameDescription = NSEntityDescription.entityForName("SpriteGame", inManagedObjectContext:managedObjectContext)
        globalParamDescription = NSEntityDescription.entityForName("GlobalParam", inManagedObjectContext:managedObjectContext)
 
    }
    
    func createSpriteGameRecord(spriteData: SpriteGameData) {
        deleteSpriteGameRecords()
        
        spriteGameEntity = SpriteGame(entity:spriteGameDescription!, insertIntoManagedObjectContext: managedObjectContext)
        spriteGameEntity!.aktLanguageKey = spriteData.aktLanguageKey
        spriteGameEntity!.name = spriteData.name
        spriteGameEntity!.showHelpLines = NSNumber(longLong: spriteData.showHelpLines)
        spriteGameEntity!.spriteLevelIndex = NSNumber(longLong: spriteData.spriteLevelIndex)
        spriteGameEntity!.spriteGameScore = NSNumber(longLong: spriteData.spriteGameScore)
        
        do {
            try self.managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func getSpriteData()->[SpriteGameData] {
        var dataArray: [SpriteGameData] = []
        //var spriteData = SpriteGameData()
        
        let request = NSFetchRequest()
        
        request.entity = self.spriteGameDescription
        
        
        do {
            let results = try managedObjectContext.executeFetchRequest(request)
            
            
            for (_, result) in results.enumerate() {
                let match = result as! NSManagedObject
                var gameData = SpriteGameData()
                gameData.aktLanguageKey = match.valueForKey("aktLanguageKey")! as! String
                gameData.name = match.valueForKey("name")! as! String
                gameData.showHelpLines = Int64(match.valueForKey("showHelpLines")! as! NSInteger)
                gameData.spriteLevelIndex = Int64(match.valueForKey("spriteLevelIndex")! as! NSInteger)
                gameData.spriteGameScore = Int64(match.valueForKey("spriteGameScore")! as! NSInteger)
                dataArray.append(gameData)
            }

//            if let match = results.first as? NSManagedObject {
//                spriteData.aktLanguageKey = match.valueForKey("aktLanguageKey") as! String!
//                spriteData.name = match.valueForKey("name") as! String!
//                spriteData.showHelpLines  = Int64(match.valueForKey("showHelpLines") as! NSInteger)
//                spriteData.spriteLevelIndex = Int64(match.valueForKey("spriteLevelIndex") as! NSInteger)
//                spriteData.spriteGameScore = Int64(match.valueForKey("spriteGameScore") as! NSInteger)
//            } else {
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

    func deleteSpriteGameRecords() {
        let request = NSFetchRequest()
        
        request.entity = spriteGameDescription
        
        do {
            let results = try managedObjectContext.executeFetchRequest(request)
            for (_,result) in results.enumerate() {
                managedObjectContext.deleteObject(result as! NSManagedObject)
            }
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
        //results = managedObjectContext!.executeFetchRequest(request, error: &error)
    }


//    func deleteGlobalVariablesRecords() {
//        let request = NSFetchRequest()
//        
//        request.entity = spriteGameDescription
//        
//        do {
//            let results = try managedObjectContext.executeFetchRequest(request)
//            for (_,result) in results.enumerate() {
//                managedObjectContext.deleteObject(result as! NSManagedObject)
//            }
//        } catch let error as NSError {
//            // failure
//            print("Fetch failed: \(error.localizedDescription)")
//        }
//        //results = managedObjectContext!.executeFetchRequest(request, error: &error)
//        
////        var results = managedObjectContext!.executeFetchRequest(request, error: &error)
////        for (ind,result) in enumerate(results!) {
////            managedObjectContext!.deleteObject(result as! NSManagedObject)
////        }
//        //results = managedObjectContext!.executeFetchRequest(request, error: &error)
//    }
    
    
}