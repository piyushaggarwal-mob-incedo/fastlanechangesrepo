//
//  SFProductGridViewCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 12/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFProductGridViewCell: UICollectionViewCell {
    
    var planNameLabel:SFLabel?
    var planPriceLabel:SFLabel?
    var planDescriptionLabel:SFLabel?
    var planSeparatorView:SFSeparatorView?
    var paymentModelObject:PaymentModel?
    var cellComponents:Array<Any> = []
    weak var delegate:SFProductListViewDelegate?
    var cellRowValue:Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: method to create cell view
    private func createCellView() {
        
        planNameLabel = SFLabel()
        self.addSubview(planNameLabel!)
        planNameLabel?.isHidden = true
        
        planPriceLabel = SFLabel()
        self.addSubview(planPriceLabel!)
        planPriceLabel?.isHidden = true
        
        planDescriptionLabel = SFLabel()
        self.addSubview(planDescriptionLabel!)
        planDescriptionLabel?.isHidden = true
        
        planSeparatorView = SFSeparatorView()
        self.addSubview(planSeparatorView!)
        planSeparatorView?.isHidden = true
        
        self.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000")
        
        self.layer.cornerRadius = 4.0
    }
    
    
    //MARK: Update Cell components
    //Reusing it in collectionview cell to update cell contents
    func updateGridSubView() {
        
        for cellComponent in cellComponents {
            
            if cellComponent is SFLabelObject {
                
                updateLabelView(labelObject: cellComponent as! SFLabelObject)
            }
            else if cellComponent is SFSeparatorViewObject {
                
                updateSeparatorView(separatorViewObject: cellComponent as! SFSeparatorViewObject)
            }
        }
    }
    
    
    //MARK: Update label view
    func updateLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        if labelObject.key != nil && labelObject.key == "planTitle" {
            planNameLabel?.isHidden = false
            planNameLabel?.relativeViewFrame = self.frame
            planNameLabel?.labelObject = labelObject
            planNameLabel?.text = paymentModelObject?.planName
            planNameLabel?.labelLayout = labelLayout
            planNameLabel?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            planNameLabel?.createLabelView()
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                planNameLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }

            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                if Constants.IPHONE{
                    planNameLabel?.font = UIFont(name: (planNameLabel?.font.fontName)!, size: 16 * Utility.getBaseScreenHeightMultiplier())
                }
                else{
                    planNameLabel?.font = UIFont(name: (planNameLabel?.font.fontName)!, size: 18 * Utility.getBaseScreenHeightMultiplier())
                }
            }
            else{
                planNameLabel?.font = UIFont(name: (planNameLabel?.font.fontName)!, size: (planNameLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
            }
            planNameLabel?.changeFrameHeight(height: (planNameLabel?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
        }
        else if labelObject.key != nil && labelObject.key == "planPriceInfo" {
            planPriceLabel?.isHidden = false
            planPriceLabel?.numberOfLines = 0
            planPriceLabel?.relativeViewFrame = self.frame
            planPriceLabel?.labelObject = labelObject
            planPriceLabel?.labelLayout = labelLayout
            planPriceLabel?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            planPriceLabel?.createLabelView()
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                planPriceLabel?.font = UIFont(name: (planPriceLabel?.font.fontName)!, size: (planNameLabel?.font.pointSize)!)
            }
            else{
                planPriceLabel?.font = UIFont(name: (planPriceLabel?.font.fontName)!, size: (planPriceLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
            }
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                planPriceLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            planPriceLabel?.attributedText = Utility.sharedUtility.createPlanPriceStringForGridProducts(paymentModelObject: paymentModelObject, isIntroductoryPriceAvailable: true, fontSize: (planPriceLabel?.font.pointSize)!)
            planPriceLabel?.adjustsFontSizeToFitWidth = true
            planPriceLabel?.minimumScaleFactor = 0.7
            planPriceLabel?.changeFrameHeight(height: (planPriceLabel?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
            planPriceLabel?.changeFrameYAxis(yAxis: (planPriceLabel?.frame.origin.y)!)
        }
        else if labelObject.key != nil && labelObject.key == "planDescription" {
            
            planDescriptionLabel?.isHidden = false
            planDescriptionLabel?.relativeViewFrame = self.frame
            planDescriptionLabel?.labelObject = labelObject
            planDescriptionLabel?.labelLayout = labelLayout
            planDescriptionLabel?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            planDescriptionLabel?.createLabelView()
            planDescriptionLabel?.text = paymentModelObject?.planDescription
            planDescriptionLabel?.numberOfLines = 0

            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                planDescriptionLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            planDescriptionLabel?.font = UIFont(name: (planDescriptionLabel?.font.fontName)!, size: (planDescriptionLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
            
            if planDescriptionLabel?.text != nil {
                
                planDescriptionLabel?.changeFrameHeight(height: (planDescriptionLabel?.text?.height(withConstraintWidth: (planDescriptionLabel?.frame.width)!, withConstraintHeight: (planDescriptionLabel?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier(), font: (planDescriptionLabel?.font)!))!)
            }
            
            planDescriptionLabel?.changeFrameYAxis(yAxis: (planDescriptionLabel?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
        }
    }
    
    
    //MARK: Update Separator View
    func updateSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        let separatorViewLayout = Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject)
        
        planSeparatorView?.isHidden = false
        planSeparatorView?.relativeViewFrame = self.frame
        planSeparatorView?.separtorViewObject = separatorViewObject
        planSeparatorView?.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: separatorViewLayout)
        
        if separatorViewObject.opacity != nil {
            
            planSeparatorView?.alpha = CGFloat(separatorViewObject.opacity! / 100)
        }
        
        //planSeparatorView?.changeFrameYAxis(yAxis: (planSeparatorView?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
    }
}
