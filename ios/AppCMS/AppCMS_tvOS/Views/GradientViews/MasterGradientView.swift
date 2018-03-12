//
//  MasterGradientView.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 21/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class MasterGradientView: UIView {
    
    @IBInspectable var firstColor: UIColor = UIColor.red
    @IBInspectable var secondColor: UIColor = UIColor.green
    
    func applyGradient() {
        //Override this method.
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        applyGradient()
        self.backgroundColor = UIColor.clear
    }
}


