//
//  SFCarouselImageView.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 07/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFCarouselImageView: SFImageView {

    #if os(tvOS)
    open override var canBecomeFocused: Bool {
        return true
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if self.isFocused {
            self.layer.borderWidth = 2.5
            self.layer.borderColor = (UIColor.green as! CGColor)
        } else {
            self.layer.borderWidth = 0.0
            self.layer.borderColor = (UIColor.clear as! CGColor)
        }
    }
    #endif

}
