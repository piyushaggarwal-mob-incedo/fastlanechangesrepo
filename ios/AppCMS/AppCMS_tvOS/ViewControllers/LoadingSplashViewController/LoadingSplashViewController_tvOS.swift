//
//  LoadingSplashViewController_tvOS.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 21/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class LoadingSplashViewController_tvOS: UIViewController {

    @IBOutlet weak var appLogoImageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            if let backgroundImage = UIImage(named: "splash.png") {
                self.view.backgroundColor = UIColor(patternImage: backgroundImage)
            }
            appLogoImageView.isHidden = true
        } else {
            if let backgroundImage = UIImage(named: "splashBackground.png") {
                self.view.backgroundColor = UIColor(patternImage: backgroundImage)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func triggerAnimation(completionHandler : @escaping (() -> Void)) {
        
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment {
            UIView.animate(withDuration: 0.8, delay: 1, options: UIViewAnimationOptions.curveLinear, animations: {
                self.appLogoImageView?.frame = CGRect(x: self.view.bounds.size.width - 220, y: self.view.bounds.size.height - 120, width: 249, height: 140)
                self.appLogoImageView?.alpha = 0.0
            }, completion: { (done) in
                completionHandler()
            })
        } else {
            completionHandler()
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
