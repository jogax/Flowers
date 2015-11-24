//
//  DetailsViewController.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 11. 08..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate  {
    let enRow = 0
    let deRow = 1
    let huRow = 2
    let ruRow = 3
    var cancelButton = UIButton()
    var doneButton = UIButton()
    var aktLanguageRow = 0
    var oldHelpLines = 0
    var aktLanguageKey: String?
    var toDo = ""
    let textCellIdentifier = "languageTextCell"
    
    var lineCountPicker: UIPickerView?
    var lineCounts = ["0","1","2","3","4"]
    var textCell = [
        "\(GV.language.getText(.TCEnglish))",
        "\(GV.language.getText(.TCGerman))",
        "\(GV.language.getText(.TCHungarian))",
        "\(GV.language.getText(.TCRussian))",
    ]
    var cell: UITableViewCell = UITableViewCell()
    var tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "languageTextCell")
        GV.language.addCallback(changeLanguage)
        aktLanguageKey = GV.language.getAktLanguageKey()
        setAktlanguageRow()
        
        
        switch toDo {
        case gameModusText: makeGameModusView()
        case volumeText: makeVolumeView()
        case helpLinesText: makeHelpLinesView()
        case languageText: makeLangageView()
        default: break
        }
        cancelButton.setTitle(GV.language.getText(.TCCancel), forState:.Normal)
        let titleColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        cancelButton.setTitleColor(titleColor, forState: UIControlState.Normal)
        
        doneButton.setTitle(GV.language.getText(.TCDone), forState: .Normal)
        doneButton.setTitleColor(titleColor, forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "cancelPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.addTarget(self, action: "donePressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton)
        self.view.addSubview(doneButton)
        
        setupLayout()
    }

    func makeGameModusView() {
        let _ = 0
    }
    
    func makeVolumeView() {
        let _ = 0
    }
    func makeHelpLinesView() {
        tableView.layer.hidden = true
        oldHelpLines = GV.showHelpLines
        lineCountPicker = UIPickerView()
        self.view.addSubview(lineCountPicker!)
        lineCountPicker!.delegate = self
        lineCountPicker!.dataSource = self
        lineCountPicker!.selectRow(Int(GV.spriteGameDataArray[GV.getAktNameIndex()].showHelpLines), inComponent: 0, animated: false)
        
        lineCountPicker!.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint(item: lineCountPicker!, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: lineCountPicker!, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: -100))
        
        self.view.addConstraint(NSLayoutConstraint(item: lineCountPicker!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100))
        
        self.view.addConstraint(NSLayoutConstraint(item: lineCountPicker!, attribute: .Height , relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 200))
    }
    
    func makeLangageView() {
        //languageTableView = UITableView()
        self.view.addSubview(tableView)
        tableView.layer.hidden = false
        tableView.layer.borderColor = UIColor.blackColor().CGColor
        tableView.layer.borderWidth = 0.5
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let tableHeight = cell.frame.height * CGFloat(textCell.count)
        
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self.view!, attribute: .Top, multiplier: 1.0, constant: 200))
        
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 300))
        
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Height , relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: tableHeight))
        
        
        
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
        cell.frame.origin.x = self.view.frame.midX - (cell.frame.size.width) / 2
        if row == aktLanguageRow {
            cell.accessoryType = .Checkmark
            cell.backgroundColor = UIColor(red: 0x00/0xff, green: 0xff/0xff, blue: 0x7f/0xff, alpha: 1) // Springgreen
        } else {
            cell.backgroundColor = UIColor(red: 0xff/0xff, green: 0xff/0xff, blue: 0xff/0xff, alpha: 1) // Springgreen
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
            case enRow:  GV.language.setLanguage(LanguageEN)
            case deRow:  GV.language.setLanguage(LanguageDE)
            case huRow:  GV.language.setLanguage(LanguageHU)
            case ruRow:  GV.language.setLanguage(LanguageRU)
            default: _ = 0
        }
        textCell.removeAll()
        textCell = [ //
            "\(GV.language.getText(.TCEnglish))",
            "\(GV.language.getText(.TCGerman))",
            "\(GV.language.getText(.TCHungarian))",
            "\(GV.language.getText(.TCRussian))",
        ]
        setAktlanguageRow()
        tableView.reloadData()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lineCounts.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return lineCounts[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        GV.showHelpLines = Int(lineCounts[row])!
    }
    
    func setAktlanguageRow() {
        switch GV.language.getAktLanguageKey() {
        case LanguageEN: aktLanguageRow = enRow
        case LanguageDE: aktLanguageRow = deRow
        case LanguageHU: aktLanguageRow = huRow
        case LanguageRU: aktLanguageRow = ruRow
        default: aktLanguageRow = enRow
        }
    }
    
    func cancelPressed(sender: UIButton) {
        switch toDo {
        case nameText: _ = 0
        case volumeText: _ = 0
        case helpLinesText: GV.showHelpLines = oldHelpLines
        case languageText:  GV.language.setLanguage(aktLanguageKey!)
        default: break
        }
        self.performSegueWithIdentifier(backToSettings, sender: self)
    }
    
    func donePressed(sender: UIButton) {
        let index = GV.getAktNameIndex()
        switch toDo {
        case nameText: _ = 0
        case volumeText: _ = 0
        case helpLinesText: GV.spriteGameDataArray[index].showHelpLines = Int64(GV.showHelpLines)
        case languageText:  GV.spriteGameDataArray[index].aktLanguageKey = GV.language.getAktLanguageKey()
        default: break
        }
        
        
        
        GV.dataStore.saveSpriteGameRecord()
        
        self.performSegueWithIdentifier(backToSettings, sender: self)
    }
    
    func changeLanguage()->Bool {
        cancelButton.setTitle(GV.language.getText(.TCCancel), forState:.Normal)
        doneButton.setTitle(GV.language.getText(.TCDone), forState: .Normal)
        return true
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

        
        
    }
    
    
}
