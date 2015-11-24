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


class ViewController: UIViewController, SettingsDelegate {
    var aktName = ""
    var skView: SKView?
    var scene: GameScene?
    override func viewDidLoad() {
        super.viewDidLoad()
        startScene()
        // Do any additional setup after loading the view, typically from a nib.
     }
    
    func startScene() {
        skView = self.view as? SKView
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView!.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        //scene.scaleMode = .AspectFill
        //print("in viewDidLoad:\(view.frame.size)")
        
        GV.globalParam = GV.dataStore.getGlobalParam()
        
        GV.spriteGameDataArray = GV.dataStore.getSpriteData()
//        for index in 0..<GV.spriteGameDataArray.count {
//            if GV.globalParam.aktName == GV.spriteGameDataArray[index].name {
//                GV.spriteGameData = GV.spriteGameDataArray[index]
//            }
//        }
        let index = GV.getAktNameIndex()
        GV.language.setLanguage(GV.spriteGameDataArray[index].aktLanguageKey)
        GV.showHelpLines = Int(GV.spriteGameDataArray[index].showHelpLines)
        scene = GameScene(size: CGSizeMake(view.frame.width, view.frame.height))
        
        GV.language.addCallback(scene!.changeLanguage)
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        skView!.ignoresSiblingOrder = true
        scene!.scaleMode = .ResizeFill
        scene!.parentViewController = self
        scene!.settingsDelegate = self
        
        
        skView!.presentScene(scene)

    }
    
    func settingsDelegateFunc() {
        aktName = GV.globalParam.aktName
        self.performSegueWithIdentifier("SettingsSegue", sender: nil)
    }

    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
        if aktName != GV.globalParam.aktName {
            startScene()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

