//
//  GamePredefinitionModel.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 09/06/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class GamePredefinitionModel: Object {
    
    dynamic var gameNumber = 0 // gameNumber
    dynamic var seedData: NSData? = NSData()
    
    override  static func primaryKey() -> String {
        return "gameNumber"
    }
    override static func indexedProperties() -> [String] {
        return ["gameNumber"]
    }

    
    
}


