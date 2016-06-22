//
//  MySKTextField.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 11/06/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import RealmSwift

struct ActMinMaxValues {
    var actValue: Int
    var minValue: Int
    var maxValue: Int
    init(actValue: Int, minValue: Int, maxValue: Int) {
        self.actValue = actValue
        self.minValue = minValue
        self.maxValue = maxValue
    }
}

class MySKTextField: SKShapeNode, UITextFieldDelegate {
    var inputField = UITextField()
    var callBack: (Int, Int)->()
    var fromTextFieldShouldReturn = false
    var mySize: CGSize = CGSizeMake(300, 80)
    let fontSize: CGFloat = 20
    let fontName: String = "TimesNewRomanPSMT"
    var myParent: SKScene
    var oldText = ""
    let emptyName = "empty"
    
    var labels = [SKLabelNode]()
    var editedFieldName: String
    
    let gameNumberLabelIndex = 0
    let gameNumberValueLabelIndex = 1
    let levelLabelIndex = 2
    let levelValueLabelIndex = 3
    let doneLabelIndex = 4
    let cancelLabelIndex = 5
    var level: ActMinMaxValues
    var game: ActMinMaxValues
    
    init(parent: SKScene, position: CGPoint, callBack: (Int, Int)->(), actLevel: ActMinMaxValues, actGameNumber: ActMinMaxValues) {
        self.callBack = callBack
        self.myParent = parent
        self.editedFieldName = emptyName
        self.level = actLevel
        self.game = actGameNumber
        super.init()
        
//        mySize.width = parent.frame.width / 4
//        mySize.height = parent.frame.height / 4
        
        let shapeRect = CGRectMake(parent.frame.midX - mySize.width / 2, parent.frame.midY * 1.2 , mySize.width, mySize.height)
        self.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).CGPath
        
        self.fillColor = UIColor.whiteColor()
        self.strokeColor = UIColor.grayColor()
        self.zPosition = 100
        
        self.lineWidth = 1
        self.userInteractionEnabled = true
        parent.addChild(self)
        
        for _ in 0...5 {
            labels.append(SKLabelNode())
        }
        createLabels(gameNumberLabelIndex, text: GV.language.getText(.TCGameNumber))
        createLabels(gameNumberValueLabelIndex, text: "\(game.actValue)")
        createLabels(levelLabelIndex, text: GV.language.getText(.TCLevel,values: ":"))
        createLabels(levelValueLabelIndex, text: "\(level.actValue)")
        createButtons(doneLabelIndex, text: GV.language.getText(.TCDone))
        createButtons(cancelLabelIndex, text: GV.language.getText(.TCCancel))
        self.inputField.delegate = self
        openTextField(String(gameNumberValueLabelIndex), text: "\(game.actValue)")
    }
    
    func createLabels(labelIndex: Int, text: String) {
        
        
        labels[labelIndex].text = text
        var xPos = parent!.frame.midX - mySize.width / 2 + 10 //130
        for index in 0..<labelIndex {
            xPos += labels[index].frame.width + 10
        }
        let yPos = self.frame.midY + self.frame.height / 3
        labels[labelIndex].name = "\(labelIndex)"
        labels[labelIndex].fontName = fontName
        labels[labelIndex].position = CGPoint(x:xPos, y:yPos) //CGPointMake(100, 0)
        labels[labelIndex].fontSize = fontSize;
        labels[labelIndex].fontColor = labelIndex.isMemberOf(1, 3) ? SKColor.blueColor() : SKColor.blackColor()
        labels[labelIndex].horizontalAlignmentMode = .Left
        labels[labelIndex].verticalAlignmentMode = .Top
//        labels[labelIndex].userInteractionEnabled = true
//        label.color = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        labels[labelIndex].zPosition = 1000
        let label = labels[labelIndex]
        self.addChild(label)
    }
    
    func createButtons(labelIndex: Int, text: String) {
        var xPos: CGFloat = 0

        labels[labelIndex].text = text
        switch labelIndex {
        case 4:
            xPos =  self.frame.minX + labels[labelIndex].frame.width
        case 5:
            xPos =  self.frame.maxX - labels[labelIndex].frame.width
        default:
            break
        }
        let yPos = self.frame.midY - self.frame.height / 3
        labels[labelIndex].name = "\(labelIndex)"
        labels[labelIndex].fontName = fontName
        labels[labelIndex].position = CGPoint(x:xPos, y:yPos) //CGPointMake(100, 0)
        labels[labelIndex].fontSize = fontSize;
        labels[labelIndex].fontColor = SKColor.blueColor()
        labels[labelIndex].horizontalAlignmentMode = .Left
        labels[labelIndex].verticalAlignmentMode = .Bottom
        labels[labelIndex].zPosition = 1000
        let label = labels[labelIndex]
        self.addChild(label)
    }

    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let firstTouch = touches.first
        let touchLocation = firstTouch!.locationInNode(self)
        let nodes = nodesAtPoint(touchLocation)
        if nodes.count > 0 && nodes[0] is SKLabelNode {
            let node = nodes[0] as! SKLabelNode
            let labelIndex = Int(node.name!)
            if labelIndex!.isMemberOf(levelValueLabelIndex, gameNumberValueLabelIndex) {
                if editedFieldName != emptyName {editingEnded(inputField)}
                openTextField(node.name!, text: node.text!)
            }
            if labelIndex!.isMemberOf(doneLabelIndex, cancelLabelIndex) {
                editingEnded(inputField)
                self.removeFromParent()
                var gameNumber = self.game.actValue
                var levelIndex = self.level.actValue
                if labelIndex! == doneLabelIndex {
                    gameNumber = Int(labels[gameNumberValueLabelIndex].text!)!
                    levelIndex = Int(labels[levelValueLabelIndex].text!)!
                }
                callBack(gameNumber, levelIndex)
            }
        }
    }
    
    func openTextField(name: String, text: String) {
        editedFieldName = name
        oldText = ""
        var rect = labels[Int(name)!].frame
        labels[Int(name)!].hidden = true
        let adder = (parent!.frame.midY - rect.midY) * 2.0
        rect.origin.y += adder
        rect.size.width += 10
        inputField.addTarget(self, action: #selector(MySKTextField.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        inputField.hidden = false
        inputField.font = UIFont(name: fontName, size: 20)
        inputField.textColor = UIColor.blueColor()
        inputField.text = text
        inputField.backgroundColor = UIColor.clearColor()
        inputField.frame = rect
        inputField.autocorrectionType = .No
        inputField.layer.borderWidth = 0.0
        inputField.becomeFirstResponder()
        inputField.keyboardType = .PhonePad
        myParent.view!.addSubview(inputField)
    }
    

    func textFieldShouldReturn(textField: UITextField)->Bool {
        fromTextFieldShouldReturn = true
        self.editingEnded(textField)
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        self.editingEnded(textField)
    }

    func editingEnded(textField: UITextField) {
        let text = textField.text
        labels[Int(editedFieldName)!].text = text
        labels[Int(editedFieldName)!].hidden = false
        inputField.removeFromSuperview()
    }
    
    func textFieldDidChange(textField: UITextField) {
        var OK = true
        if textField.text == "" {
            oldText = ""
            return
        }
        switch Int(editedFieldName)! {
            case levelValueLabelIndex:
                if !Int(textField.text!)!.between(level.minValue, max: level.maxValue) {
                    OK = false
                }
            case gameNumberValueLabelIndex:
                if !Int(textField.text!)!.between(game.minValue, max: game.maxValue) {
                    OK = false
                }
            default:
                break
        }
        if OK {
            oldText = inputField.text!
        } else {
            inputField.text = oldText
        }

    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//          check if number only
        let numberOnly = NSCharacterSet.init(charactersInString: "0123456789")
        let stringFromTextField = NSCharacterSet.init(charactersInString: string)
        let strValid = numberOnly.isSupersetOfSet(stringFromTextField)
        return strValid
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
