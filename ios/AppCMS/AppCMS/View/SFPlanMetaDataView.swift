//
//  SFPlanMetaDataView.swift
//  AppCMS
//
//  Created by Gaurav Vig on 12/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFPlanMetaDataView: UIView {

    var subscriptionPlanMetaDataArray:Array<SubscriptionPlanMetaData> = []
    var scrollView:UIScrollView?
    var yAxis:Float = 0
    var maxYAxis:Float = 0
    let labelPadding:Float = 10
    var relativeViewFrame:CGRect?
    var planMetaDataViewObject:SFPlanMetaDataViewObject?
    
    
    init() {
        
        super.init(frame: .zero)
        scrollView = UIScrollView()
        self.addSubview(scrollView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initialiseMetaDataViewFrameFromLayout(metaDataViewLayout:LayoutObject) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: metaDataViewLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    func createMetaDataView() {
    
        scrollView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        scrollView?.backgroundColor = UIColor.clear

        for subscriptionPlanMetaData in subscriptionPlanMetaDataArray {
            
            createMetaDataSubViewComponents(subscriptionPlanMetadataObject: subscriptionPlanMetaData)
            
            yAxis = maxYAxis + labelPadding
        }
        
        if yAxis <= Float(self.frame.size.height) {
            
            scrollView?.isScrollEnabled = false
        }
        else {
            
            scrollView?.isScrollEnabled = true
        }
        
        scrollView?.contentSize = CGSize(width: self.frame.size.width, height: (CGFloat(yAxis) > self.frame.size.height ? CGFloat(yAxis) : self.frame.size.height))
    }
    
    
    func createMetaDataSubViewComponents(subscriptionPlanMetadataObject:SubscriptionPlanMetaData) {
        
        if planMetaDataViewObject != nil {
            
            for module in (planMetaDataViewObject?.components)! {
                
                if module is SFLabelObject {
                    
                    createLabelView(labelObject: module as! SFLabelObject, subscriptionPlanMetadataObject: subscriptionPlanMetadataObject)
                }
                else if module is SFImageObject {
                    
                    createImageView(imageViewObject: module as! SFImageObject, subscriptionPlanMetadataObject: subscriptionPlanMetadataObject)
                }
            }
        }
    }
    
    
    func createLabelView(labelObject:SFLabelObject, subscriptionPlanMetadataObject:SubscriptionPlanMetaData) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)

        if labelObject.key == "planMetaDataTitle" && subscriptionPlanMetadataObject.metaDataTitle != nil {
            
            let label = SFLabel()
            label.relativeViewFrame = scrollView?.frame
            label.labelObject = labelObject
            label.text = subscriptionPlanMetadataObject.metaDataTitle
            label.labelLayout = labelLayout
            label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            label.createLabelView()
            label.numberOfLines = 0
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            scrollView?.addSubview(label)
            
            label.font = UIFont(name: (label.font.fontName), size: (label.font.pointSize) * Utility.getBaseScreenHeightMultiplier())
            
            label.changeFrameHeight(height: (label.frame.size.height) * Utility.getBaseScreenHeightMultiplier())
            label.changeFrameWidth(width: (label.frame.size.width) * Utility.getBaseScreenWidthMultiplier())
            label.changeFrameYAxis(yAxis: CGFloat(yAxis))
            label.sizeToFit()
            maxYAxis = Float(label.frame.maxY)
        }
        else if labelObject.key == "planMetaDataDeviceCount" && subscriptionPlanMetadataObject.deviceCount != nil {
            
            let label = SFLabel()
            label.relativeViewFrame = scrollView?.frame
            label.labelObject = labelObject
            label.text = "\(subscriptionPlanMetadataObject.deviceCount ?? "")"
            label.labelLayout = labelLayout
            label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            label.createLabelView()
            
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff")
            
            label.font = UIFont(name: (label.font.fontName), size: (label.font.pointSize) * Utility.getBaseScreenHeightMultiplier())
            
            label.changeFrameHeight(height: (label.frame.size.height) * Utility.getBaseScreenHeightMultiplier())
            label.changeFrameWidth(width: (label.frame.size.width) * Utility.getBaseScreenWidthMultiplier())
            label.changeFrameYAxis(yAxis: CGFloat(yAxis))
            label.changeFrameXAxis(xAxis: (label.frame.origin.x) * Utility.getBaseScreenHeightMultiplier())
            
            scrollView?.addSubview(label)
        }
    }
    
    
    func createImageView(imageViewObject:SFImageObject, subscriptionPlanMetadataObject:SubscriptionPlanMetaData) {
        
        let imageLayout = Utility.fetchImageLayoutDetails(imageObject: imageViewObject)
        
        if imageViewObject.key == "planMetaDataImage" && subscriptionPlanMetadataObject.isCheckMarkVisible != nil {
            
            let imageView = SFImageView()
            imageView.relativeViewFrame = scrollView?.frame
            imageView.imageViewObject = imageViewObject
            imageView.initialiseImageViewFrameFromLayout(imageLayout: imageLayout)
                        
            scrollView?.addSubview(imageView)
            
            imageView.changeFrameHeight(height: (imageView.frame.size.height) * Utility.getBaseScreenHeightMultiplier())
            imageView.changeFrameWidth(width: (imageView.frame.size.width) * Utility.getBaseScreenWidthMultiplier())
            imageView.changeFrameYAxis(yAxis: CGFloat(yAxis))
            imageView.changeFrameXAxis(xAxis: (imageView.frame.origin.x) * Utility.getBaseScreenHeightMultiplier())
            
            if subscriptionPlanMetadataObject.isCheckMarkVisible != nil {
                
                if subscriptionPlanMetadataObject.isCheckMarkVisible! {
                    
                    imageView.image = UIImage(named: "tickIcon")
                }
                else {
                    
                    imageView.image = UIImage(named: "crossIcon")
                }
            }
            else if subscriptionPlanMetadataObject.metaDataImageUrl != nil {
                
                var imageURLString = subscriptionPlanMetadataObject.metaDataImageUrl!
                imageURLString = imageURLString.trimmingCharacters(in: .whitespaces)
                
                guard let imageURL:URL = URL(string: imageURLString) else { return }
                
                imageView.af_setImage(
                    withURL: imageURL,
                    placeholderImage: nil,
                    filter: nil,
                    imageTransition: .crossDissolve(0.2)
                )
            }
            
        }
    }
    
    
    func updateMetaDataSubViewContent(subscriptionPlanMetadataObject:SubscriptionPlanMetaData) {
        
        for subView in (self.scrollView?.subviews)! {
            
            if subView is SFLabel {
                
                updateLabel(label: subView as! SFLabel, subscriptionPlanMetadataObject: subscriptionPlanMetadataObject)
            }
            else if subView is SFImageView {
                
                updateImageView(imageView: subView as! SFImageView, subscriptionPlanMetadataObject: subscriptionPlanMetadataObject)
            }
        }
    }
    
    
    func updateLabel(label:SFLabel, subscriptionPlanMetadataObject:SubscriptionPlanMetaData) {
        
        if label.labelObject?.key == "planMetaDataTitle" {
            
            label.text = subscriptionPlanMetadataObject.metaDataTitle
        }
        else if label.labelObject?.key == "planMetaDataDeviceCount" {
            
            label.text = "\(subscriptionPlanMetadataObject.deviceCount ?? "")"
        }
    }
    
    
    func updateImageView(imageView:SFImageView, subscriptionPlanMetadataObject:SubscriptionPlanMetaData) {
        
        if subscriptionPlanMetadataObject.isCheckMarkVisible != nil {
            
            if subscriptionPlanMetadataObject.isCheckMarkVisible! {
                
                imageView.image = UIImage(named: "tickIcon")
            }
            else {
                
                imageView.image = UIImage(named: "crossIcon")
            }
        }
        else if subscriptionPlanMetadataObject.metaDataImageUrl != nil {
            
            var imageURLString = subscriptionPlanMetadataObject.metaDataImageUrl!
            imageURLString = imageURLString.trimmingCharacters(in: .whitespaces)
            
            guard let imageURL:URL = URL(string: imageURLString) else { return }
            
            imageView.af_setImage(
                withURL: imageURL,
                placeholderImage: nil,
                filter: nil,
                imageTransition: .crossDissolve(0.2)
            )
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
