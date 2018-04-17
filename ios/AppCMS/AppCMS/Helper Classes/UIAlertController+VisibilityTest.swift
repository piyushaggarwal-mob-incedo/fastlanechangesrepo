//
//  UIAlertController+VisibilityTest.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 16/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension UIViewController {

    func isShowing() -> Bool {
        var _isShowing = false
        if self.isViewLoaded && (self.view.window != nil) {
            _isShowing = true
        }
        return _isShowing
    }
}
