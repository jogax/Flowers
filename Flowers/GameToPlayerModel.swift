//
//  GameToPlayerModel.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 02/06/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class GameToPlayerModel: Object {
    dynamic var ID = 0
    dynamic var playerID = 0
    dynamic var gameID = 0
//    dynamic var levelID = 0
    dynamic var score = 0
//    dynamic var time = 0
//    dynamic var timeBonus = 0
//    dynamic var lengthBonus = 0
//    dynamic var mirrorBonus = 0
//    dynamic var tippMalus = 0
//    dynamic var undoMalus = 0
    
    dynamic var created = NSDate()
    
    override  class func primaryKey() -> String {
        return "ID"
    }
    
    
}
