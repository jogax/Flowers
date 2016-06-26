//
//  Extensions.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 12. 28..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import UIKit


public extension UIDevice {
    enum UIDeviceTypes: Int {
        case NoDevice = 0, IPodTouch5, IPodTouch6, IPhone4, IPhone4s, IPhone5, IPhone5c, IPhone5s, IPhone6, IPhone6Plus, IPhone6s, IPhone6sPlus, IPad2,
        IPad3, IPad4, IPadAir, IPadAir2, IPadMini, IPadMini2, IPadMini3, IPadMini4, IPadPro, AppleTV, Simulator}
    
    var modelName: String {
        let bounds = UIScreen.mainScreen().bounds
        let width = bounds.width
        let height = bounds.height
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
            case "i386", "x86_64":
                switch (width, height) {
                    case (320, 480):                            return "iPhone 4s"
                    case (320, 568):                            return "iPhone 5s"
                    case (375, 667):                            return "iPhone 6"
                    case (414, 736):                            return "iPhone 6 Plus"
                    case (768, 1024):                           return "iPad Air"
                    case (1024, 1366):                          return "iPad Pro"
                    default:                                    return identifier
                }
            default:                                        return identifier
        }

    }
        
}

extension Double {
    var twoDecimals: Double {
        return Double(round(100*self)/100)
    }
    var threeDecimals: Double {
        return Double(round(1000*self)/1000)
    }
    func nDecimals(n: Int)->Double {
        let multiplier: Double = pow(10.0,Double(n))
        return Double(round(multiplier*self)/Double(n*1000))
        
    }
    
}

extension Int {
    var dayHourMinSec: String {
        var days: Int = 0
        var hours: Int = 0
        var minutes: Int = 0
        var seconds: Int = self
        if self > 59 {
            seconds = self % 60
            minutes = self / 60
        }
        if minutes > 59 {
            hours = minutes / 60
            minutes = minutes % 60
        }
        if hours > 23 {
            days = hours / 24
            hours = hours % 24
        }
        let daysString = days > 0 ? ((days < 10 ? "0":"") + String(days) + ":") : ""
        let hoursString = hours > 0 ? ((hours < 10 ? "0":"") + String(hours) + ":") : days > 0 ? "00:" : ""
        let minutesString = (minutes < 10 ? "0" : "") + String(minutes) + ":"
        let secondsString = (seconds < 10 ? "0" : "") + String(seconds)
        return daysString + hoursString + minutesString + secondsString
    }
    func isMemberOf(values: Int...)->Bool {
        for index in 0..<values.count {
            if self == values[index] {
                return true
            }
        }
        return false
    }
    
    func between(min: Int, max: Int)->Bool {
        return self >= min && self <= max
    }
}

extension CGFloat {
    func between(min: CGFloat, max: CGFloat)->Bool {
        return self >= min && self <= max
    }
}

extension String {
    func replace(what: String, values: [String])->String {
        let toArray = self.componentsSeparatedByString(what)
        var endString = ""
        var vIndex = 0
        for index in 0..<toArray.count {
            endString += toArray[index] + (vIndex < values.count ? values[vIndex] : "")
            vIndex += 1
        }
        return endString
    }
    
    func isMemberOf(values: String...)->Bool {
        for index in 0..<values.count {
            if self == values[index] {
                return true
            }
        }
        return false
    }
}

extension UIColor {
    static public func greenAppleColor()->UIColor {
        return UIColor(red: 0x52/0xff, green: 0xD0/0xff, blue: 0x17/0xff, alpha: 1.0)
    }
}

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        //        let radiansToDegrees: (CGFloat) -> CGFloat = {
        //            return $0 * (180.0 / CGFloat(M_PI))
        //        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}



