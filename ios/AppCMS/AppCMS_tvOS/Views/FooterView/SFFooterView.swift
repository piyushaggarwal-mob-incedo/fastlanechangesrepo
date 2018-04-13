//
//  SFFooterView.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 21/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFFooterView: UIView {
    
    //
    var viewObject:SFFooterViewObject?
    var viewlayout:LayoutObject?
    var relativeViewFrame:CGRect?
    
    func initialiseFooterViewFrameFromLayout(footerViewLayout:LayoutObject) {
        self.viewlayout = footerViewLayout
        self.frame = Utility.initialiseViewLayout(viewLayout: footerViewLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    func createFooterView() {
        
        for components in (viewObject?.components)! {
            
            if components is SFImageObject {
                
                createImageView(imageObject: components as! SFImageObject)
            }
        }
    }
    
    func createImageView(imageObject:SFImageObject) {
        
        let imageView:SFImageView = SFImageView()
        imageView.imageViewObject = imageObject
        imageView.relativeViewFrame = self.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
        imageView.updateView()
        if imageObject.key  == "footerLogoImage" {
            imageView.image = UIImage(named: "appLogo")
            self.addSubview(imageView)
            self.bringSubview(toFront: imageView)
            imageView.contentMode = .left
        }
        if imageObject.key  == "footerBackgroundImage" {
            imageView.image = UIImage(named: "footerGradientImage")
            self.addSubview(imageView)
            self.sendSubview(toBack: imageView)
        }
    }
    
    //Hard coded footer view elements.
    private var gradientImageView : UIImageView?
    private var logoImageView : UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    //TODO: Create module and update the implementation.
    private func configureView () {
        
        if gradientImageView == nil {
            gradientImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: bounds.size.width, height: 200))
            gradientImageView?.image = UIImage(named: "footerGradientImage")
            addSubview(gradientImageView!)
        }
        if logoImageView == nil{
            logoImageView = UIImageView(frame:CGRect(x: bounds.size.width - (44 + 249), y: bounds.size.height - (22 + 70), width: 249, height: 70))
            logoImageView?.image = UIImage(named: "appLogo")
            logoImageView?.contentMode = .left
            addSubview(logoImageView!)
        }
    }
}
