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
import SafariServices
import AlamofireImage

private let _imageDownloader = ImageDownloader(
    configuration: ImageDownloader.defaultURLSessionConfiguration(),
    downloadPrioritization: .FIFO,
    maximumActiveDownloads: 4,
    imageCache: AutoPurgingImageCache()
)

class PositionListTableViewController: UITableViewController {
    @IBOutlet weak var citySelectButton: UIBarButtonItem!
    
    private var _data: [JSON] = [JSON]()
    private var _page: Int = 1
    private var _pageMax: Int = Int.max
    private var _locationManager: CLLocationManager!
    private var _location: CLLocation?
    private var _locationUpdateCount: Int = 0
    private let _search = AMapSearchAPI()
    private var _addressIndex: [String: NSIndexPath] = [String: NSIndexPath]()
    private var _destinationIndex: [String: String] = [String: String]()
    private var _loadingData: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = _kd
        citySelectButton.title = _city
        clearsSelectionOnViewWillAppear = true
        tableView.estimatedRowHeight = 180.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        _loadData()
        
        _search.delegate = self
        
        _locationManager = CLLocationManager()
        _locationManager.requestWhenInUseAuthorization()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.startUpdatingLocation()
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: String())
        refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
        tableView.sendSubviewToBack(refreshControl!)
    }
    
    func refresh(sender: AnyObject) {
        _refershData()
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
            
            cell.companyName = currentData["companyName"].stringValue
            cell.companyFullName = currentData["companyShortName"].stringValue
            cell.industryField = currentData["industryField"].stringValue
            cell.financeStage = currentData["financeStage"].stringValue
            cell.companySize = currentData["companySize"].stringValue
            cell.salary = currentData["salary"].stringValue
            cell.positionId = currentData["positionId"].stringValue
            cell.experience = currentData["workYear"].stringValue
            cell.lure = currentData["positionAdvantage"].stringValue
            
            let companyLogoURLString: String = "http://www.lagou.com/\(currentData["companyLogo"].stringValue)"
            _setRemoteImageForImageView(cell.logoImageView, URLString: companyLogoURLString)
            
            // get address information
            _loadPositionDataForPositionId(cell.positionId, indexPath: indexPath)
            
            // set background color
            // cell.backgroundColor = indexPath.row%2 == 0 ? UIColor(red:0.96, green:0.96, blue:0.96, alpha:1) : UIColor.whiteColor()
            
            return cell
        } else {
            let cell = UITableViewCell()
            
            if !_loadingData {
                _page += 1
                _loadData()
            }
            
            return cell
        }
        
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? PositionListTableViewCell else {return}
        
        //_POIQueryForAddress(cell.address)
        let urlString = "http://www.lagou.com/jobs/\(cell.positionId).html"
        /*
        if #available(iOS 9.0, *) {
            let url: NSURL = NSURL(string: urlString)!
            if 64 == 32 + (32 * CGFLOAT_IS_DOUBLE) {
                let svc = SFSafariViewController(URL: url)
                self.presentViewController(svc, animated: true, completion: nil)
                return
            }
        
        }
        */
        let webVC = storyboard?.instantiateViewControllerWithIdentifier("webVC") as! WebBrowserViewController
        webVC.uri = urlString
        webVC.address = cell.address
        self.presentViewController(webVC, animated: true, completion: nil)
    }
    
    // MARK: - Custom view functions
    
    private func _reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    // MARK: - data functions
    
    private var _gj: String = "1-3年" //工作经验
    private var _px: String = "px"
    private var _city: String = "深圳" {
        didSet {
            citySelectButton.title = _city
        }
    }
    private var _kd: String = "产品经理"
    
    func updateCity(city: String) {
        _city = city
        
        _refershData()
    }
    
    func updatePositionType(type: String, workYear: String) {
        _kd = type
        _gj = workYear
        title = type
        
        _refershData()
    }
    
    private func _refershData() {
        _page = 1
        _data.removeAll(keepCapacity: false)
        _reloadTableView()
    }
    
    private func _loadData() {
        let pn: Int = _page
        let first: Bool = false
        
        let path: String = "http://www.lagou.com/jobs/positionAjax.json"
        let parameters: [String: AnyObject] = [
            "gj": _gj,
            "px": _px,
            "city": _city,
            "pn": pn,
            "kd": _kd,
            "first": first
        ]
        
        if _pageMax == _page {return}
        
        _loadingData = true
        
        Alamofire.request(.GET, path, parameters: parameters)
            .responseSwiftyJSON({ (request, response, json, error) in
                
                self._loadingData = false
                self.refreshControl?.endRefreshing()
                
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
                    //*
                    self.tableView.beginUpdates()
                    self.tableView.insertRowsAtIndexPaths(indexPathsForInsertRows, withRowAnimation: UITableViewRowAnimation.None)
                    self.tableView.endUpdates()
                    //*/
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
    
    private func _setRemoteImageForImageView(imageView: UIImageView, URLString: String) {
        
        let URL = NSURL(string: URLString)!
        let avatarURLRequest = NSURLRequest(URL: URL)
        _imageDownloader.downloadImage(URLRequest: avatarURLRequest) { (response) -> Void in
            if let image = response.result.value {
                imageView.image = image
            }
        }
    }
    
    // MARK: - user actions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueIdentifier = segue.identifier else {return}
        
        switch segueIdentifier {
        case "link2typeSelectPage":
            guard let vc = segue.destinationViewController as? PositionTypeSelectTableViewController else {return}
            vc.positionListVC = self
        case "link2citySelect":
            guard let vc = segue.destinationViewController as? CitySelectTableViewController else {return}
            vc.positionListVC = self
        default:
            break
        }
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
        let targetPointCLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double(point.location.latitude), longitude: Double(point.location.longitude))
        _NavigaitonSearchToPoint(targetPointCLLocationCoordinate2D)
        
        // 计算直线距路
        if let location = _location {
            let userPoint = MAMapPointForCoordinate(location.coordinate)
            let targetPoint = MAMapPointForCoordinate(targetPointCLLocationCoordinate2D)
            let distance: CLLocationDistance = MAMetersBetweenMapPoints(userPoint, targetPoint)
            let distanceInKm = Int(distance/100.0)/10
            if let indexPath = _addressIndex[request.keywords] {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? PositionListTableViewCell {
                    cell.distance = distanceInKm == 0 ? "" : "\(distanceInKm)Km"
                }
            }
        }
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
