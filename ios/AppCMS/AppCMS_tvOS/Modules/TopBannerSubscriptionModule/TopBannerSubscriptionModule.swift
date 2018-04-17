//
//  TopBannerSubscriptionModule.swift
//  AppCMS_tvOS
//
//  Created by Anirudh Vyas on 17/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class TopBannerSubscriptionModule: UIView {
    
    @IBOutlet weak var highlighterView: UIView!
    @IBOutlet weak var watchNowLabel: UILabel?
    @IBOutlet weak var startFreeTrialButton: UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func constructView() {
        self.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "")
        watchNowLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "")
        startFreeTrialButton?.titleLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "")
        var stringForBanner = ""
        if let buttonPrefixText = AppConfiguration.sharedAppConfiguration.pageHeaderObject?.buttonPrefixText {
            stringForBanner.append(buttonPrefixText)
        }
        if let buttonText = AppConfiguration.sharedAppConfiguration.pageHeaderObject?.buttonText {
            stringForBanner.append(buttonText)
        }
        watchNowLabel?.text = stringForBanner
    }
    
    override func draw(_ rect: CGRect) {
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TopBannerSubscriptionModule.subscribeNowButtonClicked))
        self.addGestureRecognizer(tapRecognizer)
        
//        let backgroundFocusGuide : UIFocusGuide = UIFocusGuide()
//        self.addLayoutGuide(backgroundFocusGuide)
//        backgroundFocusGuide.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        backgroundFocusGuide.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        backgroundFocusGuide.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        backgroundFocusGuide.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
//        backgroundFocusGuide.preferredFocusedView = startFreeTrialButton
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if context.nextFocusedView == self {
            highlighterView.isHidden = false
        }
        if context.previouslyFocusedView == self {
            highlighterView.isHidden = true
        }
    }
    
    func subscribeNowButtonClicked() {
        print("gesture clicked.")
    }
    
    @IBAction func startFreeTrialClicked(_ sender: UIButton) {
        print("Button clicked.")
    }
    
    override var canBecomeFocused: Bool {
        return false
    }
}
