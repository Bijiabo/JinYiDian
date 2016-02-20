//
//  PositionListTableViewCell.swift
//  Lagou+GI
//
//  Created by huchunbo on 16/2/19.
//  Copyright © 2016年 Bijiabo. All rights reserved.
//

import UIKit

class PositionListTableViewCell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyFullNameLabel: UILabel!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeCountLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var lureLabel: UILabel!
    @IBOutlet weak var industryFieldButton: UIButton!
    @IBOutlet weak var financeStageButton: UIButton!
    @IBOutlet weak var companySizeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        _setupViews()
        
        _setupBordersForButton(industryFieldButton)
        _setupBordersForButton(financeStageButton)
        _setupBordersForButton(companySizeButton)
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
        address = ""
        timeCount = ""
        distance = ""
    }
    
    private func _setupBordersForButton(button: UIButton) {
        button.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1).CGColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 13.0
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 13.0, bottom: 0, right: 13.0)
    }
    
    var companyName: String = "" {
        didSet {
            companyNameLabel.text = companyName
        }
    }
    
    var companyFullName: String = "" {
        didSet {
            companyFullNameLabel.text = companyFullName
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
            _updateDistanceAndTimeCountDisplay()
        }
    }
    
    var industryField: String = "" {
        didSet {
            industryFieldButton.setTitle("   \(industryField)   ", forState: UIControlState.Normal)
        }
    }
    
    var financeStage: String = "" {
        didSet {
            financeStageButton.setTitle("   \(financeStage)   ", forState: UIControlState.Normal)
        }
    }
    
    var companySize: String = "" {
        didSet {
            companySizeButton.setTitle("   \(companySize)   ", forState: UIControlState.Normal)
        }
    }
    
    var experience: String = "" {
        didSet {
            experienceLabel.text = experience
        }
    }
    
    var distance: String = "" {
        didSet {
            _updateDistanceAndTimeCountDisplay()
        }
    }
    
    var lure: String = "" {
        didSet {
            lureLabel.text = lure
        }
    }
    
    private func _updateDistanceAndTimeCountDisplay() {
        timeCountLabel.text = "\(distance) \(timeCount)"
    }

}
