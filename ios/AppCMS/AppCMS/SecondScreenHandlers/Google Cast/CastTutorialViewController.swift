//
//  CastTutorialViewController.swift
//  AppCMS
//
//  Created by Rajni Pathak on 08/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import Firebase


@objc protocol tutorialEventsDelegate:NSObjectProtocol {
    
    @objc optional func chromeCastButtonClicked()
    
}

class CastTutorialViewController: UIViewController{
    weak var delegate:tutorialEventsDelegate?
    @IBOutlet weak var chromeCastButton: UIButton?
    @IBOutlet weak var skipButton: UIButton?
    @IBOutlet weak var tutorialBackgroundImage: UIImageView?
    
    @IBOutlet weak var trailingLayoutConstraints: NSLayoutConstraint!
    @IBOutlet weak var topLayoutContstraints: NSLayoutConstraint!
    required init?(coder aDecoder: NSCoder) {
        print("init coder style")
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        print("init nibName style")
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tutorialBackgroundImage?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        let firstTimeKey = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kFirstTimeUserKey) as? String
        if (firstTimeKey == nil || firstTimeKey != "1") {
           Constants.kSTANDARDUSERDEFAULTS.set("1", forKey: Constants.kFirstTimeUserKey)
        }
     
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
//            FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [kFIRParameterItemName: "Touch To Cast Overlay Screen"])
            FIRAnalytics.setScreenName("Touch To Cast Overlay Screen", screenClass: nil)
        }
        
        if #available(iOS 11.0, *) {
            if (Constants.IPHONE && Utility.sharedUtility.isDeviceIphoneX){
               self.topLayoutContstraints.constant = (20 + (UIApplication.shared.keyWindow?.safeAreaInsets.top)!) / 2
               self.trailingLayoutConstraints.constant = -5
            }
            else{
                self.topLayoutContstraints.constant = 7
                
                if Constants.IPHONE {
                    
                    if Utility.getBaseScreenWidthMultiplier() > 1 {
                        
                        self.trailingLayoutConstraints.constant = -4 - (-4 * Utility.getBaseScreenWidthMultiplier())
                    }
                    else {
                        
                        self.trailingLayoutConstraints.constant = (-4 * Utility.getBaseScreenWidthMultiplier())
                    }
                }
                else {
                    
                    self.trailingLayoutConstraints.constant = 0
                }
            }
        }
        else {
            
            self.topLayoutContstraints.constant = 7
            
            if Constants.IPHONE {
                
                if Utility.getBaseScreenWidthMultiplier() > 1 {
                    
                    self.trailingLayoutConstraints.constant = -15
                }
                else {
                    
                    self.trailingLayoutConstraints.constant = -19
                }
            }
            else {
                
                self.trailingLayoutConstraints.constant = -15
            }
        }
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.allowIDFACollection = true
        
        tracker.set(kGAIScreenName, value: "Touch To Cast Overlay Screen")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    @IBAction func skipTapped(sender: UIButton) {
        self.view.removeFromSuperview()
    }
    
    
    @IBAction func chromeCastButtonTapped(sender: UIButton) {
         self.view.removeFromSuperview()
        if delegate != nil && (delegate?.responds(to: #selector(tutorialEventsDelegate.chromeCastButtonClicked)))! {
            delegate?.chromeCastButtonClicked!()
        }
    }
    
    
}
