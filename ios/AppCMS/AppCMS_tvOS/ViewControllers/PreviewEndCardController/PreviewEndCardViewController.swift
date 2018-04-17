//
//  PreviewEndCardViewController.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 12/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class PreviewEndCardViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView?
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var loginButton: UIButton?
    @IBOutlet weak var startFreeTrialButton: UIButton?
    @IBOutlet weak var previewEndText: UILabel?
    @IBOutlet weak var topMarginLoginButton: NSLayoutConstraint?
    @IBOutlet weak var topMarginStartFreeTrialButton: NSLayoutConstraint?
    
    private var backgroundFocusGuide: UIFocusGuide?
    
    private var buttonCollection: Array<UIButton?>?
    /// Holds the instance of the last focused item.
    private var lastFocusedView: Any?
    
    var completionHandler: ((_ shouldContinuePlaying: Bool) -> Void)?
    
    private var _film: SFFilm?
    var film: SFFilm? {
        set(newValue) {
            _film = newValue
        }
        get {
            return _film
        }
    }
    
    private var _imageUrl: URL?
    var imageUrl: URL? {
        set(newValue) {
            _imageUrl = newValue
            updateBackgroundImage()
        }
        get {
            return _imageUrl
        }
    }
    
    private var _supportsBackButton: Bool = true
    var supportsBackButton: Bool {
        set(newValue) {
            _supportsBackButton = newValue
            cancelButton?.isHidden = !_supportsBackButton
        }
        get {
            return _supportsBackButton
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) != nil && Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey)! as! Bool) == true {
            dismiss(true)
        }
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment {
            previewEndText?.text = "To continue watching, and access so much more, log in or subscribe now!"
            startFreeTrialButton?.titleLabel?.text = "SUBSCRIBE NOW"
        } else {
            previewEndText?.text = AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.overlayMessage ?? "Want more access to your DC sports teams? Become a member now so you don’t miss another play!"
            startFreeTrialButton?.titleLabel?.text = AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.subscriptionButtonText ?? "START FREE TRIAL"
            loginButton?.titleLabel?.text = AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.loginButtonText ?? "LOG IN"
        }
        
        if _supportsBackButton == false {
            if backgroundFocusGuide == nil {
                backgroundFocusGuide = UIFocusGuide()
                self.view.addLayoutGuide(backgroundFocusGuide!)
                backgroundFocusGuide?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                backgroundFocusGuide?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                backgroundFocusGuide?.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
                backgroundFocusGuide?.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            }
        }
        updateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if lastFocusedView != nil {
            DispatchQueue.main.async {
                if self.supportsBackButton == true {
                    self.setNeedsFocusUpdate()
                    self.updateFocusIfNeeded()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        lastFocusedView = UIScreen.main.focusedView
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender == cancelButton {
            dismiss(false)
        } else if sender == loginButton {
            showLoginPage()
        } else if sender == startFreeTrialButton {
            showPlansPage()
        }
    }
    
    private func updateBackgroundImage() {
        if let _backgroundImageView = backgroundImageView {
            if let imageUrl = imageUrl {
                _backgroundImageView.af_setImage(
                    withURL: imageUrl,
                    placeholderImage: UIImage(named: Constants.kVideoImagePlaceholder),
                    filter: nil,
                    imageTransition: .crossDissolve(0.2),
                    completion: { response in
                        
                })
            }
        }
    }

    private func updateView() {
        
        updateViewConstraintsForUserStatus() 
        //Setting Up buttons view.
        buttonCollection = [cancelButton,loginButton,startFreeTrialButton]
        cancelButton?.isHidden = !_supportsBackButton
        for button in buttonCollection! {
            button?.layer.borderWidth = 4
            button?.alpha = TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports ? 1.0 : 0.5
            //Setting Text color
            if let textColor = AppConfiguration.sharedAppConfiguration.primaryButton.textColor {
                button?.titleLabel?.textColor = Utility.hexStringToUIColor(hex: textColor)
            } else {
                button?.titleLabel?.textColor = Utility.hexStringToUIColor(hex: "ffffff")
            }
            //Setting border color.
            if let borderColor = AppConfiguration.sharedAppConfiguration.primaryButton.borderUnselectedColor {
                button?.layer.borderColor = Utility.hexStringToUIColor(hex: borderColor).cgColor
            } else {
                button?.layer.borderColor = Utility.hexStringToUIColor(hex: "ffffff").cgColor
            }
        }
        if imageUrl == nil {
            if let _backgroundImageView = backgroundImageView {
                var imagePathString: String?
                if let filmImages = _film?.images {
                    for image in filmImages {
                        let imageObj: SFImage = image as! SFImage
                        let imageType = Constants.kSTRING_IMAGETYPE_WIDGET
                        if imageObj.imageType == imageType {
                            imagePathString = imageObj.imageSource
                            break
                        }
                    }
                }
                if imagePathString == nil {
                    if let filmImages = _film?.images {
                        for image in filmImages {
                            let imageObj: SFImage = image as! SFImage
                            let imageType = Constants.kSTRING_IMAGETYPE_VIDEO
                            if imageObj.imageType == imageType {
                                imagePathString = imageObj.imageSource
                                break
                            }
                        }
                    }
                }
                if imagePathString != nil
                {
                    imagePathString = imagePathString?.appending("?impolicy=resize&w=\(_backgroundImageView.frame.size.width)&h=\(_backgroundImageView.frame.size.height)")
                    imagePathString = imagePathString?.trimmingCharacters(in: .whitespaces)
                    
                    _backgroundImageView.af_setImage(
                        withURL: URL(string:imagePathString!)!,
                        placeholderImage: UIImage(named: Constants.kVideoImagePlaceholder),
                        filter: nil,
                        imageTransition: .crossDissolve(0.2),
                        completion: { response in
                            
                    })
                }
                else {
                    _backgroundImageView.image = UIImage(named: Constants.kVideoImagePlaceholder)
                }
            }
        } else {
            updateBackgroundImage()
        }
    }
    
    private func updateViewConstraintsForUserStatus() {
        if Utility.sharedUtility.checkIfUserIsLoggedIn() {
            backgroundFocusGuide?.preferredFocusedView = startFreeTrialButton
            loginButton?.tag = 404
            startFreeTrialButton?.tag = 9876
            loginButton?.isHidden = true
            loginButton?.isEnabled = false
            topMarginStartFreeTrialButton?.constant = (topMarginLoginButton?.constant)!
            view.setNeedsLayout()
        } else {
            backgroundFocusGuide?.preferredFocusedView = loginButton
            loginButton?.tag = 9876
            startFreeTrialButton?.tag = 404
            topMarginStartFreeTrialButton?.constant = 678
            loginButton?.isHidden = false
            loginButton?.isEnabled = true
            view.setNeedsLayout()
        }
    }
    
    private func dismiss(_ shouldPlay: Bool) {
        if let _completionHandler = completionHandler {
            _completionHandler(shouldPlay)
        }
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
    }
    
    private func showLoginPage() {
        Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView(contentToLoad: .loadLoginPage,{  () in

        }, shouldJustDismiss: true)
    }
    
    private func showPlansPage() {
        Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView(contentToLoad: .loadPlansPage, { () in

        }, shouldJustDismiss: true)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let focusedButton = context.nextFocusedView as? UIButton {
            if buttonBelongsToThisViewController(focusedButton) {
                if let backGroundColor = AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor {
                    focusedButton.backgroundColor = Utility.hexStringToUIColor(hex: backGroundColor)
                }
                if let borderColor = AppConfiguration.sharedAppConfiguration.primaryButton.borderSelectedColor {
                    focusedButton.layer.borderColor = Utility.hexStringToUIColor(hex: borderColor).cgColor
                }
                focusedButton.alpha = TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports ? 1.0 : 0.5
            }
        }
        if let previousFocusedButton = context.previouslyFocusedView as? UIButton {
            if buttonBelongsToThisViewController(previousFocusedButton) {
                previousFocusedButton.backgroundColor = UIColor.clear
                previousFocusedButton.alpha = TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports ? 1.0 : 0.5
                if let borderColor = AppConfiguration.sharedAppConfiguration.primaryButton.borderUnselectedColor {
                    previousFocusedButton.layer.borderColor = Utility.hexStringToUIColor(hex: borderColor).cgColor
                } else {
                    previousFocusedButton.layer.borderColor = Utility.hexStringToUIColor(hex: "ffffff").cgColor
                }
            }
        }
    }
    
    private func buttonBelongsToThisViewController(_ focusedbutton: UIButton) -> Bool {
        var doesItBelong = false
        for button: UIButton? in buttonCollection! {
            if button == focusedbutton {
                doesItBelong = true
                break
            }
        }
        return doesItBelong
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if lastFocusedView != nil {
            let lastFocusedViewLocalCopy = lastFocusedView as? UIView
            lastFocusedView = nil
            return [lastFocusedViewLocalCopy!]
        }
        return super.preferredFocusEnvironments
    }
}
