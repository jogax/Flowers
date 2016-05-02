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
    let setPlayerFunc = "setPlayer"
    let setSoundFunc = "setSoundVolume"
    let setMusicFunc = "setMusicVolume"
    let setLanguageFunc = "setLanguage"
    let setStatisticFunc = "setStatistics"
    let setReturnFunc = "setReturn"
    var sizeMultiplier = CGSizeMake(0, 0)
    let fontSizeMultiplier:CGFloat = 0.09
    var callBack: (Bool)->()
    var parentScene: SKScene?
    
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
        let texture: SKTexture = SKTexture(image: DrawImages().getPanelImage(size))
        
        sizeMultiplier = size / 10
        
        self.callBack = callBack
        self.view = view
        self.type = type
        self.parentScene = parent
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
        self.position = CGPointMake(parent.size.width / 2, parent.size.height / 2)
        self.size = size / 10
        self.color = UIColor.yellowColor()
        self.zPosition = 100
        self.alpha = 1.0
        self.userInteractionEnabled = true
        parentScene!.userInteractionEnabled = false
        parentScene!.addChild(self)
        let zoomIn = SKAction.resizeToWidth(size.width, height: size.height, duration: 0.5)
        let callInitFunc = SKAction.runBlock({
            switch type {
                case .Settings: self.makeSettings()
            }
        })
        self.runAction(SKAction.sequence([zoomIn, callInitFunc]))

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeSettings() {
        createLabels(nameLabel, text: GV.language.getText(.TCName), lineNr: 1, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setPlayerFunc)
        createLabels(soundLabel, text: GV.language.getText(.TCSoundVolume), lineNr: 2, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setSoundFunc )
        createLabels(musicLabel, text: GV.language.getText(.TCMusicVolume), lineNr: 3, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setMusicFunc )
        createLabels(languageLabel, text: GV.language.getText(.TCLanguage), lineNr: 4, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setLanguageFunc )
        createLabels(statisticLabel, text: GV.language.getText(.TCStatistic), lineNr: 5, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setStatisticFunc )
        createLabels(returnLabel, text: GV.language.getText(.TCReturn), lineNr: 6, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setReturnFunc )

    }
    func createLabels(label: SKLabelNode, text: String, lineNr: Int, horAlignment: SKLabelHorizontalAlignmentMode, name:String) {
        label.text = text
        label.name = name
        
        label.position = CGPointMake(-CGFloat(size.width / 2) + sizeMultiplier.width ,  CGFloat(5 - lineNr) * sizeMultiplier.height )
        label.fontName = "AvenirNext"
//        print (self.frame, label.frame)
        label.fontColor = SKColor.blueColor()
        label.zPosition = self.zPosition + 10
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        label.fontSize = self.frame.width * fontSizeMultiplier * 0.7
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
            (touchesBeganWithNode as! SKLabelNode).fontSize -= 2
            let node = nodeAtPoint(touchLocation)
            if node is SKLabelNode && touchesBeganWithNode == node {
                if node.name!.isMemberOf (setPlayerFunc, setSoundFunc, setMusicFunc, setLanguageFunc, setReturnFunc) {
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
    
    func setPlayer() {
        userInteractionEnabled = false
        let _ = MySKPlayer(parent: self, view: view, callBack: callIfMySKPlayerEnds)
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
        self.userInteractionEnabled = true
    }
    
    func callIfMySKLanguagesEnds() {
        self.userInteractionEnabled = true
        nameLabel.text = GV.language.getText(.TCName)
        soundLabel.text = GV.language.getText(.TCSoundVolume)
        musicLabel.text = GV.language.getText(.TCMusicVolume)
        languageLabel.text = GV.language.getText(.TCLanguage)
        statisticLabel.text = GV.language.getText(.TCStatistic)
        returnLabel.text = GV.language.getText(.TCReturn)
    }

    deinit {
    }

}

