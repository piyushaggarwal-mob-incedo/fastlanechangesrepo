//
//  SFCollectionGridCell_tvOS.swift
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

class SFCollectionGridCell_tvOS: UICollectionViewCell {
    
    var gridComponents:Array<Any> = []
    var thumbnailTitle:SFLabel?
    var subHeadingLabel1:SFLabel?
    var subHeadingLabel2:SFLabel?
    var durationBadgeLabel:SFLabel?
    var playButton:SFButton?
    var infoButton:SFButton?
    var thumbnailImage:SFImageView?
    var badgeImage:SFImageView?
    var progressView:SFProgressView_tvOS?
    var gridObject:SFGridObject?
    var separatorView:SFSeparatorView?
    var thumbnailImageType:String?
    var trayType:String?
    var backgroundImageView:UIImageView?
    var offSetValue:Int?
    private var _originalThumbnailTitleYAxis:CGFloat?
    private var originalThumbnailTitleYAxis:CGFloat? {
        set(newValue) {
            _originalThumbnailTitleYAxis = newValue
        } get {
            return _originalThumbnailTitleYAxis
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        createGridView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createGridView() {
        
        backgroundImageView = UIImageView()
        self.addSubview(backgroundImageView!)
        backgroundImageView?.isHidden = true

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
        
        durationBadgeLabel = SFLabel()
//        self.addSubview(durationBadgeLabel!)
        durationBadgeLabel?.isHidden = true

        playButton = SFButton(frame: CGRect.zero)
        self.addSubview(playButton!)
        playButton?.isHidden = true
        
        infoButton = SFButton(frame: CGRect.zero)
        self.addSubview(infoButton!)
        infoButton?.isHidden = true
        
        badgeImage = SFImageView()
        self.addSubview(badgeImage!)
        badgeImage?.isHidden = true
        
        progressView = SFProgressView_tvOS(frame: CGRect.zero)
        self.addSubview(progressView!)
        progressView?.isHidden = true
        
        separatorView = SFSeparatorView()
        self.addSubview(separatorView!)
        separatorView?.isHidden = true
        
        #if os(tvOS)
            backgroundImageView?.adjustsImageWhenAncestorFocused = true
            thumbnailImage?.adjustsImageWhenAncestorFocused = true
            if #available(tvOS 11.0, *) {
                badgeImage?.adjustsImageWhenAncestorFocused = true
                badgeImage?.masksFocusEffectToContents = true
            }
        #endif

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
            originalThumbnailTitleYAxis = (thumbnailTitle?.frame.origin.y)!
        }
        else if labelObject.key != nil && labelObject.key == "thumbnailSubHeading1" {
            subHeadingLabel1?.isHidden = false
            subHeadingLabel1?.relativeViewFrame = self.frame
            subHeadingLabel1?.labelObject = labelObject
            subHeadingLabel1?.labelLayout = labelLayout
            subHeadingLabel1?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            subHeadingLabel1?.createLabelView()
        }
        else if labelObject.key != nil && labelObject.key == "thumbnailSubHeading2" {
            subHeadingLabel2?.isHidden = false
            subHeadingLabel2?.relativeViewFrame = self.frame
            subHeadingLabel2?.labelLayout = labelLayout
            subHeadingLabel2?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            subHeadingLabel2?.labelObject = labelObject
            subHeadingLabel2?.createLabelView()
        }
        else if labelObject.key != nil && labelObject.key == "durationBadgeLabel" {
            durationBadgeLabel?.isHidden = false
            durationBadgeLabel?.relativeViewFrame = self.frame
            durationBadgeLabel?.labelLayout = labelLayout
            durationBadgeLabel?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            durationBadgeLabel?.labelObject = labelObject
            durationBadgeLabel?.createLabelView()
            if let totalTime: Double = gridObject?.totalTime {
                var dateString: String = ""
                if let displayDuration = AppConfiguration.sharedAppConfiguration.durationMetaData.displayDuration{
                    if displayDuration{
                        dateString = "\(totalTime.timeFormattedString(interval: totalTime))"
                        if let displayPublishedDate = AppConfiguration.sharedAppConfiguration.durationMetaData.displayPublishDate{
                            if displayPublishedDate{
                                if let publishDate: Double = gridObject?.publishedDate {
                                    let pubString = Utility.sharedUtility.getDateStringFromIntervalWithPunctuationMark(timeInterval: publishDate)
                                    dateString = dateString + " | \(pubString)"
                                }
                            }
                        }
                        durationBadgeLabel?.isHidden = false
                        durationBadgeLabel?.text = dateString
                    }
                    else{
                        if let displayPublishedDate = AppConfiguration.sharedAppConfiguration.durationMetaData.displayPublishDate{
                            if displayPublishedDate{
                                if let publishDate: Double = gridObject?.publishedDate {
                                    let pubString = Utility.sharedUtility.getDateStringFromIntervalWithPunctuationMark(timeInterval: publishDate)
                                    dateString = "\(pubString)"
                                }
                                durationBadgeLabel?.isHidden = false
                                durationBadgeLabel?.text = dateString
                            }
                        }
                    }
                }
                else{
                    if let displayPublishedDate = AppConfiguration.sharedAppConfiguration.durationMetaData.displayPublishDate{
                        if displayPublishedDate{
                            if let publishDate: Double = gridObject?.publishedDate {
                                let pubString = Utility.sharedUtility.getDateStringFromIntervalWithPunctuationMark(timeInterval: publishDate)
                                dateString = "\(pubString)"
                            }
                            durationBadgeLabel?.isHidden = false
                            durationBadgeLabel?.text = dateString
                        }
                    }
                }
                
            }
            if let hugsContent = labelObject.hugsContent {
                if hugsContent {
                    durationBadgeLabel?.hugContent()
                }
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
            
            //TODO: Update logic.
            //Create a background imageView
            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports{
                if let _trayType = trayType{
                    if _trayType != "AC Tray 03"{
                        backgroundImageView?.frame = CGRect(x: -5.0, y: -5.0, width: (thumbnailImage?.bounds.size.width)! + 10, height: (thumbnailImage?.bounds.size.height)! + 10)
                        backgroundImageView?.image = UIImage(color:Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "ffffff"))
                    }
                    else{
                        backgroundImageView?.frame = CGRect(x: -10.0, y: -5.0, width: (thumbnailImage?.bounds.size.width)! + 20, height: self.bounds.size.height-5)
                        setGradientOnThumbnailImage()
                    }
                }
                else{
                    backgroundImageView?.frame = CGRect(x: -10.0, y: -5.0, width: (thumbnailImage?.bounds.size.width)! + 20, height: self.bounds.size.height-5)
                    setGradientOnThumbnailImage()
                }
                
            } else  if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment{
                backgroundImageView?.frame = CGRect(x: -5.0, y: -5.0, width: (thumbnailImage?.bounds.size.width)! + 10, height: (thumbnailImage?.bounds.size.height)! + 10)
                backgroundImageView?.image = UIImage(color:Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "ffffff"))
            }
            thumbnailImage?.contentMode = .scaleToFill
            
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
            
//            if thumbnailImage?.imageType == SFImageViewType.portrait{
//                imageURL = gridObject?.posterImageURL
//            }
//            else{
//                imageURL = gridObject?.thumbnailImageURL
//                placeHolderImage  = Constants.kVideoImagePlaceholder
//            }
//            if thumbnailImageType == "portrait" {
//                imageURL = gridObject?.posterImageURL
//            }
//            else {
//                imageURL = gridObject?.thumbnailImageURL
//                placeHolderImage  = Constants.kVideoImagePlaceholder
//            }
            
            if imageURL != nil && imageURL?.isEmpty == false {
                imageURL = imageURL?.appending("?impolicy=resize&w=\(thumbnailImage?.frame.size.width ?? 0)&h=\(thumbnailImage?.frame.size.height ?? 0)")
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
            badgeImage?.contentMode = .scaleToFill
            badgeImage?.frame = (thumbnailImage?.frame)!
            
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
                
                imageURL = imageURL?.appending("?impolicy=resize&w=\(badgeImage?.frame.size.width ?? 0)&h=\(badgeImage?.frame.size.height ?? 0)")
                imageURL = imageURL?.trimmingCharacters(in: .whitespaces)
                
                if imageURL != nil && !(imageURL?.isEmpty)! {
                    
                    badgeImage?.isHidden = false
//                    badgeImage?.image = UIImage(named: "1-1.png")
                    badgeImage?.af_setImage(
                        withURL: URL(string: imageURL!)!,
                        placeholderImage: nil,
                        filter: nil,
                        imageTransition: .crossDissolve(0.2)
                    )
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
    
    //MARK: Create Progress view
    func createprogressView(progressViewObject:SFProgressViewObject) {
        
        if gridObject?.watchedTime ?? 0 > 0 {
            
            progressView?.progressViewObject = progressViewObject
            progressView?.progress = (CGFloat)((gridObject?.watchedTime ?? 0) / (gridObject?.totalTime ?? 0))
            progressView?.isHidden = false
        }
        else {
            progressView?.isHidden = true
        }
        
        updateProgressView(progressView: progressView!)
    }
    
    //MARK: Update Progress view frame
    func updateProgressView(progressView:SFProgressView_tvOS) {
        
        if progressView.progressViewObject != nil {
            progressView.relativeViewFrame = self.frame
            let progressViewLayout:LayoutObject = Utility.fetchProgresViewLayoutDetails(progressViewObject: progressView.progressViewObject!)
            progressView.initialiseProgressViewFrameFromLayout(progressViewLayout: progressViewLayout)
            
            self.bringSubview(toFront: progressView)
        }
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
            playButton?.isHidden = true
            playButton?.relativeViewFrame = self.frame
            playButton?.isUserInteractionEnabled = false
            
            if gridObject?.watchedTime ?? 0 > 0 {
                playButton?.setImage(UIImage(named: "resume"), for: .normal)
            }
            else {
                playButton?.setImage(UIImage(named: "play"), for: .normal)
            }
            
            playButton?.frame = CGRect(x: (thumbnailImage?.frame.midX)! - (playButton?.imageView?.image?.size.width)!/2, y: (thumbnailImage?.frame.midY)! - (playButton?.imageView?.image?.size.height)!/2, width: 92, height: 92)
            //playButton?.initialiseButtonFrameFromLayout(buttonLayout: Utility.fetchButtonLayoutDetails(buttonObject: buttonObject))
        }
    }
    
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        separatorView?.isHidden = false
        separatorView?.relativeViewFrame = self.frame
        separatorView?.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject))
    }
    
    func updateGridView() {
        
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    
        coordinator.addCoordinatedAnimations({
            
            if self.isFocused {
                let nextFocusedCell = context.nextFocusedView as! SFCollectionGridCell_tvOS
                var widthDifference = (nextFocusedCell.thumbnailImage?.focusedFrameGuide.layoutFrame.size.width)! - (self.bounds.width)
                widthDifference = abs(widthDifference/2)
                nextFocusedCell.thumbnailTitle?.changeFrameXAxis(xAxis: (nextFocusedCell.thumbnailImage?.focusedFrameGuide.layoutFrame.origin.x)!)
                nextFocusedCell.progressView?.changeFrameXAxis(xAxis: (nextFocusedCell.thumbnailImage?.focusedFrameGuide.layoutFrame.origin.x)!)
                nextFocusedCell.thumbnailTitle?.changeFrameWidth(width: (self.bounds.width) + widthDifference)
                nextFocusedCell.progressView?.changeFrameWidth(width: (nextFocusedCell.thumbnailImage?.focusedFrameGuide.layoutFrame.size.width)!)
                var heightDifference = (nextFocusedCell.thumbnailImage?.focusedFrameGuide.layoutFrame.size.height)! - (self.thumbnailImage?.bounds.height)!;
                heightDifference = heightDifference/2
                if let originalYAxis = self.originalThumbnailTitleYAxis {
                    nextFocusedCell.thumbnailTitle?.changeFrameYAxis(yAxis: originalYAxis + heightDifference )
                } else {
                    nextFocusedCell.thumbnailTitle?.changeFrameYAxis(yAxis: (self.bounds.height) + heightDifference )
                }
                if #available(tvOS 11.0, *) {
                }
                else{
                    nextFocusedCell.badgeImage?.frame = (nextFocusedCell.thumbnailImage?.focusedFrameGuide.layoutFrame)!
                    Utility.addMotionEffectToViewWithStrength(viewItem: nextFocusedCell.badgeImage!, strength: 6)
                }
               
                nextFocusedCell.progressView?.changeFrameYAxis(yAxis: (nextFocusedCell.thumbnailImage?.focusedFrameGuide.layoutFrame.size.height)! - heightDifference - (nextFocusedCell.progressView?.bounds.size.height)!)
                self.backgroundImageView?.isHidden = false
                Utility.addMotionEffectToViewWithStrength(viewItem: nextFocusedCell.progressView!, strength: 12)
                nextFocusedCell.durationBadgeLabel?.changeFrameXAxis(xAxis: (nextFocusedCell.thumbnailImage?.focusedFrameGuide.layoutFrame.origin.x)!)
                nextFocusedCell.durationBadgeLabel?.changeFrameYAxis(yAxis: (nextFocusedCell.durationBadgeLabel?.frame.origin.y)! + heightDifference)
                Utility.addMotionEffectToViewWithStrength(viewItem: nextFocusedCell.durationBadgeLabel!, strength: 12)
            }
            else {
                let previousFocusedCell = context.previouslyFocusedView as! SFCollectionGridCell_tvOS
                var widthDifference = (previousFocusedCell.thumbnailImage?.focusedFrameGuide.layoutFrame.size.width)! - (self.bounds.width)
                widthDifference = abs(widthDifference/2)
                previousFocusedCell.thumbnailTitle?.changeFrameXAxis(xAxis: (self.thumbnailTitle?.bounds.minX)!)
                previousFocusedCell.thumbnailTitle?.changeFrameWidth(width: (self.bounds.width))
                if let originalYAxis = self.originalThumbnailTitleYAxis {
                    previousFocusedCell.thumbnailTitle?.changeFrameYAxis(yAxis: originalYAxis)
                } else {
                    previousFocusedCell.thumbnailTitle?.changeFrameYAxis(yAxis: (self.bounds.height))
                }
                previousFocusedCell.progressView?.changeFrameWidth(width: (self.bounds.width))
                previousFocusedCell.progressView?.changeFrameXAxis(xAxis: (self.thumbnailTitle?.bounds.minX)!)
                previousFocusedCell.progressView?.changeFrameYAxis(yAxis: (previousFocusedCell.thumbnailImage?.frame.size.height)! - (previousFocusedCell.progressView?.bounds.size.height)!)
                if #available(tvOS 11.0, *) {
                }
                else{
                    previousFocusedCell.badgeImage?.frame = (previousFocusedCell.thumbnailImage?.frame)!
                    Utility.removeMotionEffectFromView(viewItem: previousFocusedCell.badgeImage!)
                }
                let heightDifference = (previousFocusedCell.thumbnailImage?.focusedFrameGuide.layoutFrame.size.height)! - (self.thumbnailImage?.bounds.height)!;
                previousFocusedCell.durationBadgeLabel?.changeFrameXAxis(xAxis: (previousFocusedCell.thumbnailImage?.frame.origin.x)!)
                previousFocusedCell.durationBadgeLabel?.changeFrameYAxis(yAxis: (previousFocusedCell.durationBadgeLabel?.frame.origin.y)! - (heightDifference / 2))
                self.backgroundImageView?.isHidden = true
                Utility.removeMotionEffectFromView(viewItem: previousFocusedCell.progressView!)
                Utility.removeMotionEffectFromView(viewItem: previousFocusedCell.durationBadgeLabel!)
            }
        })
    }
    
    private func setGradientOnThumbnailImage() {
        let appBackgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        let appPrimaryHover = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "000000")
        var startColor = RGBA(red: appBackgroundColor.redValue, green: appBackgroundColor.greenValue, blue: appBackgroundColor.blueValue, alpha: appBackgroundColor.alphaValue)
        var endColor = RGBA(red: appPrimaryHover.redValue, green: appPrimaryHover.greenValue, blue: appPrimaryHover.blueValue, alpha: appPrimaryHover.alphaValue)
        let swapColor = startColor
        //Invert for applications where primary hover and app text color is same as in TampaBay.
        if (AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "000000") == (AppConfiguration.sharedAppConfiguration.appTextColor ?? "000000") {
            startColor = endColor
            endColor = swapColor
        }
        let gradientImage = UIImage.image(withRGBAGradientPoints: [GradientPoint(location: 0, color: startColor), GradientPoint(location: 1, color: endColor)], size: CGSize(width: (thumbnailImage?.bounds.size.width)! + 20, height: self.bounds.size.height-5))
        backgroundImageView?.image = gradientImage
    }
    
}
