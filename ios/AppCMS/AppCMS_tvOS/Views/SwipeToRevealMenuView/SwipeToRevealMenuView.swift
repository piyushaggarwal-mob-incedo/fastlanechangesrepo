//
//  SwipeToRevealMenuView.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 26/12/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SwipeToRevealMenuView: UIView {

    @IBOutlet weak var logoImageView: UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        checkAndHideLogo()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        checkAndHideLogo()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        checkAndHideLogo()
    }
    
    private func checkAndHideLogo() {
        if let logoImage = logoImageView {
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeEntertainment.lowercased() {
                logoImage.isHidden = true
            }
        }
    }
}
