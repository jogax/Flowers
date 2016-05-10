//
//  MySKPanel.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 18/03/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
enum PanelTypes: Int {
    case Settings = 0
}
class MySKPanel: SKSpriteNode {
    var view: UIView
    override var size: CGSize {
        didSet {
            if oldValue != size {
                for index in 0..<self.children.count {
                    if self.children[index] is SKLabelNode {
                        print("Label:",  self.children[index].name)
                    }
                }
            }
        }
    }
    
    let noTouchFunc = "noTouch"
    let setPlayerFunc = "setPlayer"
    let setSoundFunc = "setSoundVolume"
    let setMusicFunc = "setMusicVolume"
    let setLanguageFunc = "setLanguage"
    let setStatisticFunc = "setStatistics"
    let setReturnFunc = "setReturn"
    var sizeMultiplier = CGSizeMake(0, 0)
    var fontSize:CGFloat = 0
    var callBack: (Bool)->()
    var parentScene: SKScene?
    
    let playerLabel = SKLabelNode()
    let nameLabel = SKLabelNode()
    let soundLabel = SKLabelNode()
    let musicLabel = SKLabelNode()
    let languageLabel = SKLabelNode()
    let statisticLabel = SKLabelNode()
    let returnLabel = SKLabelNode()


    var type: PanelTypes
    var playerChanged = false
    var touchesBeganWithNode: SKNode?
    var shadow: SKSpriteNode?
    init(view: UIView, frame: CGRect, type: PanelTypes, parent: SKScene, callBack: (Bool)->()) {
        let size = parent.size / 2 //CGSizeMake(parent.size.width / 2, parent.s)
//        let texture: SKTexture = SKTexture(imageNamed: "panel")
        let texture: SKTexture = SKTexture()
        
        sizeMultiplier = size / 10
        
        self.callBack = callBack
        self.view = view
        self.type = type
        self.parentScene = parent
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
        self.texture = SKTexture(image: getPanelImage(size))
        setMyDeviceConstants()
        let startPosition = CGPointMake(parent.size.width, parent.size.height / 2)
        let zielPosition = CGPointMake(parent.size.width / 2, parent.size.height / 2)
        self.size = size
        self.position = startPosition
        self.color = UIColor.yellowColor()
        self.zPosition = 100
        self.alpha = 1.0
        self.name = "MySKPanel"
        self.userInteractionEnabled = true
        parentScene!.userInteractionEnabled = false
        makeSettings()
        parentScene!.addChild(self)
        let moveAction = SKAction.moveTo(zielPosition, duration: 0.5)
        self.runAction(moveAction)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeSettings() {
        let name = GV.player!.name == GV.language.getText(.TCAnonym) ? GV.language.getText(.TCGuest) : GV.player!.name
        createLabels(playerLabel, text: GV.language.getText(.TCPlayer) + ": \(name)", lineNr: 1, horAlignment: SKLabelHorizontalAlignmentMode.Center, name: noTouchFunc)
        playerLabel.fontColor = UIColor.blackColor()
        createLabels(nameLabel, text: GV.language.getText(.TCName), lineNr: 2, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setPlayerFunc)
        createLabels(soundLabel, text: GV.language.getText(.TCSoundVolume), lineNr: 3, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setSoundFunc )
        createLabels(musicLabel, text: GV.language.getText(.TCMusicVolume), lineNr: 4, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setMusicFunc )
        createLabels(languageLabel, text: GV.language.getText(.TCLanguage), lineNr: 5, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setLanguageFunc )
        createLabels(statisticLabel, text: GV.language.getText(.TCStatistic), lineNr: 6, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setStatisticFunc )
        createLabels(returnLabel, text: GV.language.getText(.TCReturn), lineNr: 7, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setReturnFunc )

    }
    func createLabels(label: SKLabelNode, text: String, lineNr: Int, horAlignment: SKLabelHorizontalAlignmentMode, name:String) {
        label.text = text
        label.name = name
        
        label.position = CGPointMake(-CGFloat(size.width / 2) + sizeMultiplier.width ,  CGFloat(5 - lineNr) * sizeMultiplier.height )
        label.fontName = "AvenirNext"
//        print (self.frame, label.frame)
        label.fontColor = SKColor.blueColor()
        label.zPosition = self.zPosition + 10
        label.horizontalAlignmentMode = .Left
        label.fontSize = fontSize
        self.addChild(label)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
        let node = nodeAtPoint(touchLocation)
        touchesBeganWithNode = node
//        print(node.name)
        if node is SKLabelNode && node.name!.isMemberOf (setPlayerFunc, setSoundFunc, setMusicFunc, setLanguageFunc, setStatisticFunc,setReturnFunc) {
            (node as! SKLabelNode).fontSize += 2
        }

    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
        if touchesBeganWithNode is SKLabelNode {
            if touchesBeganWithNode!.name != noTouchFunc {
                (touchesBeganWithNode as! SKLabelNode).fontSize -= 2
            }
            let node = nodeAtPoint(touchLocation)
            if node is SKLabelNode && touchesBeganWithNode == node {
                if node.name!.isMemberOf (setPlayerFunc, setSoundFunc, setMusicFunc, setLanguageFunc, setStatisticFunc, setReturnFunc) {
    //                (node   as! SKLabelNode).fontSize -= 2
                    switch node.name! {
                    case setPlayerFunc: setPlayer()
                    case setSoundFunc: setSoundVolume()
                    case setMusicFunc: setMusicVolume()
                    case setLanguageFunc: setLanguage()
                    case setStatisticFunc: setStatistic()
                    case setReturnFunc: goBack()
                    default: goBack()
                    }
                }
            }
        }
    }
    
    func noTouch() {
        
    }
    
    func setPlayer() {
        userInteractionEnabled = false
        let _ = MySKPlayer(parent: self, view: parentScene!.view!, callBack: callIfMySKPlayerEnds)
    }
    func setSoundVolume() {
        
    }
    func setMusicVolume() {
        
    }
    func setLanguage() {
        userInteractionEnabled = false
        let _ = MySKLanguages(parent: self, callBack: callIfMySKLanguagesEnds)
    }
    
    func setStatistic() {
        userInteractionEnabled = false
        let _ = MySKStatistic(parent: self, callBack: callIfMySKStatisticEnds)
    }
    
    func goBack() {
        shadow?.removeFromParent()
        self.removeFromParent()
        parentScene!.userInteractionEnabled = true
        callBack(playerChanged)
    }
    
    func callIfMySKPlayerEnds () {
        if GV.player!.name != GV.realm.objects(PlayerModel).filter("isActPlayer = true").first!.name {
            GV.realm.beginWrite()
            GV.player = GV.realm.objects(PlayerModel).filter("isActPlayer = true").first
            GV.statistic = GV.realm.objects(StatisticModel).filter("playerID = %d and levelID = %d", GV.player!.ID, GV.player!.levelID).first
            try! GV.realm.commitWrite()
            playerChanged = true
        }
        let name = GV.player!.name == GV.language.getText(.TCAnonym) ? GV.language.getText(.TCGuest) : GV.player!.name
        playerLabel.text = GV.language.getText(.TCPlayer) + ": \(name)"
        self.userInteractionEnabled = true
    }
    
    func callIfMySKLanguagesEnds() {
        self.userInteractionEnabled = true
        let name = GV.player!.name == GV.language.getText(.TCAnonym) ? GV.language.getText(.TCGuest) : GV.player!.name
        playerLabel.text = GV.language.getText(.TCPlayer) + ": \(name)"
        nameLabel.text = GV.language.getText(.TCName)
        soundLabel.text = GV.language.getText(.TCSoundVolume)
        musicLabel.text = GV.language.getText(.TCMusicVolume)
        languageLabel.text = GV.language.getText(.TCLanguage)
        statisticLabel.text = GV.language.getText(.TCStatistic)
        returnLabel.text = GV.language.getText(.TCReturn)
    }
    
    func callIfMySKStatisticEnds() {
        self.userInteractionEnabled = true
        let name = GV.player!.name == GV.language.getText(.TCAnonym) ? GV.language.getText(.TCGuest) : GV.player!.name
        playerLabel.text = GV.language.getText(.TCPlayer) + ": \(name)"
        nameLabel.text = GV.language.getText(.TCName)
        soundLabel.text = GV.language.getText(.TCSoundVolume)
        musicLabel.text = GV.language.getText(.TCMusicVolume)
        languageLabel.text = GV.language.getText(.TCLanguage)
        statisticLabel.text = GV.language.getText(.TCStatistic)
        returnLabel.text = GV.language.getText(.TCReturn)
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
            CGPointMake(size.width * 0.1, size.height * 0.12),
            CGPointMake(size.width * 0.9, size.height * 0.12)
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

