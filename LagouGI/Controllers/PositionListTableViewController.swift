//
//  PositionListTableViewController.swift
//  Lagou+GI
//
//  Created by huchunbo on 16/2/19.
//  Copyright © 2016年 Bijiabo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PositionListTableViewController: UITableViewController {
    
    private var _data: [JSON] = [JSON]()
    private var _page: Int = 1
    private var _pageMax: Int = Int.max

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "LagouGI"
        clearsSelectionOnViewWillAppear = true
        
        _loadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return _data.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("PositionListTableViewCell", forIndexPath: indexPath) as! PositionListTableViewCell
            let currentData = _data[indexPath.row]
            
            cell.companyName = "\(currentData["companyName"].stringValue) - \(currentData["companyShortName"].stringValue)"
            cell.companyInformation = "\(currentData["financeStage"].stringValue) - \(currentData["industryField"].stringValue) \n\(currentData["companySize"].stringValue)"
            cell.salary = currentData["salary"].stringValue
            
            return cell
        } else {
            let cell = UITableViewCell()
            
            _page += 1
            _loadData()
            
            return cell
        }
        
    }
    
    private func _reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    // MARK: - data functions
    
    private func _loadData() {
        let gj: String = "1-3年" //工作经验
        let px: String = "px"
        let city: String = "深圳"
        let pn: Int = _page
        let kd: String = "产品经理"
        let first: Bool = false
        
        let path: String = "http://www.lagou.com/jobs/positionAjax.json"
        let parameters: [String: AnyObject] = [
            "gj": gj,
            "px": px,
            "city": city,
            "pn": pn,
            "kd": kd,
            "first": first
        ]
        
        if _pageMax == _page {return}
        
        Alamofire.request(.GET, path, parameters: parameters)
            .responseSwiftyJSON({ (request, response, json, error) in
                
                if error != nil {
                    print(error)
                    return
                }
                
                if json["content"]["result"].count == 0 {
                    self._pageMax = self._page
                }
                
                self._data += json["content"]["result"].arrayValue
                
                self._reloadTableView()
            })
    }

}
