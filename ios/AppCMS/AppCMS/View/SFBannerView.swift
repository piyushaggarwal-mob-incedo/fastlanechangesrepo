//
//  SFBannerView.swift
//  AppCMS
//
//  Created by Gaurav Vig on 15/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol SFBannerViewDelegate:NSObjectProtocol {
    @objc optional func displayMorePopUpView(button:UIButton, gridOptionsArray:Array<SFLinkObject>) -> Void
}

class SFBannerView: UIView, SFButtonDelegate {

    var bannerViewObject:SFBannerViewObject?
    weak var bannerViewDelegate:SFBannerViewDelegate?
    
    //MARK: Method to create sub views
    func createSubView() {
        
        if bannerViewObject != nil {
            
            if bannerViewObject?.bannerViewComponents != nil {
                
                for component in (bannerViewObject?.bannerViewComponents)! {
                    
                    if component is SFLabelObject {
                        
                        createLabelView(labelObject: component as! SFLabelObject)
                    }
                    else if component is SFImageObject {
                        
                        createImageView(imageViewObject: component as! SFImageObject)
                    }
                    else if component is SFButtonObject {
                        
                        createButtonView(buttonObject: component as! SFButtonObject)
                    }
                }
            }
        }
    }
    
    
    //MARK: Method to create label view
    private func createLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = self.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.createLabelView()
        
        if labelObject.key == "bannerTitle" {
            
            label.text = bannerViewObject?.bannerTitle
            label.textColor = Utility.hexStringToUIColor(hex: bannerViewObject?.bannerTitleTextColor ?? AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        }
        
        self.addSubview(label)
    }
    
    
    //MARK: Method to create button view
    private func createButtonView(buttonObject:SFButtonObject) {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        
        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.buttonLayout = buttonLayout
        button.relativeViewFrame = self.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.buttonDelegate = self
        button.createButtonView()
        
        if buttonObject.key == "gridOptions" {
            
            let optionButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "gridOptions.png"))
            
            button.setImage(optionButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")

        }
        
        self.addSubview(button)
    }
    
    
    //MARK: Method to create image view
    private func createImageView(imageViewObject:SFImageObject) {
        
        let imageView:SFImageView = SFImageView()
        imageView.imageViewObject = imageViewObject
        imageView.relativeViewFrame = self.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageViewObject))
        imageView.updateView()
        
        if imageViewObject.key == "bannerImage" {
            
            var imagePathString:String? = bannerViewObject?.bannerImage
            
            if imagePathString != nil {
                
                imagePathString = imagePathString?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: imageView.frame.size.width))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: imageView.frame.size.height))")

                if let imageUrl = URL(string: imagePathString!) {
                    
                    imageView.af_setImage(
                        withURL: imageUrl,
                        placeholderImage: nil,
                        filter: nil,
                        imageTransition: .crossDissolve(0.2)
                    )
                }
            }
        }
        
        self.addSubview(imageView)
    }
    
    
    //MARK: Update Sub view frames on orientation change
    func updateSubViewFrames() {
        
        for subView in self.subviews {
            
            if subView is SFLabel {
                
                updateLabelFrame(label: subView as! SFLabel)
            }
            else if subView is SFImageView {
                
                updateImageViewFrame(imageView: subView as! SFImageView)
            }
            else if subView is SFButton {
                
                updateButtonViewFrame(button: subView as! SFButton)
            }
        }
    }
    
    
    //MARK: Update Label frame
    private func updateLabelFrame(label:SFLabel) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!)
        label.labelLayout = labelLayout
        label.relativeViewFrame = self.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
    }
    
    
    //MARK: Update Image view frame
    private func updateImageViewFrame(imageView:SFImageView) {
        
        imageView.relativeViewFrame = self.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageView.imageViewObject!))
    }
    
    
    //MARK: Update Button view frame
    private func updateButtonViewFrame(button:SFButton) {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: button.buttonObject!)
        
        button.relativeViewFrame = self.frame
        button.buttonLayout = buttonLayout
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
    }
    
    
    //MARK: Button Delegates
    func buttonClicked(button: SFButton) {
        
        if bannerViewObject != nil {
            
            if (bannerViewDelegate?.responds(to: #selector(SFBannerViewDelegate.displayMorePopUpView(button:gridOptionsArray:))))! {
                
                bannerViewDelegate?.displayMorePopUpView!(button: button, gridOptionsArray: (bannerViewObject?.bannerGridOptions)!)
            }
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
