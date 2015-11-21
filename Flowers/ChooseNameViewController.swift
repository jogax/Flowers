//
//  ChooseNameController.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 11. 10..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import UIKit

class ChooseNameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate  {
    var tableView: UITableView = UITableView()
    var cell: UITableViewCell = UITableViewCell()
    var textCell: [String] = []
    let textCellIdentifier = "nameTextCell"
    var nameInputField = UITextField()
    var cancelButton = UIButton()
    var doneButton = UIButton()
    var getNameModus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView = UITableView()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: textCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.hidden = false
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.blackColor().CGColor
        self.view.addSubview(tableView)
        
        if GV.globalParam.aktName == GV.dummyName {
            getNewName()
        } else {
            textCell.removeAll()
            for index in 0..<GV.spriteGameDataArray.count {
                textCell.append(GV.spriteGameDataArray[index].name)
            }
        }
        
        self.view.addSubview(cancelButton)
        self.view.addSubview(doneButton)
        cancelButton.setTitle(GV.language.getText(.TCCancel), forState:.Normal)
        let titleColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        cancelButton.setTitleColor(titleColor, forState: UIControlState.Normal)
        
        doneButton.setTitle(GV.language.getText(.TCDone), forState: .Normal)
        doneButton.setTitleColor(titleColor, forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "cancelPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.addTarget(self, action: "donePressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        setupLayout()
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
        //cell.backgroundColor = UIColor(red: 0x00/0xff, green: 0xff/0xff, blue: 0x7f/0xff, alpha: 1) // Springgreen
        cell.frame.origin.x = self.view.frame.midX - (cell.frame.size.width) / 2
        //cell!.accessoryType = .Checkmark
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        textCell.removeAll()
//        setAktlanguageRow()
        tableView.reloadData()
    }
    
    func getNewName() {
        getNameModus = true
        nameInputField = UITextField()
        nameInputField.placeholder = GV.language.getText(.TCName)
        nameInputField.borderStyle = .RoundedRect
        nameInputField.layer.borderColor = UIColor.blackColor().CGColor
        nameInputField.delegate  = self
        nameInputField.returnKeyType = UIReturnKeyType.Default
        nameInputField.autocorrectionType = .No
        //nameInputField.layer.shadowColor = UIColor.blackColor().CGColor
        //nameInputField.layer.shadowOffset = CGSizeMake(5, 5)
        nameInputField.layer.borderWidth = 1.0
        self.view.addSubview(nameInputField)
        nameInputField.translatesAutoresizingMaskIntoConstraints = false

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
        self.performSegueWithIdentifier(backToSettings, sender: self)
    }
    
    func donePressed(sender: UIButton) {
        if getNameModus {
            getNameModus = false
            if let newName = nameInputField.text {
                GV.globalParam.aktName = newName
                textCell.append(newName)
                tableView.reloadData()
                nameInputField.endEditing(true)
            }
            nameInputField.layer.hidden = true
            tableView.layer.hidden = false
        } else {
            self.performSegueWithIdentifier(backToSettings, sender: self)
        }
    }


    func setupLayout() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        //languageTableView
        self.view.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 40))
        
        self.view.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 50))
        
        self.view.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100))
        
        self.view.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .Height , relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50))
        
        
        
        
        //        // doneButton
        self.view.addConstraint(NSLayoutConstraint(item: doneButton, attribute: NSLayoutAttribute.Right, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -40.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: doneButton, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 50.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: doneButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100))
        
        self.view.addConstraint(NSLayoutConstraint(item: doneButton, attribute: .Height , relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50))
        
        let tableViewHeight = CGFloat(textCell.count * 45)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 100))
        
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 300))
        
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Height , relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: tableViewHeight))
        
        
        
        
    }

}