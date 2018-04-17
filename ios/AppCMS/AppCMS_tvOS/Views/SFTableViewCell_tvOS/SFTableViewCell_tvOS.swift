//
//  SFTableViewCell_tvOS.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 10/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import Cosmos
@objc protocol SFTableViewCellDelegate:NSObjectProtocol {
    @objc optional func buttonClicked(button:SFButton, gridObject:SFGridObject?, cellRowValue:Int) -> Void
    @objc optional func playVideo(button:UIButton, gridObject:SFGridObject?, cellRowValue:Int) -> Void
}

class SFTableViewCell_tvOS: UITableViewCell, SFButtonDelegate {
    
    var tableComponents:Array<Any> = []
    var videoSize:SFLabel?
    var durationBadgeLabel:SFLabel?
    var videoTitle:SFLabel?
    var videoDescription:SFLabel?
    var videoDuration:SFLabel?
    var videoDurationUnit:SFLabel?
    var starView:SFStarRatingView?
    var selectionButton:UIButton?
    var playImage:SFImageView?
    var deleteButton:SFButton?
    var videoImage:SFImageView?
    var badgeImage:SFImageView?
    var progressView:SFProgressView_tvOS?
    var gridObject:SFGridObject?
    var separatorView:SFSeparatorView?
    var thumbnailImageType:String?
    var watchedTimeLabel:SFLabel?
    var relativeViewFrame:CGRect?
    var cellRowValue:Int = 0
    weak var tableViewCellDelegate:SFTableViewCellDelegate?
    var film : SFFilm?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        createCellView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        
        progressView = SFProgressView_tvOS(frame: CGRect.zero)
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
        
        durationBadgeLabel = SFLabel()
        self.addSubview(durationBadgeLabel!)
        durationBadgeLabel?.isHidden = true
        
        videoDurationUnit = SFLabel()
        self.addSubview(videoDurationUnit!)
        videoDurationUnit?.isHidden = true
        
        playImage = SFImageView(frame: CGRect.zero)
        self.addSubview(playImage!)
        playImage?.isHidden = true
        
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
        
        separatorView = SFSeparatorView()
        self.addSubview(separatorView!)
        separatorView?.isHidden = true
        
        watchedTimeLabel = SFLabel()
        self.addSubview(watchedTimeLabel!)
        watchedTimeLabel?.isHidden = true
       
        starView = SFStarRatingView()
//        self.addSubview(starView!)
        starView?.isHidden = true
        
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
            else if cellComponent is SFStarRatingObject {
                
                createStarRatingView(starViewObject: cellComponent as! SFStarRatingObject)
            }
        }
    }
    
    
    //MARK: Create label view
    func createLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        if labelObject.key != nil && labelObject.key == "titleLabel" {
            videoTitle?.isHidden = false
            videoTitle?.relativeViewFrame = relativeViewFrame!
            videoTitle?.labelObject = labelObject
            videoTitle?.text = gridObject?.contentTitle
            videoTitle?.labelLayout = labelLayout
            videoTitle?.createLabelView()
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                videoTitle?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
        else if labelObject.key != nil && labelObject.key == "descriptionLabel" {
            videoDescription?.isHidden = false
            videoDescription?.relativeViewFrame = relativeViewFrame!
            videoDescription?.labelObject = labelObject
            videoDescription?.labelLayout = labelLayout

            videoDescription?.createLabelView()
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                videoDescription?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            else {
                videoDescription?.textColor = videoDescription?.textColor
            }
            videoDescription?.text = gridObject?.contentDescription
 
        }
        else if labelObject.key != nil && labelObject.key == "duration" {
            videoDuration?.isHidden = false
            videoDuration?.relativeViewFrame = relativeViewFrame!
            videoDuration?.labelLayout = labelLayout
            videoDuration?.labelObject = labelObject
            videoDuration?.createLabelView()
            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
                if let totalTime = gridObject?.totalTime {
                    var dateString: String?
                    if let publishDate: Double = gridObject?.publishedDate {
                        dateString = Utility.sharedUtility.getDateStringFromIntervalWithPunctuationMark(timeInterval: publishDate)
                        videoDuration?.text = "\(totalTime.timeFormattedString(interval: totalTime))   |   Published on \(dateString!)"
                    } else {
                        videoDuration?.text = "\(totalTime.timeFormattedString(interval: totalTime))"
                    }
                }
            }
            else{
                videoDuration?.text = getVideoDurationString(totalTime: gridObject?.totalTime)
            }
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                videoDuration?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
            /*
             else if labelObject.key != nil && labelObject.key == "durationUnit" {
             videoDurationUnit?.isHidden = false
             videoDurationUnit?.relativeViewFrame = relativeViewFrame!
             videoDurationUnit?.labelLayout = labelLayout
             videoDurationUnit?.labelObject = labelObject
             videoDurationUnit?.createLabelView()
             videoDurationUnit?.font = UIFont(name: (videoDurationUnit?.font.fontName)!, size: (videoDurationUnit?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
             videoDurationUnit?.text = "MIN"
             
             if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
             
             videoDurationUnit?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
             }
             }
             */
        else if labelObject.key != nil && labelObject.key == "watchedTime" {
            watchedTimeLabel?.isHidden = false
            watchedTimeLabel?.relativeViewFrame = relativeViewFrame!
            watchedTimeLabel?.labelLayout = labelLayout
            watchedTimeLabel?.labelObject = labelObject
            watchedTimeLabel?.createLabelView()
            
            if gridObject?.updatedDate != nil {
                
                let updatedDate:NSDate = NSDate(timeIntervalSince1970: TimeInterval((gridObject?.updatedDate)! / 1000.0))
                let watchedString = "Added \(Utility.sharedUtility.timeAgoSinceDate(date: updatedDate, numericDates: true))"
                watchedTimeLabel?.text = watchedString
            }
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                watchedTimeLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!).withAlphaComponent(0.6)
            }
            else {
                
                watchedTimeLabel?.textColor = watchedTimeLabel?.textColor.withAlphaComponent(0.6)
            }
        }
        
        else if labelObject.key != nil && labelObject.key == "durationBadgeLabel" {
            durationBadgeLabel?.relativeViewFrame = self.frame
            durationBadgeLabel?.labelLayout = labelLayout
            durationBadgeLabel?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            durationBadgeLabel?.labelObject = labelObject
            durationBadgeLabel?.createLabelView()
            if let totalTime = gridObject?.totalTime {
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
    
    
    func getVideoDurationString(totalTime:Double?) -> String {
        
        let totalTimeInMinutes:Int = Int(totalTime ?? 0)/60
        let totalTimeValue:String = "\(totalTimeInMinutes) MIN"
        
        return totalTimeValue
    }
    
    //MARK: Create Image view
    func createImageView(imageObject:SFImageObject) {
        
        if imageObject.key != nil && imageObject.key == "thumbnailImage" {
            videoImage?.isHidden = false
            videoImage?.relativeViewFrame = relativeViewFrame!
            videoImage?.imageViewObject = imageObject
            videoImage?.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
            videoImage?.updateView()
            
            videoImage?.contentMode = .scaleAspectFit
            
            var imageURL:String?
            var placeholderImagePath:String?
            if thumbnailImageType == "portrait" {
                
                imageURL = gridObject?.posterImageURL
                placeholderImagePath = Constants.kPosterImagePlaceholder
            }
            else {
                imageURL = gridObject?.thumbnailImageURL
                placeholderImagePath = Constants.kVideoImagePlaceholder
            }
            
            if imageURL != nil {
                
                imageURL = imageURL?.appending("?impolicy=resize&w=\(videoImage?.frame.size.width ?? 0)&h=\(videoImage?.frame.size.height ?? 0)")
                imageURL = imageURL?.trimmingCharacters(in: .whitespaces)
                
                videoImage?.af_setImage(
                    withURL: URL(string: imageURL ?? "")!,
                    placeholderImage: UIImage(named: placeholderImagePath!),
                    filter: nil,
                    imageTransition: .crossDissolve(0.2)
                )
            }
            else {
                videoImage?.image = UIImage(named: placeholderImagePath!)
            }
            
            selectionButton = UIButton(frame: (videoImage?.bounds)!)
            self.addSubview(selectionButton!)
            selectionButton?.backgroundColor = .clear
            selectionButton?.layer.borderWidth = 6.0
            selectionButton?.layer.borderColor = UIColor.clear.cgColor
            self.bringSubview(toFront: selectionButton!)
            selectionButton?.tag = 555
            self.selectionButton?.addTarget(self, action: #selector(buttonClicked(sender:)), for: .primaryActionTriggered)
        }
        else if imageObject.key != nil && imageObject.key == "badgeImage" {
            
            badgeImage?.relativeViewFrame = relativeViewFrame!
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
                
                imageURL = imageURL?.appending("?impolicy=resize&w=\(badgeImage?.frame.size.width ?? 0)&h=\(badgeImage?.frame.size.height ?? 0)")
                imageURL = imageURL?.trimmingCharacters(in: .whitespaces)
                
                if imageURL != nil && !(imageURL?.isEmpty)! {
                    
                    badgeImage?.isHidden = false
                    
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
//            badgeImage?.image = UIImage(named: "badgeLandscape")
//            badgeImage?.isHidden = false
            
        }
        else if imageObject.key != nil && imageObject.key == "playImage" {
            playImage?.imageViewObject = imageObject
            playImage?.relativeViewFrame = relativeViewFrame!
            //playImage?.image = #imageLiteral(resourceName: "videoDetailPlayIcon_tvOS.png")
            playImage?.image = UIImage(named: "videoDetailPlayIcon_tvOS")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            if let textColor = AppConfiguration.sharedAppConfiguration.primaryButton.backgroundColor {
                playImage?.tintColor = Utility.hexStringToUIColor(hex: textColor)
            }
            playImage?.isHidden = false
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == selectionButton {
            if let borderColor = AppConfiguration.sharedAppConfiguration.primaryButton.borderSelectedColor {
                selectionButton?.layer.borderColor = Utility.hexStringToUIColor(hex: borderColor).withAlphaComponent(0.70).cgColor
            }
        }
        else {
            selectionButton?.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    
    //MARK: Create Progress view
    func createProgressView(progressViewObject:SFProgressViewObject) {
        
        if gridObject?.watchedTime ?? 0 > 0 {
            
            progressView?.relativeViewFrame = relativeViewFrame!
            progressView?.progressViewObject = progressViewObject
//            progressView?.animated = true
            progressView?.progress = (CGFloat)((gridObject?.watchedTime ?? 0) / (gridObject?.totalTime ?? 0))
        }
        else {
            
            progressView?.isHidden = true
        }
    }
    
    
    //MARK: Create Button view
    func createButtonView(buttonObject:SFButtonObject) {
        
        if buttonObject.key != nil && buttonObject.key == "deleteItemButton" {
            let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
            deleteButton?.buttonObject = buttonObject
            deleteButton?.buttonLayout = buttonLayout
            deleteButton?.relativeViewFrame = self.frame
            deleteButton?.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
            deleteButton?.createButtonView()
            deleteButton?.isHidden = false
        }
    }
    
    
    //MARK: Create Separator view
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        separatorView?.relativeViewFrame = relativeViewFrame!
        separatorView?.separtorViewObject = separatorViewObject
        separatorView?.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject))
    }
    
    //MARK: Create Separator view
    func createStarRatingView(starViewObject:SFStarRatingObject) {
        //starView?.starRatingObject = starViewObject
        starView?.relativeViewFrame = relativeViewFrame!
        starView?.initialiseStarRatingFrameFromLayout(ratingLayout: Utility.fetchStarRatingLayoutDetails(starRatingObject: starViewObject))
        starView?.isHidden = false
        starView?.updateView(userRating: (gridObject?.viewerGrade ?? 0), startSize: starViewObject.starSize, margin: starViewObject.margin)
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
            else if subView is SFProgressView_tvOS {
                
                updateProgressView(progressView: subView as! SFProgressView_tvOS)
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
                
                if labelLayout.height != nil {
                    
                    label.changeFrameYAxis(yAxis: label.frame.origin.y + (label.frame.size.height - CGFloat(labelLayout.height!)))
                }
            }
            else if label.labelObject?.key == "description" {
                
                label.changeFrameHeight(height: label.frame.size.height * Utility.getBaseScreenHeightMultiplier())
                
                if labelLayout.height != nil {
                    
                    label.changeFrameYAxis(yAxis: label.frame.origin.y + (label.frame.size.height - CGFloat(labelLayout.height!)))
                }
            }
            else if label.labelObject?.key == "watchedTime" {
                
                label.changeFrameWidth(width: label.frame.size.width * Utility.getBaseScreenWidthMultiplier())
                label.changeFrameHeight(height: label.frame.size.height * Utility.getBaseScreenHeightMultiplier())
                
                if labelLayout.width != nil {
                    label.changeFrameXAxis(xAxis: label.frame.origin.x - (label.frame.size.width - CGFloat(labelLayout.width!)))
                }
                
                if labelLayout.height != nil {
                    
                    label.changeFrameYAxis(yAxis: label.frame.origin.y - (label.frame.size.height - CGFloat(labelLayout.height!)))
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
    func updateProgressView(progressView:SFProgressView_tvOS) {
        
        if progressView.progressViewObject != nil {
            progressView.relativeViewFrame = relativeViewFrame!
            let progressViewLayout:LayoutObject = Utility.fetchProgresViewLayoutDetails(progressViewObject: progressView.progressViewObject!)
            progressView.initialiseProgressViewFrameFromLayout(progressViewLayout: progressViewLayout)
            
            self.bringSubview(toFront: progressView)
            if let selectionButton = selectionButton {
                self.bringSubview(toFront: selectionButton)
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
            button.changeFrameHeight(height: button.frame.size.height * Utility.getBaseScreenHeightMultiplier())
            
            if buttonLayout.height != nil {
                
                button.changeFrameYAxis(yAxis: ceil(button.frame.origin.y + (button.frame.size.height - CGFloat(buttonLayout.height!))))
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
    
    func buttonClicked(sender: UIButton!) -> Void {
        if self.tableViewCellDelegate != nil {
            
            if (tableViewCellDelegate?.responds(to: #selector(SFTableViewCellDelegate.playVideo(button:gridObject:cellRowValue:))))! {
                tableViewCellDelegate?.playVideo!(button: sender, gridObject: gridObject, cellRowValue:cellRowValue)
            }
        }
    }
    
    //MARK: Button Delegate method
    func buttonClicked(button: SFButton) {
        
        if self.tableViewCellDelegate != nil {
            if (tableViewCellDelegate?.responds(to: #selector(SFTableViewCellDelegate.buttonClicked(button:gridObject:cellRowValue:))))! {
                tableViewCellDelegate?.buttonClicked!(button: button, gridObject: gridObject, cellRowValue:cellRowValue)
            }
        }
    }
    
    #if os(tvOS)
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if(presses.first?.type == UIPressType.playPause) {
            if (UIScreen.main.focusedView?.isMember(of: UIButton.self))!  {
                let button = UIScreen.main.focusedView
                if(button?.tag == 555){
                    if (tableViewCellDelegate?.responds(to: #selector(SFTableViewCellDelegate.playVideo(button:gridObject:cellRowValue:))))! {
                        tableViewCellDelegate?.playVideo!(button: button as! UIButton, gridObject: gridObject, cellRowValue:cellRowValue)
                    }
                }
            }
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
    #endif

}
