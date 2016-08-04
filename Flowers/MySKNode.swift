//
//  MySKContainer.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 13.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

enum MySKNodeType: Int {
    case SpriteType = 0, ContainerType, ButtonType, EmptyCardType, ShowCardType
}

enum TremblingType: Int {
    case NoTrembling = 0, ChangeSize, ChangeSizeOnce, ChangePos, ChangeDirection
}
let NoValue = -1
let NoColor = 1000
let MaxCardValue = 13
let LastCardValue = MaxCardValue - 1
let FirstCardValue = 0
import SpriteKit

class MySKNode: SKSpriteNode {
    
    override var size: CGSize {
        didSet {
            if oldValue != CGSizeMake(0,0) && (type != .ButtonType) {
                minValueLabel.fontSize = size.width * fontSizeMultiplier
                maxValueLabel.fontSize = size.width * fontSizeMultiplier
                let positionOffset = CGPointMake(self.size.width * offsetMultiplier.x,  self.size.height * offsetMultiplier.y)
                minValueLabel.position = positionOffset
                maxValueLabel.position = positionOffset
                if BGPictureAdded {
                    BGPicture.size = size
                }
//              print("name: \(name), type: \(type), size: \(size), self.position: \(position), minValueLabel.position: \(minValueLabel.position)")
            }
        }
    }
    var column = 0
    var row = 0
    var colorIndex = 0
    var startPosition = CGPointZero
    var minValue: Int
    var maxValue: Int
    var countScore: Int {
        get {
            let midValue = Double(minValue + maxValue + 2) / Double(2)
            return Int(midValue * Double((maxValue - minValue + 1)))
        }
    }
    var mirrored: Int
    let device = GV.deviceType
    let modelConstantLocal = UIDevice.currentDevice().modelName

    var origSize = CGSizeMake(0, 0)

    var trembling: CGFloat = 0
    var tremblingType: TremblingType = .NoTrembling {
        didSet {
            if oldValue != tremblingType {
                if tremblingType == .NoTrembling {
                    self.size = self.origSize
                    trembling = 0
                } else {
                    self.origSize = self.size
                }
            }
        }
    }
    
    var isCard = false
    

    var hitCounter: Int = 0

    var type: MySKNodeType
    var hitLabel = SKLabelNode()
    var maxValueLabel = SKLabelNode()
    var minValueLabel = SKLabelNode()
    var BGPicture = SKSpriteNode()
    var BGPictureAdded = false
    
    let cardLib: [Int:String] = [
        0:"A", 1:"2", 2:"3", 3:"4", 4:"5", 5:"6", 6:"7", 7:"8", 8:"9", 9:"10", 10: "J", 11: "Q", 12: "K", NoColor: ""]
    
    let fontSizeMultiplier: CGFloat = 0.35
    let offsetMultiplier = CGPointMake(-0.48, 0.48)
    let BGOffsetMultiplier = CGPointMake(-0.10, 0.25)
    

    init(texture: SKTexture, type:MySKNodeType, value: Int) {
        //let modelMultiplier: CGFloat = 0.5 //UIDevice.currentDevice().modelSizeConstant
        self.type = type
        self.minValue = value
        self.maxValue = value
        self.mirrored = 0
        
        if value > NoValue {
            isCard = true
        }
        
        switch type {
        case .ContainerType, .EmptyCardType, .ShowCardType:
            hitCounter = 0
        case .ButtonType:
            hitCounter = 0
        case .SpriteType:
            hitCounter = 1
        }
        
        

        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        if type == .ButtonType {
            hitLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
            hitLabel.fontSize = 20;
            hitLabel.zPosition = self.zPosition + 1
        } else {
            
            hitLabel.position = CGPointMake(self.position.x, self.position.y + self.size.width * 0.08)
            hitLabel.fontSize = 15;
            hitLabel.text = "\(hitCounter)"
            
            //print(minValue, text)
            setLabelText(minValueLabel, value: minValue)
            minValueLabel.zPosition = self.zPosition + 1
            
            
        }
        
        setLabel(hitLabel, fontSize: 15)
        setLabel(maxValueLabel, fontSize: size.width * fontSizeMultiplier)
        setLabel(minValueLabel, fontSize: size.width * fontSizeMultiplier)
        

        
        if isCard {
            if minValue == NoColor {
                switch type {
                    case .ContainerType: alpha = 0.5
                    case .EmptyCardType: alpha = 0.1
                    default: alpha = 1.0
                }
            }
            self.addChild(minValueLabel)
        } else {
            self.addChild(hitLabel)
        }

    }
    
    func setLabel(label: SKLabelNode, fontSize: CGFloat) {
        label.fontName = "ArielItalic"
        label.fontColor = SKColor.blackColor()
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        label.userInteractionEnabled = false
    }
    
    func reload() {
        if isCard {
            setLabelText(minValueLabel, value: minValue)
            setLabelText(maxValueLabel, value: maxValue)
            if minValue != NoColor {
                self.alpha = 1.0
            } else {
                switch type {
                    case .ContainerType: alpha = 0.5
                    case .EmptyCardType: alpha = 0.1
                    default: alpha = 1.0
                }
            }
            let BGPicturePosition = CGPointMake(self.size.width * BGOffsetMultiplier.x, self.size.height * BGOffsetMultiplier.y)
            let bgPictureName = "BGPicture"
            if minValue != maxValue {
                if !BGPictureAdded {
                    if self.childNodeWithName(bgPictureName) == nil {
                        self.addChild(BGPicture)
                        BGPicture.addChild(maxValueLabel)
                        BGPicture.name = bgPictureName
                        BGPicture.alpha = 1.0
                    }
                    BGPicture.texture = self.texture
                    BGPictureAdded = true
                    BGPicture.position = BGPicturePosition // CGPointMake(-3, 25)
                    BGPicture.size = size
                    self.zPosition = 0
                    BGPicture.zPosition = self.zPosition - 1
                    BGPicture.userInteractionEnabled = false
                    //maxValueLabel.position = positionOffset //CGPointMake(-20, 35)
                    maxValueLabel.zPosition = self.zPosition + 1
                    //minValueLabel.zPosition = maxValueLabel.zPosition + 1
                }
            } else {
                if BGPictureAdded || self.childNodeWithName(bgPictureName) != nil {
                    maxValueLabel.removeFromParent()
                    BGPicture.removeFromParent()
                    BGPictureAdded = false
                    if type == .ContainerType && minValue == NoValue {
                        self.alpha = 0.5
                    }
                } else {
                    if colorIndex == NoColor {
                        self.texture = atlas.textureNamed("emptycard")
                    }
                }
            }
        } else {
            hitLabel.text = "\(hitCounter)"
        }

    }

    func setLabelText(label: SKLabelNode, value: Int) {
        guard let text = cardLib[minValue == NoColor ? NoColor : value % MaxCardValue] else {
            return
        }
        label.text = "\(value == 10 ? " " : "")\(text)"
    }
    
    func getMirroredScore() -> Int {
        return countScore * mirrored
    }
        
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
