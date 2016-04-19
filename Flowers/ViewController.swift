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
        
        
//        GV.actGameParam = GV.dataStore.readActGameParamRecord()
        
//        GV.gameStatistics.nameID = GV.player!.ID
//        GV.gameStatistics.level = GV.player!.levelID
        
        if GV.realm.objects(PlayerModel).count == 0 {
            GV.player = PlayerModel()
            GV.player!.aktLanguageKey = GV.language.getAktLanguageKey()
            GV.player!.name = GV.language.getText(.TCGuest)
            GV.player!.isActPlayer = true
            GV.player!.ID = 0
            try! GV.realm.write({
                GV.realm.add(GV.player!)
            })
            
        } else {
            GV.player = GV.realm.objects(PlayerModel).filter("isActPlayer = TRUE").first!
         }
 
        if GV.realm.objects(StatisticModel).filter("playerID = %d", GV.player!.ID).count == 0 {
            GV.statistic = StatisticModel()
            GV.statistic!.ID = GV.realm.objects(StatisticModel).count
            GV.statistic!.playerID = GV.player!.ID
            GV.statistic!.levelID = GV.player!.levelID
            try! GV.realm.write({
                GV.realm.add(GV.statistic!)
            })
        } else {
            GV.statistic = GV.realm.objects(StatisticModel).filter("playerID = %d AND levelID = %d", GV.player!.ID, /*GV.player!.levelID*/0).first!
        }
        
        GV.language.setLanguage(GV.player!.aktLanguageKey)
//        GV.soundVolume = Float(GV.actGameParam.soundVolume)
//        GV.musicVolume = Float(GV.actGameParam.musicVolume)
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        skView!.ignoresSiblingOrder = true
        
//        if GV.actGameParam.gameModus == GameModusCards {
            let scene = CardGameScene(size: CGSizeMake(view.frame.width, view.frame.height))
            GV.language.addCallback(scene.changeLanguage)
            scene.scaleMode = .ResizeFill
            scene.parentViewController = self
            scene.settingsDelegate = self
            skView!.presentScene(scene)
            cardsScene = scene
//        } else {
//            let scene = FlowerGameScene(size: CGSizeMake(view.frame.width, view.frame.height))
//            GV.language.addCallback(scene.changeLanguage)
//            scene.scaleMode = .ResizeFill
//            scene.parentViewController = self
//            scene.settingsDelegate = self
//            skView!.presentScene(scene)
//            flowersScene = scene
//        }
        
        

    }
    
    func settingsDelegateFunc() {
        aktName = GV.player!.name
//        aktModus = GV.actGameParam.gameModus
        self.performSegueWithIdentifier("SettingsSegue", sender: nil)
    }

    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
//        if aktName != GV.player!.name || aktModus != GV.actGameParam.gameModus {
//            startScene()
//        } else {
            if let scene = cardsScene {
                scene.playMusic("MyMusic", volume: GV.player!.musicVolume, loops: 0)
                scene.startDoCountUpTimer()
//            } else if let scene = flowersScene {
//                scene.playMusic("MyMusic", volume: GV.player!.musicVolume, loops: 0)
//                scene.startTimer()
//            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

