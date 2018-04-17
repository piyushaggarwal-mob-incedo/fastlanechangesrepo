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

class SFShowGridCell_tvOS: UICollectionViewCell, SFButtonDelegate {
    
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
    var film : SFFilm?
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
        
        backgroundImageView = UIImageView()
        self.addSubview(backgroundImageView!)
        backgroundImageView?.isHidden = true
        
        videoImage = SFImageView()
        self.addSubview(videoImage!)
        videoImage?.isHidden = true
        videoImage?.isUserInteractionEnabled = false
        
        videoTitle = SFLabel()
        videoTitle?.isHidden = true
        self.addSubview(videoTitle!)
        videoTitle?.isUserInteractionEnabled = false

        badgeImage = SFImageView()
        self.addSubview(badgeImage!)
        badgeImage?.isHidden = true
        badgeImage?.isUserInteractionEnabled = false


        separatorView = SFSeparatorView()
        self.addSubview(separatorView!)
        separatorView?.isHidden = true
        separatorView?.isUserInteractionEnabled = false
        
        #if os(tvOS)
            backgroundImageView?.adjustsImageWhenAncestorFocused = true
            videoImage?.adjustsImageWhenAncestorFocused = true
            if #available(tvOS 11.0, *) {
                badgeImage?.adjustsImageWhenAncestorFocused = true
                badgeImage?.masksFocusEffectToContents = true
            }
        #endif
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
            videoTitle?.labelLayout = labelLayout
            videoTitle?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            videoTitle?.labelObject = labelObject
            videoTitle?.text = film?.title
            videoTitle?.labelLayout = labelLayout
            videoTitle?.createLabelView()
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                videoTitle?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            var episodeNumberString = ""
            
            if episodeNumber != nil {
                
                episodeNumberString = "\(episodeNumber!)"
            }
            
            videoTitle?.attributedText = self.createEpisodeTitle(episodeNumber: episodeNumberString, episodeTitle: film?.title ?? "")
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
            videoImage?.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
            videoImage?.imageViewObject = imageObject
            videoImage?.updateView()
            
            
            //Create a background imageView
            backgroundImageView?.frame = CGRect(x: -5.0, y: -5.0, width: (videoImage?.bounds.size.width)! + 10, height: (videoImage?.bounds.size.height)! + 10)
            backgroundImageView?.image = UIImage(color:Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "ffffff"))
            
            
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
           
            placeholderImagePath = Constants.kVideoImagePlaceholder
            
            if imageURL != nil {
                
                videoImage?.contentMode = .scaleAspectFit
                imageURL = imageURL?.appending("?impolicy=resize&w=\(videoImage?.frame.size.width ?? 0)&h=\(videoImage?.frame.size.height ?? 0)")
                imageURL = imageURL?.trimmingCharacters(in: .whitespaces)
                
                if imageURL != nil {
                    
                    videoImage?.af_setImage(
                        withURL: URL(string: imageURL!)!,
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
        else if imageObject.key != nil && imageObject.key == "badgeImage" {
            
            badgeImage?.isHidden = false
            badgeImage?.relativeViewFrame = relativeViewFrame
            badgeImage?.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
            badgeImage?.imageViewObject = imageObject
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
        }
    }
    

    
    //MARK: Create Separator view
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        separatorView?.isHidden = false
        separatorView?.relativeViewFrame = self.frame
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
            var fontFamily:String?
            if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
                fontFamily = _fontFamily
            }
            if fontFamily == nil {
                fontFamily = "OpenSans"
            }
            var fontWeight:String?
            if UIFont.init(name: "\(fontFamily!)-ExtraBold", size: 20) != nil {
                fontWeight = "ExtraBold"
            } else {
                fontWeight = "Bold"
            }
            if episodeNumber.characters.count > 0 {
                
                attributedTitleString = NSMutableAttributedString(string: concantenatedString!)
                
                attributedTitleString?.addAttributes([NSFontAttributeName: UIFont(name: "\(fontFamily!)-\(fontWeight!)", size: 25)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: "9B9B9B")], range: (concantenatedString! as NSString).range(of: episodeNumber))
                
                attributedTitleString?.addAttributes([NSFontAttributeName: UIFont(name: "\(fontFamily!)-Semibold", size: 25)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: "ffffff")], range: (concantenatedString! as NSString).range(of: episodeTitle))
            }
            else {
                
                attributedTitleString = NSMutableAttributedString(string: concantenatedString!)
                
                attributedTitleString?.addAttributes([NSFontAttributeName: UIFont(name: "\(fontFamily!)-Semibold", size: 25)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: "ffffff")], range: (concantenatedString! as NSString).range(of: episodeTitle))
            }
        }
        
        return attributedTitleString
    }
    
    //MARK: Button Delegate method
    func buttonClicked(button: SFButton) {
        
        if self.showGridCellDelegate != nil {
            
            if (showGridCellDelegate?.responds(to: #selector(SFShowGridCellDelegate.buttonClicked(button:film:cellRowValue:))))! {
                
                showGridCellDelegate?.buttonClicked!(button: button, film: film, cellRowValue:cellRowValue)
            }
        }
    }
    
    //MARK: Layout subview method
    override func layoutSubviews() {
        
        //relativeViewFrame?.size.width = UIScreen.main.bounds.width
        //updateCellSubViewsFrame()
    }

 
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        coordinator.addCoordinatedAnimations({
            
            if self.isFocused {
                let nextFocusedCell = context.nextFocusedView as! SFShowGridCell_tvOS
                var widthDifference = (nextFocusedCell.videoImage?.focusedFrameGuide.layoutFrame.size.width)! - (self.bounds.width)
                widthDifference = abs(widthDifference/2)
                nextFocusedCell.videoTitle?.changeFrameXAxis(xAxis: (nextFocusedCell.videoImage?.focusedFrameGuide.layoutFrame.origin.x)!)
                nextFocusedCell.videoTitle?.changeFrameWidth(width: (self.bounds.width) + widthDifference)
                var heightDifference = (nextFocusedCell.videoImage?.focusedFrameGuide.layoutFrame.size.height)! - (self.videoImage?.bounds.height)!;
                heightDifference = heightDifference/2
                if let originalYAxis = self.originalThumbnailTitleYAxis {
                    nextFocusedCell.videoTitle?.changeFrameYAxis(yAxis: originalYAxis + heightDifference )
                } else {
                    nextFocusedCell.videoTitle?.changeFrameYAxis(yAxis: (self.bounds.height) + heightDifference )
                }
                if #available(tvOS 11.0, *) {
                }
                else{
                    nextFocusedCell.badgeImage?.frame = (nextFocusedCell.videoImage?.focusedFrameGuide.layoutFrame)!
                    Utility.addMotionEffectToViewWithStrength(viewItem: nextFocusedCell.badgeImage!, strength: 6)
                }
                
                self.backgroundImageView?.isHidden = false

            }
            else {
                let previousFocusedCell = context.previouslyFocusedView as! SFShowGridCell_tvOS
                var widthDifference = (previousFocusedCell.videoImage?.focusedFrameGuide.layoutFrame.size.width)! - (self.bounds.width)
                widthDifference = abs(widthDifference/2)
                previousFocusedCell.videoTitle?.changeFrameXAxis(xAxis: (self.videoTitle?.bounds.minX)!)
                previousFocusedCell.videoTitle?.changeFrameWidth(width: (self.bounds.width))
                if let originalYAxis = self.originalThumbnailTitleYAxis {
                    previousFocusedCell.videoTitle?.changeFrameYAxis(yAxis: originalYAxis)
                } else {
                    previousFocusedCell.videoTitle?.changeFrameYAxis(yAxis: (self.bounds.height))
                }
                if #available(tvOS 11.0, *) {
                }
                else{
                    previousFocusedCell.badgeImage?.frame = (previousFocusedCell.videoImage?.frame)!
                    Utility.removeMotionEffectFromView(viewItem: previousFocusedCell.badgeImage!)
                }
                self.backgroundImageView?.isHidden = true
            }
        })
    }
}
