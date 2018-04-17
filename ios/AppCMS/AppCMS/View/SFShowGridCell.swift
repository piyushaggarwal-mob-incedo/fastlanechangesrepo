//
//  SFShowGridCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 20/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol SFShowGridCellDelegate:NSObjectProtocol {
    @objc optional func buttonClicked(button:SFButton, film:SFFilm?, cellRowValue:Int) -> Void
}

class SFShowGridCell: UICollectionViewCell, SFButtonDelegate {
    
    var gridComponents:Array<Any> = []
    var videoTitle:SFLabel?
    var videoDescription:SFLabel?
    var videoDuration:SFLabel?
    var playButton:SFButton?
    var videoImage:SFImageView?
    var badgeImage:SFImageView?
    var progressView:SFProgressView?
    var separatorView:SFSeparatorView?
    var thumbnailImageType:String?
    var downloadButton:SFButton?
    var relativeViewFrame:CGRect?
    var cellRowValue:Int = 0
    var episodeNumber:Int?
    var roundProgressView:RoundProgressBar?
    var film : SFFilm?
    private var progressIndicator:MBProgressHUD?
    
    weak var showGridCellDelegate:SFShowGridCellDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        createCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Creating CellView
    func createCellView() {
        
        videoImage = SFImageView()
        self.addSubview(videoImage!)
        videoImage?.isHidden = true
        videoImage?.isUserInteractionEnabled = false
        
        videoTitle = SFLabel()
        videoTitle?.isHidden = true
        self.addSubview(videoTitle!)
        videoTitle?.isUserInteractionEnabled = false

        progressView = SFProgressView(progressViewStyle: .bar)
        self.addSubview(progressView!)
        progressView?.isHidden = true
        progressView?.isUserInteractionEnabled = false

        videoDescription = SFLabel()
        self.addSubview(videoDescription!)
        videoDescription?.isHidden = true
        videoDescription?.isUserInteractionEnabled = false

        videoDuration = SFLabel()
        self.addSubview(videoDuration!)
        videoDuration?.isHidden = true
        videoDuration?.isUserInteractionEnabled = false

        playButton = SFButton(frame: CGRect.zero)
        playButton?.buttonDelegate = self
        self.addSubview(playButton!)
        playButton?.isHidden = true
        playButton?.isUserInteractionEnabled = false

        badgeImage = SFImageView()
        self.addSubview(badgeImage!)
        badgeImage?.isHidden = true
        badgeImage?.isUserInteractionEnabled = false

        downloadButton = SFButton()
        downloadButton?.buttonDelegate = self
        self.addSubview(downloadButton!)
        downloadButton?.isHidden = true

        separatorView = SFSeparatorView()
        self.addSubview(separatorView!)
        separatorView?.isHidden = true
        separatorView?.isUserInteractionEnabled = false
    }
    
    
    //MARK: Update Cell components
    //Reusing it in tableview cell to update cell contents
    func updateGridSubView() {
        
        for cellComponent in gridComponents {
            
            if cellComponent is SFLabelObject {
                
                createLabelView(labelObject: cellComponent as! SFLabelObject)
            }
            else if cellComponent is SFImageObject {
                
                createImageView(imageObject: cellComponent as! SFImageObject)
            }
            else if cellComponent is SFButtonObject {
                
                createButtonView(buttonObject: cellComponent as! SFButtonObject)
            }
            else if cellComponent is SFProgressViewObject {
                
                createProgressView(progressViewObject: cellComponent as! SFProgressViewObject)
            }
            else if cellComponent is SFSeparatorViewObject {
                
                createSeparatorView(separatorViewObject: cellComponent as! SFSeparatorViewObject)
            }
        }
    }
    
    
    //MARK: Create label view
    func createLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        if labelObject.key != nil && labelObject.key == "episodeTitle" {
            videoTitle?.isHidden = false
            videoTitle?.relativeViewFrame = relativeViewFrame
            videoTitle?.labelObject = labelObject
            videoTitle?.text = film?.title
            videoTitle?.labelLayout = labelLayout
            videoTitle?.createLabelView()
            videoTitle?.font = UIFont(name: (videoTitle?.font.fontName)!, size: (videoTitle?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                videoTitle?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            var episodeNumberString = ""
            
            if episodeNumber != nil {
                
                episodeNumberString = "\(episodeNumber!)"
            }
            
            videoTitle?.attributedText = self.createEpisodeTitle(episodeNumber: episodeNumberString, episodeTitle: film?.title ?? "")
        }
        else if labelObject.key != nil && labelObject.key == "description" {
            videoDescription?.isHidden = false
            videoDescription?.numberOfLines = 0
            videoDescription?.relativeViewFrame = relativeViewFrame
            videoDescription?.labelObject = labelObject
            videoDescription?.labelLayout = labelLayout
            videoDescription?.text = film?.desc
            videoDescription?.createLabelView()
            videoDescription?.font = UIFont(name: (videoDescription?.font.fontName)!, size: (videoDescription?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                videoDescription?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!).withAlphaComponent(0.6)
            }
            else {
                
                videoDescription?.textColor = videoDescription?.textColor.withAlphaComponent(0.6)
            }
        }
        else if labelObject.key != nil && labelObject.key == "duration" {
            videoDuration?.isHidden = false
            videoDuration?.relativeViewFrame = relativeViewFrame
            videoDuration?.labelLayout = labelLayout
            videoDuration?.labelObject = labelObject
            videoDuration?.createLabelView()
            videoDuration?.font = UIFont(name: (videoDuration?.font.fontName)!, size: (videoDuration?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
            videoDuration?.text = getVideoDurationString(totalTime: Double(film?.durationSeconds ?? 0))
            videoDuration?.numberOfLines = 2
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                videoDuration?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!).withAlphaComponent(0.51)
            }
            else {
                
                videoDuration?.textColor = videoDuration?.textColor.withAlphaComponent(0.51)
            }
        }
    }
    
    func getVideoDurationString(totalTime:Double?) -> String {
        
        let totalTimeInMinutes:Int = Int(totalTime ?? 0)/60
        var totalTimeValue:String = ""
        
        if totalTimeInMinutes >= 1 {
            
            totalTimeValue = "\(totalTimeInMinutes) MIN"
        }
        else {
            
            totalTimeValue = "\(totalTimeInMinutes) SEC"
        }
        
        return totalTimeValue
    }
    
    //MARK: Create Image view
    func createImageView(imageObject:SFImageObject) {
        
        if imageObject.key != nil && imageObject.key == "thumbnailImage" {
            
            videoImage?.isHidden = false
            videoImage?.relativeViewFrame = relativeViewFrame
            videoImage?.imageViewObject = imageObject
            videoImage?.updateView()
            
            var imageURL:String?
            var placeholderImagePath:String?
            
            if self.film != nil {
                
                for image in (self.film?.images)! {
                    
                    let imageObj: SFImage = image as! SFImage

                    if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO || imageObj.imageType == Constants.kSTRING_IMAGETYPE_WIDGET {
                        
                        imageURL = imageObj.imageSource
                        break
                    }
                }
            }
           
            if imageURL == nil {
                
                imageURL = film?.thumbnailImageURL
            }
            
            placeholderImagePath = Constants.kVideoImagePlaceholder
            
            if imageURL != nil {
                
                videoImage?.contentMode = .scaleAspectFit
                imageURL = imageURL?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: videoImage?.frame.size.width ?? 0))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: videoImage?.frame.size.height ?? 0))")
                imageURL = imageURL?.trimmingCharacters(in: .whitespaces)
                
                if imageURL != nil {
                    
                    if let imageUrl = URL(string: imageURL!) {
                        
                        videoImage?.af_setImage(
                            withURL: imageUrl,
                            placeholderImage: UIImage(named: placeholderImagePath!),
                            filter: nil,
                            imageTransition: .crossDissolve(0.2)
                        )
                    }
                    else {
                        
                        videoImage?.contentMode = .scaleToFill
                        videoImage?.image = UIImage(named: placeholderImagePath!)
                    }
                }
                else {
                    
                    videoImage?.contentMode = .scaleToFill
                    videoImage?.image = UIImage(named: placeholderImagePath!)
                }
            }
            else {
                
                videoImage?.contentMode = .scaleToFill
                videoImage?.image = UIImage(named: placeholderImagePath!)
            }
        }
        else if imageObject.key != nil && imageObject.key == "badgeImage" {
            
            badgeImage?.isHidden = false
            badgeImage?.imageViewObject = imageObject
            badgeImage?.relativeViewFrame = relativeViewFrame
            badgeImage?.updateView()
            
            var imageURL:String?

            if self.film != nil {
                
                for image in (self.film?.images)! {
                    
                    let imageObj: SFImage = image as! SFImage
                    
                    if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO || imageObj.imageType == Constants.kSTRING_IMAGETYPE_WIDGET {
                        
                        imageURL = imageObj.badgeImageUrl
                        break
                    }
                }
            }
            
            if imageURL != nil {
                
                imageURL = imageURL?.appending("?impolicy=resize&w=\(badgeImage?.frame.size.width ?? 0)&h=\(badgeImage?.frame.size.height ?? 0)")
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
    
    
    //MARK: Create Progress view
    func createProgressView(progressViewObject:SFProgressViewObject) {
        
        progressView?.relativeViewFrame = relativeViewFrame
        progressView?.progressViewObject = progressViewObject
        
        progressView?.progressTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? progressViewObject.progressColor ?? "000000")
        progressView?.trackTintColor = Utility.hexStringToUIColor(hex: progressViewObject.unprogressColor ?? "ffffff").withAlphaComponent(0.59)
        
//        if film?.filmWatchedDuration ?? 0 > 0 {
//            
//            let watchDuration:Float = Float(film?.filmWatchedDuration ?? 0)
//            let totalDuration:Float = Float(film?.durationSeconds ?? 0)
//            
//            progressView?.isHidden = false
//
//            UIView.animate(withDuration: 0.5, animations: {
//                
//                self.progressView?.progress = watchDuration/totalDuration
//            })
//        }
//        else {
            
            progressView?.isHidden = true
//        }
    }
    
    
    //MARK: Create Button view
    func createButtonView(buttonObject:SFButtonObject) {
        
        if buttonObject.key != nil && buttonObject.key == "playImage" {
            playButton?.isHidden = false
            playButton?.relativeViewFrame = relativeViewFrame
            playButton?.buttonObject = buttonObject
            playButton?.initialiseButtonFrameFromLayout(buttonLayout: Utility.fetchButtonLayoutDetails(buttonObject: buttonObject))
            let playButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "showPlayIcon.png"))
            
            playButton?.setImage(playButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            playButton?.imageView?.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")
            
            playButton?.isUserInteractionEnabled = false
        }
        else if buttonObject.key != nil && buttonObject.key == "downloadButton" {
            
            downloadButton?.relativeViewFrame = relativeViewFrame
            downloadButton?.buttonObject = buttonObject
            downloadButton?.buttonDelegate = self
            if AppConfiguration.sharedAppConfiguration.isDownloadEnabled != nil {

                downloadButton?.isHidden = false

                if (AppConfiguration.sharedAppConfiguration.isDownloadEnabled)! {

                    if (self.roundProgressView == nil) {
                        self.roundProgressView = RoundProgressBar.init(with: DownloadManager.sharedInstance.getDownloadObject(for: self.film!, andShouldSaveToDirectory: false))
                        self.addSubview(self.roundProgressView!)
                    }

                    self.roundProgressView?.frame = (downloadButton?.frame)!
                    self.roundProgressView?.tag = episodeNumber ?? 0
                    self.roundProgressView?.isUserInteractionEnabled = false
                    self.roundProgressView?.setTheProgressForItemForDownloadProgress(self.film!)
                    self.bringSubview(toFront: self.roundProgressView!)
                }
            }
            else {
                
                downloadButton?.isHidden = true
            }
        }
    }
    
    
    //MARK: Create Separator view
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        separatorView?.relativeViewFrame = relativeViewFrame
        separatorView?.separtorViewObject = separatorViewObject
        separatorView?.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject))
    }
    
    
    //MARK: Method to create episode title
    private func createEpisodeTitle(episodeNumber:String, episodeTitle:String) -> NSMutableAttributedString? {
        
        var concantenatedString:String?
        
        if episodeNumber.characters.count > 0 {
            
            concantenatedString = episodeNumber
        }
        
        if episodeTitle.characters.count > 0 {
            
            if concantenatedString != nil {
                
                concantenatedString = concantenatedString?.appending(" \(episodeTitle)")
            }
            else {
                
                concantenatedString = episodeTitle
            }
        }
        
        var attributedTitleString:NSMutableAttributedString?
        
        if concantenatedString != nil {
            
            if episodeNumber.characters.count > 0 {
                
                attributedTitleString = NSMutableAttributedString(string: concantenatedString!)
                
                let fontFamily = Utility.sharedUtility.fontFamilyForApplication()
                var fontWeight = "ExtraBold"
                
                if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                    
                    fontWeight = "Black"
                }
                
                attributedTitleString?.addAttributes([NSFontAttributeName: UIFont(name: "\(fontFamily)-\(fontWeight)", size: 14) ?? UIFont(name: "\(fontFamily)", size: 14)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: "9B9B9B")], range: (concantenatedString! as NSString).range(of: episodeNumber))

                attributedTitleString?.addAttributes([NSFontAttributeName: UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Semibold", size: 14)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: "ffffff")], range: (concantenatedString! as NSString).range(of: episodeTitle))
            }
            else {
                
                attributedTitleString = NSMutableAttributedString(string: concantenatedString!)
                
                attributedTitleString?.addAttributes([NSFontAttributeName: UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Semibold", size: 14)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: "ffffff")], range: (concantenatedString! as NSString).range(of: episodeTitle))
            }
        }
        
        return attributedTitleString
    }
    
    //MARK: Button Delegate method
    func buttonClicked(button: SFButton) {
        
        if button.buttonObject?.key != nil && button.buttonObject?.key == "downloadButton" {
            
            let autoplayhandler = AutoPlayArrayHandler()
            self.showActivityIndicator(loaderText: "")
            autoplayhandler.getTheAutoPlaybackArrayForFilm(film:(film?.id)!){ [weak self] (relatedVideoArray, filmObject) in
                guard let _ = self else {
                    return
                }
                self?.hideActivityIndicator()
                if filmObject != nil {
                    self?.film = filmObject
                }
                
                if (AppConfiguration.sharedAppConfiguration.isDownloadEnabled)! {
                    
                    if self?.roundProgressView != nil {
                        
                        self?.roundProgressView?.filmObject = self?.film
                        
                        if self?.roundProgressView?.downloadButton != nil {
                            
                            self?.roundProgressView?.downloadButtonTapped(sender: (self?.roundProgressView?.downloadButton)!)
                        }
                    }
                }
            }
        }
        else {
         
            if self.showGridCellDelegate != nil {
                
                if (showGridCellDelegate?.responds(to: #selector(SFShowGridCellDelegate.buttonClicked(button:film:cellRowValue:))))! {
                    
                    showGridCellDelegate?.buttonClicked!(button: button, film: film, cellRowValue:cellRowValue)
                }
            }
        }
    }
    
    
    //MARK - Show/Hide Activity Indicator
    func showActivityIndicator(loaderText:String?) {
        
        let window = UIApplication.shared.keyWindow!
        progressIndicator = MBProgressHUD.showAdded(to: window, animated: true)
        if loaderText != nil {
            
            progressIndicator?.label.text = loaderText!
        }
    }
    
    func hideActivityIndicator() {
        
        progressIndicator?.hide(animated: true)
    }
    
    //MARK: Layout subview method
    override func layoutSubviews() {
        
        //relativeViewFrame?.size.width = UIScreen.main.bounds.width
        updateCellSubViewsFrame()
    }
    
    //MARK: Update Cell subview frames
    func updateCellSubViewsFrame() {
        
        for subView in self.subviews {
            
            if subView is SFLabel {
                
                updateLabelView(label: subView as! SFLabel)
            }
            else if subView is SFSeparatorView {
                
                updateSeparatorView(separatorView: subView as! SFSeparatorView)
            }
            else if subView is SFButton {
                
                updateButtonView(button: subView as! SFButton)
            }
            else if subView is SFProgressView {
                
                updateProgressView(progressView: subView as! SFProgressView)
            }
            else if subView is SFImageView {
                
                updateImageView(imageView: subView as! SFImageView)
            }
        }
    }
    
    
    //MARK: Update label view
    func updateLabelView(label:SFLabel) {
        
        if label.labelObject != nil {
            
            let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!)
            
            label.relativeViewFrame = relativeViewFrame
            label.labelLayout = labelLayout
            label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            
            if label.labelObject?.key == "duration" {
                
                label.changeFrameWidth(width: label.frame.size.width * Utility.getBaseScreenWidthMultiplier())
                label.changeFrameHeight(height: label.frame.size.height * Utility.getBaseScreenHeightMultiplier())
                
                if labelLayout.width != nil {
                    label.changeFrameXAxis(xAxis: label.frame.origin.x - (label.frame.size.width - CGFloat(labelLayout.width!)))
                }
            }
            else if label.labelObject?.key == "description" {
                
                label.changeFrameHeight(height: label.frame.size.height * Utility.getBaseScreenHeightMultiplier())
            }
            else if label.labelObject?.key == "episodeTitle" {
                
                label.changeFrameHeight(height: label.frame.size.height * Utility.getBaseScreenHeightMultiplier())
            }
        }
    }
    
    
    //MARK: Update Image view frame
    func updateImageView(imageView:SFImageView) {
        
        if imageView.imageViewObject != nil {
            imageView.relativeViewFrame = relativeViewFrame
            imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageView.imageViewObject!))
        }
    }
    
    
    //MARK: Update Progress view frame
    func updateProgressView(progressView:SFProgressView) {
        
        if progressView.progressViewObject != nil {
            progressView.relativeViewFrame = relativeViewFrame
            let progressViewLayout:LayoutObject = Utility.fetchProgresViewLayoutDetails(progressViewObject: progressView.progressViewObject!)
            progressView.initialiseProgressViewFrameFromLayout(progressViewLayout: progressViewLayout)
            
            self.bringSubview(toFront: progressView)

            if videoImage != nil {
                
                progressView.changeFrameXAxis(xAxis: (videoImage?.frame.minX) ?? progressView.frame.minX)
            }
        }
    }
    
    
    //MARK: Update Button view frame
    func updateButtonView(button:SFButton) {
        
        if button.buttonObject != nil {
            
            let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: button.buttonObject!)
            
            button.relativeViewFrame = relativeViewFrame
            button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
            
            if button.buttonObject?.key == "playImage" {
                
                button.changeFrameXAxis(xAxis: button.frame.origin.x * Utility.getBaseScreenWidthMultiplier())
                button.changeFrameYAxis(yAxis: button.frame.origin.y * Utility.getBaseScreenHeightMultiplier())
                button.changeFrameHeight(height: button.frame.size.height * Utility.getBaseScreenHeightMultiplier())
                button.changeFrameWidth(width: button.frame.size.width * Utility.getBaseScreenWidthMultiplier())
            }
            else {
                
                button.changeFrameWidth(width: button.frame.size.width * Utility.getBaseScreenWidthMultiplier())
            }
            if button.buttonObject?.key == "downloadButton" && AppConfiguration.sharedAppConfiguration.isDownloadEnabled != nil {
                
                button.changeFrameHeight(height: button.frame.size.height * Utility.getBaseScreenHeightMultiplier())
                button.changeFrameWidth(width: button.frame.size.width * Utility.getBaseScreenWidthMultiplier())
                button.changeFrameYAxis(yAxis: button.frame.origin.y * Utility.getBaseScreenHeightMultiplier())

                if self.roundProgressView != nil {
                    
                    self.roundProgressView?.frame = button.frame
                    self.bringSubview(toFront: self.roundProgressView!)
                }
                
                if buttonLayout.width != nil {
                    button.changeFrameXAxis(xAxis: button.frame.origin.x - (button.frame.size.width - CGFloat(buttonLayout.width!)))
                }
            }
        }
    }
    
    
    //MARK: Update Separator view
    func updateSeparatorView(separatorView:SFSeparatorView) {
        
        if separatorView.separtorViewObject != nil {
            
            if cellRowValue > 0 {
                
                separatorView.isHidden = false
            }
            else {
                
                separatorView.isHidden = true
            }
            
            separatorView.relativeViewFrame = relativeViewFrame
            separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorView.separtorViewObject!))
        }
    }
 
    //MARK: Method to update progress view of download button
    func updateCircularProgressForDownloadObject(downloadObject:DownloadObject, downloadingProgress:Float) {
        
        self.roundProgressView?.setTheProgressForItemForDownloadProgress(DownloadManager.sharedInstance.getFilmObject(for: downloadObject))
    }
    
    //MARK: Method to update player progress
    func updateCellPlayerProgress(progressValue:Double) {
        
        if progressValue > 30 {
            
            self.film?.filmWatchedDuration = progressValue
            self.progressView?.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                
                self.progressView?.setProgress(Float(self.film?.filmWatchedDuration ?? 0) / Float(self.film?.durationSeconds ?? 0), animated: true)
            })
        }
        else {
            
            self.progressView?.isHidden = true
        }
    }
}
