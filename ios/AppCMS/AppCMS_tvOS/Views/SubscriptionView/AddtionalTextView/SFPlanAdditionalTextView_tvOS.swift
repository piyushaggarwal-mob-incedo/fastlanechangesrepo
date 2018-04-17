

import UIKit

@objc protocol SFPlanAdditionalTextCellDelegate:NSObjectProtocol {
    @objc optional func addtionalTextCellButtonClicked(button:UIButton) -> Void
}


class SFPlanAdditionalTextView_tvOS: UIView {
    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var restorePurchaseButton: UIButton!

    @IBOutlet weak var termsOfUseLabel: UILabel!
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    @IBOutlet weak var planPriceText: UILabel!
    @IBOutlet weak var planAdditionalTextDescription:UILabel!
    @IBOutlet weak var planPriceContainerView:UIView!
    @IBOutlet weak var restorePurchaseLabel:UILabel!
    @IBOutlet weak var restorePurchaseContainerView:UIView!

    weak var delegate:SFPlanAdditionalTextCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func instanceFromNib() -> UIView {
        
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            return UINib(nibName: "SFPlanAdditionalTextView_Sports_tvOS", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        } else {
            return UINib(nibName: "SFPlanAdditionalTextView_tvOS", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        }
    }
    
    func updateViewColorTheme(containerView:UIView) {
        let backgroundFocusGuide : UIFocusGuide = UIFocusGuide()
        planPriceContainerView.addLayoutGuide(backgroundFocusGuide)
        backgroundFocusGuide.leftAnchor.constraint(equalTo: planPriceContainerView.leftAnchor).isActive = true
        backgroundFocusGuide.topAnchor.constraint(equalTo: planPriceContainerView.topAnchor).isActive = true
        backgroundFocusGuide.widthAnchor.constraint(equalTo: planPriceContainerView.widthAnchor).isActive = true
        backgroundFocusGuide.heightAnchor.constraint(equalTo: planPriceContainerView.heightAnchor).isActive = true
        backgroundFocusGuide.preferredFocusedView = termsOfUseButton
        
        
        let restorePurhaseFocusGuide : UIFocusGuide = UIFocusGuide()
        restorePurchaseContainerView.addLayoutGuide(restorePurhaseFocusGuide)
        restorePurhaseFocusGuide.leftAnchor.constraint(equalTo: restorePurchaseContainerView.leftAnchor).isActive = true
        restorePurhaseFocusGuide.topAnchor.constraint(equalTo: restorePurchaseContainerView.topAnchor).isActive = true
        restorePurhaseFocusGuide.widthAnchor.constraint(equalTo: restorePurchaseContainerView.widthAnchor).isActive = true
        restorePurhaseFocusGuide.heightAnchor.constraint(equalTo: restorePurchaseContainerView.heightAnchor).isActive = true
        restorePurhaseFocusGuide.preferredFocusedView = restorePurchaseButton
        
        for subView in containerView.subviews {
            if subView is UILabel {
                let label = subView as! UILabel
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
            }
            else {
                updateViewColorTheme(containerView: subView)
            }
        }
        termsOfUseLabel.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "ffffff")
        privacyPolicyLabel.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "ffffff")
        restorePurchaseLabel.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "ffffff")
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
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let nextFocusView = context.nextFocusedView as? UIButton {
            let attributes = [
                NSUnderlineStyleAttributeName : NSUnderlineStyle.styleThick.rawValue
            ]
            if nextFocusView.tag == 100 {
                let attributedString = NSAttributedString(string: termsOfUseLabel.text!, attributes: attributes)
                termsOfUseLabel.attributedText = attributedString
                privacyPolicyLabel.text = privacyPolicyLabel.text
                restorePurchaseLabel.text = restorePurchaseLabel.text
            }
            else if nextFocusView.tag == 101 {
                let attributedString = NSAttributedString(string: privacyPolicyLabel.text!, attributes: attributes)
                privacyPolicyLabel.attributedText = attributedString
                termsOfUseLabel.text = termsOfUseLabel.text
                restorePurchaseLabel.text = restorePurchaseLabel.text
            }
            else if nextFocusView.tag == 102 {
                let attributedString = NSAttributedString(string: restorePurchaseLabel.text!, attributes: attributes)
                restorePurchaseLabel.attributedText = attributedString
                termsOfUseLabel.text = termsOfUseLabel.text
                privacyPolicyLabel.text = privacyPolicyLabel.text
            }
        }
        if let previousFocusedView = context.previouslyFocusedView as? UIButton {
            let attributes = [
                NSUnderlineStyleAttributeName : NSUnderlineStyle.styleNone.rawValue
            ]
            if previousFocusedView.tag == 102 {
                let attributedString = NSAttributedString(string: self.restorePurchaseLabel.text!, attributes: attributes)
                self.restorePurchaseLabel.attributedText = attributedString
            } else if previousFocusedView.tag == 100 {
                let attributedString = NSAttributedString(string: self.termsOfUseLabel.text!, attributes: attributes)
                self.termsOfUseLabel.attributedText = attributedString
            } else if previousFocusedView.tag == 101 {
                let attributedString = NSAttributedString(string: self.privacyPolicyLabel.text!, attributes: attributes)
                self.privacyPolicyLabel.attributedText = attributedString
            }
        }
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        if self.delegate != nil {
            if (delegate?.responds(to: #selector(SFPlanAdditionalTextCellDelegate.addtionalTextCellButtonClicked(button:))))! {
                delegate?.addtionalTextCellButtonClicked!(button: sender)
            }
        }
    }
}
