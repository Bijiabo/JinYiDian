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
    private var _locationManager: CLLocationManager!
    private var _location: CLLocation?
    private var _locationUpdateCount: Int = 0
    private let _search = AMapSearchAPI()
    private var _addressIndex: [String: NSIndexPath] = [String: NSIndexPath]()
    private var _destinationIndex: [String: String] = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "LagouGI"
        clearsSelectionOnViewWillAppear = true
        
        _loadData()
        
        _search.delegate = self
        
        _locationManager = CLLocationManager()
        _locationManager.requestWhenInUseAuthorization()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.startUpdatingLocation()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? _data.count : 1
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
            _loadPositionDataForPositionId(cell.positionId, indexPath: indexPath)
            
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
        
        _POIQueryForAddress(cell.address)
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
                    return
                }
                
                var indexPathsForInsertRows: [NSIndexPath] = [NSIndexPath]()
                for rowIndex in self._data.count..<self._data.count+json["content"]["result"].count {
                    indexPathsForInsertRows.append(NSIndexPath(forRow: rowIndex, inSection: 0))
                }
                self._data += json["content"]["result"].arrayValue
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.beginUpdates()
                    self.tableView.insertRowsAtIndexPaths(indexPathsForInsertRows, withRowAnimation: UITableViewRowAnimation.Right)
                    self.tableView.endUpdates()
                })
            })
    }
    
    private func _loadPositionDataForPositionId(id: String, indexPath: NSIndexPath) {
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
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? PositionListTableViewCell, let address = address {
                        cell.address = address
                        self._addressIndex[address] = indexPath
                        self._POIQueryForAddress(address)
                    }
                })
                
            } catch let error {
                print(error)
            }
        }
    }
    
    private func _participleResultForAddress(address: String, completionHandler: (result: [[String: AnyObject]])->Void) {
        let urlString: String = "http://api.pullword.com/get.php"
        let parameters: [String: AnyObject] = [
            "source": address,
            "param1": 0,
            "param2": 1
        ]
        
        Alamofire.request(.GET, urlString, parameters: parameters)
            .response { (request, response, data, error) -> Void in
                if error != nil || data == nil {
                    print(error)
                    return
                }
                
                let resultString: String = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                
                let participleResult = resultString.characters.split("\r\n").map { (c) -> [String: AnyObject] in
                    let s = c.split(":").map {(x) -> String in
                        return String(x)
                    }
                    return ["city": s[0], "probability": NSString(string: s[1]).floatValue ]
                }
                
                completionHandler(result: participleResult)
        }
    }
    
    private func _POIQueryForAddress(address: String) {
        guard let location = _location else {return}
        let latitude: CGFloat = CGFloat(location.coordinate.latitude)
        let longitude: CGFloat = CGFloat(location.coordinate.longitude)
        
        //构造AMapCloudPOIAroundSearchRequest对象，设置云周边检索请求参数
        let request: AMapPOIAroundSearchRequest = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.locationWithLatitude(latitude, longitude: longitude)
        request.keywords = address
        request.types = "汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施"
        request.sortrule = 0
        request.requireExtension = true
        
        //发起云本地检索
        _search.AMapPOIAroundSearch(request)
    }
    
    private func _NavigaitonSearchToPoint(point: CLLocationCoordinate2D) {
        guard let location = _location else {return}
        let latitude: CGFloat = CGFloat(location.coordinate.latitude)
        let longitude: CGFloat = CGFloat(location.coordinate.longitude)
        
        //构造AMapDrivingRouteSearchRequest对象，设置驾车路径规划请求参数
        let request: AMapTransitRouteSearchRequest = AMapTransitRouteSearchRequest()
        request.origin = AMapGeoPoint.locationWithLatitude(latitude, longitude: longitude)
        request.destination = AMapGeoPoint.locationWithLatitude(CGFloat(point.latitude), longitude: CGFloat(point.longitude))
        request.strategy = 0
        request.city = "shenzhen"
        //距离优先
        request.requireExtension = true
        //发起路径搜索
        _search.AMapTransitRouteSearch(request)
    }

}

extension PositionListTableViewController: AMapSearchDelegate {
    
    func onPOISearchDone(request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        guard let request = request as? AMapPOIAroundSearchRequest else {return}
        
        if response.pois.count == 0
        {
            var queryCharaters = request.keywords.characters
            queryCharaters.removeLast()
            let address = String(queryCharaters)
            _addressIndex[address] = _addressIndex[request.keywords]
            _POIQueryForAddress(address)
            
            return
        }
        
        let point = response.pois.first! as! AMapPOI
        _destinationIndex["\(point.location.latitude)-\(point.location.longitude)"] = request.keywords
        _NavigaitonSearchToPoint(CLLocationCoordinate2D(latitude: Double(point.location.latitude), longitude: Double(point.location.longitude)))
    }
    
    func onRouteSearchDone(request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
        
//        print(response.count)
//        print(response.route.transits)
        
        for t in response.route.transits as! [AMapTransit] {
//            print("------")
//            print("duration: \(t.duration)")
//            print("walkingDistance: \(t.walkingDistance)")
            
            if let address = _destinationIndex["\(request.destination.latitude)-\(request.destination.longitude)"] {
                if let indexPath = _addressIndex[address] {
                    if let cell = tableView.cellForRowAtIndexPath(indexPath) as? PositionListTableViewCell {
                        cell.timeCount = "\(t.duration/60) min"
                        break
                    }
                }
            }
            
        }
        
    }
}

extension PositionListTableViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else {return}
        
        _location = location
        
        _locationUpdateCount += 1
        
        if _locationUpdateCount >= 10 {
            _locationManager.stopUpdatingLocation()
        }
        
    }
    
}
