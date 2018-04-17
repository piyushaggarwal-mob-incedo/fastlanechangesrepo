//
//  CarousalViewController.swift
//  SwiftPOC
//
//  Created by Gaurav Vig on 07/03/17.
//  Copyright © 2017 Gaurav Vig. All rights reserved.
//

import UIKit

@objc protocol CarouselViewControllerDelegate:NSObjectProtocol {

    @objc func didSelectVideo(gridObject: SFGridObject?) -> Void
    @objc func didCarouselButtonClicked(contentId:String?, buttonAction:String, gridObject:SFGridObject) -> Void
}

class CarousalViewController: UIViewController,CarouselViewDelegate {
    
    var carouselContainerView:CarouselView!
    var isCarouselHidden:Bool = true
    var carouselContainerViewHeight:CGFloat = 0
    var viewControllerPage: Page?
    var pageModuleObject: SFModuleObject?
    var delegate:CarouselViewControllerDelegate?
    var carouselObject:SFJumbotronObject?
    var relativeViewFrame:CGRect?
    #if os(tvOS)
    var carouselItemFrame:CGRect?
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createSubViews() -> Void {
        
        self.view.backgroundColor = UIColor.clear

        if carouselObject != nil && pageModuleObject != nil {
            
            if pageModuleObject?.moduleData != nil {
                
                createCarouselView()
            }
        }
    }
    
    func createCarouselView() {

        carouselContainerViewHeight = (relativeViewFrame?.height)!
        
        carouselContainerView = CarouselView(frame: relativeViewFrame!)
        carouselContainerView.carouselObject = carouselObject
        
        if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
            
            carouselContainerView.isDeviceOrientationLandscape = true
        }

        self.view.addSubview(carouselContainerView)
        carouselContainerView.moduleObject = pageModuleObject
        carouselContainerView.isPageControlEnabled = true
        carouselContainerView.carouselViewDelegate = self
        carouselContainerView.relativeViewFrame = carouselContainerView.frame
        carouselContainerView.initaliseJumbotronView()
    }
    
    #if os(iOS)

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    
        if !Constants.IPHONE {
            
            if carouselObject != nil && pageModuleObject != nil {
 
                let carouselLayout = Utility.fetchCarouselLayoutDetails(carouselViewObject: self.carouselObject!)
                relativeViewFrame?.size = CGSize(width: UIScreen.main.bounds.size.width, height: CGFloat(carouselLayout.height!) * Utility.getBaseScreenHeightMultiplier())
                carouselContainerView.relativeViewFrame = relativeViewFrame!
                carouselContainerViewHeight = (relativeViewFrame?.height)!
                updateCarouselFrameOnOrientation()
            }
        }
    }
    
    #endif

    
    func updateCarouselFrameOnOrientation() {
        
        carouselContainerView.stopJumbotronAnimation()
        carouselContainerView.changeFrameHeight(height: carouselContainerViewHeight)
        carouselContainerView.changeFrameWidth(width: (relativeViewFrame?.size.width)!)
        carouselContainerView.carouselWidth = (relativeViewFrame?.size.width)!
        carouselContainerView.jumbotronView.removeFromSuperview()
        carouselContainerView.jumbotronView = nil
        carouselContainerView.updatePageControlFrame()
        carouselContainerView.createCarsouselView()
        
        if carouselContainerView.pageControl != nil {
            
            carouselContainerView.bringSubview(toFront: carouselContainerView.pageControl!)
        }
    }
    
    //MARK: CarouselView Delegate
    func didSelectVideo(gridObject:SFGridObject?) {
        
        if delegate != nil && (delegate?.responds(to: #selector(CarouselViewControllerDelegate.didSelectVideo(gridObject:))))! {
            
            self.delegate?.didSelectVideo(gridObject: gridObject)
        }
    }
    
    func didCarouselButtonClicked(contentId: String?, action: String, gridObject: SFGridObject) {
        
        if delegate != nil && (delegate?.responds(to: #selector(CarouselViewControllerDelegate.didCarouselButtonClicked(contentId:buttonAction:gridObject:))))! {
            
            self.delegate?.didCarouselButtonClicked(contentId: contentId, buttonAction: action, gridObject:gridObject)
        }
    }
    
    #if os(tvOS)
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if(presses.first?.type == UIPressType.menu) {
            super.pressesBegan(presses, with: event)
        }
    }
    #endif
}


