//
//  UIActivityIndicator+Window.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 28/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension UIActivityIndicatorView {
    
    /// Adds the activity indicator view to window.
    func showIndicatorOnWindow() {
        self.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        let window = UIApplication.shared.keyWindow!

        var alreadyShowing = false
        for view in window.subviews {
            if view is UIActivityIndicatorView {
                alreadyShowing = true
                view.removeFromSuperview()
            }
        }
        if alreadyShowing == false {
            window.addSubview(self)
        }
        self.startAnimating()
    }
}
