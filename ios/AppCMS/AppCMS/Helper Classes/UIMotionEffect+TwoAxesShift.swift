//
//  UIMotionEffect+TwoAxesShift.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 11/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

extension UIMotionEffect {
    class func twoAxesShift(strength: Float) -> UIMotionEffect {
        // internal method that creates motion effect
        func motion(type: UIInterpolatingMotionEffectType) -> UIInterpolatingMotionEffect {
            let keyPath = type == .tiltAlongHorizontalAxis ? "center.x" : "center.y"
            let motion = UIInterpolatingMotionEffect(keyPath: keyPath, type: type)
            motion.minimumRelativeValue = -strength
            motion.maximumRelativeValue = strength
            return motion
        }
        
        // group of motion effects
        let group = UIMotionEffectGroup()
        group.motionEffects = [
            motion(type: .tiltAlongHorizontalAxis),
            motion(type: .tiltAlongVerticalAxis)
        ]
        return group
    }
}
