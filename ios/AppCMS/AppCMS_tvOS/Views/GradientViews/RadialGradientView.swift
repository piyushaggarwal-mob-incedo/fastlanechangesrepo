//
//  RadialGradientView.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 21/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@IBDesignable class RadialGradientView: MasterGradientView {
    
    override func applyGradient() {
        let colors = [firstColor.cgColor, secondColor.cgColor] as CFArray
        let endRadius = sqrt(pow(frame.width/2, 2) + pow(frame.height/2, 2))
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: nil)
        let context = UIGraphicsGetCurrentContext()
        
        context?.drawRadialGradient(gradient!, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: endRadius, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
    }
    
}
