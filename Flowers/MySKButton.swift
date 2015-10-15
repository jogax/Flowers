//
//  MySKButton.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 10. 15..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import SpriteKit

class MySKButton: MySKNode {
    init(texture: SKTexture, frame: CGRect) {
        super.init(texture: texture, type:.ButtonType)
        self.position = frame.origin
        self.size = frame.size
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}