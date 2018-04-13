//
//  SFPlanMetaDataView_tvOS.swift
//  AppCMS
//
//  Created by Rajni Pathak on 01/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFPlanMetaDataView_tvOS: UIView {

    var subscriptionPlanMetaDataArray:Array<SubscriptionPlanMetaData> = []
    private var yAxis:Float = 0
    private var maxYAxis:Float = 0
    private let labelPadding:Float = 5
    var relativeViewFrame:CGRect?
    var planMetaDataViewObject:SFPlanMetaDataViewObject?
    
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
   func initialiseMetaDataViewFrameFromLayout(metaDataViewLayout:LayoutObject) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: metaDataViewLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    func createMetaDataView() {
        for subView in (self.subviews) {
            subView.removeFromSuperview()
        }
        yAxis = 0
        for subscriptionPlanMetaData in subscriptionPlanMetaDataArray {
            createMetaDataSubViewComponents(subscriptionPlanMetadataObject: subscriptionPlanMetaData)
            
            yAxis = maxYAxis + labelPadding
        }
    }
    
    private func createMetaDataSubViewComponents(subscriptionPlanMetadataObject:SubscriptionPlanMetaData) {
        
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
    
    
    private func createLabelView(labelObject:SFLabelObject, subscriptionPlanMetadataObject:SubscriptionPlanMetaData) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)

        if labelObject.key == "planMetaDataTitle" && subscriptionPlanMetadataObject.metaDataTitle != nil {
            
            let label = SFLabel()
            label.relativeViewFrame = self.frame
            label.labelObject = labelObject
            label.text = subscriptionPlanMetadataObject.metaDataTitle
            label.labelLayout = labelLayout
            label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            label.createLabelView()
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            self.addSubview(label)
            
            label.font = UIFont(name: (label.font.fontName), size: (label.font.pointSize))
            label.adjustsFontSizeToFitWidth = true

            label.changeFrameYAxis(yAxis: CGFloat(yAxis))
            
            maxYAxis = Float(label.frame.maxY)
        }
        else if labelObject.key == "planMetaDataDeviceCount" && subscriptionPlanMetadataObject.deviceCount != nil {
            
            let label = SFLabel()
            label.relativeViewFrame = self.frame
            label.labelObject = labelObject
            label.text = "\(subscriptionPlanMetadataObject.deviceCount ?? "")"
            label.labelLayout = labelLayout
            label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            label.createLabelView()

            if AppConfiguration.sharedAppConfiguration.appPageTitleColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor!)
            }
            
            label.font = UIFont(name: (label.font.fontName), size: (label.font.pointSize))
            
            label.changeFrameYAxis(yAxis: CGFloat(yAxis))
            
            self.addSubview(label)
        }
    }
    
    
    private func createImageView(imageViewObject:SFImageObject, subscriptionPlanMetadataObject:SubscriptionPlanMetaData) {
        
        let imageLayout = Utility.fetchImageLayoutDetails(imageObject: imageViewObject)
        
        if imageViewObject.key == "planMetaDataImage" && (subscriptionPlanMetadataObject.isCheckMarkVisible != nil || subscriptionPlanMetadataObject.metaDataImageUrl != nil) {
            
            let imageView = SFImageView()
            imageView.relativeViewFrame = self.frame
            imageView.imageViewObject = imageViewObject
            imageView.initialiseImageViewFrameFromLayout(imageLayout: imageLayout)
                        
            self.addSubview(imageView)
            
            imageView.changeFrameYAxis(yAxis: CGFloat(yAxis) + 5)
            
            if subscriptionPlanMetadataObject.isCheckMarkVisible != nil {
                
                if subscriptionPlanMetadataObject.isCheckMarkVisible! {
                    
                    imageView.image = UIImage(named: "tickIcon")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                }
                else {
                    
                    imageView.image = UIImage(named: "crossIcon")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                }
                if let textColor = AppConfiguration.sharedAppConfiguration.primaryHoverColor {
                    imageView.tintColor = Utility.hexStringToUIColor(hex: textColor)
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
    
    
    private func updateMetaDataSubViewContent(subscriptionPlanMetadataObject:SubscriptionPlanMetaData) {
        
        for subView in (self.subviews) {
            
            if subView is SFLabel {
                
                updateLabel(label: subView as! SFLabel, subscriptionPlanMetadataObject: subscriptionPlanMetadataObject)
            }
            else if subView is SFImageView {
                
                updateImageView(imageView: subView as! SFImageView, subscriptionPlanMetadataObject: subscriptionPlanMetadataObject)
            }
        }
    }
    
    
    private func updateLabel(label:SFLabel, subscriptionPlanMetadataObject:SubscriptionPlanMetaData) {
        
        if label.labelObject?.key == "planMetaDataTitle" {
            
            label.text = subscriptionPlanMetadataObject.metaDataTitle
        }
        else if label.labelObject?.key == "planMetaDataDeviceCount" {
            
            label.text = "\(subscriptionPlanMetadataObject.deviceCount ?? "")"
        }
    }
    
    
    private func updateImageView(imageView:SFImageView, subscriptionPlanMetadataObject:SubscriptionPlanMetaData) {
        
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
