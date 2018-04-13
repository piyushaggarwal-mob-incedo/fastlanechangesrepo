//
//  ToggleView_tvOS.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 07/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFSwitchView_tvOS: UIView {
    
    //MARK: Outlets.
    @IBOutlet private weak var overlayImageView: UIImageView?
    @IBOutlet private weak var onLabel: UILabel?
    @IBOutlet private weak var offLabel: UILabel?
    @IBOutlet private weak var toggleImageView: UIImageView?
    
    //Properties.
    
    /// Value updated Handler.
    var valueUpdatedHandler : ((Bool,SFSwitchViewObject) -> Void)?

    /// State of the switch view. Setting this calls update view.
    private var _enabled: Bool = false
    var enabled: Bool {
        set(newValue) {
            _enabled = newValue
            updateView()
        } get {
            return _enabled
        }
    }
    
    /// Associated view object. Setting this calls the createView method.
    private var _viewObject: SFSwitchViewObject?
    var viewObject: SFSwitchViewObject? {
        set(newValue) {
            _viewObject = newValue
            createView()
        } get {
            return _viewObject
        }
    }
    
    /// Associated view layout.
    var viewLayout:LayoutObject?
    
    /// Parent View layout.
    var relativeViewFrame:CGRect?
    
    /// Class Method. Returns instance loaded from nib.
    ///
    /// - Returns: Instance of SFSwitchView_tvOS
    class func getloadedViewFromNib() -> SFSwitchView_tvOS {
        return Bundle.main.loadNibNamed("SFSwitchView_tvOS", owner: self, options: nil)![0] as! SFSwitchView_tvOS
    }
    
    func initialiseViewFromLayout(viewLayout:LayoutObject) {
        self.viewLayout = viewLayout
        self.frame = Utility.initialiseViewLayout(viewLayout: viewLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    /// Creates the view initlially.
    private func createView() {
        overlayImageView?.image = UIImage(named: "toggleOverlay")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        if let textColor = AppConfiguration.sharedAppConfiguration.primaryHoverColor {
            overlayImageView?.tintColor = Utility.hexStringToUIColor(hex: textColor)
        }
        onLabel?.addTextSpacing(spacing: _viewObject?.letterSpacing ?? 0.0)
        offLabel?.addTextSpacing(spacing: _viewObject?.letterSpacing ?? 0.0)
        onLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff")
        offLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff")
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(toggleButtonTapped))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    /// Called when state of the switch is set.
    private func updateView() {
        onLabel?.alpha = _enabled ? 1.0 : 0.5
        offLabel?.alpha = _enabled ? 0.5 : 1.0
        toggleImageView?.image = _enabled ? UIImage(named: "toggleON") : UIImage(named: "toggleOFF")
    }

    /// Action for tap gesture.
    func toggleButtonTapped() {
        _enabled = !_enabled
        updateView()
        if let _valueUpdatedHandler = valueUpdatedHandler {
            if let viewObject = _viewObject {
                _valueUpdatedHandler(_enabled,viewObject)
            }
        }
    }
    
    /// Overridden property to enable focus of this view.
    override var canBecomeFocused: Bool {
        return true
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if self.isFocused {
            overlayImageView?.isHidden = false
        } else {
            overlayImageView?.isHidden = true
        }
        
    }
}
