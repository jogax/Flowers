//
//  SettingsUIViewController.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 10. 30..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import UIKit

let nameText = "getName"
let volumeText = "setVolume"
let helpLinesText = "setCountHelpLines"
let languageText = "setLanguage"
let returnText = "goBack"
let backToSettings = "backToSettings"


class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var textCell = [
        "\(GV.language.getText(.TCName))",
        "\(GV.language.getText(.TCVolume))",
        "\(GV.language.getText(.TCCountHelpLines))",
        "\(GV.language.getText(.TCLanguage))",
        "\(GV.language.getText(.TCReturn))"
    ]
    let nameRow = 0
    let volumeRow = 1
    let helpLinesRow = 2
    let languageRow = 3
    let returnRow = 4


    let textCellIdentifier = "TextCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GV.language.addCallback(changeLanguage)

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textCell.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = textCell[row]
        if row != returnRow {
            cell.accessoryType = .DisclosureIndicator
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         switch indexPath.row {
            case nameRow:       self.performSegueWithIdentifier(nameText, sender: self)
            case volumeRow:     self.performSegueWithIdentifier(volumeText, sender: self)
            case helpLinesRow:  self.performSegueWithIdentifier(helpLinesText, sender: self)
            case languageRow:   self.performSegueWithIdentifier(languageText, sender: self)
            case returnRow:     self.performSegueWithIdentifier(returnText, sender: self)
            default: _ = 0
        }
        //self.performSegueWithIdentifier(nameText, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == nameText {
////            let test = segue.destinationViewController  as? SetParametersViewController
            if let setParametersViewController = segue.destinationViewController as? ChooseLanguageViewController {
                setParametersViewController.toDo = segue.identifier!
            }
//        }
    }
    
    func changeLanguage()->Bool {
        textCell = [
            "\(GV.language.getText(.TCName))",
            "\(GV.language.getText(.TCVolume))",
            "\(GV.language.getText(.TCCountHelpLines))",
            "\(GV.language.getText(.TCLanguage))",
            "\(GV.language.getText(.TCReturn))"
        ]
        self.tableView.reloadData()
        return true
    }

    
    @IBAction func unwindToSC(segue: UIStoryboardSegue) {
    }

}

class ChooseLanguageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    let enRow = 0
    let deRow = 1
    let huRow = 2
    let ruRow = 3
    var cancelButton = UIButton()
    var doneButton = UIButton()
    var aktLanguageRow = 0
    var aktLanguageKey: String?
    var toDo = ""
    @IBOutlet weak var languageTableView: UITableView!
    let textCellIdentifier = "languageTextCell"
    var textCell = [
        "\(GV.language.getText(.TCEnglish))",
        "\(GV.language.getText(.TCGerman))",
        "\(GV.language.getText(.TCHungarian))",
        "\(GV.language.getText(.TCRussian))",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GV.language.addCallback(changeLanguage)
        aktLanguageKey = GV.language.getAktLanguageKey()
        setAktlanguageRow()
        

        switch toDo {
            case nameText: makeNameView()
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
    
    func makeNameView() {
        let _ = 0
    }
    func makeVolumeView() {
        let _ = 0
    }
    func makeHelpLinesView() {
        let _ = 0
    }
    func makeLangageView() {
        //languageTableView = UITableView()
        languageTableView.delegate = self
        languageTableView.dataSource = self
        
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textCell.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = languageTableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = textCell[row]
        if row == aktLanguageRow {
            cell.accessoryType = .Checkmark
        } else {
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
        textCell = [
            "\(GV.language.getText(.TCEnglish))",
            "\(GV.language.getText(.TCGerman))",
            "\(GV.language.getText(.TCHungarian))",
            "\(GV.language.getText(.TCRussian))",
        ]
        setAktlanguageRow()
        languageTableView.reloadData()
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
        GV.language.setLanguage(aktLanguageKey!)
        self.performSegueWithIdentifier(backToSettings, sender: self)
    }

    func donePressed(sender: UIButton) {
        
        GV.spriteGameData.aktLanguageKey = GV.language.getAktLanguageKey()
        
        GV.dataStore.createSpriteGameRecord(GV.spriteGameData)

        self.performSegueWithIdentifier(backToSettings, sender: self)
    }
    
    func changeLanguage()->Bool {
        cancelButton.setTitle(GV.language.getText(.TCCancel), forState:.Normal)
        doneButton.setTitle(GV.language.getText(.TCDone), forState: .Normal)
        return true
    }

   
    func setupLayout() {
        var constraintsArray = Array<NSLayoutConstraint>()
        languageTableView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        //languageTableView
        constraintsArray.append(NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 40))
        
        constraintsArray.append(NSLayoutConstraint(item: cancelButton, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 50))
        
        constraintsArray.append(NSLayoutConstraint(item: cancelButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100))
        
        constraintsArray.append(NSLayoutConstraint(item: cancelButton, attribute: .Height , relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50))
        
        
        
        
//        // doneButton
        constraintsArray.append(NSLayoutConstraint(item: doneButton, attribute: NSLayoutAttribute.Right, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -40.0))
        
        constraintsArray.append(NSLayoutConstraint(item: doneButton, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 50.0))
        
        constraintsArray.append(NSLayoutConstraint(item: doneButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100))
        
        constraintsArray.append(NSLayoutConstraint(item: doneButton, attribute: .Height , relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50))
        
        
        self.view.addConstraints(constraintsArray)
    }
    

}