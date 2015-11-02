//
//  SettingsUIViewController.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 10. 30..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let textCell = [
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
            case nameRow:       self.performSegueWithIdentifier("getName", sender: self)
            case volumeRow:     self.performSegueWithIdentifier("setVolume", sender: self)
            case helpLinesRow:  self.performSegueWithIdentifier("setCountHelpLines", sender: self)
            case languageRow:   self.performSegueWithIdentifier("setLanguage", sender: self)
            case returnRow:     self.performSegueWithIdentifier("goBack", sender: self)
            default: _ = 0
        }
        self.performSegueWithIdentifier("getName", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "getName" {
            if let setParametersViewController = segue.destinationViewController as? SetParametersViewController {
                setParametersViewController.toDo = segue.identifier!
            }
        }
    }
}