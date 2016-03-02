//
//  MyContainer.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2016. 03. 01..
//  Copyright © 2016. Jozsef Romhanyi. All rights reserved.
//

import SpriteKit

class MyContainer: MySKNode {
    var countScore: Int
    init(texture: SKTexture) {
        countScore = 0
        super.init(texture: texture, type: .ContainerType, value: NoColor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

