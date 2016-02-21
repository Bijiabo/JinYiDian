//
//  PositionWorkYearSelectTableViewController.swift
//  LagouGI
//
//  Created by huchunbo on 16/2/21.
//  Copyright © 2016年 Bijiabo. All rights reserved.
//

import UIKit

class PositionWorkYearSelectTableViewController: UITableViewController {

    private var _data: [String] = ["应届毕业生", "1年以下", "1-3年", "3-5年", "5-10年", "10年以上"]
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return _data.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("workYearCell", forIndexPath: indexPath)

        cell.textLabel?.text = _data[indexPath.row]

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else {return}
        guard let title = title else {return}
        guard let workYear = cell.textLabel?.text else {return}
        guard let positionListVC = positionListVC else {return}
        
        positionListVC.updatePositionType(title, workYear: workYear)
        navigationController?.popToViewController(positionListVC, animated: true)
    }

}
