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
        
        
        GV.actGameParam = GV.dataStore.readActGameParamRecord()
        
        GV.gameStatistics.nameID = GV.actGameParam.nameID
        GV.gameStatistics.level = GV.actGameParam.levelIndex
        
        if GV.realm.objects(PlayerModel).count == 0 {
            GV.player = PlayerModel()
            GV.player!.name = GV.language.getText(.TCGuest)
            GV.player!.isActPlayer = true
            GV.player!.nameID = 0
            GV.player!.aktLanguageKey = GV.actGameParam.aktLanguageKey
            try! GV.realm.write({
                GV.realm.add(GV.player!)
            })
            
        } else {
            GV.player = GV.realm.objects(PlayerModel).filter("isActPlayer = True").first!
            print(GV.player)
        }
        
        
        GV.language.setLanguage(GV.actGameParam.aktLanguageKey)
//        GV.soundVolume = Float(GV.actGameParam.soundVolume)
//        GV.musicVolume = Float(GV.actGameParam.musicVolume)
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        skView!.ignoresSiblingOrder = true
        
        if GV.actGameParam.gameModus == GameModusCards {
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
        aktName = GV.actGameParam.name
        aktModus = GV.actGameParam.gameModus
        self.performSegueWithIdentifier("SettingsSegue", sender: nil)
    }

    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
        if aktName != GV.actGameParam.name || aktModus != GV.actGameParam.gameModus {
            startScene()
        } else {
            if let scene = cardsScene {
                scene.playMusic("MyMusic", volume: GV.actGameParam.musicVolume, loops: 0)
                scene.startDoCountUpTimer()
            } else if let scene = flowersScene {
                scene.playMusic("MyMusic", volume: GV.actGameParam.musicVolume, loops: 0)
                scene.startTimer()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

