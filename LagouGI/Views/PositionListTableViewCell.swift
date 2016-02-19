//
//  PositionListTableViewCell.swift
//  Lagou+GI
//
//  Created by huchunbo on 16/2/19.
//  Copyright © 2016年 Bijiabo. All rights reserved.
//

import UIKit

class PositionListTableViewCell: UITableViewCell {

    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyInformationLabel: UILabel!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        _setupViews()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        _setupViews()
    }
    
    private func _setupViews() {
        companyName = ""
        companyInformation = ""
        address = "地址获取中..."
        timeCount = "路程时间计算中..."
    }
    
    var companyName: String = "" {
        didSet {
            companyNameLabel.text = companyName
        }
    }
    
    var companyInformation: String = "" {
        didSet {
            companyInformationLabel.text = companyInformation
        }
    }
    
    var salary: String = "" {
        didSet {
            salaryLabel.text = salary
        }
    }
    
    var address: String = "" {
        didSet {
            addressLabel.text = address
        }
    }
    
    var positionId: String = String()
    
    var timeCount: String = "" {
        didSet {
            timeCountLabel.text = timeCount
        }
    }

}
