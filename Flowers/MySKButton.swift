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
//    var progressCircle = SKShapeNode()
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
            if makePicture {
                let shadow = MySKNode(texture: texture, type: .ButtonType, value: NoValue)
                shadow.blendMode = SKBlendMode.Alpha
                shadow.colorBlendFactor = 0.5;
                shadow.color = SKColor.redColor()
                shadow.alpha = 0.25
                shadow.size = size
//                shadow.anchorPoint = self.anchorPoint + CGPointMake(-0.09, 0.04)
                shadow.zPosition = 2
                shadow.name = buttonName
                addChild(shadow)
            }
        
//        let progressCircle = SKShapeNode(circleOfRadius: 50)
////            showProgress(100, maxValue: 100)
//            progressCircle.fillColor = SKColor.redColor()
////            progressCircle.position = position
//            addChild(progressCircle)
        
        }
    
    func changeButtonPicture(texture: SKTexture) {
        (self.childNodeWithName(buttonName)! as! MySKNode).texture = texture
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func activateButton(activate: Bool) {
        if activate {
            self.alpha = 1.0
        } else {
            self.alpha = 0.2
        }
    }
    
    func showProgress(actValue: Int, maxValue:Int) {
        
//        let pathToDraw:CGMutablePathRef = CGPathCreateMutable()
//        let myProgress:SKShapeNode = SKShapeNode(path:pathToDraw)
//        myProgress.fillColor = SKColor.redColor()
//        let actAngle = (CGFloat(actValue) / CGFloat(maxValue) * 180 * GV.oneGrad)
//        let startAngle = 180 * GV.oneGrad
//
//        let minAngle = startAngle + actAngle
//        let maxAngle = startAngle - actAngle
//        
//        let bezierPath = UIBezierPath(rect: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height))
//        let center = CGPointMake(frame.midX, frame.midY)
//        let endPoint = GV.pointOfCircle(1.0, center: center, angle: maxAngle)
//        let startPoint = GV.pointOfCircle(1.0, center: center, angle: maxAngle)
////        print(center, "radius:", frame.size.height / 2, "actMultiplier:", actAngle / GV.oneGrad, "minAngle:", minAngle / GV.oneGrad, "maxAngle:", maxAngle / GV.oneGrad)
// 
////        print("vor1", actValue, maxValue)
//        
//        bezierPath.addArcWithCenter(center, radius: frame.size.height / 2, startAngle: minAngle, endAngle: maxAngle, clockwise: true)
//        bezierPath.moveToPoint(startPoint)
//        bezierPath.addLineToPoint(endPoint)
//        bezierPath.closePath()
//        print("vor2", actValue, maxValue)
//        
//        let progressCircle = SKShapeNode(path:bezierPath.CGPath)
//        print("vor3", actValue, maxValue)
////        let radius: CGFloat = frame.size.height / 2 - CGFloat(Double(actValue) / Double(maxValue)) * frame.size.height / 2
////        print(radius, actValue, maxValue)
////        let progressCircle = SKShapeNode(circleOfRadius: frame.size.height / 2 - radius)
//        progressCircle.strokeColor = UIColor(red: 0.6, green: 0.9, blue: 0.5, alpha: 0.05)
//        progressCircle.fillColor = UIColor(red: 0.6, green: 0.9, blue: 0.5, alpha: 0.05)
//        progressCircle.name = "progressCircle"
////        progressCircle.position = position
//        progressCircle.zPosition = zPosition + 10
//        
////        self.removeAllChildren()
//        
////        if self.childNodeWithName("progressCircle") != nil {
////            self.childNodeWithName("progressCircle")!.removeFromParent()
////        }
//        self.addChild(progressCircle)
//        
//        
//        
    }
}