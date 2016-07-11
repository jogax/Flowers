//
//  ViewController.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 20.09.15.
//  Copyright © 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import SpriteKit
import RealmSwift
import GameplayKit

var Pi = CGFloat(M_PI)
let DegreesToRadians = Pi / 180
let RadiansToDegrees = 180 / Pi
let countGames = 10000


class ViewController: UIViewController, SettingsDelegate, UIApplicationDelegate {
    var aktName = ""
    var aktModus = GameModusFlowers
    var skView: SKView?
    var cardsScene: CardGameScene?
    var flowersScene: FlowerGameScene?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.importGamePredefinitions()
        startScene()

//        _ = CreateGamePredefinition(countGames: countGames)
//        exportGames(1000)
        
//        let _ = ImportGamePredefinitions(countGames: countGames)
//        backgroundThread(background: {
//            self.loadGamePredefinitionIfNecessary(countGames)
//        })
//        sleep(Double(1)) // wait for a second

//        copyDefaultRealmFileIfNotExistsYet()
//        printFonts()
        // Do any additional setup after loading the view, typically from a nib.
     }
    
    func applicationWillEnterForeground(application: UIApplication) {
        _ = 0
    }
    
    func importGamePredefinitions() {
        let actCount = realm.objects(GamePredefinitionModel).count
        if actCount < GamePredefinitions.gameArray.count {
            for gameNumber in actCount..<GamePredefinitions.gameArray.count {
                let game = GamePredefinitionModel()
                game.gameNumber = gameNumber
                game.seedData = GamePredefinitions.gameArray[gameNumber]!.dataFromHexadecimalString()!
                try! realm.write({
                    realm.add(game)
                })

            }
        }


    }
    
    func copyDefaultRealmFileIfNotExistsYet() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory = paths[0] 
        let defaultFilePath = documentDirectory.stringByAppendingString("/default.realm")
        
        let manager = NSFileManager.defaultManager()
        if (manager.fileExistsAtPath(defaultFilePath)) {
            print("DB exists, nothing to do")
        } else {
            print("not exists at path: \(documentDirectory), will be copied")
            let myOrigRealmFile = NSBundle.mainBundle().pathForResource("MyDB", ofType: "realm")
//            try! manager.moveItemAtPath(myOrigRealmFile!, toPath: defaultFilePath)
            try! manager.copyItemAtPath(myOrigRealmFile!, toPath: defaultFilePath)
//            try! manager.removeItemAtPath(myOrigRealmFile!)
        }
        realm = try! Realm()
    }
    
    func loadGamePredefinitionIfNecessary(countGames: Int) {
        let realm = try! Realm()
        if realm.objects(GameModel).count < countGames {
            while Reachability.isConnectedToNetwork() == false {
                sleep(Double(5))
            }
            if Reachability.isConnectedToNetwork() == true {
                for gameNumber in 0..<countGames {
                    if realm.objects(GameModel).filter("gameNumber = %d", gameNumber).count == 0 {
//                        GV.cloudStore.readRecord(gameNumber)
                        sleep(0.025)
                    }
                }
            }
        }
    }
    
    func exportGames(countGames: Int) {
        for gameNumber in 0..<countGames {
            let random = GKARC4RandomSource()
            let myNSData = random.seed
            let quote = "\""
            print("\(gameNumber):\(quote)\(myNSData.hexString!)\(quote),")
        }
    }
    
    func startScene() {
        skView = self.view as? SKView
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        cardsScene = nil
        flowersScene = nil
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView!.ignoresSiblingOrder = true


        
        if realm.objects(PlayerModel).count == 0 {
              GV.createNewPlayer(true)
        }
        
        
        GV.player = realm.objects(PlayerModel).filter("isActPlayer = TRUE").first!
 
        if realm.objects(StatisticModel).filter("playerID = %d", GV.player!.ID).count == 0 {
            let statistic = StatisticModel()
            statistic.ID = GV.createNewRecordID(.StatisticModel)
            statistic.playerID = GV.player!.ID
            statistic.levelID = GV.player!.levelID
            try! realm.write({
                realm.add(statistic)
            })
        } else {
//            GV.statistic = GV.realm.objects(StatisticModel).filter("playerID = %d AND levelID = %d", GV.player!.ID, GV.player!.levelID).first!
        }
        
        GV.language.setLanguage(GV.player!.aktLanguageKey)
//        GV.soundVolume = Float(GV.actGameParam.soundVolume)
//        GV.musicVolume = Float(GV.actGameParam.musicVolume)
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        skView!.ignoresSiblingOrder = true
        
//        if GV.actGameParam.gameModus == GameModusCards {
            let scene = CardGameScene(size: CGSizeMake(view.frame.width, view.frame.height))
            GV.language.addCallback(scene.changeLanguage, callbackName: "CardGameCallBack")
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
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames()
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNamesForFamilyName(familyName)
            print("Font Names = [\(names)]")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

