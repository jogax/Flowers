//
//  MySKTable.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 08/04/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit


class MySKTable: SKSpriteNode {

    var columns: Int
    var rows: Int
    var sizeOfElement: CGSize
    var touchesBeganAt: NSDate = NSDate()
    var touchesBeganAtNode: SKNode?
    let separator = "/"
    
    init(size: CGSize, columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        self.sizeOfElement = CGSizeMake(size.width / CGFloat(columns), size.height / CGFloat(rows))
        super.init(texture: SKTexture(), color: UIColor.clearColor(), size: size)
        self.size = size
        self.texture = SKTexture(image: getTableImage(size, columns: columns, rows: rows))
        self.userInteractionEnabled = true

//        parent!.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showElementOfTable(element: String, column: Int, row: Int, selected: Bool) {
        let fontSizeMultiplier = GV.deviceConstants.fontSizeMultiplier
        let label = SKLabelNode()
        label.text = element
        label.name = "\(column)\(separator)\(row)"
        
        label.position = CGPointMake(-size.width * 0.45 + CGFloat(column) * sizeOfElement.width, +size.height * 0.1 - CGFloat(row) * sizeOfElement.height  )
        label.fontName = "TimesNewRoman"
        label.fontColor = SKColor.blackColor()
        label.zPosition = self.zPosition + 10
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        label.fontSize = self.frame.width * fontSizeMultiplier * 0.7
        self.addChild(label)

    }
    
    func getColumnRowOfElement(name: String)->(column:Int, row:Int) {
        let components = name.componentsSeparatedByString(separator)
        let column = Int(components[0])
        let row = Int(components[1])
        return (column: column!, row: row!)
    }
    
    func getTableImage(size: CGSize, columns: Int, rows: Int) -> UIImage {
        let opaque = false
        let scale: CGFloat = 1

        let mySize = CGSizeMake(size.width - 20, size.height)
        let heightOfTableRow = size.height / CGFloat(rows)
        UIGraphicsBeginImageContextWithOptions(mySize, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        //        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        //        CGContextBeginPath(ctx)
        let roundRect = UIBezierPath(roundedRect: CGRectMake(0, 0, mySize.width, mySize.height * 1.2), byRoundingCorners:.AllCorners, cornerRadii: CGSizeMake(5, 5)).CGPath
        CGContextAddPath(ctx, roundRect);
        CGContextSetShadow(ctx, CGSizeMake(5,5), 5.0)
        CGContextSetFillColorWithColor(ctx, UIColor(red: 240/255, green: 255/255, blue: 240/255, alpha: 1.0 ).CGColor);
        CGContextFillPath(ctx);
        CGContextStrokePath(ctx)
        
        CGContextSetLineWidth(ctx, 0.2)
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
//        CGContextStrokeRect(ctx, CGRectMake(5, 5, mySize.width, mySize.height))
        
        var lineYPosition:CGFloat = mySize.height / CGFloat(rows)
        
        if rows > 1 {
            for _ in 0..<rows - 1 {
                CGContextBeginPath(ctx)
                let p1 = CGPointMake(5, lineYPosition)
                let p2 = CGPointMake(mySize.width - 5, lineYPosition)
                lineYPosition += heightOfTableRow
                CGContextMoveToPoint(ctx, p1.x, p1.y)
                CGContextAddLineToPoint(ctx, p2.x, p2.y)
                CGContextStrokePath(ctx)
            }
        }
        
        CGContextStrokePath(ctx)
        
        
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        
        return UIImage()
    }
    

}
