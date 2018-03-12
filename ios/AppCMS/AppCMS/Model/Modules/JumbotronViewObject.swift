//
//  JumbotronViewObject.swift
//  SwiftPOC
//
//  Created by Gaurav Vig on 09/03/17.
//  Copyright © 2017 Gaurav Vig. All rights reserved.
//

import Foundation

class JumbotronViewObject: NSObject {
    
    enum PageControlType {
        case PageControlTypeNone
        case PageControlTypeRectangle
        case PageControlTypeCircular
    }
    
    enum PageControlAlignment {
        case PageControlAlignmentCenter
        case PageControlAlignmentLeft
        case PageControlAlignmentRight
    }
    
    enum PageControlVerticalAlignment {
        case PageControlVerticalAlignmentTop
        case PageControlVerticalAlignmentMiddle
        case PageControlVerticalAlignmentBottom
    }
    
    enum CarouselType {
        case CarouselTypeLinear
        case CarouselTypeCoverflow
    }
    
    var carouselXAxis:Float
    var carouselYAxis:Float
    var carouselWidthiPhone:Float
    var carouselHeightiPhone:Float
    var carouselWidthiPadLandscape:Float
    var carouselHeightiPadLandscape:Float
    var carouselWidthiPadPortrait:Float
    var carouselHeightiPadPortrait:Float
    var pageControlType:PageControlType
    var carouselType:CarouselType
    var pageControlHeightiPhone:Int
    var pageControlHeightiPadLandscape:Int
    var pageControlHeightiPadPortrait:Int
    var pageControlAlignmentType:PageControlAlignment
    var animationDuration:Int
    var carouselPlaceHolderImagePath:NSString?
    var carouselSpacing:Float
    var isCarouselWrapped:Bool
    var pageControlVerticalAlignmentType:PageControlVerticalAlignment
    var currentPageIndicatorImagePath:NSString?
    var pageIndicatorImagePath:NSString?
    var pageControlYAxisiPhone:Float
    var pageControlYAxisiPadLandscape:Float
    var pageControlYAxisiPadPortrait:Float
    var pageControlXAxis:Float
    var jumbotronContainerHeightiPhone:Float
    var jumbotronContainerHeightiPadLandscape:Float
    var jumbotronContainerHeightiPadPortrait:Float
    var jumbotronModuleId:String?

    //MARK: Settings Default Values
    override init () {
        
        carouselXAxis = 0.0
        carouselYAxis = 0.0
        carouselWidthiPhone = 0.0
        carouselHeightiPhone = 0.0
        carouselWidthiPadLandscape = 0.0
        carouselHeightiPadLandscape = 0.0
        carouselWidthiPadPortrait = 0.0
        carouselHeightiPadPortrait = 0.0
        pageControlType = PageControlType.PageControlTypeNone
        carouselType = CarouselType.CarouselTypeLinear
        pageControlHeightiPhone = 0
        pageControlHeightiPadLandscape = 0
        pageControlHeightiPadPortrait = 0
        pageControlAlignmentType = PageControlAlignment.PageControlAlignmentCenter
        animationDuration = 0
        carouselSpacing = 1.0
        isCarouselWrapped = false
        pageControlVerticalAlignmentType = PageControlVerticalAlignment.PageControlVerticalAlignmentMiddle
        pageControlYAxisiPhone = 0
        pageControlYAxisiPadLandscape = 0
        pageControlYAxisiPadPortrait = 0
        pageControlXAxis = 0
        jumbotronContainerHeightiPhone = 0
        jumbotronContainerHeightiPadPortrait = 0
        jumbotronContainerHeightiPadLandscape = 0
    }
    
    //MARK: Initialising Values
    func initaliseJumbotronObject(carouselXAxis:Float, carouselYAxis:Float , carouselWidthiPhone:Float, carouselHeightiPhone:Float, carouselWidthiPadLandscape:Float, carouselHeightiPadLandscape:Float, carouselWidthiPadPortrait:Float, carouselHeightiPadPortrait:Float, pageControlHeightiPhone:Int, pageControlHeightiPadPortrait:Int,pageControlHeightiPadLandscape:Int, animationDuration:Int, carouselSpacing:Float, isCarouselWrapped:Bool, carouselType:CarouselType, pageControlAlignmentType:PageControlAlignment, pageControlType:PageControlType, pageControlVerticalAlignmentType:PageControlVerticalAlignment, currentPageIndicatorImagePath:NSString, pageIndicatorImagePath:NSString, pageControlYAxisiPhone:Float, pageControlYAxisiPadLandscape:Float,pageControlYAxisiPadPortrait:Float, pageControlXAxis:Float, jumbotronContainerHeightiPhone:Float, jumbotronContainerHeightiPadPortrait:Float,  jumbotronContainerHeightiPadLandscape:Float) -> Void {
        
        self.carouselXAxis                          = carouselXAxis
        self.carouselYAxis                          = carouselYAxis
        self.carouselWidthiPhone                    = carouselWidthiPhone
        self.carouselHeightiPhone                   = carouselHeightiPhone
        self.carouselWidthiPadPortrait              = carouselWidthiPadPortrait
        self.carouselHeightiPadPortrait             = carouselHeightiPadPortrait
        self.carouselWidthiPadLandscape             = carouselWidthiPadLandscape
        self.carouselHeightiPadLandscape            = carouselHeightiPadLandscape
        self.pageControlHeightiPhone                = pageControlHeightiPhone
        self.pageControlHeightiPadLandscape         = pageControlHeightiPadLandscape
        self.pageControlHeightiPadPortrait          = pageControlHeightiPadPortrait
        self.animationDuration                      = animationDuration
        self.isCarouselWrapped                      = isCarouselWrapped
        self.carouselSpacing                        = carouselSpacing
        self.carouselType                           = carouselType
        self.pageControlType                        = pageControlType
        self.pageControlAlignmentType               = pageControlAlignmentType
        self.pageControlVerticalAlignmentType       = pageControlVerticalAlignmentType
        self.pageIndicatorImagePath                 = pageIndicatorImagePath
        self.currentPageIndicatorImagePath          = currentPageIndicatorImagePath
        self.jumbotronContainerHeightiPadLandscape  = jumbotronContainerHeightiPadLandscape
        self.jumbotronContainerHeightiPadPortrait   = jumbotronContainerHeightiPadPortrait
        self.jumbotronContainerHeightiPhone         = jumbotronContainerHeightiPhone
    }
}
