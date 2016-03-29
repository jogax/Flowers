//
//  PlayerModel.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 29/03/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class PlayerModel: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
    dynamic var name: String = ""
    dynamic var nameID: NSNumber = 0
    dynamic var isActPlayer: Bool = false
    dynamic var aktLanguageKey: String = ""
    dynamic var levelIndex: Int = 0
    dynamic var soundVolume: Float = 0
    dynamic var musicVolume: Float = 0
    dynamic var created = NSDate()
    

}
