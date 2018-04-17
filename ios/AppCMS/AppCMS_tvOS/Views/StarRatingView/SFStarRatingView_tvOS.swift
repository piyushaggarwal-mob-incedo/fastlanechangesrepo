//
//  SFStarRatingView.swift
//  AppCMS
//
//  Created by Rajni Pathak on 01/12/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import Cosmos

class SFStarRatingView: UIView {
   
    
    var starView:CosmosView?
    var relativeViewFrame:CGRect?
    
    func initialiseStarRatingFrameFromLayout(ratingLayout:LayoutObject) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: ratingLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    func updateView(userRating: Double, startSize: Double?, margin: Double?) -> Void {
        if starView == nil{
            starView = CosmosView.init(frame: self.bounds)
            starView?.settings.emptyColor = UIColor.clear
            starView?.settings.filledBorderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff")
            starView?.settings.filledColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff")
            starView?.settings.emptyBorderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff")
            starView?.settings.totalStars = 5
            starView?.settings.starSize = startSize ??  35
            starView?.settings.starMargin = margin ?? 2
            starView?.settings.fillMode = StarFillMode(rawValue: 2)!
            starView?.settings.emptyBorderWidth = 1.0
            starView?.isUserInteractionEnabled = false
            self.addSubview(starView!)
        }
        starView?.rating = userRating
    }
 
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
