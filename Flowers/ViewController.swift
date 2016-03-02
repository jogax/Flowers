//
//  ViewController.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 20.09.15.
//  Copyright © 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import SpriteKit

let Pi = CGFloat(M_PI)
let DegreesToRadians = Pi / 180
let RadiansToDegrees = 180 / Pi


class ViewController: UIViewController, SettingsDelegate, UIApplicationDelegate {
    var aktName = ""
    var aktModus = GameModusFlowers
    var skView: SKView?
    var cardsScene: CardGameScene?
    var flowersScene: FlowerGameScene?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startScene()
        // Do any additional setup after loading the view, typically from a nib.
     }
    
    func applicationWillEnterForeground(application: UIApplication) {
        _ = 0
    }
    
    
    func startScene() {
        skView = self.view as? SKView
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        cardsScene = nil
        flowersScene = nil
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView!.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        //scene.scaleMode = .AspectFill
        //print("in viewDidLoad:\(view.frame.size)")
        
        GV.globalParam = GV.dataStore.getGlobalParam()
        
        GV.spriteGameDataArray = GV.dataStore.getSpriteData()
        
        GV.gameStatistics.name = GV.globalParam.aktName
        GV.gameStatistics.level = GV.spriteGameDataArray[GV.getAktNameIndex()].spriteLevelIndex
        
        
//        for index in 0..<GV.spriteGameDataArray.count {
//            if GV.globalParam.aktName == GV.spriteGameDataArray[index].name {
//                GV.spriteGameData = GV.spriteGameDataArray[index]
//            }
//        }
        let index = GV.getAktNameIndex()
        GV.language.setLanguage(GV.spriteGameDataArray[index].aktLanguageKey)
        GV.showHelpLines = Int(GV.spriteGameDataArray[index].showHelpLines)
        GV.soundVolume = Float(GV.spriteGameDataArray[index].soundVolume)
        GV.musicVolume = Float(GV.spriteGameDataArray[index].musicVolume)
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        skView!.ignoresSiblingOrder = true
        
        if GV.spriteGameDataArray[GV.getAktNameIndex()].gameModus == GameModusCards {
            let scene = CardGameScene(size: CGSizeMake(view.frame.width, view.frame.height))
            GV.language.addCallback(scene.changeLanguage)
            scene.scaleMode = .ResizeFill
            scene.parentViewController = self
            scene.settingsDelegate = self
            skView!.presentScene(scene)
            cardsScene = scene
        } else {
            let scene = FlowerGameScene(size: CGSizeMake(view.frame.width, view.frame.height))
            GV.language.addCallback(scene.changeLanguage)
            scene.scaleMode = .ResizeFill
            scene.parentViewController = self
            scene.settingsDelegate = self
            skView!.presentScene(scene)
            flowersScene = scene
        }
        
        

    }
    
    func settingsDelegateFunc() {
        aktName = GV.globalParam.aktName
        aktModus = GV.spriteGameDataArray[GV.getAktNameIndex()].gameModus
        self.performSegueWithIdentifier("SettingsSegue", sender: nil)
    }

    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
        if aktName != GV.globalParam.aktName || aktModus != GV.spriteGameDataArray[GV.getAktNameIndex()].gameModus {
            startScene()
        } else {
            if let scene = cardsScene {
                scene.playMusic("MyMusic", volume: GV.musicVolume, loops: 0)
                scene.startDoCountUpTimer()
            } else if let scene = flowersScene {
                scene.playMusic("MyMusic", volume: GV.musicVolume, loops: 0)
                scene.startTimer()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

