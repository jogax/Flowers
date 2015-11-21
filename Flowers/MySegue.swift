//
//  MySegue.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 11. 11..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import UIKit

    class MySegue: UIStoryboardSegue {
        override func perform() {
            self.sourceViewController.presentViewController(self.destinationViewController as UIViewController, animated: false, completion: nil)
        }
    }
