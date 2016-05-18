//
//  MySKSlider.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 13/05/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import AVFoundation

enum SoundType: Int {
    case Music = 0, Sound
}
class MySKSlider: MySKTable, AVAudioPlayerDelegate {
    var callBack: ()->()
    let myColumnWidths: [CGFloat] = [10,80,10]  // in %
    //    let myDetailedColumnWidths = [20, 20, 20, 20, 20] // in %
    let myName = "MySKSlider"
    let countLines = 1
    var volumeValue = CGFloat(50)
    var startLocation = CGPointZero
    var sliderMinMaxXPosition = CGFloat(0)
    var soundType: SoundType
    var soundEffects: AVAudioPlayer?
    var url: NSURL?
    

    
    init (parent: SKSpriteNode, callBack: ()->(), soundType: SoundType) {
        let headLines: [String] = [
            GV.language.getText(.TCPlayer) + ": \(GV.player!.name)",
            soundType == .Music ? GV.language.getText(.TCMusicVolume) : GV.language.getText(.TCSoundVolume),
//            "Testline 3",
//            "Testline 4",
        ]
        self.callBack = callBack
        self.soundType = soundType
        self.volumeValue = CGFloat((soundType == .Music ? GV.player!.musicVolume : GV.player!.soundVolume))
        super.init(columnWidths: myColumnWidths, rows:countLines, headLines: headLines, parent: parent, width: parent.parent!.frame.width * 0.9)
        sliderMinMaxXPosition = self.size.width * myColumnWidths[1] / 2 / 100
        self.name = myName
        let fileName = soundType == .Music ? "MyMusic" : "OK"
        url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource(fileName, ofType: "m4a")!)
        do {
            try soundEffects = AVAudioPlayer(contentsOfURL: url!)
            soundEffects!.delegate = self
            soundEffects!.prepareToPlay()
            soundEffects!.volume = 0.001 * Float(volumeValue)
            soundEffects!.numberOfLoops = -1
        } catch {
            print("audioPlayer error")
        }

        showMe(showSlider)
    }
    
    func showSlider() {
        let sliderImage = DrawImages.getSetVolumeImage(CGSizeMake(self.size.width * 0.8, heightOfLabelRow), volumeValue: volumeValue)
        let elements: [MultiVar] = [
            MultiVar(string: ""),
            MultiVar(image: sliderImage),
            MultiVar(string: "\(volumeValue)")
        ]
        showRowOfTable(elements, row: 0, selected: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
        startLocation = touchLocation
        touchesBeganAtNode = nodeAtPoint(touchLocation)
        if !(touchesBeganAtNode is SKLabelNode || (touchesBeganAtNode is SKSpriteNode && touchesBeganAtNode!.name != myName)) {
            touchesBeganAtNode = nil
        }
        soundEffects!.play()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let sliderNode = self.childNodeWithName("1-0") {
            volumeValue = round((touches.first!.locationInNode(sliderNode).x + self.sliderMinMaxXPosition) / (2 * self.sliderMinMaxXPosition) * 100)
            volumeValue = volumeValue < 0 ? 0 : volumeValue > 100 ? 100 : volumeValue
            showSlider()
            soundEffects!.volume = Float(volumeValue) * 0.001
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInNode(self)
        switch checkTouches(touches, withEvent: event) {
        case MyEvents.GoBackEvent:
            let fadeInAction = SKAction.fadeInWithDuration(0.5)
            myParent.runAction(fadeInAction)
            removeFromParent()
            callBack()
        case .NoEvent:
            let touchesEndedAtNode = nodeAtPoint(touchLocation)
            if touchesBeganAtNode != nil && touchesEndedAtNode is SKSpriteNode && touchesEndedAtNode.name != myName {
                if let sliderNode = self.childNodeWithName("1-0") {
                    volumeValue = round((touches.first!.locationInNode(sliderNode).x + self.sliderMinMaxXPosition) / (2 * self.sliderMinMaxXPosition) * 100)
                    volumeValue = volumeValue < 0 ? 0 : volumeValue > 100 ? 100 : volumeValue
                    showSlider()
                    GV.realm.beginWrite()
                    switch self.soundType {
                    case .Music:
                        GV.player!.musicVolume = Float(volumeValue)
                    default:
                        GV.player!.soundVolume = Float(volumeValue)
                    }
                    try! GV.realm.commitWrite()
                    soundEffects!.stop()
                }
            }
            
        }
        
    }
    
    override func setMyDeviceSpecialConstants() {
        switch GV.deviceConstants.type {
        case .iPadPro12_9:
            fontSize = CGFloat(20)
            heightOfLabelRow = 40
        case .iPad2:
            fontSize = CGFloat(20)
            heightOfLabelRow = 30
        case .iPadMini:
            fontSize = CGFloat(20)
            heightOfLabelRow = 40
        case .iPhone6Plus:
            fontSize = CGFloat(15)
            heightOfLabelRow = 35
        case .iPhone6:
            fontSize = CGFloat(15)
            heightOfLabelRow = 35
        case .iPhone5:
            fontSize = CGFloat(13)
            heightOfLabelRow = 30
        case .iPhone4:
            fontSize = CGFloat(12)
            heightOfLabelRow = 30
        default:
            break
        }
    }
}

