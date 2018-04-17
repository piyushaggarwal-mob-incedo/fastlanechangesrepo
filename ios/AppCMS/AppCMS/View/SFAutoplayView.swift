//
//  SFAutoplayView.swift
//  AppCMS
//
//  Created by  Diksha Goyal on 10/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

let backButtonString = "backButtonString"
let movieNameLabelString = "movieNameTitle"
let movieSubheadingLabelString = "movieNameSubheading"
let movieDescriptionString = "movieDescription"
let directorString = "directorLabel"
let subDirectorString = "subDirectorLabel"
let playedButtonString = "playButton"
let cancelButtonString = "cancelButton"
let playingInLabelString = "playInLabel"
let timerLabelString = "timerLabel"
let parentLabelString = "parentalRating"


@objc protocol SFAutoPlayDelegate:NSObjectProtocol {
   // @objc func dismissAutoPlayView(button:SFButton) -> Void
    @objc func moreButtonTapped(filmObject: SFFilm) -> Void
}



class SFAutoplayView: UIView,SFButtonDelegate {
    weak var loginViewDelegate: LoginViewDelegate?
    var autoPlayObject: SFAutoplayObject!
    var film: SFFilm!
    var progressIndicator:MBProgressHUD?
    weak var autoPlayDelegate:SFAutoPlayDelegate?
    var timer: Timer!
    var timerValue : Int!

    init(frame: CGRect, autoplayObject: SFAutoplayObject, filmObject: SFFilm) {
        super.init(frame: frame)
        self.autoPlayObject = autoplayObject
        self.film=filmObject
        timerValue=autoplayObject.timerValue
        self.backgroundColor=UIColor.clear
        createView()
        timer=Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector (self.updateTimer), userInfo: nil, repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createView() -> Void {
        createAutoPlayView(containerView: self, itemIndex: 0)
    }
    
    func updateTimer()
    {
        if(timerValue==1)
        {
            timer .invalidate()
            NotificationCenter.default.post(name: Notification.Name("dismissAutoplayView"), object: autoPlayButtonAction.play)
        }
        else
        {
            for component: AnyObject in self.subviews {
                
                if component is SFLabel {
                    
                    updateTimerValue(label: component as! SFLabel, containerView: self)
                }
            }
        }
   }
        
    func updateView() -> Void
    {
        for component: AnyObject in self.subviews {
            
            if component is SFButton {
                
                updateButtonViewFrame(button: component as! SFButton, containerView: self)
            }
            else if component is SFLabel {
                
                updateLabelViewFrame(label: component as! SFLabel, containerView: self)
            }
            else if component is SFStarRatingView {
                
                updateStarViewFrame(starView: component as! SFStarRatingView, containerView: self)
            }
            else if component is SFImageView {
                
                updateImageViewFrame(imageView: component as! SFImageView, containerView: self)
            }
            else if component is SFCastView {
                
                updateCastViewFrame(castView: component as! SFCastView, containerView: self)
            }

        }
    }
    func updateButtonViewFrame(button:SFButton, containerView:UIView) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: button.buttonObject!)
        
        button.relativeViewFrame = containerView.frame

        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.changeFrameWidth(width: button.frame.width * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameHeight(height: button.frame.height * Utility.getBaseScreenHeightMultiplier())
        if button.buttonObject?.key == "playButton" || button.buttonObject?.key == "cancelButton" {
            if #available(iOS 11.0, *) {
                if ((UIApplication.shared.keyWindow?.safeAreaInsets.bottom)! > CGFloat(0.0)){
                    button.changeFrameYAxis(yAxis: button.frame.minY - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!)
                }
            }
        }
        
        if buttonLayout.height != nil {
            
            button.changeFrameYAxis(yAxis: button.frame.origin.y - (button.frame.size.height - CGFloat(buttonLayout.height!))/2)
        }
        
        if button.buttonObject?.key == "cancelButton" {
            
            if buttonLayout.width != nil {
                
                button.changeFrameXAxis(xAxis: button.frame.origin.x + ((button.frame.size.width - CGFloat(buttonLayout.width!)) * -1))
            }
        }
    }
    
    func updateImageViewFrame(imageView:SFImageView, containerView:UIView) {
        
        if imageView.imageViewObject?.key != nil && imageView.imageViewObject?.key == "movieImage" {
            
            imageView.relativeViewFrame = containerView.frame
            imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageView.imageViewObject!))
            
            imageView.changeFrameYAxis(yAxis: imageView.frame.minY * Utility.getBaseScreenHeightMultiplier())
            imageView.changeFrameWidth(width: imageView.frame.width * Utility.getBaseScreenWidthMultiplier())
            imageView.changeFrameHeight(height: imageView.frame.height * Utility.getBaseScreenHeightMultiplier())
        }
    }
    
    func updateStarViewFrame(starView:SFStarRatingView, containerView:UIView) {
        
        starView.relativeViewFrame = containerView.frame
        starView.initialiseStarRatingFrameFromLayout(ratingLayout: Utility.fetchStarRatingLayoutDetails(starRatingObject: starView.starRatingObject!))
  
    }
    //MARK: Update Video Description Subviews
    func updateLabelViewFrame(label:SFLabel, containerView:UIView) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!)
        label.labelLayout = labelLayout
        
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
      
        //label.changeFrameWidth(width: label.frame.width * Utility.getBaseScreenWidthtMultiplierForAutoPlay())
        label.changeFrameHeight(height: label.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        if label.labelObject?.key == movieDescriptionString &&  self.film.desc != nil
        {
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            label.text = self.film.desc!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        }
    }

    
    func updateTimerValue(label:SFLabel, containerView:UIView) {
        
        if(label.labelObject?.key==timerLabelString){
            timerValue! -= 1
            label.text=String(format:"%d seconds",timerValue)}
     
    }
    
    //MARK: Creation of View Components
    func createAutoPlayView(containerView: UIView, itemIndex:Int) -> Void
    {
        
        for component:AnyObject in self.autoPlayObject.components {
            
            if component is SFButtonObject {
                
                let buttonObject:SFButtonObject = component as! SFButtonObject
                
                createButtonView(buttonObject: buttonObject, containerView: self, itemIndex: itemIndex, type: component.key!!)
            }
            else if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject, containerView: containerView, type: component.key!!)
            }
            else if component is SFImageObject {
                
                createImageView(imageObject: component as! SFImageObject, containerView: containerView)
            }
            else if component is SFCastViewObject
            {
                if !Constants.IPHONE {
                createCastView(castObject: component as! SFCastViewObject, containerView: containerView)
                }
            }

            else if component is SFStarRatingObject
            {
                createStarView(starObject: component as! SFStarRatingObject, containerView: containerView)
            }
            
        }
    }
    
    func createButtonView(buttonObject:SFButtonObject, containerView:UIView, itemIndex:Int, type: String) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        
        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.buttonLayout = buttonLayout
        //button.buttonLayout?.updateLayoutObjectForCurrentSystem()
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.buttonDelegate = self
        button.tag = itemIndex
        button.createButtonView()
        
        if type == backButtonString{
            
            let backButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "Back Chevron.png"))
            
            button.setImage(backButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        }
       
        if buttonObject.key == "playButton" {
            
            button.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000")
            button.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor ?? AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        }
        
        button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!, size: (button.titleLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
        if button.buttonObject?.key == "playButton" || button.buttonObject?.key == "cancelButton" {
            if #available(iOS 11.0, *) {
                if ((UIApplication.shared.keyWindow?.safeAreaInsets.bottom)! > CGFloat(0.0)){
                    button.changeFrameYAxis(yAxis: button.frame.minY - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)! + 20)
                }
            }
        }
        containerView.addSubview(button)
        containerView.bringSubview(toFront: button)
    }
    
    
    func createCastView(castObject:SFCastViewObject, containerView:UIView) {
        
        let castView:SFCastView_tvOS = SFCastView_tvOS()
        castView.castViewObject = castObject
        castView.relativeViewFrame = containerView.frame
        castView.initialiseCastViewFrameFromLayout(castViewLayout: Utility.fetchCastViewLayoutDetails(castViewObject: castObject))
        containerView.addSubview(castView)
        castView.updateView()
        castView.createSegregatedCastViewWithCastSet(self.film.credits)
        
    }
    
    func createLabelView(labelObject:SFLabelObject, containerView:UIView, type: String) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        //label.labelLayout?.updateLayoutObjectForCurrentSystem()
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.createLabelView()
        
        if type ==  movieNameLabelString
        {
            label.text = self.film.title
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
        else if type == movieSubheadingLabelString
        {
            label.textColor = UIColor.white.withAlphaComponent(0.51)
            
            label.text = getVideoInfoString()
        }
        else if type == movieDescriptionString {
            label.numberOfLines = 0
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }

            if self.film.desc != nil {
                label.text = self.film.desc!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            }

        }
        else if type == parentLabelString
        {
            if self.film.parentalRating != nil {
                
                label.layer.borderColor = UIColor.white.withAlphaComponent(0.39).cgColor
                label.textColor = UIColor.white.withAlphaComponent(0.39)
                label.text = Utility.sharedUtility.calculateParentalRating(parentalRating: self.film.parentalRating!) ?? ""
                label.textAlignment = .center
                label.layer.borderWidth = 2.0
                if (label.text?.isEmpty)! {
                    
                    label.isHidden = true
                }
            }
            else {
                label.isHidden = true
            }
        }
        else{
            label.text = labelObject.text 
        }
       
        containerView.addSubview(label)
        containerView.bringSubview(toFront: label)
          label.font = UIFont(name: label.font.fontName, size: label.font.pointSize * Utility.getBaseScreenHeightMultiplier())
    }
    func moreTapGestureRecongniser(tapGesture: UITapGestureRecognizer) -> Void {
        if self.autoPlayDelegate != nil && (self.autoPlayDelegate?.responds(to: #selector(self.autoPlayDelegate?.moreButtonTapped(filmObject:))))! {
            self.autoPlayDelegate?.moreButtonTapped(filmObject: self.film)
        }
    }
    func createImageView(imageObject:SFImageObject, containerView:UIView) {
        
        let imageView:SFImageView = SFImageView()
        if imageObject.key != nil && imageObject.key == "movieImage" {
            imageView.imageViewObject = imageObject
            imageView.relativeViewFrame = containerView.frame
            imageView.imageViewObject = imageObject
            imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
            imageView.updateView()

            imageView.changeFrameYAxis(yAxis: imageView.frame.minY * Utility.getBaseScreenHeightMultiplier())
            imageView.changeFrameWidth(width: imageView.frame.width * Utility.getBaseScreenWidthMultiplier())
            imageView.changeFrameHeight(height: imageView.frame.height * Utility.getBaseScreenHeightMultiplier())

            var imagePathString: String?

            for image in self.film.images {
                
                let imageObj: SFImage = image as! SFImage
                if imageObj.imageType == Constants.kSTRING_IMAGETYPE_POSTER
                {
                    imagePathString = imageObj.imageSource
                    break
                }
            }
            
            if imagePathString == nil {
                for image in self.film.images {
                    let imageObj: SFImage = image as! SFImage
                    if imageObj.imageType == nil {
                        if  imageObj.imageSource != nil {
                            imagePathString = imageObj.imageSource
                            break
                        }
                    }
                    else {
                       if imageObj.imageType == Constants.kSTRING_IMAGETYPE_POSTER || imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO
                        {
                            imagePathString = imageObj.imageSource
                            break
                        }
                    }
                }
            }

            if imagePathString != nil
            {
                if !(imagePathString?.isEmpty)! {
                    imagePathString = imagePathString?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: imageView.frame.size.width))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: imageView.frame.size.height))")
                    imagePathString = imagePathString?.trimmingCharacters(in: .whitespaces)
                    if let imageUrl = URL(string:imagePathString!) {
                        
                        imageView.af_setImage(
                            withURL: imageUrl,
                            placeholderImage: UIImage(named: Constants.kPosterImagePlaceholder),
                            filter: nil,
                            imageTransition: .crossDissolve(0.2)
                        )
                    }
                    else {
                        
                        imageView.image = UIImage(named: Constants.kPosterImagePlaceholder)
                    }
                }
            }
            else
            {
                imageView.image = UIImage(named: Constants.kPosterImagePlaceholder)
            }
        }
        else if imageObject.key != nil && imageObject.key == "badgeImage" {

            imageView.imageViewObject = imageObject
            imageView.relativeViewFrame = containerView.frame
            imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
            imageView.updateView()

            imageView.changeFrameYAxis(yAxis: imageView.frame.minY * Utility.getBaseScreenHeightMultiplier())
            imageView.changeFrameWidth(width: imageView.frame.width * Utility.getBaseScreenWidthMultiplier())
            imageView.changeFrameHeight(height: imageView.frame.height * Utility.getBaseScreenHeightMultiplier())

            var imagePathString: String?

            for image in self.film.images {
                
                let imageObj: SFImage = image as! SFImage
                if imageObj.imageType == Constants.kSTRING_IMAGETYPE_POSTER
                {
                    imagePathString = imageObj.badgeImageUrl
                }
            }

            if imagePathString != nil
            {
                if !(imagePathString?.isEmpty)! {

                    if let imageUrl = URL(string:imagePathString!) {
                        
                        imageView.isHidden = false
                        imageView.af_setImage(
                            withURL: imageUrl,
                            placeholderImage: nil,
                            filter: nil,
                            imageTransition: .crossDissolve(0.2)
                        )
                    }
                }
                else {
                    
                    imageView.isHidden = true
                }
            }
            else
            {
                imageView.isHidden = true
            }
        }

        containerView.addSubview(imageView)
    }
    
    func updateCastViewFrame(castView:SFCastView, containerView:UIView) {
        
        // let castLayout = Utility.fetchCastViewLayoutDetails(castViewObject: castView.castViewObject!)
        castView.relativeViewFrame = containerView.frame
        //castLayout.updateLayoutObjectForCurrentSystem()
        castView.initialiseCastViewFrameFromLayout(castViewLayout: Utility.fetchCastViewLayoutDetails(castViewObject: castView.castViewObject!))
        
        //castView.changeFrameXAxis(xAxis: castView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        //castView.changeFrameYAxis(yAxis: castView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        castView.changeFrameWidth(width: castView.frame.width * Utility.getBaseScreenWidthMultiplier())
        castView.changeFrameHeight(height: castView.frame.height * Utility.getBaseScreenHeightMultiplier())
    }
    
    func createStarView(starObject:SFStarRatingObject, containerView:UIView) {
        
        let starView:SFStarRatingView = SFStarRatingView()
        starView.starRatingObject = starObject
        starView.relativeViewFrame = containerView.frame
        
        starView.initialiseStarRatingFrameFromLayout(ratingLayout: Utility.fetchStarRatingLayoutDetails(starRatingObject: starObject))
        
        starView.changeFrameXAxis(xAxis: starView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        starView.changeFrameYAxis(yAxis: starView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        starView.changeFrameWidth(width: starView.frame.width * Utility.getBaseScreenWidthMultiplier())
        starView.changeFrameHeight(height: starView.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        if self.film.viewerGrade != nil
        {
            if Int(self.film.viewerGrade!) > 0 {
                starView.updateView(userRating: self.film.viewerGrade!)
            }
        }
        //starView.isUserInteractionEnabled = true
       // let starTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.starTapGestureRecongniser(tapGesture:)))
        //            moreTapGesture.addTarget(self, action: #selector(moreTapGestureRecongniser(tapGesture:)))
        //starView.addGestureRecognizer(starTapGesture)
 
        containerView.addSubview(starView)
    }

    @objc func buttonClicked(button:SFButton) -> Void
    {
         if button.buttonObject?.key == cancelButtonString
        {
            timer .invalidate()
           
            NotificationCenter.default.post(name: Notification.Name("dismissAutoplayView"), object: autoPlayButtonAction.cancel)
        }
        else if button.buttonObject?.key == playButtonString
         {
            timer .invalidate()
            
            NotificationCenter.default.post(name: Notification.Name("dismissAutoplayView"), object: autoPlayButtonAction.play)
        }
    }
    //MARK - method to create video detail page - video info label(metadata)
    func getVideoInfoString() -> String? {
        
        let videoDurationInMinutes:Int = Int(self.film.durationSeconds ?? 0) / 60
        
        var videoDurationValue:String?
        
        if videoDurationInMinutes > 1 {
            
            videoDurationValue = "\(videoDurationInMinutes) MINS"
        }
        else if videoDurationInMinutes == 1{
            
            videoDurationValue = "\(videoDurationInMinutes) MIN"
        }
        
        let videoYear:String? = self.film.year
        let videoCategory:String? = self.film.primaryCategory
        
        var videoInfoString:String?
        
        if videoDurationValue != nil {
            
            videoInfoString = videoDurationValue
        }
        
        if videoYear != nil {
            
            if videoInfoString != nil {
                
                if !(videoYear?.isEmpty)! {
                    
                    videoInfoString?.append(" | \(videoYear!)")
                }
            }
            else {
                videoInfoString = videoYear!
            }
        }
        
        if videoCategory != nil {
            
            if videoInfoString != nil {
                
                if !(videoCategory?.isEmpty)! {
                    videoInfoString?.append(" | \(videoCategory!.uppercased())")
                }
            }
            else {
                videoInfoString = videoCategory!
            }
        }
        
        return videoInfoString
    }
}
