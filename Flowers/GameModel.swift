//
//  GameModel.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 19/04/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class GameModel: Object {
    
    dynamic var ID = 0
    dynamic var levelID = 0
    dynamic var bestTime = 0
    dynamic var bestScore = 0
    dynamic var seedData = NSData()
    dynamic var created = NSDate()
    
    override  class func primaryKey() -> String {
        return "ID"
    }
    
    
}

