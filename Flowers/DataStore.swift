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


let GameModusFlowers = 0
let GameModusCards = 1


class DataStore {
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    var error: NSError?
    var spriteGameEntity: SpriteGame?
    var globalParamEntity: GlobalParam?
    //var appVariables: AppVariables?
    var exists: Bool = true
    var spriteGameDescription:NSEntityDescription?
    var globalParamDescription:NSEntityDescription?
    
    init() {
        
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //_ = appDelegate.managedObjectContext
        spriteGameDescription = NSEntityDescription.entityForName("SpriteGame", inManagedObjectContext:managedObjectContext)
        globalParamDescription = NSEntityDescription.entityForName("GlobalParam", inManagedObjectContext:managedObjectContext)
 
    }
    
    func saveSpriteGameRecord() {
        deleteRecords(spriteGameDescription)
        
        for index in 0..<GV.spriteGameDataArray.count {
            
            spriteGameEntity = SpriteGame(entity:spriteGameDescription!, insertIntoManagedObjectContext: managedObjectContext)
//            spriteGameEntity!.aktLanguageKey = GV.spriteGameDataArray[index].aktLanguageKey
//            spriteGameEntity!.showHelpLines = NSNumber(longLong: GV.spriteGameDataArray[index].showHelpLines)
//            spriteGameEntity!.spriteLevelIndex = NSNumber(longLong: GV.spriteGameDataArray[index].spriteLevelIndex)
//            spriteGameEntity!.spriteGameScore = NSNumber(longLong: GV.spriteGameDataArray[index].spriteGameScore)
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