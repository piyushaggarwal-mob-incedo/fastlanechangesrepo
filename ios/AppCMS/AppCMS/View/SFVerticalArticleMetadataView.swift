//
//  SFVerticalArticleMetadataView.swift
//  AppCMS
//
//  Created by Gaurav Vig on 26/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import UIKit

class SFVerticalArticleMetadataView: UIView, SFButtonDelegate {

    var articleTitle:SFLabel?
    var articleSubtitle:SFLabel?
    var separatorView:SFSeparatorView?
    var articleDescription:SFLabel?
    var readMoreButton:SFButton?
    var articleMetadataInfo:SFLabel?
    var infoButton:SFButton?
    var components:Array<Any> = []
    var gridObject:SFGridObject?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createMetadataView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Method to create metadata view
    private func createMetadataView() {
    
        articleTitle = SFLabel()
        self.addSubview(articleTitle!)
        articleTitle?.isHidden = true
        articleTitle?.isUserInteractionEnabled = false
        
        articleSubtitle = SFLabel()
        self.addSubview(articleSubtitle!)
        articleSubtitle?.isHidden = true
        articleSubtitle?.isUserInteractionEnabled = false
        
        separatorView = SFSeparatorView()
        self.addSubview(separatorView!)
        separatorView?.isHidden = true
        separatorView?.isUserInteractionEnabled = false
        
        articleDescription = SFLabel()
        self.addSubview(articleDescription!)
        articleDescription?.isHidden = true
        articleDescription?.isUserInteractionEnabled = false
        
        readMoreButton = SFButton()
        self.addSubview(readMoreButton!)
        readMoreButton?.isHidden = true
        readMoreButton?.isUserInteractionEnabled = false
        
        articleMetadataInfo = SFLabel()
        self.addSubview(articleMetadataInfo!)
        articleMetadataInfo?.isHidden = true
        articleMetadataInfo?.isUserInteractionEnabled = false
        
        infoButton = SFButton()
        self.addSubview(infoButton!)
        infoButton?.isHidden = true
        infoButton?.isUserInteractionEnabled = false
    }
    
    //MARK: Update Subview components
    func updateSubViews() {
        
        for subView in components {
            
            if subView is SFLabelObject {
                
                createLabelView(labelObject: subView as! SFLabelObject)
            }
            else if subView is SFButtonObject {
                
                createButtonView(buttonObject: subView as! SFButtonObject)
            }
            else if subView is SFSeparatorViewObject {
                
                createSeparatorView(separatorViewObject: subView as! SFSeparatorViewObject)
            }
        }
    }
    
    //MARK: Method to create label
    private func createLabelView(labelObject:SFLabelObject) {
        
        if let labelObjecKey = labelObject.key {
            
            let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)

            switch labelObjecKey {
                
            case "title":
                articleTitle?.isHidden = false
                articleTitle?.relativeViewFrame = self.frame
                articleTitle?.labelObject = labelObject
                articleTitle?.text = gridObject?.contentTitle
                articleTitle?.labelLayout = labelLayout
                articleTitle?.createLabelView()
                articleTitle?.font = UIFont(name: (articleTitle?.font.fontName)!, size: (articleTitle?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
                
                if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                    
                    articleTitle?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
                }
                break
            case "subTitle":
                articleSubtitle?.isHidden = false
                articleSubtitle?.relativeViewFrame = self.frame
                articleSubtitle?.labelObject = labelObject
                articleSubtitle?.text = gridObject?.contentTitle
                articleSubtitle?.labelLayout = labelLayout
                articleSubtitle?.createLabelView()
                articleSubtitle?.font = UIFont(name: (articleSubtitle?.font.fontName)!, size: (articleSubtitle?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
                
                if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                    
                    articleSubtitle?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
                }
                break
            case "description":
                articleDescription?.isHidden = false
                articleDescription?.relativeViewFrame = self.frame
                articleDescription?.labelObject = labelObject
                articleDescription?.text = gridObject?.contentTitle
                articleDescription?.labelLayout = labelLayout
                articleDescription?.createLabelView()
                articleDescription?.font = UIFont(name: (articleDescription?.font.fontName)!, size: (articleDescription?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
                
                if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                    
                    articleDescription?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
                }
                break
            case "infoLabel":
                articleMetadataInfo?.isHidden = false
                articleMetadataInfo?.relativeViewFrame = self.frame
                articleMetadataInfo?.labelObject = labelObject
                articleMetadataInfo?.text = gridObject?.contentTitle
                articleMetadataInfo?.labelLayout = labelLayout
                articleMetadataInfo?.createLabelView()
                articleMetadataInfo?.font = UIFont(name: (articleMetadataInfo?.font.fontName)!, size: (articleMetadataInfo?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
                
                if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                    
                    articleMetadataInfo?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
                }
                break
            default:
                break
            }
        }
    }
    
    //MARK: Method to create button
    private func createButtonView(buttonObject:SFButtonObject) {
        
        if let buttonObjectKey = buttonObject.key {
            
            let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
            
            switch buttonObjectKey {
                
            case "readMore":
                
                readMoreButton?.buttonObject = buttonObject
                readMoreButton?.buttonLayout = buttonLayout
                readMoreButton?.relativeViewFrame = self.frame
                readMoreButton?.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
                readMoreButton?.buttonDelegate = self
                readMoreButton?.createButtonView()
                break
            case "gridOptions":
                
                infoButton?.isHidden = false
                infoButton?.isUserInteractionEnabled = true
                infoButton?.buttonObject = buttonObject
                infoButton?.relativeViewFrame = self.frame
                infoButton?.buttonDelegate = self
                infoButton?.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
                let infoButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "icon-dropDown.png"))
                
                infoButton?.setImage(infoButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                infoButton?.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")

                infoButton?.createButtonView()
                break
            default:
                break
            }
        }
    }
    
    //MARK: Method to create separatorView
    private func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        separatorView?.isHidden = false
        separatorView?.relativeViewFrame = self.frame
        separatorView?.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject))
    }
    
    
    //MARK: Button Delegate
    func buttonClicked(button: SFButton) {
        //TODO:
    }
}
