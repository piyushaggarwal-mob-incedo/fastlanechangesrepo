//
//  SFCarouselItemView.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 04/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFCarouselItemView: UIView {
    
    
    var carouselItemObject:SFCarouselItemObject?
    var relativeViewFrame:CGRect?
    
    func initialiseCarouselItemViewFrameFromLayout(carouselItemLayout:LayoutObject) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: carouselItemLayout, relativeViewFrame: relativeViewFrame!)
        self.backgroundColor =  Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        //Extend if background color is added.
    }
}
