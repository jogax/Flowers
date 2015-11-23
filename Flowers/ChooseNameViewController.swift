//
//  ChooseNameController.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 11. 10..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import UIKit

class ChooseNameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate  {
    var tableView = UITableView()
    var cell: UITableViewCell = UITableViewCell()
    var textCell: [String] = []
    let textCellIdentifier = "nameTextCell"
    var nameInputField = UITextField()
    var cancelButton = UIButton()
    var chooseButton = UIButton()
    var modifyButton = UIButton()
    var deleteButton = UIButton()
    var doneNameButton = UIButton()
    var cancelNameButton = UIButton()
    var newNameButton = UIButton()
    var getNameModus = false
    var originalAktName = ""
    var tableViewConstraints = [NSLayoutConstraint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalAktName = GV.globalParam.aktName
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: textCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.hidden = false
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.blackColor().CGColor
        
        self.view.addSubview(tableView)

        self.view.addSubview(cancelButton)
        self.view.addSubview(chooseButton)
        self.view.addSubview(modifyButton)
        self.view.addSubview(deleteButton)
        self.view.addSubview(newNameButton)
        self.view.addSubview(doneNameButton)
        self.view.addSubview(cancelNameButton)
        self.view.addSubview(nameInputField)
 

 
        prepareButton(cancelButton, text: .TCCancel, action: "cancelPressed:", placeOffset: CGPointMake(20, 20), relativeTo: tableView)
        prepareButton(chooseButton, text: .TCChoose, action: "choosePressed:", placeOffset: CGPointMake(220, 20), relativeTo: tableView)
        prepareButton(modifyButton, text: .TCNewName , action: "newNamePressed:", placeOffset: CGPointMake(20, 80), relativeTo: tableView)
        prepareButton(deleteButton, text: .TCModify, action: "modifyPressed:", placeOffset: CGPointMake(120, 80), relativeTo: tableView)
        prepareButton(newNameButton, text: .TCDelete, action: "deletePressed:", placeOffset: CGPointMake(220, 80), relativeTo: tableView)

        prepareButton(cancelNameButton, text: .TCCancel, action: "cancelNamePressed:", placeOffset: CGPointMake(20, 50), relativeTo: nameInputField)
        prepareButton(doneNameButton, text: .TCDone, action: "doneNamePressed:", placeOffset: CGPointMake(220, 50), relativeTo: nameInputField)
        
        hideNameTableButtons(false)
        
        if GV.globalParam.aktName == GV.dummyName {
            getNewName()
        } else {
            textCell.removeAll()
            for index in 0..<GV.spriteGameDataArray.count {
                textCell.append(GV.spriteGameDataArray[index].name)
            }
            setupTableViewLayout()
        }
        
    }
    
    func prepareButton(button: UIButton, text: TextConstants, action: Selector, placeOffset: CGPoint, relativeTo: UIView) {
        let titleColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        button.setTitle(GV.language.getText(text), forState:.Normal)
        button.setTitleColor(titleColor, forState: UIControlState.Normal)
        button.addTarget(self, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: placeOffset.x))
        
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: relativeTo, attribute: .Bottom, multiplier: 1.0, constant: placeOffset.y))
        
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100))
        
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .Height , relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50))
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textCell.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        cell = self.tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = textCell[row]
        
        if textCell[row] == GV.globalParam.aktName {
            cell.backgroundColor = UIColor(red: 0x00/0xff, green: 0xff/0xff, blue: 0x7f/0xff, alpha: 1) // Springgreen
        } else {
            cell.backgroundColor = UIColor(red: 0xff/0xff, green: 0xff/0xff, blue: 0xff/0xff, alpha: 1) // Springgreen
        }
        cell.frame.origin.x = self.view.frame.midX - (cell.frame.size.width) / 2
        //cell!.accessoryType = .Checkmark
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        GV.globalParam.aktName = textCell[indexPath.row]
        tableView.reloadData()
    }
    
    func getNewName() {

        hideNameTableButtons(true)
        nameInputField.text = ""
        nameInputField.placeholder = GV.language.getText(.TCName)
        nameInputField.borderStyle = .RoundedRect
        nameInputField.layer.borderColor = UIColor.blackColor().CGColor
        nameInputField.delegate  = self
        nameInputField.returnKeyType = UIReturnKeyType.Default
        nameInputField.autocorrectionType = .No
        //nameInputField.layer.shadowColor = UIColor.blackColor().CGColor
        //nameInputField.layer.shadowOffset = CGSizeMake(5, 5)
        nameInputField.layer.borderWidth = 1.0
        nameInputField.translatesAutoresizingMaskIntoConstraints = false
        nameInputField.becomeFirstResponder()

        tableView.layer.hidden = true
        
        self.view.addConstraint(NSLayoutConstraint(item: nameInputField, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: nameInputField, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 100))
        
        self.view.addConstraint(NSLayoutConstraint(item: nameInputField, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 300))
        
        self.view.addConstraint(NSLayoutConstraint(item: nameInputField, attribute: .Height , relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50))
        
        
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textFieldEditingDidChange(sender: AnyObject) {
        print("textField:hier)")
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
            _ = 0
    }

    func cancelPressed(sender: UIButton) {
        GV.globalParam.aktName = originalAktName
        GV.dataStore.saveGlobalParamRecord()
        self.performSegueWithIdentifier(backToSettings, sender: self)
    }
    
    func choosePressed(sender: UIButton) {
        if let newName = nameInputField.text {
            if newName != "" {
                GV.globalParam.aktName = newName
            }
            GV.dataStore.saveGlobalParamRecord()
            textCell.append(newName)
            tableView.reloadData()
            nameInputField.endEditing(true)
        }
        nameInputField.layer.hidden = true
        tableView.layer.hidden = false
        self.performSegueWithIdentifier(backToSettings, sender: self)
    }
    
    func modifyPressed(sender: UIButton) {
    }

    func newNamePressed(sender: UIButton) {
        getNewName()
    }
    
    func deletePressed(sender: UIButton) {
        var ind = 0
        for index in 0..<GV.spriteGameDataArray.count {
            if GV.spriteGameDataArray[index].name == GV.globalParam.aktName {
                GV.spriteGameDataArray.removeAtIndex(index)
                textCell.removeAtIndex(index)
                if index >= GV.spriteGameDataArray.count {
                    ind = GV.spriteGameDataArray.count - 1
                } else {
                    ind = index
                }
                break
            }
        }
        
        GV.globalParam.aktName = GV.spriteGameDataArray[ind].name
        GV.dataStore.saveGlobalParamRecord()
        GV.dataStore.saveSpriteGameRecord()
        tableView.reloadData()
        setupTableViewLayout()
    }
    
    func cancelNamePressed(sender: UIButton) {
        nameInputField.endEditing(true)
        hideNameTableButtons(false)
    }

    func doneNamePressed(sender: UIButton) {
        if let newName = nameInputField.text {
            var newGameParam: SpriteGameData
            if GV.globalParam.aktName == GV.dummyName {
                GV.spriteGameDataArray[0].name = newName
            } else {
                newGameParam = SpriteGameData()
                newGameParam.name = newName
                GV.spriteGameDataArray.append(newGameParam)
            }
            GV.globalParam.aktName = newName
            GV.dataStore.saveSpriteGameRecord()
            textCell.append(newName)
            tableView.reloadData()
            setupTableViewLayout()
            nameInputField.endEditing(true)
        }
        hideNameTableButtons(false)
    }
    
    func hideNameTableButtons(hidden: Bool) {
        chooseButton.hidden = hidden
        cancelButton.hidden = hidden
        modifyButton.hidden = hidden
        deleteButton.hidden = hidden
        newNameButton.hidden = hidden
        tableView.hidden = hidden

        doneNameButton.hidden = !hidden
        cancelNameButton.hidden = !hidden
        nameInputField.hidden = !hidden

    }

    func setupTableViewLayout() {
        
        if tableViewConstraints.count > 0 {
            self.view.removeConstraints(tableViewConstraints)
            tableViewConstraints.removeAll()
        }
        let tableViewHeight = CGFloat(textCell.count * 45)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableViewConstraints.append(NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0))
        
        tableViewConstraints.append(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 100))
        
        tableViewConstraints.append(NSLayoutConstraint(item: tableView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 300))
        
        tableViewConstraints.append(NSLayoutConstraint(item: tableView, attribute: .Height , relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: tableViewHeight))
        
        self.view.addConstraints(tableViewConstraints)
    }

}