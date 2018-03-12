//
//  SFPlanAdditionalTextCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 17/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol SFPlanAdditionalTextCellDelegate:NSObjectProtocol {
    @objc optional func buttonClicked(button:UIButton) -> Void
}


class SFPlanAdditionalTextCell: UITableViewCell {

    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var planPriceText: UILabel!
    @IBOutlet weak var planAdditionalTextDescription:UILabel!
    @IBOutlet weak var planPriceContainerView:UIView!
    @IBOutlet weak var restorePurchaseButton:UIButton!
    
    weak var delegate:SFPlanAdditionalTextCellDelegate?
    
    func updateViewColorTheme(containerView:UIView) {
        
        for subView in containerView.subviews {
            
            if subView is UILabel {
                
                let label = subView as! UILabel
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
            }
            else if subView is UIButton {
                
                let button = subView as! UIButton
                
                button.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff"), for: .normal)
                
                if button.tag == 102 {
                    
                    var yAxisMargin:CGFloat = 4.0
                    
                    if !Constants.IPHONE {
                        
                        yAxisMargin = 10.0
                    }
                    
                    let line = CAShapeLayer()
                    let linePath = UIBezierPath()
                    linePath.move( to: CGPoint.init(x: (button.frame.width - button.intrinsicContentSize.width)/2, y: (button.frame.maxY - yAxisMargin)))
                    linePath.addLine(to: CGPoint.init(x: button.intrinsicContentSize.width + (button.frame.width - button.intrinsicContentSize.width)/2, y: (button.frame.maxY - yAxisMargin)))
                    line.path = linePath.cgPath
                    
                    line.strokeColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff").cgColor
                    line.lineWidth =  1.0
                    line.lineJoin = kCALineJoinRound
                    button.layer.addSublayer(line)
                }
            }
            else {
                
                updateViewColorTheme(containerView: subView)
            }
        }
    }
    
    
    func updatePlanPriceText(annualPriceValue: String?) {
        
        if annualPriceValue != nil {
            
            self.planPriceText.text = "** Annual plan costs \(annualPriceValue!) and is charged annually. There is no refund for early termination of annual plan."
        }
        else {
            
            self.planPriceText.isHidden = true
            self.planPriceContainerView.changeFrameYAxis(yAxis: self.planPriceText.frame.minY)
        }
    }
    
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        
        if self.delegate != nil {
            
            if (delegate?.responds(to: #selector(SFPlanAdditionalTextCellDelegate.buttonClicked(button:))))! {
                
                delegate?.buttonClicked!(button: sender)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
