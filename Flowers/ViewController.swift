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


class ViewController: UIViewController {
    var scene: SKScene?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        //scene.scaleMode = .AspectFill
        print("in viewDidLoad:\(view.frame.size)")
    
        GV.spriteGameData = GV.dataStore.getSpriteData()
        
        scene = GameScene(size: CGSizeMake(view.frame.width, view.frame.height), parentViewController: self)
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene!.scaleMode = .ResizeFill
       // scene!.parentViewController = self
        
        
        skView.presentScene(scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeScene(scene: SKScene) {
        
    }


}

