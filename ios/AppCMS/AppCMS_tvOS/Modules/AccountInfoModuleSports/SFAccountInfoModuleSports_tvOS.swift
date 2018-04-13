//
//  SFAccountInfoModuleSports_tvOS.swift
//  AppCMS_tvOS
//
//  Created by Anirudh Vyas on 22/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//  TODO: Currently showing as a hard-coded. To be upgraded to json based. Use: Account_Sports_AppleTV.json

import UIKit

class SFAccountInfoModuleSports_tvOS: BaseViewController {

    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var prefixLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let backgroundColor = AppConfiguration.sharedAppConfiguration.backgroundColor{
            self.view.backgroundColor = Utility.hexStringToUIColor(hex: backgroundColor)
        }
        else {
            if AppConfiguration.sharedAppConfiguration.appTheme == .light{
                self.view.backgroundColor = .white
            }
            else{
                self.view.backgroundColor = .black
            }
        }
        var viewStartY: CGFloat = 0
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            let topBar = UIView(frame: CGRect(x: 0, y: 0, width: (self.view.bounds.size.width), height: 10))
            topBar.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "#000000")
            self.view.addSubview(topBar)
            self.view.bringSubview(toFront: topBar)
            let isSubscribed = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool ?? false)
            if isSubscribed == false && (AppConfiguration.sharedAppConfiguration.pageHeaderObject?.buttonPrefixText != nil && AppConfiguration.sharedAppConfiguration.pageHeaderObject?.buttonPrefixText != ""){
                let startingY = 10
                let topBannerView = UINib(nibName: "TopBannerSubscriptionModule", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TopBannerSubscriptionModule
                topBannerView.frame = CGRect(x: 0, y: startingY, width: Int(topBannerView.bounds.size.width), height: 55)
                topBannerView.constructView()
                self.view.addSubview(topBannerView)
                self.view.bringSubview(toFront: topBannerView)
                viewStartY = CGFloat(55 + startingY)
            }
        }
        pageTitleLabel.changeFrameYAxis(yAxis: pageTitleLabel.frame.origin.y + viewStartY)
        prefixLabel.changeFrameYAxis(yAxis: prefixLabel.frame.origin.y + viewStartY)
        emailLabel.changeFrameYAxis(yAxis: emailLabel.frame.origin.y + viewStartY)
        pageTitleLabel.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff")
        prefixLabel.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff")
        emailLabel.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff")
        fetchUserDetails()
    }
    
    private func fetchUserDetails() {
        self.showActivityIndicator()
        let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/user?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        DispatchQueue.global(qos: .userInitiated).async {
            DataManger.sharedInstance.fetchUserPageDetails(apiEndPoint: apiRequest) {  [weak self] (userResult, isSuccess) in
                guard let checkedSelf = self else {
                    return
                }
                checkedSelf.hideActivityIndicator()
                if userResult != nil && isSuccess {
                    checkedSelf.emailLabel.text = userResult?.emailID
                }
            }
        }
    }

}
