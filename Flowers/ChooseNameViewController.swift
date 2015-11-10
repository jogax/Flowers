//
//  ChooseNameController.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 11. 10..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import UIKit

class ChooseNameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    var tableView: UITableView?
    var cell: UITableViewCell?
    var textCell: [String] = []
    let textCellIdentifier = "nameTextCell"
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textCell.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        cell = self.tableView!.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell!.textLabel?.text = textCell[row]
        cell!.backgroundColor = UIColor(red: 0x00/0xff, green: 0xff/0xff, blue: 0x7f/0xff, alpha: 1) // Springgreen
        cell!.frame.origin.x = self.view.frame.midX - (cell?.frame.size.width)! / 2
        //cell!.accessoryType = .Checkmark
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        textCell.removeAll()
//        setAktlanguageRow()
        tableView.reloadData()
    }
}