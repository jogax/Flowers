//
//  MyScene.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 10. 21..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import SpriteKit

class XXScene: SKScene {
    var parentViewController: ViewController?
    init(size: CGSize, parentViewController: ViewController) {
        self.parentViewController = parentViewController
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
