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
    let setReturnFunc = "setReturn"
    var sizeMultiplier = CGSizeMake(0, 0)
    let fontSizeMultiplier:CGFloat = 0.09

    var type: PanelTypes
    var touchesBeganWithNode: SKNode?
    var shadow: SKSpriteNode?
    init(view: UIView, frame: CGRect, type: PanelTypes, parent: SKScene) {
        let size = parent.size / 2 //CGSizeMake(parent.size.width / 2, parent.s)
//        let texture: SKTexture = SKTexture(imageNamed: "panel")
        let texture: SKTexture = SKTexture(image: DrawImages().getPanelImage(size))
        
        sizeMultiplier = size / 10
        
        self.view = view
        self.type = type
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
        self.position = CGPointMake(parent.size.width / 2, parent.size.height / 2)
        self.size = size / 10
        self.color = UIColor.yellowColor()
        self.zPosition = 100
        self.alpha = 1.0
        self.userInteractionEnabled = true
        
        parent.addChild(self)
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
        let nameLabel = SKLabelNode()
        createLabels(nameLabel, text: GV.language.getText(.TCName), lineNr: 1, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setPlayerFunc)
        let soundLabel = SKLabelNode()
        createLabels(soundLabel, text: GV.language.getText(.TCSoundVolume), lineNr: 2, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setSoundFunc )
        let musicLabel = SKLabelNode()
        createLabels(musicLabel, text: GV.language.getText(.TCMusicVolume), lineNr: 3, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setMusicFunc )
        let languageLabel = SKLabelNode()
        createLabels(languageLabel, text: GV.language.getText(.TCLanguage), lineNr: 4, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setLanguageFunc )
        let returnLabel = SKLabelNode()
        createLabels(returnLabel, text: GV.language.getText(.TCReturn), lineNr: 5, horAlignment: SKLabelHorizontalAlignmentMode.Left, name: setReturnFunc )

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
        if node is SKLabelNode && node.name!.isMemberOf (setPlayerFunc, setSoundFunc, setMusicFunc, setLanguageFunc, setReturnFunc) {
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
                    case setReturnFunc: goBack()
                    default: goBack()
                    }
                }
            }
        }
    }
    
    func setPlayer() {
        
        MySKPlayer(parent: self, view: view)
    }
    func setSoundVolume() {
        
    }
    func setMusicVolume() {
        
    }
    func setLanguage() {
        
    }
    func goBack() {
        shadow?.removeFromParent()
        self.removeFromParent()
    }


}

