//
//  SFPopOverController.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 12/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

let BUTTON_WIDTH = 255
let BUTTON_PADDING_FROM_CENTER = 20

/// Style associated to #SFPopOverController.
///
/// - popOverSheet: Use this to set PopOver style Controller.
/// - alert: Use this to set Alert style Controller.
public enum SFPopOverControllerStyle : Int {
    
    case popOverSheet
    case alert
    case alertWithBackground
}


/// Action associated to a SFPopOverController controller.
class SFPopOverAction : NSObject {
    
    var title: String?
    var handler: ((SFPopOverAction) -> Void)?

    init(title: String?, handler: ((_ action: SFPopOverAction) -> Void)?) {
        super.init()
        self.handler = handler
        self.title = title
    }
}

class SFPopOverController: UIViewController {

    var viewFixedWidth = 1210
    var viewFixedHeight = 572
    var baseView = UIView()
    var backgroundOverlayView: UIView?
    var messageTextView = UITextView()
    var parentView : UIView?
    var titleLabel = UILabel()

    /// Pop over actions.
    var actions : Array<SFPopOverAction>?
    var message : String?
    var popOverTitle: String?

    var preferredStyle : SFPopOverControllerStyle?
    
    public init(title: String?, message: String?, preferredStyle: SFPopOverControllerStyle) {
        super.init(nibName: nil, bundle: nil)
        self.popOverTitle = title
        self.message = message
        self.preferredStyle = preferredStyle
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.construct()
    }

    private func construct() {
        
        switch self.preferredStyle! {
        case .alertWithBackground:
            backgroundOverlayView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
            backgroundOverlayView?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff").withAlphaComponent(0.45)
            view.addSubview(backgroundOverlayView!)
            fallthrough
        case .alert:
            viewFixedWidth = 875
            viewFixedHeight = 350
            break
        case .popOverSheet:
            viewFixedWidth = 1210
            viewFixedHeight = 572
            break
        }
        //Constructing base view.
        baseView.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff").withAlphaComponent(0.95)
        baseView.frame = CGRect(x: 0, y: 0, width: viewFixedWidth, height: viewFixedHeight)
        view.addSubview(baseView)
        //Constructing buttons.
        if popOverTitle != nil && popOverTitle != "" {
            constructTitleView()
        }
        if message != nil && message != "" {
            constructMessageView()
            checkIfTextLengthIsMoreThanTheAreaAvailable()
        }
        updateBaseViewHeight()
        constructButtonView()
    }
    
    private func updateBaseViewHeight() {
        let numberOfLinesOfTitleLabel = titleLabel.numberOfVisibleLines
        if numberOfLinesOfTitleLabel > 1 && (self.preferredStyle! == .alert || self.preferredStyle! == .alertWithBackground) {
            baseView.changeFrameHeight(height: baseView.bounds.size.height + CGFloat(numberOfLinesOfTitleLabel * 61))
        }
        baseView.center = self.view.center
    }
    
    private func constructTitleView() {
        titleLabel.frame = CGRect(x: 30, y: 51, width: baseView.bounds.size.width - 60, height: 126)
        var fontFamily:String?
        if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
            fontFamily = _fontFamily
        }
        if fontFamily == nil {
            fontFamily = "OpenSans"
        }
        titleLabel.font = UIFont(name: fontFamily!, size: 45)
        titleLabel.numberOfLines = 0
        titleLabel.text = popOverTitle
        titleLabel.addTextSpacing(spacing: 6)
        titleLabel.changeFrameHeight(height: CGFloat(63 * titleLabel.numberOfVisibleLines))
        titleLabel.textAlignment = .center
        titleLabel.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff")
        baseView.addSubview(titleLabel)
    }
    
    
    private func constructMessageView() {
        if self.preferredStyle! == .alert || self.preferredStyle! == .alertWithBackground {
            messageTextView.frame = CGRect(x: 83, y: 95, width: baseView.bounds.size.width - 166, height: 300)
            messageTextView.textAlignment = .center
        } else {
            messageTextView.frame = CGRect(x: 83, y: 80, width: 1039, height: 300)
        }
        var fontFamily:String?
        if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
            fontFamily = _fontFamily
        }
        if fontFamily == nil {
            fontFamily = "OpenSans"
        }
        messageTextView.font = UIFont(name: fontFamily!, size: 23)
        messageTextView.panGestureRecognizer.allowedTouchTypes = [UITouchType.indirect.rawValue as NSNumber,UITouchType.direct.rawValue as NSNumber]
        messageTextView.text = self.message?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        messageTextView.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff")
        messageTextView.bounces = true
        baseView.addSubview(messageTextView)
    }
    
    private func constructButtonView() {
        
        var ii = 0
        while ii < (actions?.count)! {
            
            let buttonObject = SFPopOverButtonObject()
            let button = SFPopOverButton()
            buttonObject.textColor = AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff"
            var fontFamily:String?
            if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
                fontFamily = _fontFamily
            }
            if fontFamily == nil {
                fontFamily = "OpenSans"
            }
            buttonObject.fontFamily = fontFamily!
            buttonObject.textFontSize = 18
            buttonObject.borderWidth = 4
            buttonObject.borderColor = AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff"
            buttonObject.popOverAction = actions?[ii]
            button.popOverButtonObject = buttonObject
            button.tag = ii
            button.createButtonView()
            if actions?.count == 1 {
                button.frame = CGRect(x: (baseView.bounds.size.width - 255)/2, y: baseView.bounds.size.height - 120, width: 255, height: 60)
            } else {
                button.frame = CGRect(x: 164 + (ii * 295), y: Int(baseView.bounds.size.height - 120), width: 255, height: 60)
            }
            button.addTarget(self, action: #selector(self.popOverButtonClicked(sender:)), for: .primaryActionTriggered)
            baseView.addSubview(button)
            ii = ii + 1
        }
    }
    
    private func checkIfTextLengthIsMoreThanTheAreaAvailable() {
        let lengthForVisibleString: Int = messageTextView.visibleTextLength()
        if lengthForVisibleString >= messageTextView.text.characters.count {
            messageTextView.isUserInteractionEnabled = false
        } else {
            messageTextView.showsVerticalScrollIndicator = true
            messageTextView.flashScrollIndicators()
            messageTextView.isUserInteractionEnabled = true
        }
    }
    
    func blurTheParentView(view: UIView?) {
        parentView = view
        if view != nil {
            view?.blur(blurRadius: 2)
        }
    }
    
    private func unBlurTheParentViewController() {
        if parentView != nil {
            parentView?.unBlur()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unBlurTheParentViewController()
        super.viewWillDisappear(animated)
    }
    
    func popOverButtonClicked(sender: SFPopOverButton) -> Void {
        guard let action = sender.popOverButtonObject?.popOverAction else {
            return
        }
        action.handler!(action)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Do Not Remove!
    //    override var preferredFocusedView: UIView? {
    //
    //        if shouldUpdateFocus == true {
    //            if let buttonToBeFocused = self.view.viewWithTag(0) {
    //                shouldUpdateFocus = false
    //                return buttonToBeFocused
    //            } else {
    //                return nil
    //            }
    //        } else {
    //            return nil
    //        }
    //    }

}
