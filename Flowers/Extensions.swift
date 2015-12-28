//
//  Extensions.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 12. 28..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import UIKit

public extension UIDevice {

    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    var modelSizeConstant: CGFloat {
        let bounds = UIScreen.mainScreen().bounds
        let width = bounds.width
        let height = bounds.height
        let iphone4Multiplier: CGFloat = 0.5
        let iphone5Multiplier: CGFloat = 0.5
        let iphone6Multiplier: CGFloat = 0.65
        let iphone6PlusMultiplier: CGFloat = 0.8
        let ipadMultiplier: CGFloat = 1.1
        let ipadProMultiplier: CGFloat = 1.2
        switch modelName {
            case "iPod Touch 5": return 0.5
            case "iPod Touch 5": return 0.5
            case "iPod Touch 6": return 0.5
            case "iPhone 4": return 0.5
            case "iPhone 4s": return 0.5
            case "iPhone 5": return 0.5
            case "iPhone 5c": return 0.5
            case "iPhone 5s": return 0.5
            case "iPhone 6": return iphone6Multiplier
            case "iPhone 6 Plus": return iphone6PlusMultiplier
            case "iPhone 6s": return iphone6Multiplier
            case "iPhone 6s Plus": return iphone6PlusMultiplier
            case "iPad 2": return 1.0
            case "iPad 3": return 1.0
            case "iPad 4": return 1.0
            case "iPad Air": return 1.0
            case "iPad Air 2": return 1.0
            case "iPad Mini": return 0.8
            case "iPad Mini 2": return 0.8
            case "iPad Mini 3": return 0.8
            case "iPad Mini 4": return 0.8
            case "iPad Pro": return 1.2
            case "Apple TV": return 0
            case "Simulator":
                switch (width, height) {
                    case (320, 480): return iphone4Multiplier
                    case (320, 568): return iphone5Multiplier
                    case (375, 667): return iphone6Multiplier
                    case (414, 736): return iphone6PlusMultiplier
                    case (768, 1024): return ipadMultiplier
                case (1024, 1366): return ipadProMultiplier
                    default: return 0
            }
            default: return 0
        }
    }
    
}
