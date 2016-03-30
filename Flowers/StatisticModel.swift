//
//  StatisticModel.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 30/03/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class StatisticModel: Object {
    
    dynamic var nameID: NSNumber = 0
    dynamic var level: NSNumber = 0
    dynamic var actScore: NSNumber = 0
    dynamic var actTime: NSNumber = 0
    dynamic var allTime: NSNumber = 0
    dynamic var bestScore: NSNumber = 0
    dynamic var bestTime: NSNumber = 0
    dynamic var countPlays: NSNumber = 0
    dynamic var levelScore: NSNumber = 0
    
}
