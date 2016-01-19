//
//  MySKButton.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 10. 15..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import SpriteKit

let buttonName = "buttonName"
class MySKButton: MySKNode {
    convenience init(texture: SKTexture, frame: CGRect) {
        self.init(texture: texture, frame: frame, makePicture: true)
    }

    init(texture: SKTexture, frame: CGRect, makePicture: Bool) {
        var buttonTexture: SKTexture
        if makePicture {
            buttonTexture = atlas.textureNamed("myRoundButton")
        } else {
            buttonTexture = atlas.textureNamed("emptyCard")
        }
        super.init(texture: buttonTexture, type:.ButtonType, value: NoValue)
        self.position = frame.origin
        self.size = frame.size
            let buttonPicture = MySKNode(texture: texture, type: .ButtonType, value: NoValue)
            buttonPicture.size = size * 0.95
            buttonPicture.zPosition = 1
            buttonPicture.name = buttonName
            addChild(buttonPicture)
            let shadow = MySKNode(texture: texture, type: .ButtonType, value: NoValue)
            shadow.blendMode = SKBlendMode.Alpha
            shadow.colorBlendFactor = 0.5;
            shadow.color = SKColor.redColor()
            shadow.alpha = 0.25
            shadow.size = size
            shadow.anchorPoint = self.anchorPoint + CGPointMake(-0.09, 0.04)
            shadow.zPosition = 2
            shadow.name = buttonName
            addChild(shadow)
        }
    
    func changeButtonPicture(texture: SKTexture) {
        (self.childNodeWithName(buttonName)! as! MySKNode).texture = texture
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}