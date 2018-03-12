//
//  VerticalGradientView.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 21/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@IBDesignable class VerticalGradientView: MasterGradientView {
    
    override func applyGradient() {
        let colors = [firstColor.cgColor, secondColor.cgColor]
        
        let layer = CAGradientLayer()
        layer.colors = colors
        layer.frame = self.bounds
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        self.layer.addSublayer(layer)
    }
}

