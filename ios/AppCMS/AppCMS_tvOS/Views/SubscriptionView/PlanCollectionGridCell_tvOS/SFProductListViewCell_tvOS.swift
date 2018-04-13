//
//  SFProductListViewCell_tvOS.swift
//  AppCMS
//
//  Created by Rajni Pathak on 01/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//
import MarqueeLabel
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
        planNameLabel?.isUserInteractionEnabled = false
        self.contentView.addSubview(planNameLabel!)
        
        planPriceLabel = SFLabel()
        self.contentView.addSubview(planPriceLabel!)
        planPriceLabel?.isHidden = true
        planPriceLabel?.isUserInteractionEnabled = false
        
        planMetaDataView = SFPlanMetaDataView_tvOS()
        self.contentView.addSubview(planMetaDataView!)
        planMetaDataView?.isHidden = true
        planMetaDataView?.isUserInteractionEnabled = false
        
        planSelectionButton = SFButton()
        planSelectionButton?.titleLabel?.numberOfLines = 2
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
            planNameLabel?.relativeViewFrame = self.frame
            planNameLabel?.labelObject = labelObject
            planNameLabel?.labelLayout = labelLayout
            planNameLabel?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            planNameLabel?.createLabelView()
            planNameLabel?.isHidden = false
            let paragraphStyle = NSMutableParagraphStyle()
            if let lineHeight = labelObject.lineHeight {
                paragraphStyle.lineBreakMode = .byTruncatingTail
                paragraphStyle.minimumLineHeight = CGFloat(lineHeight)
                paragraphStyle.maximumLineHeight = CGFloat(lineHeight)
                paragraphStyle.alignment = .center
                let attrString = NSMutableAttributedString(string: (paymentModelObject?.planName)!)
                attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
                attrString.addAttribute(NSFontAttributeName, value: planNameLabel?.font, range: NSMakeRange(0, attrString.length))
                planNameLabel?.attributedText = attrString
            } else {
                planNameLabel?.text = paymentModelObject?.planName
            }
            planNameLabel?.numberOfLines = 2
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                planNameLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
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
            
            planPriceLabel?.attributedText = Utility.sharedUtility.createPlanPriceString(paymentModelObject: paymentModelObject)//createPlanPriceString()
            planPriceLabel?.changeFrameYAxis(yAxis: (planPriceLabel?.frame.origin.y)!)
        }
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
            planSelectionButton?.titleLabel?.textAlignment = .center
            
            updatePlanSelectorButtonViewOnSelectionStatus(selectionStatus: (planSelectionButton?.isSelected)!)
            planSelectionButton?.titleLabel?.font = UIFont(name: (planSelectionButton?.titleLabel?.font.fontName)!, size: (planSelectionButton?.titleLabel?.font.pointSize)!)
        }
    }
    
    
    //MARK: Update plan selector button based on cell selection status
    func updatePlanSelectorButtonViewOnSelectionStatus(selectionStatus:Bool) {
        var defaultPrimaryColor : String?
        var defaultSecondaryColor: String?
        if AppConfiguration.sharedAppConfiguration.appTheme == .dark {
            defaultPrimaryColor = "000000"
            defaultSecondaryColor = "ffffff"
        } else {
            defaultPrimaryColor = "ffffff"
            defaultSecondaryColor = "000000"
        }
        if selectionStatus {
            if AppConfiguration.sharedAppConfiguration.primaryButton.borderColor != nil {
                self.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.borderColor!).cgColor
            }
            else   {
                self.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? defaultSecondaryColor!).cgColor
            }
            
            
            if AppConfiguration.sharedAppConfiguration.primaryButton.textColor != nil {
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.textColor!), for: .normal)
            }
            else if AppConfiguration.sharedAppConfiguration.secondaryButton.textColor != nil {
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor!), for: .normal)
            }
            else{
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: defaultPrimaryColor!), for: .normal)
            }
            
            if AppConfiguration.sharedAppConfiguration.primaryButton.backgroundColor != nil {
                planSelectionButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.backgroundColor!)
            }
            else if AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor != nil {
                
                planSelectionButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor!)
            }
            else{
                planSelectionButton?.backgroundColor = Utility.hexStringToUIColor(hex: defaultSecondaryColor!)
            }
            planSelectionButton?.setTitle(paymentModelObject?.planSelectionButtonText ?? planSelectionButton?.buttonObject?.text?.uppercased() ?? "SELECT YOUR PLAN", for: .normal)
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
            else{
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: defaultSecondaryColor!).withAlphaComponent(0.38), for: .normal)
            }
            if AppConfiguration.sharedAppConfiguration.secondaryButton.borderColor != nil {
                planSelectionButton?.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.borderColor!).withAlphaComponent(0.38).cgColor
            }
            else{
                planSelectionButton?.layer.borderColor = Utility.hexStringToUIColor(hex: defaultSecondaryColor!).withAlphaComponent(0.38).cgColor
            }
            planSelectionButton?.setTitle(planSelectionButton?.buttonObject?.text?.uppercased() ?? "SELECT YOUR PLAN", for: .normal)
            planSelectionButton?.layer.borderWidth = 2
            planSelectionButton?.isEnabled = selectionStatus
            planSelectionButton?.backgroundColor = UIColor.clear
            planSelectionButton?.alpha = 1
        }
    }
    
    
    func updatePlanSelectorButtonViewForConfirmation(selectionStatus:Bool){
        var defaultPrimaryColor : String?
        var defaultSecondaryColor: String?
        if AppConfiguration.sharedAppConfiguration.appTheme == .dark {
            defaultPrimaryColor = "000000"
            defaultSecondaryColor = "ffffff"
        } else {
            defaultPrimaryColor = "ffffff"
            defaultSecondaryColor = "000000"
        }
        if selectionStatus {
            if AppConfiguration.sharedAppConfiguration.primaryButton.borderColor != nil {
                self.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.borderColor!).cgColor
            }
            else   {
                self.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? defaultSecondaryColor!).cgColor
            }
            
            
            if AppConfiguration.sharedAppConfiguration.primaryButton.textColor != nil {
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.textColor!), for: .normal)
            }
            else if AppConfiguration.sharedAppConfiguration.secondaryButton.textColor != nil {
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor!), for: .normal)
            }
            else{
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: defaultPrimaryColor!), for: .normal)
            }
            
            if AppConfiguration.sharedAppConfiguration.primaryButton.backgroundColor != nil {
                planSelectionButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.backgroundColor!)
            }
            else if AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor != nil {
                
                planSelectionButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor!)
            }
            else{
                planSelectionButton?.backgroundColor = Utility.hexStringToUIColor(hex: defaultSecondaryColor!)
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
            else{
                planSelectionButton?.setTitleColor(Utility.hexStringToUIColor(hex: defaultSecondaryColor!).withAlphaComponent(0.38), for: .normal)
            }
            if AppConfiguration.sharedAppConfiguration.secondaryButton.borderColor != nil {
                planSelectionButton?.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.borderColor!).withAlphaComponent(0.38).cgColor
            }
            else{
                planSelectionButton?.layer.borderColor = Utility.hexStringToUIColor(hex: defaultSecondaryColor!).withAlphaComponent(0.38).cgColor
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
