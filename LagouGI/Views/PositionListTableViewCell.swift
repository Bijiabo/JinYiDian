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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    

}
