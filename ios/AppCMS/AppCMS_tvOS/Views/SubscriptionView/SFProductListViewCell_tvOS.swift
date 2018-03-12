//
//  SFProductListViewCell_tvOS.swift
//  AppCMS
//
//  Created by Rajni Pathak on 01/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFProductListViewCell_tvOS: UICollectionViewCell {
    
    private var planNameLabel:SFLabel?
    private var planPriceLabel:SFLabel?

    private var planMetaDataView:SFPlanMetaDataView_tvOS?
    var planSelectionButton:SFButton?
    var paymentModelObject:PaymentModel?
    var cellComponents:Array<Any> = []
    var cellRowValue:Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //MARK: method to create cell view
    private func createCellView() {
        planNameLabel = SFLabel()
        self.addSubview(planNameLabel!)
        planNameLabel?.isHidden = true
        planNameLabel?.isUserInteractionEnabled = false

        planPriceLabel = SFLabel()
        self.contentView.addSubview(planPriceLabel!)
        planPriceLabel?.isHidden = true
        planPriceLabel?.isUserInteractionEnabled = false

        planMetaDataView = SFPlanMetaDataView_tvOS()
        self.contentView.addSubview(planMetaDataView!)
        planMetaDataView?.isHidden = true
        planMetaDataView?.isUserInteractionEnabled = false
        
        planSelectionButton = SFButton()
        planSelectionButton?.isEnabled = false
        self.contentView.addSubview(planSelectionButton!)
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
    private func updateLabelView(labelObject:SFLabelObject) {
        
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
            
            planNameLabel?.font = UIFont(name: (planNameLabel?.font.fontName)!, size: (planNameLabel?.font.pointSize)!)
        }
        else if labelObject.key != nil && labelObject.key == "planPriceInfo" {
            planPriceLabel?.isHidden = false
            planPriceLabel?.numberOfLines = 0
            planPriceLabel?.relativeViewFrame = self.frame
            planPriceLabel?.labelObject = labelObject
            planPriceLabel?.labelLayout = labelLayout
            planPriceLabel?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            planPriceLabel?.createLabelView()
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                planPriceLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            planPriceLabel?.attributedText = Utility.sharedUtility.createPlanPriceString(paymentModelObject: paymentModelObject)
                        planPriceLabel?.changeFrameYAxis(yAxis: (planPriceLabel?.frame.origin.y)!)
        }
    }
    
    
    //MARK: Method to create plan price as per ui
    private func createPlanPriceString() -> NSAttributedString? {
        
        let currencySymbol:String? = Utility.getSymbolForCurrencyCode(countryCode: (paymentModelObject?.recurringPaymentsTotalCurrency)!)
        
        let planOriginalPrice:Float = (paymentModelObject?.recurringPaymentsTotal?.floatValue)!
        
        var completeString:String = ""
        var discountedPriceString:String?
        var originalPriceString:String?
        
        originalPriceString = "\(currencySymbol ?? "")\(planOriginalPrice)"

        if originalPriceString != nil {
            
            completeString = completeString.appending(originalPriceString!)
        }
        
        if paymentModelObject?.planDiscountedPrice != nil {
            
            let planDiscountedPrice:Float = (paymentModelObject?.planDiscountedPrice?.floatValue)!
            discountedPriceString = "\(currencySymbol ?? "")\(planDiscountedPrice)"
            
            completeString = completeString.appending(" \(discountedPriceString!) ")
        }
        
        var pendingPriceString:String?
        
        if paymentModelObject?.billingPeriodType == .MONTHLY {
            
            pendingPriceString = " / Month"
            
        }
        else if paymentModelObject?.billingPeriodType == .YEARLY {
            
            pendingPriceString = " / Year"
        }
        
        if pendingPriceString != nil {
            
            completeString = completeString.appending(pendingPriceString!)
        }
        
        
        var planPriceString:NSMutableAttributedString?
        
        if discountedPriceString != nil {
            
            planPriceString = NSMutableAttributedString(string: completeString)
            
            if originalPriceString != nil {
                
                planPriceString?.addAttributes([NSBaselineOffsetAttributeName: 0, NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue), NSStrikethroughColorAttributeName: Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor ?? "000000"), NSFontAttributeName: UIFont(name: "OpenSans-BoldItalic", size: 26)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff").withAlphaComponent(0.55)], range: (completeString as NSString).range(of: originalPriceString!))
            }
            
            planPriceString?.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-BoldItalic", size: 26)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")], range: (completeString as NSString).range(of: discountedPriceString!))

            if pendingPriceString != nil {
                
                planPriceString?.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Italic", size: 26)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")], range: (completeString as NSString).range(of: pendingPriceString!))
            }
        }
        else {
            
            planPriceString = NSMutableAttributedString(string: completeString)
            
            if originalPriceString != nil {
            
                planPriceString?.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-BoldItalic", size: 26)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")], range: (completeString as NSString).range(of: originalPriceString!))
            }
            
            if pendingPriceString != nil {
                
                planPriceString?.addAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Italic", size: 26)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")], range: (completeString as NSString).range(of: pendingPriceString!))
            }
        }
        
        return planPriceString
    }
    
    //MARK: Update Button View
    private func updateButtonView(buttonObject:SFButtonObject) {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        
        if buttonObject.key == "planPurchaseButton" && buttonObject.key != nil {
            
            planSelectionButton?.isHidden = false
            planSelectionButton?.buttonObject = buttonObject
            planSelectionButton?.buttonLayout = buttonLayout
            planSelectionButton?.relativeViewFrame = self.frame
            planSelectionButton?.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
            planSelectionButton?.createButtonView()
            updatePlanSelectorButtonViewOnSelectionStatus(selectionStatus: (planSelectionButton?.isSelected)!)
            planSelectionButton?.titleLabel?.font = UIFont(name: (planSelectionButton?.titleLabel?.font.fontName)!, size: (planSelectionButton?.titleLabel?.font.pointSize)!)
        }
    }
    
    
    //MARK: Update plan selector button based on cell selection status
    func updatePlanSelectorButtonViewOnSelectionStatus(selectionStatus:Bool) {
        if selectionStatus {
            self.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor ?? "ffffff").cgColor
            if AppConfiguration.sharedAppConfiguration.secondaryButton.textColor != nil {
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor!), for: .normal)
            }
            if AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor != nil {
                
                planSelectionButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor!)
            }
            planSelectionButton?.setTitle(planSelectionButton?.buttonObject?.text?.uppercased() ?? "START YOUR FREE TRIAL", for: .normal)
            planSelectionButton?.layer.borderWidth = 0
            planSelectionButton?.layer.borderColor = UIColor.clear.cgColor
            planSelectionButton?.isEnabled = selectionStatus
            planSelectionButton?.alpha = 1
        }
        else {
            self.layer.borderColor = UIColor.clear.cgColor
            if AppConfiguration.sharedAppConfiguration.secondaryButton.textColor != nil {
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor!).withAlphaComponent(0.38), for: .normal)
            }
            if AppConfiguration.sharedAppConfiguration.secondaryButton.textColor != nil {
                planSelectionButton?.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor!).withAlphaComponent(0.38).cgColor
            }
            planSelectionButton?.setTitle(planSelectionButton?.buttonObject?.text?.uppercased() ?? "START YOUR FREE TRIAL", for: .normal)
            planSelectionButton?.layer.borderWidth = 2
            planSelectionButton?.isEnabled = selectionStatus
            planSelectionButton?.backgroundColor = UIColor.clear
            planSelectionButton?.alpha = 1
        }
    }
    
    
    func updatePlanSelectorButtonViewForConfirmation(selectionStatus:Bool){
        if selectionStatus {
            self.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor ?? "ffffff").cgColor
            if AppConfiguration.sharedAppConfiguration.secondaryButton.textColor != nil {
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor!), for: .normal)
            }
            if AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor != nil {
                
                planSelectionButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor!)
            }
            planSelectionButton?.setTitle(planSelectionButton?.buttonObject?.selectedText?.uppercased() ?? "CONFIRM", for: .normal)
            planSelectionButton?.layer.borderWidth = 0
            planSelectionButton?.layer.borderColor = UIColor.clear.cgColor
            planSelectionButton?.isEnabled = true
            planSelectionButton?.alpha = 1
        }
        else {
            self.layer.borderColor = UIColor.clear.cgColor
            if AppConfiguration.sharedAppConfiguration.secondaryButton.textColor != nil {
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor!).withAlphaComponent(0.38), for: .normal)
            }
            if AppConfiguration.sharedAppConfiguration.secondaryButton.textColor != nil {
                planSelectionButton?.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor!).withAlphaComponent(0.38).cgColor
            }
            planSelectionButton?.setTitle(planSelectionButton?.buttonObject?.selectedText?.uppercased() ?? "CONFIRM", for: .normal)
            planSelectionButton?.layer.borderWidth = 2
            planSelectionButton?.isEnabled = selectionStatus
            planSelectionButton?.backgroundColor = UIColor.clear
            planSelectionButton?.alpha = 1
        }
    }
    
    //MARK: Update plan metadata view
    private func updateMetaDataView(metaDataViewObject:SFPlanMetaDataViewObject) {
        let planMetaDataViewLayout = Utility.fetchPlanMetaDataViewLayoutDetails(planMetaDataViewObject: metaDataViewObject)
        if metaDataViewObject.keyName == "planMetaDataView" {
            planMetaDataView?.isHidden = false
            planMetaDataView?.relativeViewFrame = self.frame
            planMetaDataView?.planMetaDataViewObject = metaDataViewObject
            planMetaDataView?.initialiseMetaDataViewFrameFromLayout(metaDataViewLayout: planMetaDataViewLayout)
            planMetaDataView?.subscriptionPlanMetaDataArray = paymentModelObject?.subscriptionPlansMetaData ?? []
            planMetaDataView?.createMetaDataView()
        }
    }
    
}
