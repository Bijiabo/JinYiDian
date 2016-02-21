//
//  PositionTypeSelectTableViewController.swift
//  LagouGI
//
//  Created by huchunbo on 16/2/20.
//  Copyright © 2016年 Bijiabo. All rights reserved.
//

import UIKit
import SwiftyJSON

class PositionTypeSelectTableViewController: UITableViewController {
    
    private var _data: JSON = JSON([])
    var positionListVC: PositionListTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "职位搜索"
        _loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return _data.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bigTypeCell", forIndexPath: indexPath)
        let currentData = _data[indexPath.row]
        cell.textLabel?.text = currentData["title"].stringValue

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueIdentifier = segue.identifier else {return}
        
        switch segueIdentifier {
        case "link2SubType":
            guard let vc = segue.destinationViewController as? PositionSubTypeSelectTableViewController else {return}
            guard let cell = sender as? UITableViewCell else {return}
            guard let indexPath = tableView.indexPathForCell(cell) else {return}
            vc.data = _data[indexPath.row]["data"]
            vc.positionListVC = positionListVC
            vc.title = _data[indexPath.row]["title"].stringValue
        default:
            break
        }
    }
    
    // MARK: - data functions
    
    private func _loadData() {
        let dataFileURL: NSURL = NSBundle.mainBundle().resourceURL!.URLByAppendingPathComponent("PositionData.json")
        _data = JSON(data: NSData(contentsOfURL: dataFileURL)!)
        
        tableView.reloadData()
    }


}
