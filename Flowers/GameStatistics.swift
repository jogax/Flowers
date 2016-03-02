//
//  GameStatistics.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2016. 03. 02..
//  Copyright © 2016. Jozsef Romhanyi. All rights reserved.
//

import Foundation
import CoreData


class GameStatistics: NSManagedObject {

    @NSManaged var allTime: NSNumber?
    @NSManaged var bestScore: NSNumber?
    @NSManaged var bestTime: NSNumber?
    @NSManaged var countPlays: NSNumber?
    @NSManaged var level: NSNumber?
    @NSManaged var name: String?
    @NSManaged var actScore: NSNumber?
    @NSManaged var levelScore: NSNumber?
    @NSManaged var actTime: NSNumber?
    
}
