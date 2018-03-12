//
//  ModuleContainerViewModel_tvOS.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 10/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

enum PageOpenAction {
    case subNavigationClickAction
    case masterNavigationClickAction
    case videoClickAction
    case showClickAction
    case displayAction
}

class ModuleContainerViewModel_tvOS: NSObject {
    
    private var notificationHandler: NotificationHandler?
    private var notificationHandlerForBottomView: NotificationHandler?
    weak var viewController: ModuleContainerViewController_tvOS?
    var pageOpenAction : PageOpenAction?
    
    override init () {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(menuBarToggled), name: Constants.kToggleMenuBarNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Constants.kToggleMenuBarNotification, object: nil)
    }
    
    func menuBarToggled() {
        hideSwipeUpToSeeMenuHeadsUpNotification()
    }
    
    func showSwipeUpToSeeMenuHeadsUpNotification (afterDelay: TimeInterval) {
        self.perform(#selector(showAlertAfterDelay), with: nil, afterDelay: afterDelay)
    }
    
    func showScrollToSeeContentNotification (afterDelay: TimeInterval) {
        self.perform(#selector(showBottomAlertAfterDelay), with: nil, afterDelay: afterDelay)
    }
    
    @objc private func showAlertAfterDelay() {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.didMenuRevealMessageShowOnce == false {
            let view = UINib(nibName: "SwipeToRevealMenuView_tvOS", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SwipeToRevealMenuView
            view.frame = CGRect(x: 0, y: -(view.bounds.size.height), width: view.bounds.size.width, height: view.bounds.size.height)
            view.layer.masksToBounds = true
            notificationHandler = NotificationHandler()
            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
                notificationHandler?.showNotification(view: view, dismissDelay: 7)
            } else {
                notificationHandler?.showNotification(view: view, dismissDelay: 5)
            }
            appDelegate.didMenuRevealMessageShowOnce = true
        }
    }
    
    @objc private func showBottomAlertAfterDelay() {
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            let bottomView = UINib(nibName: "ScrollForContentAlert_tvOS", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
            bottomView.frame = CGRect(x: 0, y: 0, width: bottomView.bounds.size.width, height: bottomView.bounds.size.height)
            bottomView.layer.masksToBounds = true
            notificationHandlerForBottomView = NotificationHandler()
            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
                notificationHandlerForBottomView?.showNotification(view: bottomView, dismissDelay: 7, .down)
            } else {
                notificationHandlerForBottomView?.showNotification(view: bottomView, dismissDelay: 5, .down)
            }
        }
    }
    
    func hideSwipeUpToSeeMenuHeadsUpNotification() {
        notificationHandler?.hideNotification()
        notificationHandlerForBottomView?.hideNotification()
    }
}
