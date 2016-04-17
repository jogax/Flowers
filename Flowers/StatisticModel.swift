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
    
    dynamic var ID = 0
    dynamic var playerID = 0
    dynamic var levelID = 0
    dynamic var actScore = 0
    dynamic var actTime = 0
    dynamic var allTime = 0
    dynamic var bestScore = 0
    dynamic var bestTime = 0
    dynamic var countPlays = 0
    dynamic var levelScore = 0
     
}
