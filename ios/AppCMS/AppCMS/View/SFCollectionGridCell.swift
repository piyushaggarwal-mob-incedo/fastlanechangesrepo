//
//  SFCollectionGridCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 24/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import AlamofireImage

@objc protocol SFCollectionGridCellDelegate:NSObjectProtocol {
    @objc optional func buttonClicked(button:SFButton, gridObject:SFGridObject?) -> Void
}

class SFCollectionGridCell: UICollectionViewCell, SFButtonDelegate {
    
    var gridComponents:Array<Any> = []
    var thumbnailTitle:SFLabel?
    var subHeadingLabel1:SFLabel?
    var subHeadingLabel2:SFLabel?
    var playButton:SFButton?
    var infoButton:SFButton?
    var thumbnailImage:SFImageView?
    var badgeImage:SFImageView?
    var progressView:SFProgressView?
    var starRatingView:SFStarRatingView?
    var gridObject:SFGridObject?
    var separatorView:SFSeparatorView?
    var thumbnailImageType:String?
    var thumbnailInfo:SFLabel?
    var offSetValue:Int?
    weak var collectionGridCellDelegate:SFCollectionGridCellDelegate?

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        createGridView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createGridView() {
        
        thumbnailImage = SFImageView()
        self.addSubview(thumbnailImage!)
        thumbnailImage?.isHidden = true
        
        thumbnailTitle = SFLabel()
        thumbnailTitle?.isHidden = true
        self.addSubview(thumbnailTitle!)
        
        subHeadingLabel1 = SFLabel()
        self.addSubview(subHeadingLabel1!)
        subHeadingLabel1?.isHidden = true
        
        subHeadingLabel2 = SFLabel()
        self.addSubview(subHeadingLabel2!)
        subHeadingLabel2?.isHidden = true

        playButton = SFButton(frame: CGRect.zero)
        self.addSubview(playButton!)
        playButton?.buttonDelegate = self
        playButton?.isHidden = true
        
        infoButton = SFButton(frame: CGRect.zero)
        self.addSubview(infoButton!)
        infoButton?.buttonDelegate = self
        infoButton?.isHidden = true
        
        badgeImage = SFImageView()
        self.addSubview(badgeImage!)
        badgeImage?.isHidden = true
        
        progressView = SFProgressView()
        self.addSubview(progressView!)
        progressView?.isHidden = true
        
        starRatingView = SFStarRatingView()
        self.addSubview(starRatingView!)
        starRatingView?.isHidden = true
        
        separatorView = SFSeparatorView()
        self.addSubview(separatorView!)
        separatorView?.isHidden = true
        
        thumbnailInfo = SFLabel()
        self.addSubview(thumbnailInfo!)
        thumbnailInfo?.isHidden = true
    }
    
    func updateGridSubViewFrames() {
        
        for gridComponent in gridComponents {
            
            if gridComponent is SFLabelObject {
                
                createLabelView(labelObject: gridComponent as! SFLabelObject)
            }
            else if gridComponent is SFImageObject {
                
                createImageView(imageObject: gridComponent as! SFImageObject)
            }
            else if gridComponent is SFButtonObject {
                
                createbuttonView(buttonObject: gridComponent as! SFButtonObject)
            }
            else if gridComponent is SFProgressViewObject {
                
                createprogressView(progressViewObject: gridComponent as! SFProgressViewObject)
            }
            else if gridComponent is SFStarRatingObject {
                
                createStarRatingView(starRatingObject: gridComponent as! SFStarRatingObject)
            }
            else if gridComponent is SFSeparatorViewObject {
                
                createSeparatorView(separatorViewObject: gridComponent as! SFSeparatorViewObject)
            }
        }
    }
    
    func createLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        if labelObject.key != nil && labelObject.key == "thumbnailTitle" {
            thumbnailTitle?.isHidden = false
            thumbnailTitle?.relativeViewFrame = self.frame
            thumbnailTitle?.labelObject = labelObject
            thumbnailTitle?.text = gridObject?.contentTitle
            thumbnailTitle?.labelLayout = labelLayout
            thumbnailTitle?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            thumbnailTitle?.createLabelView()
            
            if thumbnailTitle?.text != nil {
                
                thumbnailTitle?.changeFrameHeight(height: (thumbnailTitle?.text?.height(withConstraintWidth: (thumbnailTitle?.frame.width)!, withConstraintHeight: (thumbnailTitle?.frame.size.height)!, font: (thumbnailTitle?.font)!))!)
            }
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                if let contentType = gridObject?.contentType {
                    
                    if contentType.lowercased() == Constants.kArticleContentType || contentType.lowercased() == Constants.kArticlesContentType {
                        
                        thumbnailTitle?.textColor = .black
                    }
                    else {
                        
                        thumbnailTitle?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
                    }
                }
            }
        }
        else if labelObject.key != nil && (labelObject.key == "thumbnailSubHeading1" || labelObject.key == "thumbnailDescription"){
            subHeadingLabel1?.relativeViewFrame = self.frame
            subHeadingLabel1?.labelObject = labelObject
            subHeadingLabel1?.labelLayout = labelLayout
            subHeadingLabel1?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            subHeadingLabel1?.createLabelView()
            subHeadingLabel1?.text = nil
            
            if let contentType = gridObject?.contentType {
                
                if contentType.lowercased() == Constants.kArticleContentType || contentType.lowercased() == Constants.kArticlesContentType {
                    
                    subHeadingLabel1?.textColor = .black
                    subHeadingLabel1?.text = gridObject?.contentDescription
                }
            }
            
            if subHeadingLabel1?.text != nil {
                
                subHeadingLabel1?.isHidden = false
            }
//            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
//
//                subHeadingLabel1?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
//            }
        }
        else if labelObject.key != nil && labelObject.key == "thumbnailSubHeading2" {
            subHeadingLabel2?.isHidden = false
            subHeadingLabel2?.relativeViewFrame = self.frame
            subHeadingLabel2?.labelLayout = labelLayout
            subHeadingLabel2?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            subHeadingLabel2?.labelObject = labelObject
            subHeadingLabel2?.createLabelView()
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                subHeadingLabel2?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
        else if labelObject.key != nil && labelObject.key == "thumbnailInfo" {
            thumbnailInfo?.relativeViewFrame = self.frame
            thumbnailInfo?.labelLayout = labelLayout
            thumbnailInfo?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            thumbnailInfo?.labelObject = labelObject
            thumbnailInfo?.createLabelView()
            thumbnailInfo?.text = nil
            
            if let contentType = gridObject?.contentType {
                
                if contentType.lowercased() == Constants.kArticleContentType || contentType.lowercased() == Constants.kArticlesContentType {
                    
                    if let totalTime: Double = gridObject?.totalTime {
                        thumbnailInfo?.text = totalTime.articleTimeFormattedString(interval: Int(totalTime))
                    }
                    
                    let separatorText:String = " | "
                    
                    if let publishTime:Double = gridObject?.publishedDate {
                        
                        if thumbnailInfo?.text != nil {
                            
                            thumbnailInfo?.text = thumbnailInfo?.text?.appending("\(separatorText)\(Utility.sharedUtility.getDateStringFromInterval(timeInterval: publishTime))")
                        }
                        else {
                            
                            thumbnailInfo?.text = Utility.sharedUtility.getDateStringFromInterval(timeInterval: publishTime)
                        }
                    }
                }
                else {
                    
                    //MSEIOS-1318 Issue fix
                    if let totalTime: Double = gridObject?.totalTime {
                        thumbnailInfo?.text = totalTime.timeFormattedString(interval: totalTime)
                    }
                }
            }
            
//
//            let separatorText:String = " | "
//
//            if let publishTime:Double = gridObject?.publishedDate {
//
//                MSEIOS-1318 Issue fix
//                if thumbnailInfo?.text != nil {
//
//                    thumbnailInfo?.text = thumbnailInfo?.text?.appending("\(separatorText)\(Utility.sharedUtility.getDateStringFromInterval(timeInterval: publishTime))")
//                }
//                else {
//
//                thumbnailInfo?.text = Utility.sharedUtility.getDateStringFromInterval(timeInterval: publishTime)
//                }
//            }
            
            if let hugsContent = labelObject.hugsContent {
                if hugsContent {
                    thumbnailInfo?.hugContent()
                }
            }
            
            if thumbnailInfo?.text != nil {
                
                thumbnailInfo?.isHidden = false
            }
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                thumbnailInfo?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
    }
    
    func createImageView(imageObject:SFImageObject) {
        
        if imageObject.key != nil && imageObject.key == "thumbnailImage" {
            thumbnailImage?.isHidden = false
            thumbnailImage?.relativeViewFrame = self.frame
            thumbnailImage?.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
            thumbnailImage?.imageViewObject = imageObject
            thumbnailImage?.updateView()
            thumbnailImage?.contentMode = .scaleAspectFit
            
            var imageURL:String?
            var placeHolderImage:String?
            
            if self.gridObject != nil {
                
                for image in (self.gridObject?.images)! {
                    
                    let imageObj: SFImage = image as! SFImage
                    
                    if thumbnailImageType == "portrait" {
                        
                        if imageObj.imageType == Constants.kSTRING_IMAGETYPE_POSTER
                        {
                            imageURL = imageObj.imageSource
                            placeHolderImage = Constants.kPosterImagePlaceholder
                            break
                        }
                    }
                    else {
                        
                        if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO {
                            
                            imageURL = imageObj.imageSource
                            placeHolderImage = Constants.kVideoImagePlaceholder
                            break
                        }
                    }
                }
            }
           
            if imageURL == nil {
                
                if thumbnailImageType == "portrait" {
                    
                    imageURL = gridObject?.posterImageURL
                    placeHolderImage = Constants.kPosterImagePlaceholder
                }
                else {
                    imageURL = gridObject?.thumbnailImageURL
                    placeHolderImage = Constants.kVideoImagePlaceholder
                }
            }
            if placeHolderImage == nil {
                
                if thumbnailImageType == "portrait" {
                    
                    placeHolderImage = Constants.kPosterImagePlaceholder
                }
                else {
                    
                    placeHolderImage = Constants.kVideoImagePlaceholder
                }
            }
            
            if imageURL != nil {
                
                imageURL = imageURL?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: thumbnailImage?.frame.size.width ?? 0))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: thumbnailImage?.frame.size.height ?? 0))")
                imageURL = imageURL?.trimmingCharacters(in: .whitespaces)

                if let imageUrl = URL(string: imageURL!) {
                    
                    thumbnailImage?.af_setImage(
                        withURL: imageUrl,
                        placeholderImage: UIImage(named: placeHolderImage!),
                        filter: nil,
                        imageTransition: .crossDissolve(0.2)
                    )
                }
                else {
                    
                    thumbnailImage?.image = UIImage(named: placeHolderImage!)
                }
            }
            else {
                thumbnailImage?.image = UIImage(named: placeHolderImage!)
            }
        }
        else if imageObject.key != nil && (imageObject.key == "badgeImage" || imageObject.key == "thumbnailBadgeImage") {
            
            badgeImage?.relativeViewFrame = self.frame
            badgeImage?.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
            badgeImage?.imageViewObject = imageObject
            badgeImage?.updateView()
            badgeImage?.contentMode = .scaleAspectFit
            
            var imageURL:String?
            
            if self.gridObject != nil {
                
                for image in (self.gridObject?.images)! {
                    
                    let imageObj: SFImage = image as! SFImage
                    if thumbnailImageType == "portrait" {
                        
                        if imageObj.imageType == Constants.kSTRING_IMAGETYPE_POSTER
                        {
                            imageURL = imageObj.badgeImageUrl
                            break
                        }
                    }
                    else {
                        
                        if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO {
                            
                            imageURL = imageObj.badgeImageUrl
                            break
                        }
                    }
                }
            }
            
            if imageURL != nil {
                
                imageURL = imageURL?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: badgeImage?.frame.size.width ?? 0))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: badgeImage?.frame.size.height ?? 0))")
                imageURL = imageURL?.trimmingCharacters(in: .whitespaces)
                
                if imageURL != nil && !(imageURL?.isEmpty)! {
                    
                    if let imageUrl = URL(string: imageURL!) {
                        
                        badgeImage?.isHidden = false
                        badgeImage?.af_setImage(
                            withURL: imageUrl,
                            placeholderImage: nil,
                            filter: nil,
                            imageTransition: .crossDissolve(0.2)
                        )
                    }
                }
                else {
                    
                    badgeImage?.isHidden = true
                }
            }
            else {
                
                badgeImage?.isHidden = true
            }
        }

    }
    
    func createprogressView(progressViewObject:SFProgressViewObject) {
        
        if gridObject?.watchedTime ?? 0 > 0 {
        
            progressView?.isHidden = false
            
            progressView?.frame = CGRect(x: (thumbnailImage?.frame.minX)!, y: (thumbnailImage?.frame.maxY)!-10, width: (thumbnailImage?.frame.width)!, height: 10)
            progressView?.progressTintColor = UIColor.red
            progressView?.trackTintColor = UIColor.black
            progressView?.progress = (Float) ((gridObject?.watchedTime ?? 0) / (gridObject?.totalTime ?? 0))
        }
        else {
            
            progressView?.isHidden = true
        }
    }
    
    func createStarRatingView(starRatingObject:SFStarRatingObject) {
    }
    
    func createbuttonView(buttonObject:SFButtonObject) {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        
        if buttonObject.key != nil && buttonObject.key == "gridOptions" {
            infoButton?.isHidden = false
            infoButton?.buttonObject = buttonObject
            infoButton?.relativeViewFrame = self.frame
            infoButton?.initialiseButtonFrameFromLayout(buttonLayout: Utility.fetchButtonLayoutDetails(buttonObject: buttonObject))
            
            var gridOptionImageName = "gridOptions"
            
            if let contentType = gridObject?.contentType {
                
                if contentType.lowercased() == Constants.kArticleContentType || contentType.lowercased() == Constants.kArticlesContentType {
                    
                    gridOptionImageName = "articleGridOptions"
                }
            }
            let infoButtonImageView: UIImageView = UIImageView.init(image: UIImage(named: gridOptionImageName))
            
            infoButton?.setImage(infoButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            infoButton?.imageView?.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")
        }
        else if buttonObject.key != nil && buttonObject.key == "add" {
            infoButton?.isHidden = false
            infoButton?.relativeViewFrame = self.frame
            infoButton?.initialiseButtonFrameFromLayout(buttonLayout: Utility.fetchButtonLayoutDetails(buttonObject: buttonObject))
        }
        else if buttonObject.key != nil && buttonObject.key == "play" {
            
            playButton?.isHidden = false
            playButton?.buttonObject = buttonObject
            playButton?.relativeViewFrame = self.frame
            let playButtonImageView: UIImageView = UIImageView.init(image: UIImage(named: "play"))
            
            playButton?.setImage(playButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            playButton?.imageView?.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")
            
            playButton?.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        }
    }
    
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        separatorView?.isHidden = false
        separatorView?.relativeViewFrame = self.frame
        separatorView?.separtorViewObject = separatorViewObject
        separatorView?.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject))
    }
    
    func updateGridViewFrames() {
        
    }
    
    //MARK: Button Delegate method
    func buttonClicked(button: SFButton) {
        
        if self.collectionGridCellDelegate != nil {
            
            if (collectionGridCellDelegate?.responds(to: #selector(SFCollectionGridCellDelegate.buttonClicked(button:gridObject:))))! {
                
                collectionGridCellDelegate?.buttonClicked!(button: button, gridObject: gridObject)
            }
        }
    }
}
