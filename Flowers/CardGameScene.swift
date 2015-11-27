//
//  CardGameScene.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 11. 26..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import AVFoundation

class CardGameScene: MyGameScene {
    override func getTexture(index: Int)->SKTexture {
        return atlas.textureNamed ("sprite\(index)")
    }

}
