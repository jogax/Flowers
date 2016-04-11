//
//  DrawImages.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 30.04.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class DrawImages {
    var pfeillinksImage = UIImage()
    var pfeilrechtsImage = UIImage()
    var settingsImage = UIImage()
    var backImage = UIImage()
    var undoImage = UIImage()
    var restartImage = UIImage()
    var exchangeImage = UIImage()
    var uhrImage = UIImage()
    var cardPackage = UIImage()
    var tippImage = UIImage()
    
    //let imageColor = GV.khakiColor.CGColor
    let opaque = false
    let scale: CGFloat = 1
    
    init() {
        self.pfeillinksImage = drawPfeillinks(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.pfeilrechtsImage = pfeillinksImage.imageRotatedByDegrees(180.0, flip: false)
        self.settingsImage = drawSettings(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.undoImage = drawUndo(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.restartImage = drawRestart(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.exchangeImage = drawExchange(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.backImage = drawBack(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.cardPackage = drawCardPackage(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.tippImage = drawTipps(CGRect(x: 0, y: 0, width: 100, height: 100))
        
    }
    
    func drawPfeillinks(frame: CGRect) -> UIImage {
        let multiplier = frame.width / frame.height
        let size = CGSize(width: frame.width * multiplier, height: frame.height)
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        /*
        CGContextSetLineWidth(ctx, 0.5)
        let center1 = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let radius1 = frame.width / 2 - 5
        CGContextAddArc(ctx, center1.x, center1.y, radius1, CGFloat(0), CGFloat(2 * M_PI), 1)
        CGContextSetFillColorWithColor(ctx, imageColor)
        //CGContextSetStrokeColorWithColor(ctx,GV.springGreenColor.CGColor)
        CGContextDrawPath(ctx, kCGPathFillStroke)
        CGContextStrokePath(ctx)
        */
        CGContextSetLineWidth(ctx, 4.0)
        CGContextBeginPath(ctx)
        
        let adder:CGFloat = 10.0
        let p1 = CGPoint(x: frame.origin.x + 1.2 * adder, y: frame.height / 2)
        let p2 = CGPoint(x: frame.origin.x + adder + frame.width / 4,   y: frame.origin.y + frame.height / 4)
        let p3 = CGPoint(x: frame.origin.x + adder + frame.width / 4,   y: frame.origin.y + frame.height / 2.5)
        let p4 = CGPoint(x: frame.origin.x - adder + frame.width - adder,       y: frame.origin.y + frame.height / 2.5)
        let p5 = CGPoint(x: frame.origin.x - adder + frame.width - adder,       y: frame.height   - frame.height / 2.5)
        let p6 = CGPoint(x: frame.origin.x + adder + frame.width / 4,   y: frame.height   - frame.height / 2.5)
        let p7 = CGPoint(x: frame.origin.x + adder + frame.width / 4,   y: frame.height   - frame.height / 4)
        CGContextMoveToPoint(ctx, p1.x, p1.y)
        CGContextAddLineToPoint(ctx, p2.x, p2.y)
        CGContextAddLineToPoint(ctx, p3.x, p3.y)
        CGContextAddLineToPoint(ctx, p4.x, p4.y)
        CGContextAddLineToPoint(ctx, p5.x, p5.y)
        CGContextAddLineToPoint(ctx, p6.x, p6.y)
        CGContextAddLineToPoint(ctx, p7.x, p7.y)
        CGContextAddLineToPoint(ctx, p1.x, p1.y)
        //CGContextSetAlpha(ctx, 0)
        CGContextSetRGBFillColor(ctx, 0.5, 0.5, 0, 1)
        CGContextStrokePath(ctx)
        /*
        let center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let radius = frame.width / 2 - 5
        CGContextAddArc(ctx, center.x, center.y, radius, CGFloat(0), CGFloat(2 * M_PI), 1)
        CGContextStrokePath(ctx)
        */
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }

    func drawCardPackage(frame: CGRect) -> UIImage {
        let multiplier = frame.width / frame.height
        let size = CGSize(width: frame.width * multiplier, height: frame.height)
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(ctx, UIColor.blueColor().CGColor)

        CGContextSetLineWidth(ctx, 0.2)
        
        CGContextStrokeRect(ctx, frame)
        

        CGContextSetLineWidth(ctx, 0.5)
        CGContextBeginPath(ctx)

        for index in 1...10 {
            let p1 = CGPoint(x: frame.origin.x, y: frame.height - frame.height / 10 * CGFloat(index))
            let p2 = CGPoint(x: frame.origin.x + frame.width / 10 * CGFloat(index), y: frame.height)
            let p3 = CGPoint(x: frame.width, y: frame.origin.y + frame.height / 10 * CGFloat(index))
            let p4 = CGPoint(x: frame.width - frame.width / 10 * CGFloat(index), y: frame.origin.y)
            let p5 = CGPoint(x: frame.width, y: frame.height - frame.height / 10 * CGFloat(index))
            let p6 = CGPoint(x: frame.width - frame.width / 10 * CGFloat(index), y: frame.height)
            
            let p7 = CGPoint(x: frame.origin.x, y: frame.height - frame.height / 10 * CGFloat(index))
            let p8 = CGPoint(x: frame.width - frame.width / 10 * CGFloat(index), y: frame.origin.y)
            CGContextMoveToPoint(ctx, p1.x, p1.y)
            CGContextAddLineToPoint(ctx, p2.x, p2.y)
            CGContextMoveToPoint(ctx, p3.x, p3.y)
            CGContextAddLineToPoint(ctx, p4.x, p4.y)
            CGContextMoveToPoint(ctx, p5.x, p5.y)
            CGContextAddLineToPoint(ctx, p6.x, p6.y)
            CGContextMoveToPoint(ctx, p7.x, p7.y)
            CGContextAddLineToPoint(ctx, p8.x, p8.y)
            CGContextStrokePath(ctx)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }

    func drawBack(frame: CGRect) -> UIImage {
        let size = CGSize(width: frame.width, height: frame.height)
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        CGContextSetLineWidth(ctx, 16.0)
        CGContextBeginPath(ctx)
        
        let adder:CGFloat = frame.width / 8
        
        let p1 = CGPoint(x: frame.origin.x + adder,                 y: frame.origin.y + adder)
        let p2 = CGPoint(x: frame.origin.x + adder,                 y: frame.origin.y + frame.height - adder)
        let p3 = CGPoint(x: frame.origin.x + frame.height - adder,  y: frame.origin.y + frame.height - adder)
        let p4 = CGPoint(x: frame.origin.x + frame.height - adder,  y: frame.origin.y + adder)
        CGContextMoveToPoint(ctx, p1.x, p1.y)
        CGContextAddLineToPoint(ctx, p3.x, p3.y)
        CGContextStrokePath(ctx)
        
        CGContextMoveToPoint(ctx, p2.x, p2.y)
        CGContextAddLineToPoint(ctx, p4.x, p4.y)
        CGContextStrokePath(ctx)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
    
    func drawExchange(frame: CGRect) -> UIImage {
        let size = CGSize(width: frame.width, height: frame.height)
        //let endAngle = CGFloat(2*M_PI)
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        CGContextBeginPath(ctx)
        CGContextSetLineWidth(ctx, 4.0)
        
        let adder:CGFloat = frame.width / 20
        let r0 = frame.width * 0.4
        
        let center1 = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + adder + r0 * 1.5)
        let center2 = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height - adder - r0 * 1.5)
        
        
//        let oneGrad:CGFloat = CGFloat(M_PI) / 180
        let minAngle1 = 330 * GV.oneGrad
        let maxAngle1 = 210 * GV.oneGrad
        //println("1 Grad: \(oneGrad)")
        
        let minAngle2 = 150 * GV.oneGrad
        let maxAngle2 = 30 * GV.oneGrad
        
        CGContextAddArc(ctx, center1.x, center1.y, r0, minAngle1, maxAngle1, 1)
        CGContextStrokePath(ctx)
        
        CGContextAddArc(ctx, center2.x, center2.y, r0, minAngle2, maxAngle2, 1)
        CGContextStrokePath(ctx)
        
        let p1 = pointOfCircle(r0, center: center1, angle: minAngle1)
        let p2 = CGPoint(x: p1.x - 20, y: p1.y - 30)
        let p3 = CGPoint(x: p1.x - 30, y: p1.y - 10)
        let p4 = pointOfCircle(r0, center: center2, angle: minAngle2)
        let p5 = CGPoint(x: p4.x + 20, y: p4.y + 30)
        let p6 = CGPoint(x: p4.x + 30, y: p4.y + 15)
        
        CGContextMoveToPoint(ctx, p1.x, p1.y)
        CGContextAddLineToPoint(ctx, p2.x, p2.y)
        CGContextStrokePath(ctx)
        CGContextMoveToPoint(ctx, p1.x, p1.y)
        CGContextAddLineToPoint(ctx, p3.x, p3.y)
        CGContextStrokePath(ctx)
        CGContextMoveToPoint(ctx, p4.x, p4.y)
        CGContextAddLineToPoint(ctx, p5.x, p5.y)
        CGContextStrokePath(ctx)
        CGContextMoveToPoint(ctx, p4.x, p4.y)
        CGContextAddLineToPoint(ctx, p6.x, p6.y)
        CGContextStrokePath(ctx)
        
        
        
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
    
    func drawUndo(frame: CGRect) -> UIImage {
        let size = CGSize(width: frame.width, height: frame.height)
        //let endAngle = CGFloat(2*M_PI)
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        CGContextBeginPath(ctx)
        CGContextSetLineWidth(ctx, 4.0)
        
        let adder:CGFloat = frame.width / 20
        let r0 = frame.width * 0.4
        
        let center1 = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + adder + r0 * 1.5)
//        let center2 = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height - adder - r0 * 1.5)
        
        
//        let oneGrad:CGFloat = CGFloat(M_PI) / 180
        let minAngle1 = 340 * GV.oneGrad
        let maxAngle1 = 200 * GV.oneGrad
        //println("1 Grad: \(oneGrad)")
        
//        let minAngle2 = 150 * oneGrad
//        let maxAngle2 = 30 * oneGrad
        
        CGContextAddArc(ctx, center1.x, center1.y, r0, minAngle1, maxAngle1, 1)
        CGContextStrokePath(ctx)
        
//        CGContextAddArc(ctx, center2.x, center2.y, r0, minAngle2, maxAngle2, 1)
//        CGContextStrokePath(ctx)
        
        let p1 = pointOfCircle(r0, center: center1, angle: maxAngle1)
        let p2 = CGPoint(x: p1.x + 10, y: p1.y - 30)
//        let p3 = CGPoint(x: p1.x + 30, y: p1.y + 10)
//        let p2 = CGPoint(x: p1.x - 20, y: p1.y - 30)
        let p3 = CGPoint(x: p1.x + 30, y: p1.y - 10)
//        let p4 = pointOfCircle(r0, center: center2, angle: minAngle2)
//        let p5 = CGPoint(x: p4.x + 20, y: p4.y + 30)
//        let p6 = CGPoint(x: p4.x + 30, y: p4.y + 15)
        
        CGContextMoveToPoint(ctx, p1.x, p1.y)
        CGContextAddLineToPoint(ctx, p2.x, p2.y)
        CGContextStrokePath(ctx)
        CGContextMoveToPoint(ctx, p1.x, p1.y)
        CGContextAddLineToPoint(ctx, p3.x, p3.y)
        CGContextStrokePath(ctx)
//        CGContextMoveToPoint(ctx, p4.x, p4.y)
//        CGContextAddLineToPoint(ctx, p5.x, p5.y)
//        CGContextStrokePath(ctx)
//        CGContextMoveToPoint(ctx, p4.x, p4.y)
//        CGContextAddLineToPoint(ctx, p6.x, p6.y)
//        CGContextStrokePath(ctx)
        
        
        
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
    
    func drawRestart(frame: CGRect) -> UIImage {
        let size = CGSize(width: frame.width, height: frame.height)
        //let endAngle = CGFloat(2*M_PI)
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        CGContextBeginPath(ctx)
        CGContextSetLineWidth(ctx, 4.0)
        
        let adder:CGFloat = frame.width / 20
        let r0 = frame.width * 0.4
        
        let center1 = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + adder + r0 * 1.0)
        //        let center2 = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height - adder - r0 * 1.5)
        
        
        let minAngle1 = 430 * GV.oneGrad
        let maxAngle1 = 90 * GV.oneGrad
        //println("1 Grad: \(oneGrad)")
        
        //        let minAngle2 = 150 * oneGrad
        //        let maxAngle2 = 30 * oneGrad
        
        CGContextAddArc(ctx, center1.x, center1.y, r0, minAngle1, maxAngle1, 1)
        CGContextStrokePath(ctx)
        
        //        CGContextAddArc(ctx, center2.x, center2.y, r0, minAngle2, maxAngle2, 1)
        //        CGContextStrokePath(ctx)
        
        let p1 = pointOfCircle(r0, center: center1, angle: maxAngle1)
        let p2 = CGPoint(x: p1.x - 20, y: p1.y - 20)
        //        let p3 = CGPoint(x: p1.x + 30, y: p1.y + 10)
        //        let p2 = CGPoint(x: p1.x - 20, y: p1.y - 30)
        let p3 = CGPoint(x: p1.x - 30, y: p1.y + 10)
        //        let p4 = pointOfCircle(r0, center: center2, angle: minAngle2)
        //        let p5 = CGPoint(x: p4.x + 20, y: p4.y + 30)
        //        let p6 = CGPoint(x: p4.x + 30, y: p4.y + 15)
        
        CGContextMoveToPoint(ctx, p1.x, p1.y)
        CGContextAddLineToPoint(ctx, p2.x, p2.y)
        CGContextStrokePath(ctx)
        CGContextMoveToPoint(ctx, p1.x, p1.y)
        CGContextAddLineToPoint(ctx, p3.x, p3.y)
        CGContextStrokePath(ctx)
        //        CGContextMoveToPoint(ctx, p4.x, p4.y)
        //        CGContextAddLineToPoint(ctx, p5.x, p5.y)
        //        CGContextStrokePath(ctx)
        //        CGContextMoveToPoint(ctx, p4.x, p4.y)
        //        CGContextAddLineToPoint(ctx, p6.x, p6.y)
        //        CGContextStrokePath(ctx)
        
        
        
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
    
    func drawTipps(frame: CGRect) -> UIImage {
        let size = CGSize(width: frame.width, height: frame.height)
        //let endAngle = CGFloat(2*M_PI)
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        CGContextBeginPath(ctx)
        CGContextSetLineWidth(ctx, 4.0)
        
        let adder:CGFloat = frame.width * 0.05
        let r0 = frame.width * 0.25
        
        let center1 = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + adder + r0 * 1.8)
        //        let center2 = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height - adder - r0 * 1.5)
        
        
        let minAngle1 = 410 * GV.oneGrad
        let maxAngle1 = 130 * GV.oneGrad
        let blitzAngle1 = 200 * GV.oneGrad
        let blitzAngle2 = 230 * GV.oneGrad
        let blitzAngle3 = 270 * GV.oneGrad
        let blitzAngle4 = 310 * GV.oneGrad
        let blitzAngle5 = 340 * GV.oneGrad
        //println("1 Grad: \(oneGrad)")
        
        //        let minAngle2 = 150 * oneGrad
        //        let maxAngle2 = 30 * oneGrad
        
        CGContextAddArc(ctx, center1.x, center1.y, r0, minAngle1, maxAngle1, 1)
        CGContextStrokePath(ctx)
        
        //        CGContextAddArc(ctx, center2.x, center2.y, r0, minAngle2, maxAngle2, 1)
        //        CGContextStrokePath(ctx)
        
        let endPoint = pointOfCircle(r0, center: center1, angle: minAngle1)
        let p1 = pointOfCircle(r0, center: center1, angle: maxAngle1)
        let p2 = CGPoint(x: p1.x, y: p1.y + 4 * adder)
        let p3 = CGPoint(x: endPoint.x, y: p2.y)
        let p4 = CGPoint(x: p3.x, y: endPoint.y)
        let p5 = CGPoint(x: p1.x, y: p1.y + 1.3 * adder)
        let p6 = CGPoint(x: p3.x, y: p5.y)
        let p7 = CGPoint(x: p1.x, y: p1.y + 2.6 * adder)
        let p8 = CGPoint(x: p3.x, y: p7.y)
        
        let blitzStartAdder = adder * 1
        let blitzEndAdder = adder * 4
        
        let blitzStartPoint1 = pointOfCircle(r0 + blitzStartAdder, center: center1, angle: blitzAngle1)
        let blitzEndPoint1 = pointOfCircle(r0 + blitzEndAdder, center: center1, angle: blitzAngle1)
        let blitzStartPoint2 = pointOfCircle(r0 + blitzStartAdder, center: center1, angle: blitzAngle2)
        let blitzEndPoint2 = pointOfCircle(r0 + blitzEndAdder, center: center1, angle: blitzAngle2)
        let blitzStartPoint3 = pointOfCircle(r0 + blitzStartAdder, center: center1, angle: blitzAngle3)
        let blitzEndPoint3 = pointOfCircle(r0 + blitzEndAdder, center: center1, angle: blitzAngle3)
        let blitzStartPoint4 = pointOfCircle(r0 + blitzStartAdder, center: center1, angle: blitzAngle4)
        let blitzEndPoint4 = pointOfCircle(r0 + blitzEndAdder, center: center1, angle: blitzAngle4)
        let blitzStartPoint5 = pointOfCircle(r0 + blitzStartAdder, center: center1, angle: blitzAngle5)
        let blitzEndPoint5 = pointOfCircle(r0 + blitzEndAdder, center: center1, angle: blitzAngle5)

        
        
        CGContextMoveToPoint(ctx, p1.x, p1.y)
        CGContextAddLineToPoint(ctx, p2.x, p2.y)
        CGContextAddLineToPoint(ctx, p3.x, p3.y)
        CGContextAddLineToPoint(ctx, p4.x, p4.y)
        CGContextStrokePath(ctx)

        CGContextSetLineWidth(ctx, 2.0)
        CGContextMoveToPoint(ctx, p5.x, p5.y)
        CGContextAddLineToPoint(ctx, p6.x, p6.y)
        CGContextStrokePath(ctx)
        
        CGContextMoveToPoint(ctx, p7.x, p7.y)
        CGContextAddLineToPoint(ctx, p8.x, p8.y)
        CGContextStrokePath(ctx)
        
        CGContextMoveToPoint(ctx, blitzStartPoint1.x, blitzStartPoint1.y)
        CGContextAddLineToPoint(ctx, blitzEndPoint1.x, blitzEndPoint1.y)
        CGContextStrokePath(ctx)

        CGContextMoveToPoint(ctx, blitzStartPoint2.x, blitzStartPoint2.y)
        CGContextAddLineToPoint(ctx, blitzEndPoint2.x, blitzEndPoint2.y)
        CGContextStrokePath(ctx)
        
        CGContextMoveToPoint(ctx, blitzStartPoint3.x, blitzStartPoint3.y)
        CGContextAddLineToPoint(ctx, blitzEndPoint3.x, blitzEndPoint3.y)
        CGContextStrokePath(ctx)
        
        CGContextMoveToPoint(ctx, blitzStartPoint4.x, blitzStartPoint4.y)
        CGContextAddLineToPoint(ctx, blitzEndPoint4.x, blitzEndPoint4.y)
        CGContextStrokePath(ctx)
        
        CGContextMoveToPoint(ctx, blitzStartPoint5.x, blitzStartPoint5.y)
        CGContextAddLineToPoint(ctx, blitzEndPoint5.x, blitzEndPoint5.y)
        CGContextStrokePath(ctx)
        
        CGContextAddArc(ctx, center1.x, center1.y, r0, maxAngle1, minAngle1, 1)
        CGContextStrokePath(ctx)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
    
    func drawSettings(frame: CGRect) -> UIImage {
        let size = CGSize(width: frame.width, height: frame.height)
        let endAngle = CGFloat(2*M_PI)
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextBeginPath(ctx)
        
        /*
        CGContextSetLineWidth(ctx, 0.5)
        let center1 = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let radius1 = frame.width / 2 - 5
        CGContextAddArc(ctx, center1.x, center1.y, radius1, CGFloat(0), CGFloat(2 * M_PI), 1)
        CGContextSetFillColorWithColor(ctx, imageColor)
        CGContextDrawPath(ctx, kCGPathFillStroke)
        CGContextStrokePath(ctx)
        */
        CGContextSetLineWidth(ctx, 4.0)
        
        let adder:CGFloat = 10.0
        let center = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height / 2)
        let r0 = frame.width / 2.2 - adder
        let r1 = frame.width / 3.0 - adder
        let r2 = frame.width / 4.0 - adder
        let count: CGFloat = 8
        let countx2 = count * 2
        let firstAngle = (endAngle / countx2) / 2
        
        CGContextSetFillColorWithColor(ctx,
            UIColor.blackColor().CGColor)
        
        //CGContextSetRGBFillColor(ctx, UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1).CGColor);
        for ind in 0..<Int(count) {
            let minAngle1 = firstAngle + CGFloat(ind) * endAngle / count
            let maxAngle1 = minAngle1 + endAngle / countx2
            let minAngle2 = maxAngle1
            let maxAngle2 = minAngle2 + endAngle / countx2
            
            
            let startP = pointOfCircle(r1, center: center, angle: maxAngle1)
            let midP1 = pointOfCircle(r0, center: center, angle: maxAngle1)
            let midP2 = pointOfCircle(r0, center: center, angle: maxAngle2)
            let endP = pointOfCircle(r1, center: center, angle: maxAngle2)
            CGContextAddArc(ctx, center.x, center.y, r0, max(minAngle1, maxAngle1) , min(minAngle1, maxAngle1), 1)
            CGContextStrokePath(ctx)
            CGContextMoveToPoint(ctx, startP.x, startP.y)
            CGContextAddLineToPoint(ctx, midP1.x, midP1.y)
            CGContextStrokePath(ctx)
            CGContextAddArc(ctx, center.x, center.y, r1, max(minAngle2, maxAngle2), min(minAngle2, maxAngle2), 1)
            CGContextStrokePath(ctx)
            CGContextMoveToPoint(ctx, midP2.x, midP2.y)
            CGContextAddLineToPoint(ctx, endP.x, endP.y)
            CGContextStrokePath(ctx)
        }
        CGContextFillPath(ctx)
        
        CGContextAddArc(ctx, center.x, center.y, r2, 0, endAngle, 1)
        CGContextStrokePath(ctx)
        
        /*
        let center2 = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let radius = frame.width / 2 - 5
        CGContextAddArc(ctx, center2.x, center2.y, radius, CGFloat(0), CGFloat(2 * M_PI), 1)
        CGContextStrokePath(ctx)
        */
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
    func getPfeillinks () -> UIImage {
        return pfeillinksImage
    }
    
    func getPfeilrechts () -> UIImage {
        return pfeilrechtsImage
    }
    
    func getSettings () -> UIImage {
        return settingsImage
    }
    
    func getUndo () -> UIImage {
        return undoImage
    }
    
    func getRestart () -> UIImage {
        return restartImage
    }
    
    func getExchange () -> UIImage {
        return exchangeImage
    }
    
    func getBack () -> UIImage {
        return backImage
    }

    func getCardPackage () -> UIImage {
        return cardPackage
    }

    func getTipp () -> UIImage {
        return tippImage
    }
    
    func pointOfCircle(radius: CGFloat, center: CGPoint, angle: CGFloat) -> CGPoint {
        let pointOfCircle = CGPoint (x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
        return pointOfCircle
    }
    
    func getPanelImage (size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
//        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
//        CGContextBeginPath(ctx)
        let roundRect = UIBezierPath(roundedRect: CGRectMake(0, 0, size.width, size.height), byRoundingCorners:.AllCorners, cornerRadii: CGSizeMake(size.width / 20, size.height / 20)).CGPath
        CGContextAddPath(ctx, roundRect)
        
        CGContextSetShadow(ctx, CGSizeMake(10,10), 1.0)
//        CGContextStrokePath(ctx)

        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor);
        CGContextFillPath(ctx)

        
        CGContextClosePath(ctx)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        return image
    }
    
    func getDeleteImage (size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        let w = size.width
        let h = size.height
        CGContextSetLineWidth(ctx, w * 0.04)
       
        CGContextSetStrokeColorWithColor(ctx, UIColor.redColor().CGColor)
        CGContextSetLineJoin (ctx, .Round)
        CGContextSetLineCap (ctx, .Round)
        
        let points1 = [
            CGPointMake(w * 0.20,h * 0.20),
            CGPointMake(w * 0.30, h * 0.90),
            CGPointMake(w * 0.70, h * 0.90),
            CGPointMake(w * 0.80, h * 0.20)
        ]
        CGContextAddLines(ctx, points1, points1.count)
        
        CGContextMoveToPoint(ctx, w * 0.32, h * 0.25)
        CGContextAddLineToPoint(ctx, w * 0.38, h * 0.80)
        
        CGContextMoveToPoint(ctx, w * 0.50, h * 0.25)
        CGContextAddLineToPoint(ctx, w * 0.50, h * 0.80)
        
        CGContextMoveToPoint(ctx, w * 0.68, h * 0.25)
        CGContextAddLineToPoint(ctx, w * 0.62, h * 0.80)

        
        
        CGContextMoveToPoint(ctx, w * 0.16, h * 0.18)
        CGContextAddLineToPoint(ctx, w * 0.84, h * 0.18)
        
        
        CGContextMoveToPoint(ctx, w * 0.18, h * 0.15)
        CGContextAddLineToPoint(ctx, w * 0.82, h * 0.15)
        
        CGContextSetLineCap (ctx, .Round)
        CGContextStrokePath(ctx)
        
        CGContextBeginPath(ctx)
        
        let r0 = w * 0.10
        
        let center1 = CGPointMake(w * 0.50, h * 0.14)
        
        
        //        let oneGrad:CGFloat = CGFloat(M_PI) / 180
        let minAngle1 = 180 * GV.oneGrad
        let maxAngle1 = 0 * GV.oneGrad
        //println("1 Grad: \(oneGrad)")
        
        
        CGContextAddArc(ctx, center1.x, center1.y, r0, minAngle1, maxAngle1, 0)
 
        CGContextStrokePath(ctx)
        
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        return UIImage()
    }

    
    func getModifyImage (size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        let w = size.width
        let h = size.height
        CGContextSetLineWidth(ctx, w * 0.08)
        //        let roundRect = UIBezierPath(roundedRect: CGRectMake(0, 0, size.width * 0.6, size.height * 0.8), byRoundingCorners:.AllCorners, cornerRadii: CGSizeMake(size.width * rounding, size.height * rounding)).CGPath
        //
        //        CGContextAddPath(ctx, roundRect)
        
        //        CGContextSetShadow(ctx, CGSizeMake(10,10), 1.0)
        //        CGContextStrokePath(ctx)
        
        
        CGContextSetStrokeColorWithColor(ctx, UIColor.grayColor().CGColor)
        CGContextSetLineJoin (ctx, .Round)
        CGContextSetLineCap (ctx, .Round)
        
        let roundRect = UIBezierPath(roundedRect: CGRectMake(w * 0.1, h * 0.4, w * 0.8, h * 0.5), byRoundingCorners:.AllCorners, cornerRadii: CGSizeMake(w * 0.08, h * 0.08)).CGPath
        CGContextAddPath(ctx, roundRect)
        CGContextStrokePath(ctx)

        CGContextBeginPath(ctx)
        CGContextSetLineWidth(ctx, w * 0.1)
        CGContextSetStrokeColorWithColor(ctx, UIColor.brownColor().CGColor)
        CGContextSetLineJoin (ctx, .Round)
        CGContextSetLineCap (ctx, .Round)
        
        
//        CGContextSetShadow(ctx, CGSizeMake(w * 0.04, h * 0.04), 0.5)
//        CGContextSetFillColorWithColor(ctx, UIColor(red: 240/255, green: 255/255, blue: 240/255, alpha: 1.0 ).CGColor);

//        let frame = CGRectMake(w * 0.1, h * 0.1, w * 0.8, h * 0.8)
//        
//        CGContextStrokeRect(ctx, frame)

        let points = [
            CGPointMake(w * 0.60, h * 0.60),
            CGPointMake(w * 0.80, h * 0.20)
        ]
        CGContextAddLines(ctx, points, points.count)
        CGContextStrokePath(ctx)

        CGContextBeginPath(ctx)
        CGContextSetLineWidth(ctx, w * 0.03)
        CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextSetLineJoin (ctx, .Round)
        CGContextSetLineCap (ctx, .Round)
        let points1 = [
            CGPointMake(w * 0.63, h * 0.50),
            CGPointMake(w * 0.73, h * 0.30)
        ]
        CGContextAddLines(ctx, points1, points1.count)

        CGContextStrokePath(ctx)
        
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        return UIImage()
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

