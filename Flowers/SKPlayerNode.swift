//
//  SKPlayerNode.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 04/04/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import RealmSwift

class SKPlayer: SKSpriteNode {
    
    init(parent: SKSpriteNode) {
        let countLines = GV.realm.objects(PlayerModel).count
        let texture: SKTexture = SKTexture(image: DrawImages().getTableImage(CGSizeMake(parent.frame.size.width, parent.frame.size.height),countLines: countLines, countRows: 1))
        
        
        super.init(texture: texture, color: UIColor.clearColor(), size: parent.frame.size)
        self.position = CGPointMake(10, -10)
        self.color = UIColor.yellowColor()
        self.zPosition = parent.zPosition + 200
        self.alpha = 1.0
        self.userInteractionEnabled = true
        parent.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.removeFromParent()
    }

}
