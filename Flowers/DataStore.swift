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
    //var appVariables: AppVariables?
    var exists: Bool = true
    var gameStatusDescription:NSEntityDescription?
    var appVariablesDescription:NSEntityDescription?
    var spriteGameDescription:NSEntityDescription?
    
    init() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        _ = appDelegate.managedObjectContext
        gameStatusDescription = NSEntityDescription.entityForName("GameStatus", inManagedObjectContext:managedObjectContext)
        appVariablesDescription = NSEntityDescription.entityForName("AppVariables", inManagedObjectContext:managedObjectContext)
        spriteGameDescription = NSEntityDescription.entityForName("SpriteGame", inManagedObjectContext:managedObjectContext)
 
    }
    
    func createSpriteGameRecord(spriteData: SpriteGameData) {
        deleteGlobalVariablesRecords()
        //GV.cloudData.saveRecord(gameData)
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
    
    func getSpriteData()->SpriteGameData {
        var spriteData = SpriteGameData()
        
        let request = NSFetchRequest()
        
        request.entity = self.spriteGameDescription
        
        
        //var results = managedObjectContext!.executeFetchRequest(request, error: &error)
        do {
            let results = try managedObjectContext.executeFetchRequest(request)
            if let match = results.first as? NSManagedObject {
                spriteData.aktLanguageKey = match.valueForKey("aktLanguageKey") as! String!
                spriteData.name = match.valueForKey("name") as! String!
                spriteData.showHelpLines  = Int64(match.valueForKey("showHelpLines") as! NSInteger)
                spriteData.spriteLevelIndex = Int64(match.valueForKey("spriteLevelIndex") as! NSInteger)
                spriteData.spriteGameScore = Int64(match.valueForKey("spriteGameScore") as! NSInteger)
            } else {
                spriteData.aktLanguageKey = GV.language.getAktLanguageKey()
                spriteData.name = "dummy"
                spriteData.showHelpLines  = 0
                spriteData.spriteLevelIndex  = 0
                spriteData.spriteGameScore = 0
            }
            // success ...
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }

        return spriteData
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


    func deleteGlobalVariablesRecords() {
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
        
//        var results = managedObjectContext!.executeFetchRequest(request, error: &error)
//        for (ind,result) in enumerate(results!) {
//            managedObjectContext!.deleteObject(result as! NSManagedObject)
//        }
        //results = managedObjectContext!.executeFetchRequest(request, error: &error)
    }
    
//    func printRecords() {
//        let request = NSFetchRequest()
//        request.entity = gameStatusDescription
//        var results = managedObjectContext?.executeFetchRequest(request, error: &error)
//        for (ind, result) in enumerate(results!) {
//            let match = result as! NSManagedObject
//
//            let gameName = match.valueForKey("gameName")! as! String
//            let gameNumber = match.valueForKey("gameNumber")! as! NSInteger
//            let countLines = match.valueForKey("countLines")! as! NSInteger
//            let countMoves = match.valueForKey("countMoves")! as! NSInteger
//            let countSeconds = match.valueForKey("countSeconds")! as! NSInteger
//            
//            //println("name: \(gameName), number: \(gameNumber), lines: \(countLines), moves:\(countMoves), seconds:\(countSeconds)")
//
//        }
//        
//    }
//    
//    func convertFarbschemasToString () -> String{
//        var str: String = ""
//        for index in 0..<GV.colorSets.count {
//            for colorIndex in 1..<GV.colorSets[0].count - 3 {
//                let components = CGColorGetComponents(GV.colorSets[index][colorIndex].CGColor)
//                let red = Int(components[0] * 255)
//                let green = Int(components[1] * 255)
//                let blue = Int(components[2] * 255)
//                /*
//                let redStr = red == 0 ? "000" : red < 10 ? "00" + String(red) : red < 100 ? "0" + String(red) : String(red)
//                let greenStr = green == 0 ? "000" : green < 10 ? "00" + String(green) : green < 100 ? "0" + String(green) : String(green)
//                let blueStr = blue == 0 ? "000" : blue < 10 ? "00" + String(blue) : blue < 100 ? "0" + String(blue) : String(blue)
//                */
//                let redStr = String(format: "%03d", red)
//                let greenStr = String(format: "%03d", green)
//                let blueStr = String(format: "%03d", blue)
//
//                str = str + "\(redStr)\(greenStr)\(blueStr)"
//            }
//        }
//        return str
//    }
//    
//    func convertStringToFarbSchemas (farbSchemas: String) {
//        let str = farbSchemas as NSString
//        let strLen = str.length
//        let colSetLen = strLen / 3
//        for index in 0..<GV.colorSets.count {
//            let colorSetLength = (GV.colorSets[0].count - 4) * 9
//            let startIndex = index * colorSetLength
//            let colorSetString = str.substringWithRange(NSRange(location: startIndex, length: colorSetLength)) as NSString
//            for colorIndex in 1..<GV.colorSets[0].count - 3 {
//                let aktLocation = (colorIndex - 1) * 9
//                let aktColor = colorSetString.substringWithRange(NSRange(location:aktLocation, length: 9)) as NSString
//                let red = CGFloat(aktColor.substringWithRange(NSRange(location: 0, length: 3)).toInt()!) / 255
//                let green = CGFloat(aktColor.substringWithRange(NSRange(location: 3, length: 3)).toInt()!) / 255
//                let blue = CGFloat(aktColor.substringWithRange(NSRange(location: 6, length: 3)).toInt()!) / 255
//                GV.colorSets[index][colorIndex] = UIColor(red: red, green: green, blue: blue, alpha: 1)
//            }
//        }
//    }
    
}