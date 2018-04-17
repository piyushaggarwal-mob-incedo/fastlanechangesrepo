//
//  SFVerticalCollectionGridCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 15/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import AlamofireImage

@objc protocol SFVerticalCollectionGridCellDelegate:NSObjectProtocol {
    @objc optional func buttonClicked(button:SFButton, gridObject:SFGridObject?) -> Void
}

class SFVerticalCollectionGridCell: UICollectionViewCell, SFButtonDelegate {
    
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
    var offSetValue:Int?
    weak var collectionGridCellDelegate:SFVerticalCollectionGridCellDelegate?
    
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
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                thumbnailTitle?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            thumbnailTitle?.font = UIFont(name: (thumbnailTitle?.font.fontName)!, size: (thumbnailTitle?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
            
            if labelLayout.width != nil {
                
                thumbnailTitle?.changeFrameWidth(width: (thumbnailTitle?.frame.size.width)! * Utility.getBaseScreenWidthMultiplier())
            }
            
            thumbnailTitle?.changeFrameHeight(height: (thumbnailTitle?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
            thumbnailTitle?.changeFrameYAxis(yAxis: (thumbnailTitle?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
        }
        else if labelObject.key != nil && labelObject.key == "thumbnailSubHeading1" {
            subHeadingLabel1?.isHidden = false
            subHeadingLabel1?.relativeViewFrame = self.frame
            subHeadingLabel1?.labelObject = labelObject
            subHeadingLabel1?.labelLayout = labelLayout
            subHeadingLabel1?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            subHeadingLabel1?.createLabelView()
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                subHeadingLabel1?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            subHeadingLabel1?.changeFrameWidth(width: (subHeadingLabel1?.frame.size.width)! * Utility.getBaseScreenWidthMultiplier())
            subHeadingLabel1?.changeFrameHeight(height: (subHeadingLabel1?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
            subHeadingLabel1?.changeFrameYAxis(yAxis: (subHeadingLabel1?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
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
            
            subHeadingLabel2?.changeFrameWidth(width: (subHeadingLabel2?.frame.size.width)! * Utility.getBaseScreenWidthMultiplier())
            subHeadingLabel2?.changeFrameHeight(height: (subHeadingLabel2?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
            subHeadingLabel2?.changeFrameYAxis(yAxis: (subHeadingLabel2?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
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
            
            thumbnailImage?.changeFrameWidth(width: (thumbnailImage?.frame.size.width)! * Utility.getBaseScreenWidthMultiplier())
            thumbnailImage?.changeFrameHeight(height: (thumbnailImage?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
            thumbnailImage?.changeFrameYAxis(yAxis: (thumbnailImage?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
            
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
        else if imageObject.key != nil && imageObject.key == "badgeImage" {
            badgeImage?.relativeViewFrame = self.frame
            badgeImage?.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
            
            badgeImage?.imageViewObject = imageObject
            badgeImage?.updateView()
            badgeImage?.contentMode = .scaleAspectFit
            
            badgeImage?.changeFrameWidth(width: (badgeImage?.frame.size.width)! * Utility.getBaseScreenWidthMultiplier())
            badgeImage?.changeFrameHeight(height: (badgeImage?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
            badgeImage?.changeFrameYAxis(yAxis: (badgeImage?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
            
            var imageURL:String?
            
            if self.gridObject != nil {
 
                for image in (self.gridObject?.images)! {
                    
                    let imageObj: SFImage = image as! SFImage
                    if thumbnailImageType == "portrait" {
                        
                        if imageObj.imageType == Constants.kSTRING_IMAGETYPE_POSTER
                        {
                            imageURL = imageObj.badgeImageUrl
                        }
                    }
                    else {
                        
                        if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO {
                            
                            imageURL = imageObj.badgeImageUrl
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
        
        if buttonObject.key != nil && buttonObject.key == "info" {
            infoButton?.isHidden = false
            infoButton?.relativeViewFrame = self.frame
            infoButton?.initialiseButtonFrameFromLayout(buttonLayout: Utility.fetchButtonLayoutDetails(buttonObject: buttonObject))
        }
        else if buttonObject.key != nil && buttonObject.key == "add" {
            infoButton?.isHidden = false
            infoButton?.relativeViewFrame = self.frame
            infoButton?.initialiseButtonFrameFromLayout(buttonLayout: Utility.fetchButtonLayoutDetails(buttonObject: buttonObject))
        }
        
        if buttonObject.key != nil && buttonObject.key == "play" {
            
            let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
            
            playButton?.isHidden = false
            playButton?.buttonObject = buttonObject
            playButton?.relativeViewFrame = self.frame
            let playButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "play.png"))
            
            playButton?.setImage(playButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            playButton?.imageView?.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")
            
            playButton?.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
            
            playButton?.changeFrameWidth(width: (playButton?.frame.size.width)! * Utility.getBaseScreenWidthMultiplier())
            playButton?.changeFrameHeight(height: (playButton?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
            
            if buttonLayout.height != nil {
                
                playButton?.changeFrameYAxis(yAxis: ceil((playButton?.frame.origin.y)! - ((playButton?.frame.size.height)! - CGFloat(buttonLayout.height!))))
            }
            
            if buttonLayout.width != nil {
                
                playButton?.changeFrameXAxis(xAxis: ceil((playButton?.frame.origin.x)! + ((playButton?.frame.size.width)! - CGFloat(buttonLayout.width!))))
            }
        }
    }
    
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        separatorView?.isHidden = false
        separatorView?.relativeViewFrame = self.frame
        separatorView?.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject))
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
