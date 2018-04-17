//
//  SFAutoPlayViewModule_tvOS.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 01/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//
import MarqueeLabel
import UIKit

class SFAutoPlayViewModule_tvOS: UIViewController, SFButtonDelegate {

    var isEpisodicContent : Bool = false
    /// Closure used as a callback for auto play. Acts as the interface between calling class and this class.
    var completionHandler : ((Bool) -> Void)?
    
    /// Holds Array of modules for the page.
    var modulesListArray:Array<AnyObject> = []
    
    /// Associated view object.
    var viewObject:SFAutoPlayViewModuleViewObject?
    
    /// Associated view layout.
    var viewLayout:LayoutObject?
    
    /// Parent view's frame.
    var relativeViewFrame:CGRect?
    
    /// Custom timer loader view.
    var loaderView: SFTimerLoaderView?
    
    let isEpisodeNumberToBeDisplayed : Bool = false
    /// SFFilm object, used to populate the data of the film to be played next.
    private var _nextFilm: SFFilm?
    var nextFilm: SFFilm? {
        set(newValue){
            _nextFilm = newValue
            createModules()
        } get {
            return _nextFilm
        }
    }
    
    /// SFFilm object, used to populate the data of the previously played film.
    private var _previousFilm: SFFilm?
    var previousFilm: SFFilm? {
        set(newValue){
            _previousFilm = newValue
            updatePreviousFilmDetails()
        } get {
            return _previousFilm
        }
    }

    
    init(isEpisodicVideo:Bool) {
        super.init(nibName: nil, bundle: nil)
        isEpisodicContent = isEpisodicVideo
        fetchPageModuleList()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// Method to fetch Page's Module List.
    private func fetchPageModuleList() {
        
        var filePath:String!
        var pageName : String = ""
        if isEpisodicContent{
            pageName = "AutoPlay Screen (Landscape)"
        }
        else{
            pageName = "AutoPlay Screen (Portrait)"
        }
        var pageID: String? = Utility.getPageIdFromPagesArray(pageName: pageName)
        if pageID == nil {
            pageID = Utility.getPageIdFromPagesArray(pageName: "AutoPlay Screen (Portrait)")
        }
        if pageID == nil {
            pageID = Utility.getPageIdFromPagesArray(pageName: "AutoPlay Screen")
        }
        
        guard let page_Id = pageID else{
            return
        }
        filePath = AppSandboxManager.getpageFilePath(fileName: page_Id)
        
        if FileManager.default.fileExists(atPath: filePath) {
            let jsonData:Data = FileManager.default.contents(atPath: filePath)!
            
            let responseStarJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, Any>
            let responseJson:Array<Dictionary<String, AnyObject>> = responseStarJson["moduleList"] as! Array<Dictionary<String, AnyObject>>
            
            let moduleUIParser = ModuleUIParser()
            modulesListArray = moduleUIParser.parseModuleConfigurationJson(modulesConfigurationArray: responseJson) as Array<AnyObject>
        }
    }
    
    /// Method to create modules for the page.
    private func createModules() {
        if modulesListArray.isEmpty == false && modulesListArray[0] is SFAutoPlayViewModuleViewObject {
            viewObject = modulesListArray[0] as? SFAutoPlayViewModuleViewObject
            createPageViewElements()
        }
    }
    
    //MARK: Creating view elements
    private func createPageViewElements() {
        for component:AnyObject in (self.viewObject?.components)! {
            
            if component is SFButtonObject {
                
                let buttonObject:SFButtonObject = component as! SFButtonObject
                createButtonView(buttonObject: buttonObject, type: component.key!!)
            }
            else if component is SFImageObject {
                
                createImageView(imageObject: component as! SFImageObject)
            }
            else if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject, type: component.key!!)
            }
            else if component is SFTimerLoaderViewObject {
                createLoaderView(loaderObject: component as! SFTimerLoaderViewObject)
            }
        }
    }
    
    /// View manuplator method. Called to update the previous film's information.
    private func updatePreviousFilmDetails() {
        for view in self.view.subviews {
            if view is SFLabel && view.tag == 707 {
                let label = view as! SFLabel
                if let previousMovieName = _previousFilm?.title {
                    if isEpisodeNumberToBeDisplayed{
                        label.attributedText = getAttributedTitleForVideo(title: previousMovieName, seasonNumber: "\(String(describing: _previousFilm?.seasonNumber))", episodeNumber: "\(String(describing: _previousFilm?.episodeNumber))", labelObjectFont: label.font)
                    }
                    else{
                        label.text = previousMovieName
                    }
                    break
                }
            }
            
            if view is SFImageView &&  (view.tag == 1009 || view.tag == 2009){
                let imageView = view as! SFImageView
                var imagePathString: String?
                for image in (_previousFilm?.images)! {
                    let imageObj: SFImage = image as! SFImage
                    let imageTypeBackground = Constants.kSTRING_IMAGETYPE_WIDGET
                    let imageTypeThumbnail = self.isEpisodicContent ? Constants.kSTRING_IMAGETYPE_VIDEO :Constants.kSTRING_IMAGETYPE_POSTER
                    
                    let imageType = imageView.imageViewObject?.key == "backgroundImage" ? imageTypeBackground : imageTypeThumbnail

                    
                    if imageObj.imageType == imageType {
                        imagePathString = imageObj.imageSource
                        break
                    }
                    else if imageView.imageViewObject?.key == "backgroundImage"{
                        if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO  {
                            imagePathString = imageObj.imageSource
                            break
                        }
                    }
                }
                if imagePathString != nil
                {
                    imagePathString = imagePathString?.appending("?impolicy=resize&w=\(imageView.frame.size.width)&h=\(imageView.frame.size.height)")
                    imagePathString = imagePathString?.trimmingCharacters(in: .whitespaces)
                    
                    imageView.af_setImage(
                        withURL: URL(string:imagePathString!)!,
                        placeholderImage: UIImage(named: (imageView.imageViewObject?.key == "backgroundImage") ? Constants.kVideoImagePlaceholder : self.isEpisodicContent ? Constants.kVideoImagePlaceholder : Constants.kPosterImagePlaceholder),
                        filter: nil,
                        imageTransition: .crossDissolve(0.2),
                        completion: { response in
                    }
                    )
                }
                else
                {
                    imageView.image = UIImage(named: self.isEpisodicContent ? Constants.kVideoImagePlaceholder : Constants.kPosterImagePlaceholder)
                }
            }
            
            if view is SFImageView && view.tag == 899 {
                let imageView = view as! SFImageView
                var imagePathString: String?
                for image in (_previousFilm?.images)! {
                    
                    let imageObj: SFImage = image as! SFImage
                    if imageObj.imageType == Constants.kSTRING_IMAGETYPE_POSTER
                    {
                        imagePathString = imageObj.badgeImageUrl
                        break
                    }
                }
                
                if imagePathString != nil
                {
                    if !(imagePathString?.isEmpty)! {
                        
                        imageView.isHidden = false
                        imageView.af_setImage(
                            withURL: URL(string:imagePathString!)!,
                            placeholderImage: nil,
                            filter: nil,
                            imageTransition: .crossDissolve(0)
                        )
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
        }
    }
    
    private func createLoaderView(loaderObject: SFTimerLoaderViewObject) {
        let loaderlayout = Utility.fetchLoaderViewLayoutDetails(loaderObject: loaderObject)
        loaderView = SFTimerLoaderView(frame: CGRect.zero)
        loaderView?.relativeViewFrame = self.view.frame
        loaderView?.initialiseViewFromLayout(viewLayout: loaderlayout)
        loaderView?.viewObject = loaderObject
        loaderView?.countdownCompletionHandler = { [weak self] in
            print("countdown Completed")
            self?.dismiss(success: true)
        }
        self.view.addSubview(loaderView!)
    }
    
    
    private func createLabelView(labelObject:SFLabelObject, type: String) {
        
        if labelObject.key == "nextMovieName" {
            let marqueueLabel:MarqueeLabel  = MarqueeLabel()
            let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
            marqueueLabel.frame = Utility.initialiseViewLayout(viewLayout: labelLayout, relativeViewFrame: self.view.frame)
            marqueueLabel.text = _nextFilm?.title
            if isEpisodeNumberToBeDisplayed{
                marqueueLabel.attributedText = getAttributedTitleForVideo(title: (_nextFilm?.title)!, seasonNumber: "\(String(describing: _nextFilm?.seasonNumber))", episodeNumber: "\(String(describing: _nextFilm?.episodeNumber))", labelObjectFont: marqueueLabel.font)
            }
            else{
                marqueueLabel.text = _nextFilm?.title
            }
            marqueueLabel.type = .continuous
            marqueueLabel.speed = .duration(10.0)
            marqueueLabel.animationCurve = .easeInOut
            marqueueLabel.fadeLength = 10.0
            marqueueLabel.leadingBuffer = 0.0
            marqueueLabel.trailingBuffer = 10.0
            marqueueLabel.textAlignment = .left
            marqueueLabel.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
            marqueueLabel.layer.shadowRadius = 1.0
            marqueueLabel.layer.shadowOpacity = 0.8
            marqueueLabel.layer.masksToBounds = false
            marqueueLabel.layer.shouldRasterize = true
            marqueueLabel.isUserInteractionEnabled = false
            marqueueLabel.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff")
            self.view.addSubview(marqueueLabel)

        }
        else{
            let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
            let label:SFLabel = SFLabel(frame: CGRect.zero)
            label.labelObject = labelObject
            label.labelLayout = labelLayout
            label.relativeViewFrame = self.view.frame
            label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            
            label.text = labelObject.text
            if labelObject.key == "previousMovieName" {
                if let previousFilmTitle = _previousFilm?.title {
                    if isEpisodeNumberToBeDisplayed{
                        label.attributedText = getAttributedTitleForVideo(title: previousFilmTitle, seasonNumber: "\(String(describing: _previousFilm?.seasonNumber))", episodeNumber: "\(String(describing: _previousFilm?.episodeNumber))", labelObjectFont: label.font)
                    }
                    else{
                        label.text = previousFilmTitle
                    }
                }
                label.tag = 707
            }
            if labelObject.key == "movieDescription" {
                let paragraphStyle = NSMutableParagraphStyle()
                if let lineHeight = labelObject.lineHeight {
                    paragraphStyle.lineBreakMode = .byTruncatingTail
                    paragraphStyle.minimumLineHeight = CGFloat(lineHeight)
                    paragraphStyle.maximumLineHeight = CGFloat(lineHeight)
                    
                    let attrString = NSMutableAttributedString(string: _nextFilm?.desc ?? "")
                    attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
                    attrString.addAttribute(NSFontAttributeName, value: label.font, range: NSMakeRange(0, attrString.length))
                    label.attributedText = attrString
                } else {
                    label.text = _nextFilm?.desc ?? ""
                }
                label.numberOfLines = 5
            }
            
            if labelObject.key == "upnextLabel" {
                label.tag = 888
            }
            
            label.createLabelView()
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff")
            self.view.addSubview(label)
        }
    }
    
    private func getAttributedTitleForVideo(title : String, seasonNumber: String?, episodeNumber:String?, labelObjectFont:UIFont) -> NSAttributedString{
        let attrString = NSAttributedString(string: title)
        let seasonEpisodeNumber:NSMutableString = NSMutableString()
        if seasonNumber != nil{
            seasonEpisodeNumber.append("S" + seasonNumber!)
        }
        if episodeNumber != nil{
            if seasonNumber != nil{
                seasonEpisodeNumber.append(":")
            }
            seasonEpisodeNumber.append("E" + episodeNumber! + " ")
        }
        let attrString1 = NSMutableAttributedString(string: seasonEpisodeNumber as String)
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
        attrString1.addAttribute(NSForegroundColorAttributeName, value:UIColor.gray, range:NSMakeRange(0, attrString1.length))
        attrString1.addAttribute(NSFontAttributeName, value: UIFont.init(name: "\(fontFamily!)-\(fontWeight!)", size: labelObjectFont.pointSize) ?? "", range: NSMakeRange(0, attrString1.length))

        attrString1.append(attrString)
        
        return attrString1
    }
    
    private func createImageView(imageObject:SFImageObject) {
        let imageView:SFImageView = SFImageView()
        imageView.imageViewObject = imageObject
        imageView.relativeViewFrame = self.view.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
        imageView.updateView()
        if imageView.imageViewObject?.key == "videoImage"{
            var imagePathString: String?
            for image in (_nextFilm?.images)! {
                let imageObj: SFImage = image as! SFImage
                let imageTypeThumbnail: String?
                if imageView.imageType == .landscape {
                    imageTypeThumbnail = Constants.kSTRING_IMAGETYPE_VIDEO
                } else {
                    imageTypeThumbnail = Constants.kSTRING_IMAGETYPE_POSTER
                }
//                imageTypeThumbnail = self.isEpisodicContent ? Constants.kSTRING_IMAGETYPE_VIDEO :Constants.kSTRING_IMAGETYPE_POSTER
                
                let imageType =  imageTypeThumbnail
                if imageObj.imageType == imageType {
                    imagePathString = imageObj.imageSource
                    break
                }
            }
            if imagePathString != nil
            {
                imagePathString = imagePathString?.appending("?impolicy=resize&w=\(imageView.frame.size.width)&h=\(imageView.frame.size.height)")
                imagePathString = imagePathString?.trimmingCharacters(in: .whitespaces)
                
                imageView.af_setImage(
                    withURL: URL(string:imagePathString!)!,
                    placeholderImage: UIImage(named: imageView.imageType == .landscape ? Constants.kVideoImagePlaceholder : Constants.kPosterImagePlaceholder),
                    filter: nil,
                    imageTransition: .crossDissolve(0.2),
                    completion: { response in
                }
                )
            }
            else
            {
                imageView.image = UIImage(named: self.isEpisodicContent ? Constants.kVideoImagePlaceholder : Constants.kPosterImagePlaceholder)
            }
        }
        
        if imageView.imageViewObject?.key == "nextBadgeImage" {
            
            var imagePathString: String?
            for image in (_nextFilm?.images)! {
                
                let imageObj: SFImage = image as! SFImage
                if imageObj.imageType == Constants.kSTRING_IMAGETYPE_POSTER
                {
                    imagePathString = imageObj.badgeImageUrl
                    break
                }
            }
            
            if imagePathString != nil
            {
                if !(imagePathString?.isEmpty)! {
                    
                    imageView.isHidden = false
                    imageView.af_setImage(
                        withURL: URL(string:imagePathString!)!,
                        placeholderImage: nil,
                        filter: nil,
                        imageTransition: .crossDissolve(0)
                    )
                }
                else {
                    
                    imageView.isHidden = true
                }
            }
            else
            {
                imageView.isHidden = true
            }
            imageView.tag = 709
//                        imageView.image = UIImage(named: "badgePotrait")
//                        imageView.isHidden = false
        }

        if  imageView.imageViewObject?.key == "previousVideoImage" {
            imageView.image = UIImage(named: Constants.kVideoImagePlaceholder)
            imageView.tag = 1009
            
            
        }
        
        if imageView.imageViewObject?.key == "previousBadgeImage" {
             imageView.tag = 899
        }
        
        if  imageView.imageViewObject?.key == "backgroundImage" {
            imageView.image = UIImage(named: Constants.kVideoImagePlaceholder)
            imageView.tag = 2009
            
        }
        if imageView.imageViewObject?.key == "backgroundImage" || imageView.imageViewObject?.key == "darkOverlayView" {
            imageView.contentMode = .scaleAspectFill
            imageView.blur(blurRadius: 6)
        }
        if imageView.imageViewObject?.key == "lightOverlayView" {
            imageView.image = UIImage(named: "autoPlayOverlay.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            if let backgroundColor = AppConfiguration.sharedAppConfiguration.backgroundColor {
                imageView.tintColor = Utility.hexStringToUIColor(hex: backgroundColor)
            }
        }
        self.view.addSubview(imageView)
        if imageView.imageViewObject?.key == "videoImage" {
            imageView.contentMode = .scaleAspectFit
            imageView.tag = 909
            addTemporaryFocusButton(imageView: imageView)
        }
    }
    
    private func addTemporaryFocusButton(imageView: SFImageView) {
        let temporaryFocusButton = UIButton(frame: imageView.frame)
        temporaryFocusButton.backgroundColor = .clear
        temporaryFocusButton.tag = 9009
        temporaryFocusButton.addTarget(self, action: #selector(imageButtonTapped), for: .primaryActionTriggered)
        self.view.addSubview(temporaryFocusButton)
    }
    
    private func createButtonView(buttonObject:SFButtonObject, type: String) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        
        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.buttonLayout = buttonLayout
        button.relativeViewFrame = self.view.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.buttonDelegate = self
        button.createButtonView()
        self.view.addSubview(button)
        self.view.bringSubview(toFront: button)
        
        
        if button.buttonObject?.key == "cancelCountdown" {
            let backgroundFocusGuide : UIFocusGuide = UIFocusGuide()
            self.view.addLayoutGuide(backgroundFocusGuide)
            backgroundFocusGuide.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            backgroundFocusGuide.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            backgroundFocusGuide.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            backgroundFocusGuide.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
            backgroundFocusGuide.preferredFocusedView = button
        }
        
    }
    
    /// Button action for playback.
    @objc private func imageButtonTapped() {
        dismiss(success: true)
    }
    
    /// Master method. Called when the view gets dismissed for both should auto play and shouldn't auto play cases.
    ///
    /// - Parameter success: pass true, if the video should get autoplayed and false otherwise.
    private func dismiss(success: Bool) {
        if let completionHandler = completionHandler {
            self.dismiss(animated: true, completion: { 
                completionHandler(success)
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: Presses method overridden.
    private func ignoreMenu(presses: Set<NSObject>) -> Bool {
        return (presses.first! as! UIPress).type == .menu
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if self.ignoreMenu(presses: presses) {
            self.stopCountdown()
            self.dismiss(success: false)
        } else if(presses.first?.type == UIPressType.playPause) {
            dismiss(success: true)
        } else {
            super.pressesBegan(presses, with: event)
        }
    }

    //MARK: SFButton Delegate.
    func buttonClicked(button: SFButton) {
        if button.buttonObject?.key == "cancelCountdown" {
            if button.isSelected { //Back button tapped.
                self.dismiss(success: false)
            } else { //Continue Button tapped.
                self.stopCountdown()
                button.isSelected = true
            }
        }
    }
    
    /// Call this method to stop countdown.
    private func stopCountdown() {
        if let loader = loaderView {
            loader.stopCountdownTimer()
        }
        for view in self.view.subviews {
            if view is SFLabel && view.tag == 888 {
                view.removeFromSuperview()
                break
            }
        }
    }
    
    //MARK: Helper Methods.
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    
        if let button = context.nextFocusedView as? UIButton {
            if button.tag == 9009 {
                let videoImageView : SFImageView = self.view.viewWithTag(909) as! SFImageView
                DispatchQueue.main.async {
                    videoImageView.udpdateBorderColorAndWidth(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "ffffff"), 6)
                }
                Utility.addMotionEffectToViewWithStrength(viewItem: videoImageView, strength: 10.0)
                
                if let prevVideoImageView : SFImageView = self.view.viewWithTag(1009) as? SFImageView{
                    Utility.addMotionEffectToViewWithStrength(viewItem: prevVideoImageView, strength: 10.0)
                }
                
                if let prevBadgeImageView : SFImageView = self.view.viewWithTag(899) as? SFImageView{
                    if #available(tvOS 11.0, *) {
                        Utility.addMotionEffectToViewWithStrength(viewItem: prevBadgeImageView, strength: 10.0)
                    }
                    else{
                        Utility.addMotionEffectToViewWithStrength(viewItem: prevBadgeImageView, strength: 6.0)
                    }
                }
                
                if let nextBadgeImageView : SFImageView = self.view.viewWithTag(709) as? SFImageView{
                    if #available(tvOS 11.0, *) {
                        Utility.addMotionEffectToViewWithStrength(viewItem: nextBadgeImageView, strength: 10.0)
                    }
                    else{
                        Utility.addMotionEffectToViewWithStrength(viewItem: nextBadgeImageView, strength: 6.0)
                    }
                    
                }
              
            }
        }
        
        if let button = context.previouslyFocusedView as? UIButton {
            if button.tag == 9009 {
                let videoImageView : SFImageView = self.view.viewWithTag(909) as! SFImageView
                DispatchQueue.main.async {
                    videoImageView.udpdateBorderColorAndWidth(UIColor.clear, 0)
                }
                Utility.removeMotionEffectFromView(viewItem: videoImageView)
                
                
                if let prevVideoImageView : SFImageView = self.view.viewWithTag(1009) as? SFImageView{
                    Utility.removeMotionEffectFromView(viewItem: prevVideoImageView)
                }
                
                if let prevBadgeImageView : SFImageView = self.view.viewWithTag(899) as? SFImageView{
                    Utility.removeMotionEffectFromView(viewItem: prevBadgeImageView)
                }
                
                if let nextBadgeImageView : SFImageView = self.view.viewWithTag(709) as? SFImageView{
                    Utility.removeMotionEffectFromView(viewItem: nextBadgeImageView)
                }
            }
        }
    }
    
    deinit {
        print("Deinit called!")
    }
}
