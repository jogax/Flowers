//
//  SettingsNode.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 10. 19..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import SpriteKit


func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

func * (point: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: point.width * scalar, height: point.height * scalar)
}

func / (point: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: point.width / scalar, height: point.height / scalar)
}


class SettingsScene: SKScene {
    var returnToScene: SKScene?
    
    let tcName = 1
    let tcSoundVolume = 2
    let tcMusicVolume = 3
    let tcCountHelpLines = 4
    let tcLanguage = 5
    let tcReturn = 6
    
    let tcGerman = 1
    let tcEnglish = 2
    let tcHungarian = 3
    let tcRussian = 4
    
    var settingsWindow: SKSpriteNode?
    var languageWindow: SKSpriteNode?
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor.whiteColor()
       
        settingsWindow!.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
        settingsWindow!.size = self.size / 1.3
        
        self.addChild(settingsWindow!)
        
        
        addNewButton("\(GV.language.getText(.TCName))", buttonNr: tcName)
        addNewButton("\(GV.language.getText(.TCSoundVolume))", buttonNr: tcSoundVolume)
        addNewButton("\(GV.language.getText(.TCMusicVolume))", buttonNr: tcMusicVolume)
        addNewButton("\(GV.language.getText(.TCCountHelpLines))", buttonNr: tcCountHelpLines)
        addNewButton("\(GV.language.getText(.TCLanguage))", buttonNr: tcLanguage)
        addNewButton("\(GV.language.getText(.TCReturn))", buttonNr: tcReturn)
        
    }

    override init(size:CGSize) {
        let texture = atlas.textureNamed("settings")
        settingsWindow = SKSpriteNode(texture: texture)
        super.init(size: size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    func addNewButton(buttonName: String, buttonNr: Int) {
        let yPosMultiplier = settingsWindow!.size.height / 7
        let yPosKorr = settingsWindow!.size.height / 3
        let texture = atlas.textureNamed("mybutton")
        let button = SKSpriteNode(texture: texture)
        
        //button.position.x = settingsWindow.position.x
        let buttonSizeKorr = button.size.height / button.size.width
        button.position.y = settingsWindow!.frame.minY + yPosKorr - CGFloat(buttonNr) * yPosMultiplier
        button.size.width = settingsWindow!.size.width * 0.9
        button.size.height = button.size.width * buttonSizeKorr
        button.name = "\(buttonNr)"
        
        
        let buttonText = SKLabelNode()
        buttonText.text = buttonName
        buttonText.position = position
        buttonText.fontColor = SKColor.blackColor()
        buttonText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        buttonText.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        buttonText.fontSize = settingsWindow!.size.height / 20
        buttonText.zPosition = 10
        button.addChild(buttonText)
        button.zPosition = 10
        settingsWindow!.addChild(button)

    }
    
    func addNewRadioButton(language: String, languageNr: Int) {
        var texture: SKTexture
        var text = ""
        switch language {
            case LanguageDE: text = GV.language.getText(.TCGerman)
            case LanguageEN: text = GV.language.getText(.TCEnglish)
            case LanguageHU: text = GV.language.getText(.TCHungarian)
            case LanguageRU: text = GV.language.getText(.TCRussian)
            default: text = ""
        }
        let radioText = SKLabelNode(text: text)
        //let aktLanguage = GV.language.getAktLanguageKey()
        if GV.language.isAktLanguage(language) {
            texture = atlas.textureNamed("radioButtonChecked")
        } else {
            texture = atlas.textureNamed("radioButton")
        }
        let radioPane = SKSpriteNode(texture: texture)
        radioPane.addChild(radioText)
        languageWindow!.addChild(radioPane)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let firstTouch = touches.first
        let touchLocation = firstTouch!.locationInNode(self)
        
        let testNode = self.nodeAtPoint(touchLocation)
        var button: SKSpriteNode
        switch testNode {
        case is SKLabelNode:
                button = testNode.parent as! SKSpriteNode
        default:
                button = testNode as! SKSpriteNode
        }
        button.size.height *= 0.98
        button.size.width *= 0.98
        
        
        
        
        
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let firstTouch = touches.first
        let touchLocation = firstTouch!.locationInNode(self)
        
        let testNode = self.nodeAtPoint(touchLocation)
        var button: SKSpriteNode
        switch testNode {
        case is SKLabelNode:
            button = testNode.parent as! SKSpriteNode
        default:
            button = testNode as! SKSpriteNode
        }
        button.size.height /= 0.98
        button.size.width /= 0.98
        switch Int(button.name!) {
        case tcName?:
            _ = 1
        case tcSoundVolume?:
            _ = 2
        case tcMusicVolume?:
            _ = 3
        case tcCountHelpLines?:
            _ = 4
        case tcLanguage?:
            tcLanguageFunc()
        case tcReturn?:
            tcReturnFunc()
        default:
            _ = 7

        }
    }
        
    func tcReturnFunc() {
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 1.0)
        self.view?.presentScene(self.returnToScene!, transition: transition)
    }
    
    func tcLanguageFunc() {
        
        let texture = atlas.textureNamed("settings")
        languageWindow = SKSpriteNode(texture: texture)
        languageWindow!.size = settingsWindow!.size
        languageWindow!.position = settingsWindow!.position
        languageWindow!.zPosition = settingsWindow!.zPosition + 1
        settingsWindow!.removeFromParent()
        self.addChild(languageWindow!)
        addNewRadioButton(LanguageDE, languageNr: tcGerman)
        addNewRadioButton(LanguageEN, languageNr: tcEnglish)
        addNewRadioButton(LanguageHU, languageNr: tcHungarian)
        addNewRadioButton(LanguageRU, languageNr: tcRussian)

    }

    
}
