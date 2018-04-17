//
//  SFCRWModule.swift
//  AppCMS_tvOS
//
//  Created by Anirudh Vyas on 10/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFCRWModule: UIViewController, SFButtonDelegate {
    
    fileprivate var backButton:SFButton?
    fileprivate var warningLabel:SFLabel?
    fileprivate var ratingLabel:SFLabel?
    fileprivate var borderLabel:SFLabel?
    fileprivate var viewerDiscretionLable:SFLabel?
    fileprivate var progressView:SFProgressView_tvOS?

    /// Closure used as a callback for auto play. Acts as the interface between calling class and this class.
    var completionHandler : ((Bool) -> Void)?
    
    /// Holds Array of modules for the page.
    private var modulesListArray:Array<AnyObject> = []
    
    /// Associated view object.
    var viewObject:SFCRWModuleViewObject?
    
    /// Associated view layout.
    var viewLayout:LayoutObject?
    
    /// Parent view's frame.
    var relativeViewFrame:CGRect?
    
    /// Set this to update the content rating for the view.
    private var _contentRating:String?
    var contentRating:String? {
        set(newValue) {
            if let _rating = contentRating {
                if _rating != newValue {
                    _contentRating = newValue
                    updateTheContentRatingLabel()
                }
             } else {
                _contentRating = newValue
                updateTheContentRatingLabel()
            }
        } get {
            return _contentRating
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        fetchPageModuleList()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createModules()
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "#000000")
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        triggerAnimations()
    }
    
    /// Method to fetch Page's Module List.
    private func fetchPageModuleList() {
        
        var filePath:String!
        
        if DEBUGMODE {
            let filePath:String = (Bundle.main.resourcePath?.appending("/CRW_AppleTV.json"))!
            if FileManager.default.fileExists(atPath: filePath) {
                let jsonData:Data = FileManager.default.contents(atPath: filePath)!
                let responseJson:Array<Dictionary<String, AnyObject>>? = try! JSONSerialization.jsonObject(with:jsonData) as? Array<Dictionary<String, AnyObject>>
                let moduleParser = ModuleUIParser()
                modulesListArray = moduleParser.parseModuleConfigurationJson(modulesConfigurationArray: responseJson!) as Array<AnyObject>
            }
            
        } else {
            guard let pageID: String = Utility.getPageIdFromPagesArray(pageName: "Content Rating Warning Screen") else { return }
            filePath = AppSandboxManager.getpageFilePath(fileName: pageID)
            
            if FileManager.default.fileExists(atPath: filePath) {
                let jsonData:Data = FileManager.default.contents(atPath: filePath)!
                
                let responseStarJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, Any>
                let responseJson:Array<Dictionary<String, AnyObject>> = responseStarJson["moduleList"] as! Array<Dictionary<String, AnyObject>>
                
                let moduleUIParser = ModuleUIParser()
                modulesListArray = moduleUIParser.parseModuleConfigurationJson(modulesConfigurationArray: responseJson) as Array<AnyObject>
            }
        }
    }
    
    /// Method to create modules for the page.
    private func createModules() {
        if modulesListArray.isEmpty == false && modulesListArray[0] is SFCRWModuleViewObject {
            viewObject = modulesListArray[0] as? SFCRWModuleViewObject
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
            else if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject, type: component.key!!)
            }
            else if component is SFProgressViewObject {
                createProgressView(progressViewObject: component as! SFProgressViewObject)
            }
        }
    }
    
    private func createLabelView(labelObject:SFLabelObject, type: String) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = self.view.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.text = labelObject.text
        label.createLabelView()
        self.view.addSubview(label)
        if labelObject.key == "warningLabel" {
            warningLabel = label
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor ?? "#ffffff")
        } else if labelObject.key == "borderLabel" {
            borderLabel = label
            label.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor ?? "#ffffff").cgColor
        } else {
            if labelObject.key == "viewerDiscretion" {
                viewerDiscretionLable = label
            } else if labelObject.key == "ratingLabel" {
                ratingLabel = label
                ratingLabel?.changeFrameXAxis(xAxis: (ratingLabel?.frame.origin.x)! + 35)
            }
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff")
        }
        label.alpha = 0.0
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
        if buttonObject.key == "backButton" {
            backButton = button
        }
    }
    
    //MARK: Create Progress view
    private func createProgressView(progressViewObject:SFProgressViewObject) {
        let viewLayout = Utility.fetchProgresViewLayoutDetails(progressViewObject: progressViewObject)

        let _progressView: SFProgressView_tvOS = SFProgressView_tvOS.init(frame: CGRect.zero)
        _progressView.progressViewObject = progressViewObject
        _progressView.relativeViewFrame = self.view.frame
        _progressView.initialiseProgressViewFrameFromLayout(progressViewLayout: viewLayout)
        _progressView.backgroundColor = Utility.hexStringToUIColor(hex: progressViewObject.unprogressColor ?? "ffffff")
        _progressView.progress = 0.0
        self.view.addSubview(_progressView)
        progressView = _progressView
    }
    
    func buttonClicked(button: SFButton) {
        exit(success: false)
    }
    
    private func updateTheContentRatingLabel() {
        if let ratingLabel = ratingLabel {
            ratingLabel.text?.append(" \(contentRating ?? "")")
        } else {
            for view in view.subviews {
                if let label = view as? SFLabel {
                    if label.labelObject?.key == "ratingLabel" {
                        ratingLabel = label
                        ratingLabel?.text?.append(" \(contentRating ?? "")")
                        break
                    }
                }
            }
        }
    }
    
    private func exit(success: Bool) {
        if let progressView = progressView {
            progressView.stopAnimating()
        }
        if let completionHandler = completionHandler {
            self.dismiss(animated: true, completion: {
                completionHandler(success)
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func displayContent() {
        
    }
    
    /// Animates the view content.
    fileprivate func triggerAnimations() {
        let totalDuration = viewObject?.moduleDuration ?? 2.0
        var viewAnimationDuration = 0.0
        if let animates = viewObject?.moduleSupportsAnimation {
            if animates {
                viewAnimationDuration = min(totalDuration/2, 1.5)
            }
        }
        progressView?.animateProgressFill(duration: totalDuration, completion: { [weak self] in
            guard let checkedSelf = self else {
                return
            }
            checkedSelf.exit(success: true)
        })
        //Fade in animation.
        UIView.animate(withDuration: viewAnimationDuration, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { [weak self] in
            guard let checkedSelf = self else {
                return
            }
            checkedSelf.ratingLabel?.changeFrameXAxis(xAxis: (checkedSelf.ratingLabel?.frame.origin.x)! - 35)
            checkedSelf.ratingLabel?.alpha = 1.0
            checkedSelf.warningLabel?.alpha = 1.0
            checkedSelf.borderLabel?.alpha = 1.0
            }, completion: nil)
        //Fade in animation.
        UIView.animate(withDuration: viewAnimationDuration, delay: viewAnimationDuration/2, options: UIViewAnimationOptions.curveLinear, animations: { [weak self] in
            guard let checkedSelf = self else {
                return
            }
            checkedSelf.viewerDiscretionLable?.alpha = 1.0
            }, completion: nil)
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if (presses.first!).type == .menu {
            self.exit(success: false)
        } else if(presses.first?.type == UIPressType.playPause) {
            self.exit(success: true)
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
}
