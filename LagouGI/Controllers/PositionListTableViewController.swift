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
import Fuzi

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
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("PositionListTableViewCell", forIndexPath: indexPath) as! PositionListTableViewCell
            let currentData = _data[indexPath.row]
            
            cell.companyName = "\(currentData["companyName"].stringValue) - \(currentData["companyShortName"].stringValue)"
            cell.companyInformation = "\(currentData["financeStage"].stringValue) - \(currentData["industryField"].stringValue) \n\(currentData["companySize"].stringValue)"
            cell.salary = currentData["salary"].stringValue
            cell.positionId = currentData["positionId"].stringValue
            
            // get address information
            cell.address = "获取地址中..."
            _loadPositionDataForPositionId(cell.positionId, completeHandler: { (address) -> Void in
                if let address = address {
                    cell.address = address
                } else {
                    cell.address = "地址获取失败"
                }
            })
            
            // set background color
            cell.backgroundColor = indexPath.row%2 == 0 ? UIColor(red:0.96, green:0.96, blue:0.96, alpha:1) : UIColor.whiteColor()
            
            return cell
        } else {
            let cell = UITableViewCell()
            
            _page += 1
            _loadData()
            
            return cell
        }
        
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? PositionListTableViewCell else {return}
        
//        _loadPositionDataForPositionId(cell.positionId)
    }
    
    // MARK: - Custom view functions
    
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
    
    private func _loadPositionDataForPositionId(id: String, completeHandler: (address: String?)->Void) {
        let urlString: String = "http://www.lagou.com/jobs/\(id).html"
        Alamofire.request(.GET, urlString)
        .response { (request, response, data, error) -> Void in
            if error != nil || data == nil {
                print(error)
                return
            }
            
            let htmlString: String = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            
            do {
                // if encoding is omitted, it defaults to NSUTF8StringEncoding
                let doc = try HTMLDocument(string: htmlString, encoding: NSUTF8StringEncoding)
                
                // CSS queries
                let address = doc.css(".job_company dd div").first?.stringValue
                completeHandler(address: address)
                
            } catch let error {
                print(error)
            }
        }
    }

}
