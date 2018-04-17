//
//  JumbotronModuleParser.swift
//  SwiftPOCConfiguration
//
//  Created by Abhinav Saldi on 10/03/17.
//
//

import Foundation

class JumbotronModuleParser: NSObject {
    
    func parseJumbotronJson(jumbotronDictionary: Dictionary<String, AnyObject>) -> JumbotronViewObject
    {
        let jumbotronObject = JumbotronViewObject()
        
        jumbotronObject.pageControlType = .PageControlTypeCircular
        jumbotronObject.carouselType = .CarouselTypeLinear
        jumbotronObject.carouselSpacing = 1
        jumbotronObject.carouselHeightiPadLandscape = 300
        jumbotronObject.carouselHeightiPadPortrait = 400
        jumbotronObject.carouselHeightiPhone = 300
        jumbotronObject.carouselPlaceHolderImagePath = ""
        jumbotronObject.animationDuration = 3
        jumbotronObject.carouselWidthiPadLandscape = Float(UIScreen.main.bounds.width)
        jumbotronObject.carouselWidthiPadPortrait = Float(UIScreen.main.bounds.width)
        jumbotronObject.carouselWidthiPhone = Float(UIScreen.main.bounds.width)
        jumbotronObject.carouselXAxis = 0
        jumbotronObject.carouselYAxis = 0
        jumbotronObject.currentPageIndicatorImagePath = ""
        jumbotronObject.isCarouselWrapped = true
        jumbotronObject.jumbotronContainerHeightiPadLandscape = 340
        jumbotronObject.jumbotronContainerHeightiPadPortrait = 440
        jumbotronObject.jumbotronContainerHeightiPhone = 330
        jumbotronObject.pageControlAlignmentType = .PageControlAlignmentCenter
        jumbotronObject.pageControlHeightiPadLandscape = 10
        jumbotronObject.pageControlHeightiPadPortrait = 10
        jumbotronObject.pageControlHeightiPhone = 10
        jumbotronObject.pageControlVerticalAlignmentType = .PageControlVerticalAlignmentMiddle
        jumbotronObject.pageControlXAxis = 0.0
        jumbotronObject.pageControlYAxisiPadLandscape = 0.0
        jumbotronObject.pageControlYAxisiPadPortrait = 0.0
        jumbotronObject.pageControlYAxisiPhone = 0.0
        jumbotronObject.pageIndicatorImagePath = ""
        
        jumbotronObject.jumbotronModuleId = jumbotronDictionary["id"] as? String
        
        return jumbotronObject
    }
    
}
