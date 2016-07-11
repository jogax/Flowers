//
//  RecordIDModel.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 03/06/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class RecordIDModel: Object {
    
    dynamic var ID = 0
    dynamic var gameModelID = 0
    dynamic var playerModelID = 0
    dynamic var statisticModelID = 0
    
    override  class func primaryKey() -> String {
        return "ID"
    }
    
    
}

