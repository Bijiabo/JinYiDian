//
//  CitySelectTableViewController.swift
//  LagouGI
//
//  Created by huchunbo on 16/2/21.
//  Copyright © 2016年 Bijiabo. All rights reserved.
//

import UIKit

class CitySelectTableViewController: UITableViewController {

    private var _data: [String] = [
        "全国",
        "北京",
        "上海",
        "深圳",
        "广州",
        "杭州",
        "成都",
        "南京",
        "武汉",
        "西安",
        "厦门",
        "长沙",
        "苏州",
        "天津",
        "重庆",
        "郑州",
        "青岛",
        "合肥",
        "福州",
        "济南",
        "大连",
        "珠海",
        "无锡",
        "佛山",
        "东莞",
        "宁波",
        "常州",
        "沈阳",
        "石家庄",
        "昆明",
        "南昌",
        "南宁",
        "哈尔滨",
        "海口",
        "中山",
        "惠州",
        "贵阳",
        "长春",
        "太原",
        "嘉兴",
        "泰安",
        "昆山",
        "烟台",
        "兰州",
        "泉州"
    ]
    var positionListVC: PositionListTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "选择城市"
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cityCell", forIndexPath: indexPath)

        cell.textLabel?.text = _data[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else {return}
        guard let city = cell.textLabel?.text else {return}
        guard let positionListVC = positionListVC else {return}
        
        positionListVC.updateCity(city)
        navigationController?.popToViewController(positionListVC, animated: true)
    }
}
