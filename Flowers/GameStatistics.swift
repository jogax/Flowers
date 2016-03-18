//
//  GameStatistics.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 16/03/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import CoreData


class GameStatistics: NSManagedObject {

    @NSManaged var actScore: NSNumber?
    @NSManaged var actTime: NSNumber?
    @NSManaged var allTime: NSNumber?
    @NSManaged var bestScore: NSNumber?
    @NSManaged var bestTime: NSNumber?
    @NSManaged var countPlays: NSNumber?
    @NSManaged var level: NSNumber?
    @NSManaged var levelScore: NSNumber?
    @NSManaged var nameID: NSNumber?

}
