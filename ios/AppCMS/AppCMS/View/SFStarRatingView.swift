//
//  SFStarRatingView.swift
//  AppCMS
//
//  Created by Gaurav Vig on 28/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import Cosmos

class SFStarRatingView: UIView {
   
    
    var starRatingObject:SFStarRatingObject?
    var relativeViewFrame:CGRect?
    
    func initialiseStarRatingFrameFromLayout(ratingLayout:LayoutObject) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: ratingLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    func updateView(userRating: Double) -> Void {
        
        let starView: CosmosView = CosmosView.init(frame: self.bounds)
        starView.settings.emptyColor = UIColor.clear
        
        starView.settings.filledBorderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff")
        starView.settings.filledColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff")
        starView.settings.emptyBorderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff")
        
        starView.settings.totalStars = 5
        starView.rating = userRating
        starView.settings.starMargin = 1.5
        starView.settings.fillMode = StarFillMode(rawValue: 2)!
        starView.settings.emptyBorderWidth = 1.0
        starView.isUserInteractionEnabled = false
        self.addSubview(starView)
    }
 
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
