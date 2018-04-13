//
//  SFTableViewCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 22/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol SFTableViewCellDelegate:NSObjectProtocol {
    @objc optional func buttonClicked(button:SFButton, gridObject:SFGridObject?, cellRowValue:Int) -> Void
}

class SFTableViewCell: UITableViewCell,SFButtonDelegate {

    var tableComponents:Array<Any> = []
    var videoSize:SFLabel?
    var videoTitle:SFLabel?
    var videoDescription:SFLabel?
    var videoDuration:SFLabel?
    var videoDurationUnit:SFLabel?
    var playButton:SFButton?
    var deleteButton:SFButton?
    var videoImage:SFImageView?
    var badgeImage:SFImageView?
    var progressView:SFProgressView?
    var gridObject:SFGridObject?
    var separatorView:SFSeparatorView?
    var thumbnailImageType:String?
    var downloadButton:SFButton?
    var watchedTimeLabel:SFLabel?
    var relativeViewFrame:CGRect?
    var cellRowValue:Int = 0
    var roundProgressView:RoundProgressBar?
    var film : SFFilm?
    var cancelOnGoingDownloadButtton:SFButton?
    
    weak var tableViewCellDelegate:SFTableViewCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        createCellView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    //MARK: Creating CellView
    func createCellView() {
        
        videoImage = SFImageView()
        self.addSubview(videoImage!)
        videoImage?.isHidden = true
        
        videoTitle = SFLabel()
        videoTitle?.isHidden = true
        self.addSubview(videoTitle!)
        
        progressView = SFProgressView(progressViewStyle: .bar)
        self.addSubview(progressView!)
        progressView?.isHidden = true
        
        videoSize = SFLabel()
        videoSize?.isHidden = true
        self.addSubview(videoSize!)
        
        videoDescription = SFLabel()
        self.addSubview(videoDescription!)
        videoDescription?.isHidden = true
        
        videoDuration = SFLabel()
        self.addSubview(videoDuration!)
        videoDuration?.isHidden = true
        
        videoDurationUnit = SFLabel()
        self.addSubview(videoDurationUnit!)
        videoDurationUnit?.isHidden = true
        
        playButton = SFButton(frame: CGRect.zero)
        playButton?.buttonDelegate = self
        self.addSubview(playButton!)
        playButton?.isHidden = true
        
        deleteButton = SFButton(frame: CGRect.zero)
        self.addSubview(deleteButton!)
        deleteButton?.buttonDelegate = self
        deleteButton?.isHidden = true

        deleteButton = SFButton(frame: CGRect.zero)
        self.addSubview(deleteButton!)
        deleteButton?.buttonDelegate = self
        deleteButton?.isHidden = true

        badgeImage = SFImageView()
        self.addSubview(badgeImage!)
        badgeImage?.isHidden = true
        
        downloadButton = SFButton()
        downloadButton?.buttonDelegate = self
        self.addSubview(downloadButton!)
        downloadButton?.isHidden = true
        
        separatorView = SFSeparatorView()
        self.addSubview(separatorView!)
        separatorView?.isHidden = true
        
        watchedTimeLabel = SFLabel()
        self.addSubview(watchedTimeLabel!)
        watchedTimeLabel?.isHidden = true
        
        cancelOnGoingDownloadButtton = SFButton()
        self.addSubview(cancelOnGoingDownloadButtton!)
        cancelOnGoingDownloadButtton?.isHidden = true
    }
    
    
    //MARK: Update Cell components 
    //Reusing it in tableview cell to update cell contents
    func updateGridSubView() {
        
        for cellComponent in tableComponents {
            
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
        
        if labelObject.key != nil && labelObject.key == "title" {
            videoTitle?.isHidden = false
            videoTitle?.relativeViewFrame = relativeViewFrame!
            videoTitle?.labelObject = labelObject
            videoTitle?.text = gridObject?.contentTitle
            videoTitle?.labelLayout = labelLayout
            videoTitle?.createLabelView()
            videoTitle?.font = UIFont(name: (videoTitle?.font.fontName)!, size: (videoTitle?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())

            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                videoTitle?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
        else if labelObject.key != nil && labelObject.key == "description" {
            videoDescription?.isHidden = false
            videoDescription?.numberOfLines = 0
            videoDescription?.relativeViewFrame = relativeViewFrame!
            videoDescription?.labelObject = labelObject
            videoDescription?.labelLayout = labelLayout
            videoDescription?.text = gridObject?.contentDescription
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
            videoDuration?.relativeViewFrame = relativeViewFrame!
            videoDuration?.labelLayout = labelLayout
            videoDuration?.labelObject = labelObject
            videoDuration?.createLabelView()
            videoDuration?.font = UIFont(name: (videoDuration?.font.fontName)!, size: (videoDuration?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
            videoDuration?.text = getVideoDurationString(totalTime: gridObject?.totalTime)

            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                videoDuration?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
        else if labelObject.key != nil && labelObject.key == "watchedTime" {
            watchedTimeLabel?.isHidden = false
            watchedTimeLabel?.relativeViewFrame = relativeViewFrame!
            watchedTimeLabel?.labelLayout = labelLayout
            watchedTimeLabel?.labelObject = labelObject
            watchedTimeLabel?.createLabelView()
            watchedTimeLabel?.font = UIFont(name: (watchedTimeLabel?.font.fontName)!, size: (watchedTimeLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())

            if gridObject?.updatedDate != nil {
                
                let updatedDate:NSDate = NSDate(timeIntervalSince1970: TimeInterval((gridObject?.updatedDate)! / 1000.0))
                watchedTimeLabel?.text = Utility.sharedUtility.timeAgoSinceDate(date: updatedDate, numericDates: true)
            }
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                watchedTimeLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!).withAlphaComponent(0.6)
            }
            else {
                
                watchedTimeLabel?.textColor = watchedTimeLabel?.textColor.withAlphaComponent(0.6)
            }
        }
        else if labelObject.key != nil && labelObject.key == "videoSize" {
            videoSize?.isHidden = false
            videoSize?.relativeViewFrame = relativeViewFrame!
            videoSize?.labelObject = labelObject
            videoSize?.font = UIFont(name: (videoSize?.font.fontName)!, size: (videoSize?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
            videoSize?.labelLayout = labelLayout
            videoSize?.createLabelView()
            videoSize?.text = Utility.sharedUtility.getdownloadedVideoSize((gridObject?.totalSize) ?? 0)

            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                videoSize?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
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
            videoImage?.relativeViewFrame = relativeViewFrame!
            videoImage?.imageViewObject = imageObject
            videoImage?.updateView()
            
            videoImage?.contentMode = .scaleAspectFit
            
            var imageURL:String?
            var placeholderImagePath:String?
            
            if self.gridObject != nil {
                
                for image in (self.gridObject?.images)! {
                    
                    let imageObj: SFImage = image as! SFImage
                    
                    if thumbnailImageType == "portrait" {
                        
                        if imageObj.imageType == Constants.kSTRING_IMAGETYPE_POSTER
                        {
                            imageURL = imageObj.imageSource
                            placeholderImagePath = Constants.kPosterImagePlaceholder
                            break
                        }
                    }
                    else {
                        
                        if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO {
                            
                            imageURL = imageObj.imageSource
                            placeholderImagePath = Constants.kVideoImagePlaceholder
                            break
                        }
                    }
                }
            }
            
            if imageURL == nil {
                
                if thumbnailImageType == "portrait" {
                    
                    imageURL = gridObject?.posterImageURL
                    placeholderImagePath = Constants.kPosterImagePlaceholder
                }
                else {
                    imageURL = gridObject?.thumbnailImageURL
                    placeholderImagePath = Constants.kVideoImagePlaceholder
                }
            }
            
            if placeholderImagePath == nil {
                
                if thumbnailImageType == "portrait" {
                    
                    placeholderImagePath = Constants.kPosterImagePlaceholder
                }
                else {
                    
                    placeholderImagePath = Constants.kVideoImagePlaceholder
                }
            }
            
            if imageURL != nil {
                
                imageURL = imageURL?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: videoImage?.frame.size.width ?? 0))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: videoImage?.frame.size.height ?? 0))")
                imageURL = imageURL?.trimmingCharacters(in: .whitespaces)

                if let imageUrl = URL(string: imageURL!) {
                    
                    videoImage?.af_setImage(
                        withURL: imageUrl,
                        placeholderImage: UIImage(named: placeholderImagePath!),
                        filter: nil,
                        imageTransition: .crossDissolve(0.2)
                    )
                }
                else {
                    
                    videoImage?.image = UIImage(named: placeholderImagePath!)
                }
            }
            else {
                videoImage?.image = UIImage(named: placeholderImagePath!)
            }

        }
        else if imageObject.key != nil && imageObject.key == "badgeImage" {
            
            badgeImage?.isHidden = false
            badgeImage?.relativeViewFrame = relativeViewFrame!
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
    
    
    //MARK: Create Progress view
    func createProgressView(progressViewObject:SFProgressViewObject) {
        
        if gridObject?.watchedTime ?? 0 > 0 {
        
            progressView?.relativeViewFrame = relativeViewFrame!
            progressView?.progressViewObject = progressViewObject
            progressView?.progress = (Float) ((gridObject?.watchedTime ?? 0) / (gridObject?.totalTime ?? 0))
            
            progressView?.progressTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? progressViewObject.progressColor ?? "000000")
            progressView?.trackTintColor = Utility.hexStringToUIColor(hex: progressViewObject.unprogressColor ?? "ffffff").withAlphaComponent(0.59)
        }
        else {
            
            progressView?.isHidden = true
        }
    }
    
    
    //MARK: Create Button view
    func createButtonView(buttonObject:SFButtonObject) {
        
        if buttonObject.key != nil && buttonObject.key == "deleteImage" {
            deleteButton?.buttonObject = buttonObject
            deleteButton?.relativeViewFrame = relativeViewFrame!
            
            let deleteButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "deleteIcon.png"))
            
            deleteButton?.setImage(deleteButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            deleteButton?.imageView?.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")
            
            if gridObject?.isDownloadComplete == nil || gridObject?.isDownloadComplete == true  {
                deleteButton?.isHidden = false
                
            }
            else {
                if (self.roundProgressView != nil) {
                    self.roundProgressView?.removeFromSuperview()
                    self.roundProgressView = nil
                }
                self.roundProgressView = RoundProgressBar.init(with: DownloadManager.sharedInstance.getDownloadObject(for: self.film!, andShouldSaveToDirectory: false))
                self.addSubview(self.roundProgressView!)
                self.roundProgressView?.isHidden = false
                self.roundProgressView?.frame = (deleteButton?.frame)!
                self.roundProgressView?.setTheProgressForItemForDownloadProgress(self.film!)
            }
        }
        else if buttonObject.key != nil && buttonObject.key == "playImage" {
            playButton?.isHidden = false
            playButton?.relativeViewFrame = relativeViewFrame!
            playButton?.buttonObject = buttonObject
            
            let playButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "play.png"))
            
            playButton?.setImage(playButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            playButton?.imageView?.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")
            
        }
        else if buttonObject.key != nil && buttonObject.key == "cancelImage" {
            
            let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
            cancelOnGoingDownloadButtton?.relativeViewFrame = relativeViewFrame!
            cancelOnGoingDownloadButtton?.buttonObject = buttonObject
            cancelOnGoingDownloadButtton?.buttonLayout = buttonLayout
            cancelOnGoingDownloadButtton?.isHidden = false
            cancelOnGoingDownloadButtton?.contentHorizontalAlignment = .right
            cancelOnGoingDownloadButtton?.createButtonView()
            cancelOnGoingDownloadButtton?.titleLabel?.font = UIFont(name: (cancelOnGoingDownloadButtton?.titleLabel?.font.fontName)!, size: (cancelOnGoingDownloadButtton?.titleLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
            
            if gridObject?.isDownloadComplete == nil || gridObject?.isDownloadComplete == true  {
                
                let totalDownloadedDataSize = Int((gridObject?.totalSize ?? 0) / (1024 * 1024))
                let downloadSizeString = "\(totalDownloadedDataSize) MB"
                
                cancelOnGoingDownloadButtton?.setTitle(downloadSizeString, for: .normal)
                cancelOnGoingDownloadButtton?.isEnabled = false
                cancelOnGoingDownloadButtton?.isUserInteractionEnabled = false
                cancelOnGoingDownloadButtton?.buttonDelegate = nil
            }
            else {
                
                cancelOnGoingDownloadButtton?.setTitle("CANCEL", for: .normal)
                cancelOnGoingDownloadButtton?.isEnabled = true
                cancelOnGoingDownloadButtton?.isUserInteractionEnabled = true
                cancelOnGoingDownloadButtton?.buttonDelegate = self
            }
            
            cancelOnGoingDownloadButtton?.relativeViewFrame = relativeViewFrame!
            cancelOnGoingDownloadButtton?.buttonObject = buttonObject
        }
    }
    
    
    //MARK: Create Separator view
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        separatorView?.relativeViewFrame = relativeViewFrame!
        separatorView?.separtorViewObject = separatorViewObject
        separatorView?.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject))
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
            
            label.relativeViewFrame = relativeViewFrame!
            label.labelLayout = labelLayout
            label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            
            if label.labelObject?.key == "duration" {
                
                label.changeFrameWidth(width: label.frame.size.width * Utility.getBaseScreenWidthMultiplier())
                label.changeFrameHeight(height: label.frame.size.height * Utility.getBaseScreenHeightMultiplier())
        
            }
            else if label.labelObject?.key == "description" {
                
                label.changeFrameHeight(height: label.frame.size.height * Utility.getBaseScreenHeightMultiplier())
            }
            else if label.labelObject?.key == "watchedTime" {
                
                label.changeFrameWidth(width: label.frame.size.width * Utility.getBaseScreenWidthMultiplier())
                label.changeFrameHeight(height: label.frame.size.height * Utility.getBaseScreenHeightMultiplier())
                
                if labelLayout.width != nil {
                    
                    label.changeFrameXAxis(xAxis: label.frame.origin.x - ((label.frame.size.width - CGFloat(labelLayout.width!))))
                }
            }
        }
    }
    
    
    //MARK: Update Image view frame
    func updateImageView(imageView:SFImageView) {
        
        if imageView.imageViewObject != nil {
            imageView.relativeViewFrame = relativeViewFrame!
            imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageView.imageViewObject!))
            
            imageView.changeFrameWidth(width: imageView.frame.size.width * Utility.getBaseScreenWidthMultiplier())
            imageView.changeFrameHeight(height: imageView.frame.size.height * Utility.getBaseScreenHeightMultiplier())
        }
    }
    
    
    //MARK: Update Progress view frame
    func updateProgressView(progressView:SFProgressView) {
        
        if progressView.progressViewObject != nil {
            progressView.relativeViewFrame = relativeViewFrame!
            let progressViewLayout:LayoutObject = Utility.fetchProgresViewLayoutDetails(progressViewObject: progressView.progressViewObject!)
            progressView.initialiseProgressViewFrameFromLayout(progressViewLayout: progressViewLayout)
            
            self.bringSubview(toFront: progressView)
            progressView.changeFrameWidth(width: progressView.frame.size.width * Utility.getBaseScreenWidthMultiplier())
            progressView.changeFrameHeight(height: progressView.frame.size.height * Utility.getBaseScreenHeightMultiplier())

            if videoImage != nil {
                
                progressView.changeFrameXAxis(xAxis: (videoImage?.frame.minX) ?? progressView.frame.minX)
            }
        }
    }
    
    
    //MARK: Update Button view frame
    func updateButtonView(button:SFButton) {
        
        if button.buttonObject != nil {
            
            let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: button.buttonObject!)
            
            button.relativeViewFrame = relativeViewFrame!
            button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
            
            button.changeFrameWidth(width: button.frame.size.width * Utility.getBaseScreenWidthMultiplier())

            if button.buttonObject?.key != nil && button.buttonObject?.key == "playImage" && (gridObject?.contentType == Constants.kShowContentType || gridObject?.contentType == Constants.kShowsContentType) {
                
                playButton?.isHidden = true
            }
            else if button.buttonObject?.key != nil && button.buttonObject?.key == "deleteImage" {

                if gridObject?.isDownloadComplete != nil && gridObject?.isDownloadComplete == false  {
                    self.roundProgressView?.isHidden = false
                    self.deleteButton?.isHidden = true
                    self.roundProgressView?.frame = button.frame
                    self.roundProgressView?.setTheProgressForItemForDownloadProgress(self.film!)
                    self.roundProgressView?.downloadObject = DownloadManager.sharedInstance.getDownloadObject(for: self.film!, andShouldSaveToDirectory: false)
                }
                else{
                    self.roundProgressView?.isHidden = true
                    self.deleteButton?.isHidden = false
                }
            }
            else if button.buttonObject?.key != nil && button.buttonObject?.key == "cancelImage" {
                
                if buttonLayout.width != nil {
                    
                    button.changeFrameXAxis(xAxis: button.frame.origin.x + ((button.frame.size.width - CGFloat(buttonLayout.width!)) * -1))
                }
                
                if gridObject?.isDownloadComplete == nil || gridObject?.isDownloadComplete == true  {
                    
                    let totalDownloadedDataSize = Int((gridObject?.totalSize ?? 0) / (1024 * 1024))
                    let downloadSizeString = "\(totalDownloadedDataSize) MB"
                    
                    cancelOnGoingDownloadButtton?.setTitle(downloadSizeString, for: .normal)
                    cancelOnGoingDownloadButtton?.isEnabled = false
                    cancelOnGoingDownloadButtton?.isUserInteractionEnabled = false
                    cancelOnGoingDownloadButtton?.buttonDelegate = nil
                }
                else {
                    
                    cancelOnGoingDownloadButtton?.setTitle("CANCEL", for: .normal)
                    cancelOnGoingDownloadButtton?.isEnabled = true
                    cancelOnGoingDownloadButtton?.isUserInteractionEnabled = true
                    cancelOnGoingDownloadButtton?.buttonDelegate = self
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
            
            separatorView.relativeViewFrame = relativeViewFrame!
            separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorView.separtorViewObject!))
        }
    }
    
    //MARK: Layout subview method
    override func layoutSubviews() {
        
        relativeViewFrame?.size.width = UIScreen.main.bounds.width
        updateCellSubViewsFrame()
    }
    
    //MARK: Button Delegate method
    func buttonClicked(button: SFButton) {
        
        if self.tableViewCellDelegate != nil {
            
            if (tableViewCellDelegate?.responds(to: #selector(SFTableViewCellDelegate.buttonClicked(button:gridObject:cellRowValue:))))! {
             
                tableViewCellDelegate?.buttonClicked!(button: button, gridObject: gridObject, cellRowValue:cellRowValue)
            }
        }
    }
}
