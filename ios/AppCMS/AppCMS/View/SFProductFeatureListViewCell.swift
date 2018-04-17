//
//  SFProductFeatureListViewCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 12/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFProductFeatureListViewCell: UICollectionViewCell {
    
    var productFeatureImage:SFImageView?
    var productFeatureTitle:SFLabel?
    var productFeatureDescription:SFLabel?
    var cellComponents:Array<Any> = []
    var relativeViewFrame:CGRect?
    var featureListModel:FeatureListModel?

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        createCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createCellView() {
        
        productFeatureImage = SFImageView()
        self.addSubview(productFeatureImage!)
        productFeatureImage?.isHidden = true
        
        productFeatureTitle = SFLabel()
        productFeatureTitle?.isHidden = true
        self.addSubview(productFeatureTitle!)
        
        productFeatureDescription = SFLabel()
        self.addSubview(productFeatureDescription!)
        productFeatureDescription?.isHidden = true
    }
    
    
    //MARK: Update Cell components
    //Reusing it in collectionview cell to update cell contents
    func updateGridSubView() {
        
        for cellComponent in cellComponents {
            
            if cellComponent is SFLabelObject {
                
                updateLabelView(labelObject: cellComponent as! SFLabelObject)
            }
            else if cellComponent is SFImageObject {
                
                updateImageView(imageObject: cellComponent as! SFImageObject)
            }
        }
    }
    
    
    //MARK: Create label view
    func updateLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        if labelObject.key != nil && labelObject.key == "planFeatureTitle" {
            productFeatureTitle?.isHidden = false
            productFeatureTitle?.relativeViewFrame = self.frame
            productFeatureTitle?.labelObject = labelObject
            productFeatureTitle?.text = featureListModel?.featureListTitle
            productFeatureTitle?.labelLayout = labelLayout
            productFeatureTitle?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            productFeatureTitle?.createLabelView()
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                productFeatureTitle?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            productFeatureTitle?.changeFrameWidth(width: (productFeatureTitle?.frame.size.width)! * Utility.getBaseScreenWidthMultiplier())
        }
        else if labelObject.key != nil && labelObject.key == "planFeatureDescription" {
            productFeatureDescription?.isHidden = false
            productFeatureDescription?.numberOfLines = 0
            productFeatureDescription?.relativeViewFrame = self.frame
            productFeatureDescription?.labelObject = labelObject
            productFeatureDescription?.labelLayout = labelLayout
            productFeatureDescription?.text = featureListModel?.featureListDescription
            productFeatureDescription?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)

            productFeatureDescription?.createLabelView()
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                productFeatureDescription?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            productFeatureDescription?.changeFrameWidth(width: (productFeatureDescription?.frame.size.width)! * Utility.getBaseScreenWidthMultiplier())
        }
    }
    

    //MARK: Update Image view
    func updateImageView(imageObject:SFImageObject) {
        
        if imageObject.key != nil && imageObject.key == "planFeatureImage" {
            productFeatureImage?.isHidden = false
            productFeatureImage?.relativeViewFrame = self.frame
            productFeatureImage?.imageViewObject = imageObject
            productFeatureImage?.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
            productFeatureImage?.contentMode = .scaleAspectFit
            
            var imageURLString:String? = featureListModel?.featureListImageURL
            
            if imageURLString != nil {
                
                imageURLString = imageURLString?.trimmingCharacters(in: .whitespaces)
                
                guard let imageURL:URL = URL(string: imageURLString!) else { return }
                
                productFeatureImage?.af_setImage(
                    withURL: imageURL,
                    placeholderImage: nil,
                    filter: nil,
                    imageTransition: .crossDissolve(0.2)
                )
            }
        }
    }
}
