//
//  MySKTable.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 08/04/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit


class MySKTable: SKSpriteNode {

    
    enum MyEvents: Int {
        case GoBackEvent = 0, NoEvent
    }
    
    enum VarType: Int {
        case String = 0, Image
    }
    struct MultiVar {
        var varType: VarType
        var stringVar: String?
        var imageVar: UIImage?
        init(string:String) {
            stringVar = string
            varType = .String
        }
        init(image: UIImage) {
            imageVar = image
            varType = .Image
        }
    }
    var heightOfMyImageRow = CGFloat(0)
    var heightOfLabelRow = CGFloat(0)
    var fontSize = CGFloat(0)
    var myImageSize = CGFloat(0)
    var columns: Int
    var rows: Int
    var sizeOfElement: CGSize
    var touchesBeganAt: NSDate = NSDate()
    var touchesBeganAtNode: SKNode?
    var myParent: SKSpriteNode
    let separator = "/"
    var columnWidths: [CGFloat]
    var columnXPositions = [CGFloat]()
    var myHeight: CGFloat = 0
    var positionsTable: [[CGPoint]]
    var parentView: UIView?
    var showVerticalLines = false
    
    let goBackImageName = "GoBackImage"
    
    init(columnWidths: [CGFloat], rows: Int, headLines: String, parent: SKSpriteNode, width: CGFloat...) {
        
        self.columns = columnWidths.count
        self.rows = rows
        self.sizeOfElement = CGSizeMake(parent.size.width / CGFloat(self.columns), heightOfLabelRow)
        self.columnWidths = columnWidths
        self.myParent = parent
        positionsTable = Array(count: columnWidths.count, repeatedValue: Array(count: rows, repeatedValue: CGPointZero))
        
        super.init(texture: SKTexture(), color: UIColor.clearColor(), size: CGSizeZero)
        setMyDeviceConstants()
        setMyDeviceSpecialConstants()

        myHeight = heightOfLabelRow * CGFloat(rows) + heightOfMyImageRow
        
        var mySize = CGSizeZero
        if width.count > 0 {
            mySize = CGSizeMake(width[0], myHeight)
            self.showVerticalLines = true
        } else {
            mySize = CGSizeMake(parent.size.width * 0.9, myHeight)
        }
        self.size = mySize
        self.alpha = 1.0
        self.texture = SKTexture(image: drawTableImage(mySize, columnWidths: columnWidths, columns: self.columns, rows: rows))
        var columnMidX = -(mySize.width * 0.48)
        for column in 0..<columnWidths.count {
            columnXPositions.append(columnMidX)
            columnMidX += mySize.width * columnWidths[column] / 100
        }
        self.userInteractionEnabled = true
        //        fontSize = CGFloat(0)
        showMyImages(DrawImages.getGoBackImage(CGSizeMake(myImageSize, myImageSize)), position: 10, name: goBackImageName)
        
        //        parent!.addChild(self)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showLineOfTable(elements: [MultiVar], row: Int, selected: Bool) {
        for column in 0..<elements.count {
            switch elements[column].varType {
            case .String:
                showElementOfTable(elements[column].stringVar!, column: column, row: row, selected: selected)
            case .Image:
                showImageInTable(elements[column].imageVar!, column: column, row: row, selected: selected)
            }
        }
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
            label.fontName = "Times New Roman"
            label.fontColor = SKColor.blueColor()
        } else {
            label.fontName = "Times New Roman"
            label.fontColor = SKColor.blackColor()
        }
        label.text = element

        label.fontSize = fontSize
        if !labelExists {
            label.zPosition = self.zPosition + 10
            label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
            label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
            label.name = name
            let verticalPosition = (self.size.height - heightOfLabelRow) / 2 - heightOfMyImageRow
            let horizontalPosition = columnXPositions[column]
            label.position = CGPointMake(horizontalPosition,  verticalPosition - CGFloat(row) * heightOfLabelRow)
            if self.parentView != nil {
                let panelAbsPosition = CGPointMake(parentView!.frame.midX, parentView!.frame.midY)
                let myAbsPosition = CGPointMake(panelAbsPosition.x + position.x, panelAbsPosition.y + position.y)
                let labelAbsPosition = CGPointMake(myAbsPosition.x + label.position.x, myAbsPosition.y + label.position.y)
                positionsTable[0][row] = labelAbsPosition
            }
            self.addChild(label)
        }
    }
    
    func showMyImages(image: UIImage, position: CGFloat, name: String) {
        let shape = SKSpriteNode(texture: SKTexture(image: image))
 //       shape.texture = SKTexture(image: image)
        shape.name = name
        
        
        shape.position = CGPointMake(-(self.size.width * 0.4), (self.size.height - heightOfMyImageRow) / 2) //CGPointMake(self.size.width * position, (self.size.height - heigthOfMyImageRow) / 2)
        shape.alpha = 1.0
        shape.size = image.size
        shape.zPosition = self.zPosition + 1000
        self.addChild(shape)
        
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
        
        let verticalPosition = (self.size.height - heightOfLabelRow) / 2 - heightOfMyImageRow
//        label.position = CGPointMake(-size.width * 0.45 + CGFloat(column) * sizeOfElement.width,  verticalPosition - CGFloat(row) * sizeOfElement.height)
        shape.position = CGPointMake(xPos, verticalPosition - CGFloat(row) * heightOfLabelRow)
        shape.alpha = 1.0
        shape.size = image.size
        shape.zPosition = self.zPosition + 1000
        self.addChild(shape)
        
    }
    

    func reDrawWhenChanged(columnWidths: [CGFloat], rows: Int) {
        if rows == self.rows {
            return
        }
        for _ in 0..<children.count {
            self.children.last!.removeFromParent()
        }
        self.columns = columnWidths.count
        self.rows = rows
        self.sizeOfElement = CGSizeMake(size.width / CGFloat(columns), size.height / CGFloat(rows))
        myHeight = heightOfLabelRow * CGFloat(rows) + heightOfMyImageRow

        self.size = CGSizeMake(self.size.width, myHeight)
        self.texture = SKTexture(image: drawTableImage(size, columnWidths: columnWidths, columns: columns, rows: rows))
        let myPosition = CGPointMake(0, (myParent.size.height - size.height) / 2 - 10)
        self.position = myPosition
        positionsTable = Array(count: columnWidths.count, repeatedValue: Array(count: rows, repeatedValue: CGPointZero))
        self.removeFromParent()
        showMyImages(DrawImages.getGoBackImage(CGSizeMake(myImageSize, myImageSize)), position: 20, name: goBackImageName)
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

//        let heightOfTableRow = size.height -  / CGFloat(rows)
        
        
        let w = size.width / 100
        let h = size.height / 100
        
        //let mySize = CGSizeMake(size.width - 20, size.height)
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, myHeight), opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextBeginPath(ctx)
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextFillRect(ctx, CGRectMake(w * 0, h * 0, w * 100, myHeight))
        CGContextStrokePath(ctx)

        CGContextBeginPath(ctx)
        CGContextSetLineJoin(ctx, .Round)
        CGContextSetLineCap(ctx, .Round)
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        var points = [
            CGPointMake(w * 0, 0),
            CGPointMake(w * 100, 0),
            CGPointMake(w * 100, myHeight),
            CGPointMake(w * 0, myHeight),
            CGPointMake(w * 0, h * 0)
        ]
        CGContextAddLines(ctx, points, points.count)
        CGContextStrokePath(ctx)
        
        points.removeAll()
        points = [
            CGPointMake(w * 0, heightOfMyImageRow),
            CGPointMake(w * 100, heightOfMyImageRow)
        ]
        CGContextSetLineWidth(ctx, 0.1)
        CGContextSetStrokeColorWithColor(ctx, UIColor.darkGrayColor().CGColor)
        CGContextAddLines(ctx, points, points.count)
        CGContextStrokePath(ctx)
        
        
        
        CGContextBeginPath(ctx)
        
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        CGContextFillPath(ctx);
        CGContextStrokePath(ctx)
        
        CGContextSetLineWidth(ctx, 0.2)
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
//        CGContextStrokeRect(ctx, CGRectMake(5, 5, mySize.width, mySize.height))
        
        var yPos:CGFloat = (size.height - heightOfMyImageRow) / CGFloat(rows) + heightOfMyImageRow
        CGContextBeginPath(ctx)
        
        if rows > 1 {
            for _ in 0..<rows - 1 {
                let p1 = CGPointMake(5, yPos)
                let p2 = CGPointMake(size.width - 5, yPos)
                yPos += heightOfLabelRow
                CGContextMoveToPoint(ctx, p1.x, p1.y)
                CGContextAddLineToPoint(ctx, p2.x, p2.y)
            }
        }
        CGContextStrokePath(ctx)
        
        
        
        if showVerticalLines {
            CGContextBeginPath(ctx)
            var xProcent = CGFloat(0)
            for column in 0..<columnWidths.count {
                xProcent += columnWidths[column]
                let p1 = (CGPointMake(w * xProcent, heightOfMyImageRow))
                let p2 = (CGPointMake(w * xProcent, myHeight))
                CGContextMoveToPoint(ctx, p1.x, p1.y)
                CGContextAddLineToPoint(ctx, p2.x, p2.y)
            }
            CGContextStrokePath(ctx)
        }
        
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        
        return UIImage()
    }
    
    func checkTouches(touches: Set<UITouch>, withEvent event: UIEvent?)->MyEvents {
        let touchLocation = touches.first!.locationInNode(self)
        let touchesEndedAtNode = nodeAtPoint(touchLocation)
        if touchesEndedAtNode is SKSpriteNode && (touchesEndedAtNode as! SKSpriteNode).name == goBackImageName {
            return .GoBackEvent
        }
        return .NoEvent
        
        
    }
    func setMyDeviceSpecialConstants() {
        
    }
    
    func setMyDeviceConstants() {
        
        switch GV.deviceConstants.type {
        case .iPadPro12_9:
            heightOfMyImageRow = CGFloat(30)
            heightOfLabelRow = CGFloat(40)
            fontSize = CGFloat(30)
            myImageSize = CGFloat(30)
        case .iPad2:
            heightOfMyImageRow = CGFloat(30)
            heightOfLabelRow = CGFloat(40)
            fontSize = CGFloat(30)
            myImageSize = CGFloat(25)
        case .iPadMini:
            heightOfMyImageRow = CGFloat(30)
            heightOfLabelRow = CGFloat(40)
            fontSize = CGFloat(30)
            myImageSize = CGFloat(30)
        case .iPhone6Plus:
            heightOfMyImageRow = CGFloat(30)
            heightOfLabelRow = CGFloat(40)
            fontSize = CGFloat(25)
            myImageSize = CGFloat(23)
        case .iPhone6:
            heightOfMyImageRow = CGFloat(30)
            heightOfLabelRow = CGFloat(40)
            fontSize = CGFloat(25)
            myImageSize = CGFloat(20)
        case .iPhone5:
            heightOfMyImageRow = CGFloat(25)
            heightOfLabelRow = CGFloat(35)
            fontSize = CGFloat(28)
            myImageSize = CGFloat(15)
        case .iPhone4:
            heightOfMyImageRow = CGFloat(20)
            heightOfLabelRow = CGFloat(35)
            fontSize = CGFloat(20)
            myImageSize = CGFloat(15)
        default:
            break
        }
        
    }
    

   
}
