//
//  ChooseGamePanel.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 11/07/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

//
//  MySKPanel.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 18/03/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
class ChooseGamePanel: SKSpriteNode {
    var view: UIView
    var sizeMultiplier = CGSizeMake(0, 0)
    var fontSize:CGFloat = 0
    var callBack: (Int, Int)->()
    var parentScene: SKScene?
    
    var levels = [SKLabelNode]()
    var levelButtons = [SKShapeNode]()
    
    var playerChanged = false
    var touchesBeganWithNode: SKNode?
    var shadow: SKSpriteNode?
    init(view: UIView, frame: CGRect, parent: SKScene, callBack: (Int, Int)->()) {
        let size = parent.size / 2 //CGSizeMake(parent.size.width / 2, parent.s)
        //        let texture: SKTexture = SKTexture(imageNamed: "panel")
        let texture: SKTexture = SKTexture()
        
        sizeMultiplier = size / 10
        
        self.callBack = callBack
        self.view = view
        self.parentScene = parent
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
        
        let countLevels = LevelsForPlayWithCards().count()
        self.texture = SKTexture(image: getPanelImage(size))
        setMyDeviceConstants()
        let startPosition = CGPointMake(parent.size.width, parent.size.height / 2)
        let zielPosition = CGPointMake(parent.size.width / 2, parent.size.height / 2)
        self.size = size
        self.position = startPosition
        self.color = UIColor.yellowColor()
        self.zPosition = 100
        self.alpha = 1.0
        self.name = "ChooseGamePanel"
        self.userInteractionEnabled = true
        parentScene!.userInteractionEnabled = false
        parentScene!.addChild(self)
        
        let distance = size.width / (CGFloat(countLevels) + 1)
        let radius = distance / 4
        
        for levelIndex in 0..<countLevels {
            levelButtons.append(
                createRadioButton(
                    CGPointMake((CGFloat(levelIndex) + 1) * distance - size.width / 2, size.height * 0.34),
                    radius: radius,
                    labelText: String(levelIndex + 1)
                ))
            self.addChild(levelButtons[levelIndex])
        }
        
        let moveAction = SKAction.moveTo(zielPosition, duration: 0.5)
        self.runAction(moveAction)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createRadioButton(position: CGPoint, radius: CGFloat, labelText: String)->SKShapeNode {
        let button = SKShapeNode(circleOfRadius: radius)
        
        button.position = position
        button.fillColor = UIColor.whiteColor()
        button.strokeColor = UIColor.blackColor()
        button.zPosition = self.zPosition + 10
        let label = SKLabelNode()
        label.position = CGPointMake(0, radius * 1.1)
        label.text = labelText
        label.color = UIColor.blackColor()
        label.fontSize = 10
        label.fontName = "TimesNewRoman"
        label.fontColor = UIColor.blackColor()
        button.addChild(label)
        return button
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
        let node = nodeAtPoint(touchLocation)
        touchesBeganWithNode = node
        //        print(node.name)
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
        if touchesBeganWithNode is SKLabelNode {
            let node = nodeAtPoint(touchLocation)
        }
    }
    
    func setMyDeviceConstants() {
        
        switch GV.deviceConstants.type {
        case .iPadPro12_9:
            fontSize = CGFloat(20)
        case .iPad2:
            fontSize = CGFloat(20)
        case .iPadMini:
            fontSize = CGFloat(20)
        case .iPhone6Plus:
            fontSize = CGFloat(15)
        case .iPhone6:
            fontSize = CGFloat(15)
        case .iPhone5:
            fontSize = CGFloat(13)
        case .iPhone4:
            fontSize = CGFloat(12)
        default:
            break
        }
        
    }
    
    func getPanelImage (size: CGSize) -> UIImage {
        let opaque = false
        let scale: CGFloat = 1
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        //        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        //        CGContextBeginPath(ctx)
        let roundRect = UIBezierPath(roundedRect: CGRectMake(0, 0, size.width, size.height), byRoundingCorners:.AllCorners, cornerRadii: CGSizeMake(size.width / 20, size.height / 20)).CGPath
        CGContextAddPath(ctx, roundRect)
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor);
        CGContextFillPath(ctx)
        
        
        let points = [
            CGPointMake(size.width * 0.08, size.height * 0.20),
            CGPointMake(size.width * 0.92, size.height * 0.20)
        ]
        CGContextAddLines(ctx, points, points.count)
        CGContextStrokePath(ctx)
        
        
        
        
        //        CGContextSetShadow(ctx, CGSizeMake(10,10), 1.0)
        //        CGContextStrokePath(ctx)
        
        
        
        CGContextClosePath(ctx)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
    
    
    
    
    deinit {
    }
    
}

