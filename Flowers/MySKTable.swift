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
    var myParent: SKSpriteNode
    let separator = "/"
    var columnWidths: [CGFloat]
    var fontSize:CGFloat = 0
    
    init(size: CGSize, columnWidths: [CGFloat], columns: Int, rows: Int, parent: SKSpriteNode) {
        self.columns = columnWidths.count
        self.rows = rows
        self.sizeOfElement = CGSizeMake(size.width / CGFloat(columns), size.height / CGFloat(rows))
        self.columnWidths = columnWidths
        self.myParent = parent
        super.init(texture: SKTexture(), color: UIColor.clearColor(), size: size)
        self.size = size
        self.alpha = 1.0
        self.texture = SKTexture(image: drawTableImage(size, columnWidths: columnWidths, columns: columns, rows: rows))
        self.userInteractionEnabled = true
        fontSize = size.width * GV.deviceConstants.fontSizeMultiplier * 0.7

//        parent!.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showElementOfTable(element: String, column: Int, row: Int, selected: Bool) {
        let name = "\(column)\(separator)\(row)"
        var label = SKLabelNode()
        var labelExists = false
        
        for index in 0..<self.children.count {
            if self.children[index].name == name {
                label = self.children[index] as! SKLabelNode
                labelExists = true
                break
            }
        }
        
        if selected {
            label.fontName = "ArialMT"
            label.fontColor = SKColor.blueColor()
        } else {
            label.fontName = "Arial"
            label.fontColor = SKColor.blackColor()
        }
        label.text = element

        label.fontSize = fontSize
        if !labelExists {
            label.zPosition = self.zPosition + 10
            label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
            label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
            label.name = name
            
            label.position = CGPointMake(-size.width * 0.45 + CGFloat(column) * sizeOfElement.width, (self.size.height - sizeOfElement.height) / 2 - CGFloat(row) * sizeOfElement.height)
            self.addChild(label)
        }
    }
    
    func showImageInTable(image: UIImage, column: Int, row: Int, selected: Bool) {
        let name = "\(column)\(separator)\(row)"
        
        for index in 0..<self.children.count {
            if self.children[index].name == name {
                self.children[index].removeFromParent()
                break
            }
        }
        if !selected {
            return
        }
        let shape = SKSpriteNode()
        shape.texture = SKTexture(image: image)
        shape.name = name
        
        var xPos: CGFloat = 0
        for index in 0..<column {
            xPos += size.width * columnWidths[index] / 100
        }
        xPos += (size.width * columnWidths[column] / 100) / 2
        xPos -= self.size.width / 2
        
        shape.position = CGPointMake(xPos, (self.size.height - sizeOfElement.height) / 2 - CGFloat(row) * sizeOfElement.height  )
        shape.alpha = 1.0
        shape.size = image.size
        shape.zPosition = self.zPosition + 1000
        self.addChild(shape)
        
    }
    

    func reDraw(size: CGSize, columnWidths: [CGFloat], rows: Int) {
        for _ in 0..<children.count {
            self.children.last!.removeFromParent()
        }
        self.columns = columnWidths.count
        self.rows = rows
        self.sizeOfElement = CGSizeMake(size.width / CGFloat(columns), size.height / CGFloat(rows))
        self.size = size
        self.texture = SKTexture(image: drawTableImage(size, columnWidths: columnWidths, columns: columns, rows: rows))
        let myPosition = CGPointMake(0, (myParent.size.height - size.height) / 2 - 10)
        self.position = myPosition
        self.removeFromParent()
        myParent.addChild(self)
        
    }
    
    func getColumnRowOfElement(name: String)->(column:Int, row:Int) {
        let components = name.componentsSeparatedByString(separator)
        let column = Int(components[0])
        let row = Int(components[1])
        return (column: column!, row: row!)
    }
    
    func drawTableImage(size: CGSize, columnWidths:[CGFloat], columns: Int, rows: Int) -> UIImage {
        let opaque = false
        let scale: CGFloat = 1

        let w = size.width / 100
        let h = size.height / 100
        
        //let mySize = CGSizeMake(size.width - 20, size.height)
        let heightOfTableRow = size.height / CGFloat(rows)
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextBeginPath(ctx)
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextFillRect(ctx, CGRectMake(w * 0, h * 0, w * 100, h * 100))
        CGContextStrokePath(ctx)

        CGContextBeginPath(ctx)
        CGContextSetLineJoin(ctx, .Round)
        CGContextSetLineCap(ctx, .Round)
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        let points = [
            CGPointMake(w * 0, h * 0),
            CGPointMake(w * 100, h * 0),
            CGPointMake(w * 100, h * 100),
            CGPointMake(w * 0, h * 100),
            CGPointMake(w * 0, h * 0)
        ]
        CGContextAddLines(ctx, points, points.count)
        CGContextStrokePath(ctx)
        
        CGContextBeginPath(ctx)
        
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        CGContextFillPath(ctx);
        CGContextStrokePath(ctx)
        
        CGContextSetLineWidth(ctx, 0.2)
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
//        CGContextStrokeRect(ctx, CGRectMake(5, 5, mySize.width, mySize.height))
        
        var yPos:CGFloat = size.height / CGFloat(rows)
        
        if rows > 1 {
            for _ in 0..<rows - 1 {
                CGContextBeginPath(ctx)
                let p1 = CGPointMake(5, yPos)
                let p2 = CGPointMake(size.width - 5, yPos)
                yPos += heightOfTableRow
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
