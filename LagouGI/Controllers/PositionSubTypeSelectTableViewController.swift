//
//  PositionSubTypeSelectTableViewController.swift
//  LagouGI
//
//  Created by huchunbo on 16/2/20.
//  Copyright © 2016年 Bijiabo. All rights reserved.
//

import UIKit
import SwiftyJSON

class PositionSubTypeSelectTableViewController: UITableViewController {

    var data: JSON = JSON([])
    var positionListVC: PositionListTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return data.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data[section]["data"].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section]["title"].stringValue
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("subTypeCell", forIndexPath: indexPath)
        let currentData = data[indexPath.section]["data"][indexPath.row]
        cell.textLabel?.text = currentData.stringValue

        return cell
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueIdentifier = segue.identifier else {return}
        
        switch segueIdentifier {
        case "link2workYearSelect":
            guard let vc = segue.destinationViewController as? PositionWorkYearSelectTableViewController else {return}
            guard let cell = sender as? UITableViewCell else {return}
            guard let indexPath = tableView.indexPathForCell(cell) else {return}
            vc.positionListVC = positionListVC
            vc.title = data[indexPath.section]["data"][indexPath.row].stringValue
        default:
            break
        }
    }

    

}
