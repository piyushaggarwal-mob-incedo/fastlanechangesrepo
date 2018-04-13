//
//  CarouselView.swift
//  SwiftPOC
//
//  Created by Gaurav Vig on 08/03/17.
//  Copyright © 2017 Gaurav Vig. All rights reserved.
//

import Foundation

#if os(tvOS)
    import ParallaxView
#endif

@objc protocol CarouselViewDelegate:NSObjectProtocol {
    @objc func didSelectVideo(gridObject:SFGridObject?) -> Void
    @objc func didCarouselButtonClicked(contentId:String?, action:String, gridObject:SFGridObject) -> Void
}

class CarouselView: UIView, iCarouselDelegate, iCarouselDataSource, SFButtonDelegate {
    
    var jumbotronView:iCarousel!
    var carouselXAxis:CGFloat = 0.0, carouselYAxis:CGFloat = 0, carouselWidth:CGFloat = 0.0, carouselHeight:CGFloat = 0.0
    var moduleObject:SFModuleObject?
    var isAnimationEnabledForCarousel = false
    var currentIndex:Int = 0
    var jumbotronTimer: Timer?
    var animationDuration:Int = 3
    var pageControl:FXPageControl?
    var isPageControlEnabled = false
    var jumbotronViewObject:JumbotronViewObject!
    var isCarouselWraped:Bool = false
    var carouselSpacing:CGFloat = 1.0
    var isDeviceOrientationLandscape:Bool = false
    var pageControlHeight:CGFloat = 0.0
    var carouselViewDelegate: CarouselViewDelegate?
    var carouselObject:SFJumbotronObject?
    var relativeViewFrame:CGRect?
    var carouselUIObject:SFCarouselObject?
    var pageControlObject:SFPageControlObject?
    var baseFrameForImage:CGSize?
    
    //MARK: Initialisation for Carousel
    func initaliseJumbotronView() {
        
        if carouselObject != nil {
            
            for module:AnyObject in (carouselObject?.jumbotronComponents)! {
                
                if module is SFPageControlObject {
                    
                    if let moduleData = moduleObject?.moduleData {
                        
                        if moduleData.count > 1 {
                            
                            pageControlObject = module as? SFPageControlObject
                            createPageControl()
                        }
                    }
                }
                else if module is SFCarouselObject {
                    
                    carouselUIObject = module as? SFCarouselObject
                    createCarsouselView()
                }
            }
        }
    }
    
    func createCarsouselView() {
        
        jumbotronView = iCarousel (frame: relativeViewFrame!)
        jumbotronView.delegate = self;
        jumbotronView.dataSource = self;
        jumbotronView.isPagingEnabled = true
        jumbotronView.bounces = false;
        jumbotronView.currentItemIndex = self.currentIndex

        jumbotronView.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")

        #if os(tvOS)
            jumbotronView.type = .rotary
        #else
            jumbotronView.type = .linear
        #endif

        self.addSubview(jumbotronView)
        
//        if carouselObject?.animationDuration != nil {
//            
//            if (carouselObject?.animationDuration)! > 0 {
                startJumbotronAnimation()
//            }
//        }
    }

    
    //MARK: Creation of Page Control
    func updatePageControlFrame() {

        if pageControlObject != nil {
            
            let pageControlLayout = Utility.fetchPageControlLayoutDetails(pageControlObject: pageControlObject!)
            pageControl?.frame = Utility.initialiseViewLayout(viewLayout: pageControlLayout, relativeViewFrame: relativeViewFrame!)
        }
    }
    
    
    func createPageControl() {
        
        let pageControlLayout = Utility.fetchPageControlLayoutDetails(pageControlObject: pageControlObject!)

        pageControl = FXPageControl (frame: Utility.initialiseViewLayout(viewLayout: pageControlLayout, relativeViewFrame: relativeViewFrame!))
        pageControl?.defersCurrentPageDisplay = true
        pageControl?.alignment = SFPageControlAlignment.center
        pageControl?.dotSize = (pageControl?.frame.size.height)!
        pageControl?.dotWidth = (pageControl?.frame.size.height)!
        pageControl?.selectedDotColor = Utility.hexStringToUIColor(hex: pageControlObject?.selectorColor ?? "000000")
        pageControl?.dotColor = Utility.hexStringToUIColor(hex: pageControlObject?.unSelectedColor ?? "ffffff")
        pageControl?.autoresizingMask = [.flexibleWidth]
        pageControl?.isUserInteractionEnabled = false
        pageControl?.numberOfPages = (moduleObject?.moduleData?.count)!
        pageControl?.backgroundColor = UIColor.clear
        self.addSubview(pageControl!)
        
        pageControl?.selectedDotColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appPageTitleColor ?? "000000")
        
        if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
            
            pageControl?.dotColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
        }
        
        pageControl?.verticalAlignment = SFPageControlVerticalAlignment.middle
        
    }

    
    //MARK: Jumbotron animation methods
    func startJumbotronAnimation() -> Void {
        if jumbotronTimer == nil {
            
            self.currentIndex = jumbotronView.currentItemIndex
            jumbotronTimer = Timer.scheduledTimer(timeInterval: TimeInterval(carouselObject?.animationDuration ?? 3), target: self, selector: #selector(animateCarousel), userInfo: nil, repeats: true)
            
            RunLoop.current.add(jumbotronTimer!, forMode: RunLoopMode.commonModes)
        }
    }
    
    func stopJumbotronAnimation() -> Void {
        
        jumbotronTimer?.invalidate()
        jumbotronTimer = nil
    }
    
    func animateCarousel() -> Void {
        
        #if os(tvOS)
            if UIScreen.main.focusedView?.isMember(of: (CarouselView.self)) == true {
                stopJumbotronAnimation()
            } else {
                if !(moduleObject?.moduleData?.isEmpty)! {
                    self.currentIndex += 1
                    
                    if self.currentIndex == moduleObject?.moduleData?.count {
                        
                        self.currentIndex = 0
                    }
                    jumbotronView.scrollToItem(at: self.currentIndex, animated: true)
                }
            }
        #else
            if !(moduleObject?.moduleData?.isEmpty)! {
                self.currentIndex += 1
                
                if self.currentIndex == moduleObject?.moduleData?.count {
                    
                    self.currentIndex = 0
                }
                jumbotronView.scrollToItem(at: self.currentIndex, animated: true)
            }
        #endif
    }
    
    //MARK: Carousel Delegates
    @available(iOS 2.0, *)
    public func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        #if os(iOS)
            var itemView: UIView
        #else
            var itemView: SFCarouselItemView

        #endif
        
        //reuse view if available, otherwise create a new view
        if view != nil {
            #if os(iOS)
                itemView = view!
            #else
                itemView = view! as! SFCarouselItemView
            #endif
            
            let gridObject:SFGridObject! = moduleObject?.moduleData![index] as! SFGridObject
            updateCarouselViewComponents(containerView: itemView, gridObject: gridObject, itemIndex: index)
            
        } else {

            #if os(iOS)
                itemView = UIView(frame: relativeViewFrame!)
            #else
                itemView = SFCarouselItemView(frame: relativeViewFrame!)

                for component:AnyObject in (carouselUIObject?.carouselComponents)! {
                    
                    if component is SFCarouselItemObject {
                
                        itemView = SFCarouselItemView(frame: relativeViewFrame!)
                        itemView.relativeViewFrame = jumbotronView?.frame
                        let itemLayout = Utility.fetchCarouselItemLayoutDetails(carouselObject: component as! SFCarouselItemObject)
                        itemView.initialiseCarouselItemViewFrameFromLayout(carouselItemLayout: itemLayout)
                        itemView.layer.cornerRadius = 5
                        itemView.clipsToBounds = true
                    }
                
                }
            #endif
            
            #if os(iOS)
                itemView.backgroundColor = UIColor.clear
                
                let gradient = CAGradientLayer()
                gradient.frame = itemView.bounds
                
                gradient.locations = [0.0, 0.25, 0.65, 0.95]
                
                gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
                gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
                gradient.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor]
                itemView.layer.insertSublayer(gradient, at: 0)
            #endif
            
            let gridObject:SFGridObject! = moduleObject?.moduleData![index] as! SFGridObject
            createCarouselViewComponents(containerView: itemView, gridObject: gridObject, itemIndex:index)
        }
        return itemView
    }
    
    public func numberOfItems(in carousel: iCarousel) -> Int {
        return moduleObject?.moduleData?.count ?? 0
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        switch option {
            
        case iCarouselOption.wrap:
            let result = (carouselObject?.isJumbotronLoopEnabled)! ? 1 : 0
            return CGFloat(result)
        case iCarouselOption.spacing:
            return value
        default:
            return value
        }
    }

    
    public func carouselWillBeginDragging(_ carousel: iCarousel) {
        
        jumbotronTimer?.invalidate()
        jumbotronTimer = nil
    }
    
    public func carouselDidEndDragging(_ carousel: iCarousel, willDecelerate decelerate: Bool) {
        
        startJumbotronAnimation()
    }
    
    
    func carouselItemWidth(_ carousel: iCarousel) -> CGFloat {
        return carouselWidth
    }
    
    
    public func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        
        self.currentIndex = carousel.currentItemIndex
        
        if pageControl != nil {
            
            pageControl?.currentPage = self.currentIndex
        }
        #if os(tvOS)
            if UIScreen.main.focusedView?.isMember(of: (CarouselView.self)) == true {
                removeMotionEffectFromJumbotronObjectAndSelectionBorder(viewItem: self.jumbotronView.previousItemView)
                addMotionEffectToJumbotronObjectAndSelectionBorder(viewItem: self.jumbotronView.currentItemView!)
            }
        #endif
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        if carouselViewDelegate != nil && (carouselViewDelegate?.responds(to: #selector(CarouselViewDelegate.didSelectVideo(gridObject:))))! {
            
            let gridObject = moduleObject?.moduleData?[index] as? SFGridObject
            carouselViewDelegate?.didSelectVideo(gridObject: gridObject)
        }
    }
    
    
    //MARK: Creation of Carousel View Components
    func createCarouselViewComponents(containerView: UIView, gridObject:SFGridObject, itemIndex:Int) {
        
        for component:AnyObject in (carouselUIObject?.carouselComponents)! {
            
            if component is SFButtonObject {
                
                let buttonObject:SFButtonObject = component as! SFButtonObject
                #if os(iOS)

                    if buttonObject.isVisibleForPhone != nil {
                        
                        if Constants.IPHONE && buttonObject.isVisibleForPhone! {
                            createButtonView(buttonObject: buttonObject, containerView: containerView, gridObject: gridObject, itemIndex:itemIndex)
                        }
                    }
                    
                    if buttonObject.isVisibleForTablet != nil {
                        
                        if !Constants.IPHONE && buttonObject.isVisibleForTablet! {
                            createButtonView(buttonObject: buttonObject, containerView: containerView, gridObject: gridObject, itemIndex: itemIndex)
                        }
                    }
                    
                #else
                    
                    createButtonView(buttonObject: buttonObject, containerView: containerView, gridObject: gridObject, itemIndex: itemIndex)
                
                #endif
            }
            else if component is SFImageObject {
                
                createImageView(imageObject: component as! SFImageObject, containerView: containerView, gridObject: gridObject)
            }
            else if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject, containerView: containerView, gridObject: gridObject)
            }
        }
    }
    
    func createLabelView(labelObject:SFLabelObject, containerView:UIView, gridObject:SFGridObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame

        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        containerView.addSubview(label)
        
        label.createLabelView()
        
        if labelObject.key == "carouselTitle" {
            
            label.text = gridObject.contentTitle ?? ""
            
        }
        else if labelObject.key == "carouselInfo" {
            
            let carouselInfoString:String? = getCarouselInfoString(gridObject: gridObject)
            label.text = carouselInfoString ?? ""
        }
        
        label.changeFrameHeight(height: label.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        if labelLayout.height != nil {
            
            label.changeFrameYAxis(yAxis: label.frame.origin.y - (label.frame.size.height - CGFloat(labelLayout.height!)))
        }
        
        if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
            
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
        }
        
        label.font = UIFont(name: label.font.fontName, size: label.font.pointSize * Utility.getBaseScreenHeightMultiplier())
    }
    
    
    func getCarouselInfoString(gridObject:SFGridObject) -> String? {
        
        let videoDurationInMinutes:Int = Int(gridObject.totalTime ?? 0) / 60
        
        var videoDurationValue:String?
        
        if videoDurationInMinutes > 1 {
            
            videoDurationValue = "\(videoDurationInMinutes) MINS"
        }
        else if videoDurationInMinutes == 1{
            
            videoDurationValue = "\(videoDurationInMinutes) MIN"
        }
        
        let videoYear:String? = gridObject.year
        let videoCategory:String? = gridObject.videoCategory
        
        var carouselInfoString:String?
        
        if videoDurationValue != nil {
            
            carouselInfoString = videoDurationValue
        }
        
        if videoYear != nil {
            
            if carouselInfoString != nil {
                
                carouselInfoString?.append(" | \(videoYear!)")
            }
            else {
                carouselInfoString = videoYear!
            }
        }
        
        if videoCategory != nil {
            
            if carouselInfoString != nil {
                
                carouselInfoString?.append(" | \(videoCategory!.uppercased())")
            }
            else {
                carouselInfoString = videoCategory!.uppercased()
            }
        }

        return carouselInfoString
    }
    
    func createButtonView(buttonObject:SFButtonObject, containerView:UIView, gridObject:SFGridObject, itemIndex:Int) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        
        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.buttonLayout = buttonLayout
        button.buttonDelegate = self
        button.tag = itemIndex
        containerView.addSubview(button)
        
        button.createButtonView()

        button.changeFrameHeight(height: button.frame.height * Utility.getBaseScreenHeightMultiplier())
        button.changeFrameWidth(width: button.frame.width * Utility.getBaseScreenWidthMultiplier())
        if buttonObject.isVisibleForPhone! {
            
            let playButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "play.png"))
            
            button.setImage(playButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView?.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")

        }
        else {
            
            button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!, size: (button.titleLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
        }
        
        if buttonLayout.height != nil {
            
            button.changeFrameYAxis(yAxis: button.frame.origin.y - (button.frame.size.height - CGFloat(buttonLayout.height!)))
        }
        
        if buttonObject.key == "watchNow" {
            
            button.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000")
            button.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor ?? AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        }
        
        if buttonLayout.width != nil {
            
            if buttonLayout.isVerticallyCentered != nil {
                button.changeFrameXAxis(xAxis: button.frame.origin.x - (button.frame.size.width - CGFloat(buttonLayout.width!))/2)
            }
        }
        
        if gridObject.contentType == Constants.kShowContentType || gridObject.contentType == Constants.kShowsContentType {
            
            button.isHidden = true
            button.isUserInteractionEnabled = false
        }
        else {
            
            button.isHidden = false
            button.isUserInteractionEnabled = true
        }
    }
    
    
    func createImageView(imageObject:SFImageObject, containerView:UIView, gridObject:SFGridObject) {
        
        if imageObject.key == "playImage" {
        
            if imageObject.isVisibleForiPhone != nil {
                
                #if os(iOS)
                if !(imageObject.isVisibleForiPhone!) && !Constants.IPHONE {
                    
                    return
                }
                #endif
            }
            else {
                return
            }
        }
        
        let imageView:SFImageView = SFImageView()
        imageView.imageViewObject = imageObject
        imageView.relativeViewFrame = containerView.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
        imageView.updateView()

        imageView.backgroundColor = UIColor.clear
        containerView.addSubview(imageView)

        if imageObject.key == "carouselImage" {
            
            if baseFrameForImage == nil {
                
                baseFrameForImage = imageView.frame.size
            }
            
            var imageURLPath:String?
            
            for image in gridObject.images {
                
                let imageObj: SFImage = image as! SFImage
                
                if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO || imageObj.imageType == Constants.kSTRING_IMAGETYPE_WIDGET {
                    
                    imageURLPath = imageObj.imageSource
                    break
                }
            }
            
            if imageURLPath == nil {
                
                imageURLPath = gridObject.thumbnailImageURL
            }
            
            if baseFrameForImage != nil {
                
                if imageURLPath != nil {
                    
                    imageURLPath = imageURLPath?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: baseFrameForImage?.width ?? 0))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: baseFrameForImage?.height ?? 0))")
                    imageURLPath = imageURLPath?.trimmingCharacters(in: NSCharacterSet.whitespaces)
                }
            }
            
            if imageURLPath != nil {
                imageURLPath = imageURLPath?.trimmingCharacters(in: .whitespaces)
                if let imgUrl = URL(string: imageURLPath!){
                    
                    imageView.af_setImage(
                        withURL: imgUrl,
                        placeholderImage: UIImage(named: Constants.kVideoImagePlaceholder),
                        filter: nil,
                        imageTransition: .crossDissolve(0.2)
                    )
                }
                else{
                    
                    imageView.image = UIImage(named: Constants.kVideoImagePlaceholder)
                }
            }
            else {
                
                imageView.image = UIImage(named: Constants.kVideoImagePlaceholder)
            }
            
            containerView.sendSubview(toBack: imageView)
        }
        else if imageObject.key == "carouselBadgeImage" {
            
            if baseFrameForImage == nil {
                
                baseFrameForImage = imageView.frame.size
            }
            
            var imageURLPath:String?
            
            for image in gridObject.images {
                
                let imageObj: SFImage = image as! SFImage
                
                if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO || imageObj.imageType == Constants.kSTRING_IMAGETYPE_WIDGET {
                    
                    imageURLPath = imageObj.badgeImageUrl
                    break
                }
            }
            
            if baseFrameForImage != nil {
                
                if imageURLPath != nil {
                    
                    imageURLPath = imageURLPath?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: baseFrameForImage?.width ?? 0))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: baseFrameForImage?.height ?? 0))")
                    imageURLPath = imageURLPath?.trimmingCharacters(in: NSCharacterSet.whitespaces)
                }
            }
            
            if imageURLPath != nil {
                
                imageURLPath = imageURLPath?.trimmingCharacters(in: .whitespaces)
                
                if let imageUrl = URL(string: imageURLPath!) {
                    
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
            
            imageView.tag = 999
        }
        else if imageObject.key == "playImage" {
            
            imageView.image = UIImage(named: "play")
        }
    }

    //MARK: Updation of Carousel Components
    func updateCarouselViewComponents(containerView: UIView, gridObject:SFGridObject, itemIndex:Int) {
        
        for component:AnyObject in containerView.subviews {
            
            if component is SFImageView {
            
                updateImageView(imageView: component as! SFImageView, gridObject: gridObject)
            }
            else if component is SFLabel {
                
                updateLabelText(label: component as! SFLabel, gridObject: gridObject)
            }
            else if component is SFButton {
                
                updateButton(button: component as! SFButton, itemIndex: itemIndex)
            }
        }
    }
    
    func updateImageView(imageView:SFImageView, gridObject:SFGridObject) {
        
        if imageView.imageViewObject?.key == "carouselImage" {
            
            var imageURLPath:String?
            
            for image in gridObject.images {
                
                let imageObj: SFImage = image as! SFImage
                
                if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO {
                    
                    imageURLPath = imageObj.imageSource
                    break
                }
                else if imageObj.imageType == Constants.kSTRING_IMAGETYPE_WIDGET {
                    
                    imageURLPath = imageObj.imageSource
                    break
                }
            }
            
            if imageURLPath == nil {
                
                imageURLPath = gridObject.thumbnailImageURL
            }
            
            if baseFrameForImage != nil {
                
                if imageURLPath != nil {
                    
                    imageURLPath = imageURLPath?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: baseFrameForImage?.width ?? 0))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: baseFrameForImage?.height ?? 0))")
                }
            }
            
            if imageURLPath != nil {
                
                imageURLPath = imageURLPath?.trimmingCharacters(in: .whitespaces)
                
                if imageURLPath != nil && !(imageURLPath?.isEmpty)! {
                    
                    if let imageUrl = URL(string: imageURLPath!) {
                        
                        imageView.af_setImage(
                            withURL: imageUrl,
                            placeholderImage: UIImage(named: Constants.kVideoImagePlaceholder),
                            filter: nil,
                            imageTransition: .crossDissolve(0.2)
                        )
                    }
                    else {
                        
                        imageView.image = UIImage(named: Constants.kVideoImagePlaceholder)
                    }
                }
            }
        }
        else if imageView.imageViewObject?.key == "carouselBadgeImage" {

            var imageURLPath:String?
            
            for image in gridObject.images {
                
                let imageObj: SFImage = image as! SFImage
                
                if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO {
                    
                    imageURLPath = imageObj.badgeImageUrl
                    break
                }
                else if imageObj.imageType == Constants.kSTRING_IMAGETYPE_WIDGET {
                    
                    imageURLPath = imageObj.badgeImageUrl
                    break
                }
            }

            if baseFrameForImage != nil {

                if imageURLPath != nil {
                    
                    imageURLPath = imageURLPath?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: baseFrameForImage?.width ?? 0))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: baseFrameForImage?.height ?? 0))")
                }
            }

            if imageURLPath != nil {
                
                imageURLPath = imageURLPath?.trimmingCharacters(in: .whitespaces)
                
                if imageURLPath != nil && !(imageURLPath?.isEmpty)! {
                    
                    if let imageUrl = URL(string: imageURLPath!) {
                        
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
            else {
                
                imageView.isHidden = true
            }
        }
    }
    
    
    func updateLabelText(label:SFLabel, gridObject:SFGridObject) {
        
        if label.labelObject?.key == "carouselTitle" {
            
            label.text = gridObject.contentTitle ?? ""
            
        }
        else if label.labelObject?.key == "carouselInfo" {
            
            let carouselInfoString:String? = getCarouselInfoString(gridObject: gridObject)
            label.text = carouselInfoString ?? ""
        }
    }
    
    
    func updateButton(button:SFButton, itemIndex:Int) {
        
        button.tag = itemIndex
        
    }
    //MARK: Button Delegate Events
    func buttonClicked(button: SFButton) {
        let gridObject:SFGridObject! = moduleObject?.moduleData![button.tag] as! SFGridObject
        
        if carouselViewDelegate != nil && (carouselViewDelegate?.responds(to: #selector(CarouselViewDelegate.didCarouselButtonClicked(contentId:action:gridObject:))))! {
            
            carouselViewDelegate?.didCarouselButtonClicked(contentId: gridObject.contentId, action: button.buttonObject?.action ?? "", gridObject: gridObject)
        }
    }
    
    #if os (tvOS)
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if(presses.first?.type == UIPressType.playPause) {
            if (UIScreen.main.focusedView?.isMember(of: (CarouselView.self)))! || UIScreen.main.focusedView is CarouselView  {
                let index = jumbotronView.currentItemIndex
                
                let gridObject:SFGridObject! = moduleObject?.moduleData![index] as! SFGridObject
                if carouselViewDelegate != nil && (carouselViewDelegate?.responds(to: #selector(CarouselViewDelegate.didCarouselButtonClicked(contentId:action:gridObject:))))! {
                    carouselViewDelegate?.didCarouselButtonClicked(contentId: gridObject.contentId!, action: "watchVideo", gridObject: gridObject)
                }
                
            }
        } else if (presses.first?.type == UIPressType.menu) {
//            let userInfo = [ "presses" : presses, "event": event!] as [String : Any]
//            NotificationCenter.default.post(name: Notification.Name("MenuButtonTappedOnCarousel"), object: nil , userInfo : userInfo)
            super.pressesBegan(presses, with: event)
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if(presses.first?.type == UIPressType.select) {
            if (UIScreen.main.focusedView?.isMember(of: (CarouselView.self)))! || UIScreen.main.focusedView is CarouselView  {
                let index = jumbotronView.currentItemIndex
                
                if carouselViewDelegate != nil && (carouselViewDelegate?.responds(to: #selector(CarouselViewDelegate.didSelectVideo(gridObject:))))! {
                    
                    let gridObject = moduleObject?.moduleData?[index] as? SFGridObject
                    carouselViewDelegate?.didSelectVideo(gridObject: gridObject)
                }
            }
        }
        else {
            
            super.pressesEnded(presses, with: event)
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {

        //TODO: need to rmeove the effect
        if context.nextFocusedView != nil && context.nextFocusedView?.isMember(of: (CarouselView.self)) == true {
            addMotionEffectToJumbotronObjectAndSelectionBorder(viewItem: self.jumbotronView.currentItemView!)
            stopJumbotronAnimation()
        } else {
            removeMotionEffectFromJumbotronObjectAndSelectionBorder(viewItem: self.jumbotronView.currentItemView!)
            startJumbotronAnimation()
        }
    }
    
    func addMotionEffectToJumbotronObjectAndSelectionBorder (viewItem : UIView) {

        udpdateBorderColorAndWidth(viewItem, Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "ffffff"), 5)
        removeMotionEffectFromJumbotronObjectAndSelectionBorder(viewItem: viewItem)
        viewItem.addMotionEffect(UIMotionEffect.twoAxesShift(strength: 15))
    }
    
    func removeMotionEffectFromJumbotronObjectAndSelectionBorder (viewItem : UIView) {
        var ii = 0
        while ii < (viewItem.motionEffects.count) {
            var motionEffect = viewItem.motionEffects[ii]
            if motionEffect is UIMotionEffectGroup {
                motionEffect = motionEffect as! UIMotionEffectGroup
                viewItem.removeMotionEffect(motionEffect)
                udpdateBorderColorAndWidth(viewItem, UIColor.clear, 0)
            }
            ii = ii + 1
        }
    }
    
    func udpdateBorderColorAndWidth(_ view: UIView,_ color: UIColor, _ width: CGFloat) {
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = width
    }
    
    override var canBecomeFocused: Bool {
        return true
    }
    #endif
    
}
