//
//  SFProductListViewCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 12/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol SFProductListViewDelegate:NSObjectProtocol {
    @objc optional func buttonClicked(button:UIButton, cellRowValue:Int) -> Void
}

class SFProductListViewCell: UICollectionViewCell, SFButtonDelegate {
    
    var planNameLabel:SFLabel?
    var planPriceLabel:SFLabel?
    var planMetaDataView:SFPlanMetaDataView?
    var bestValueLabel:SFLabel?
    var planSelectionButton:SFButton?
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
    func createCellView() {
        
        planNameLabel = SFLabel()
        self.addSubview(planNameLabel!)
        planNameLabel?.isHidden = true
        planNameLabel?.isUserInteractionEnabled = false

        planPriceLabel = SFLabel()
        self.addSubview(planPriceLabel!)
        planPriceLabel?.isHidden = true
        planPriceLabel?.isUserInteractionEnabled = false

        planMetaDataView = SFPlanMetaDataView()
        self.addSubview(planMetaDataView!)
        planMetaDataView?.isHidden = true
        planMetaDataView?.isUserInteractionEnabled = false
        
        bestValueLabel = SFLabel()
        self.addSubview(bestValueLabel!)
        bestValueLabel?.isHidden = true
        bestValueLabel?.isUserInteractionEnabled = false
        
        planSelectionButton = SFButton()
        planSelectionButton?.isEnabled = false
        planSelectionButton?.titleLabel?.numberOfLines = 2
        planSelectionButton?.titleLabel?.textAlignment = .center
        self.addSubview(planSelectionButton!)
        planSelectionButton?.isHidden = true
    }
    
    
    //MARK: Update Cell components
    //Reusing it in collectionview cell to update cell contents
    func updateGridSubView() {
        
        for cellComponent in cellComponents {
            
            if cellComponent is SFLabelObject {
                
                updateLabelView(labelObject: cellComponent as! SFLabelObject)
            }
            else if cellComponent is SFButtonObject {
                
                updateButtonView(buttonObject: cellComponent as! SFButtonObject)
            }
            else if cellComponent is SFPlanMetaDataViewObject {
                
                updateMetaDataView(metaDataViewObject: cellComponent as! SFPlanMetaDataViewObject)
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
            
            planNameLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff")
            
            planNameLabel?.font = UIFont(name: (planNameLabel?.font.fontName)!, size: (planNameLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
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
            
            planPriceLabel?.font = UIFont(name: (planPriceLabel?.font.fontName)!, size: (planPriceLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())

            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                planPriceLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            planPriceLabel?.attributedText = Utility.sharedUtility.createPlanPriceString(paymentModelObject: paymentModelObject)
            
            planPriceLabel?.changeFrameHeight(height: (planPriceLabel?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
            planPriceLabel?.changeFrameYAxis(yAxis: (planPriceLabel?.frame.origin.y)!)
        }
        else if labelObject.key != nil && labelObject.key == "planBestValueLabel" {
            
            bestValueLabel?.numberOfLines = 0
            bestValueLabel?.relativeViewFrame = self.frame
            bestValueLabel?.labelObject = labelObject
            bestValueLabel?.labelLayout = labelLayout
            bestValueLabel?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            bestValueLabel?.createLabelView()
            bestValueLabel?.text = labelObject.text ?? ""
            
            if paymentModelObject?.planDiscountedPrice != nil {
            
                bestValueLabel?.isHidden = false
            }
            else {
                
                bestValueLabel?.isHidden = true
            }
            
            bestValueLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff")
            
            bestValueLabel?.font = UIFont(name: (bestValueLabel?.font.fontName)!, size: (bestValueLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
            
            bestValueLabel?.changeFrameHeight(height: (bestValueLabel?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
            bestValueLabel?.changeFrameYAxis(yAxis: (bestValueLabel?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
        }
    }
    
    
    //MARK: Update Button View
    func updateButtonView(buttonObject:SFButtonObject) {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        
        if buttonObject.key == "planPurchaseButton" && buttonObject.key != nil {
            
            planSelectionButton?.isHidden = false
            planSelectionButton?.buttonObject = buttonObject
            planSelectionButton?.buttonLayout = buttonLayout
            planSelectionButton?.relativeViewFrame = self.frame
            planSelectionButton?.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
            planSelectionButton?.createButtonView()
            planSelectionButton?.buttonDelegate = self
            updatePlanSelectorButtonViewOnSelectionStatus(selectionStatus: (planSelectionButton?.isSelected)!)
            
            planSelectionButton?.changeFrameHeight(height: (planSelectionButton?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
            planSelectionButton?.changeFrameWidth(width: (planSelectionButton?.frame.size.width)! * Utility.getBaseScreenWidthMultiplier())
            planSelectionButton?.changeFrameYAxis(yAxis: (planSelectionButton?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
            planSelectionButton?.changeFrameXAxis(xAxis: (planSelectionButton?.frame.origin.x)! * Utility.getBaseScreenWidthMultiplier())
            
            planSelectionButton?.titleLabel?.font = UIFont(name: (planSelectionButton?.titleLabel?.font.fontName)!, size: (planSelectionButton?.titleLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
        }
    }
    
    
    //MARK: Update plan selector button based on cell selection status
    func updatePlanSelectorButtonViewOnSelectionStatus(selectionStatus:Bool) {
        
        if selectionStatus {
            
            self.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000").cgColor

            if AppConfiguration.sharedAppConfiguration.secondaryButton.textColor != nil {
                
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor!), for: .normal)
            }
            
            if AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor != nil {
                
                planSelectionButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor!)
            }
            
            planSelectionButton?.setTitle(paymentModelObject?.planSelectionButtonText ?? planSelectionButton?.buttonObject?.selectedText?.uppercased() ?? "CONTINUE WITH SELECTION", for: .normal)

            planSelectionButton?.layer.borderWidth = 0
            planSelectionButton?.layer.borderColor = UIColor.clear.cgColor
            planSelectionButton?.isEnabled = selectionStatus
        }
        else {
            
            self.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff").cgColor
            
            if AppConfiguration.sharedAppConfiguration.secondaryButton.textColor != nil {
                
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor!).withAlphaComponent(0.38), for: .normal)
            }
            
            if AppConfiguration.sharedAppConfiguration.secondaryButton.textColor != nil {
                
                planSelectionButton?.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor!).withAlphaComponent(0.38).cgColor
            }
            
            planSelectionButton?.setTitle(Constants.startSubscriptionString, for: .normal)

            planSelectionButton?.layer.borderWidth = 1
            planSelectionButton?.isEnabled = selectionStatus
            planSelectionButton?.backgroundColor = UIColor.clear
        }
    }
    
    
    //MARK: Update plan metadata view
    func updateMetaDataView(metaDataViewObject:SFPlanMetaDataViewObject) {
        
        let planMetaDataViewLayout = Utility.fetchPlanMetaDataViewLayoutDetails(planMetaDataViewObject: metaDataViewObject)
        
        if metaDataViewObject.keyName == "planMetaDataView" {
            
            planMetaDataView?.isHidden = false
            planMetaDataView?.isUserInteractionEnabled = true
            planMetaDataView?.relativeViewFrame = self.frame
            planMetaDataView?.planMetaDataViewObject = metaDataViewObject
            planMetaDataView?.initialiseMetaDataViewFrameFromLayout(metaDataViewLayout: planMetaDataViewLayout)
            planMetaDataView?.subscriptionPlanMetaDataArray = paymentModelObject?.subscriptionPlansMetaData ?? []
            
            planMetaDataView?.changeFrameHeight(height: (planMetaDataView?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
            planMetaDataView?.changeFrameWidth(width: (planMetaDataView?.frame.size.width)! * Utility.getBaseScreenWidthMultiplier())
            
            planMetaDataView?.changeFrameYAxis(yAxis: (planMetaDataView?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
            
            planMetaDataView?.createMetaDataView()            
        }
    }
    
    
    //MARK: Button Delegate method
    func buttonClicked(button: SFButton) {
        
        if delegate != nil {
            
            if (delegate?.responds(to: #selector(SFProductListViewDelegate.buttonClicked(button:cellRowValue:))))! {
                
                delegate?.buttonClicked!(button: button, cellRowValue:cellRowValue!)
            }
        }
    }
}
