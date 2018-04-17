//
//  Animator.swift
//  HeadsUpNotification
//
//  Created by Anirudh Vyas on 31/07/17.
//  Copyright © 2017 Anirudh Vyas. All rights reserved.
//

import UIKit

class Animator: NSObject {

    class func animateViewWithDuration(view: UIView, duration: CGFloat, toHeight: CGFloat,_ direction: DirectionOfAnimation = .up) {
        
        if direction == .up {
            UIView.animate(withDuration: TimeInterval(duration), delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                #if os(iOS)
                    view.frame.origin.y = UIApplication.shared.statusBarFrame.height + (view.frame.height * 0.1)
                #else
                    view.alpha = 1.0
                    view.frame.origin.y = toHeight
                #endif
            })
        } else {
            UIView.animate(withDuration: TimeInterval(duration), delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                #if os(iOS)
                    view.frame.origin.y = UIApplication.shared.statusBarFrame.height + (view.frame.height * 0.1)
                #else
                    view.alpha = 1.0
                    view.frame.origin.y = UIScreen.main.bounds.height - view.frame.height
                #endif
            })
        }
       
    }
    
    class func dismissViewWithAnimation(_ view: UIView, _ direction: DirectionOfAnimation = .up) {
        
        if direction == .up {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                view.frame.origin.y = view.frame.origin.y
            }, completion: {
                (complete: Bool) in
                UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    view.center.y = -view.frame.height
                }, completion: { (complete) in
                    view.removeFromSuperview()
                })
            })
        } else {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                view.frame.origin.y = view.frame.origin.y
            }, completion: {
                (complete: Bool) in
                UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    view.center.y = UIScreen.main.bounds.height
                }, completion: { (complete) in
                    view.removeFromSuperview()
                })
            })
        }
    }
    
    class func animateViewInCircularMotion(view: UIView, duration: CGFloat) {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = CFTimeInterval(duration)
        rotateAnimation.repeatCount=Float.infinity
        view.layer.add(rotateAnimation, forKey: nil)
    }
    
    class func stopCircularAnimation(view: UIView) {
        view.layer.removeAllAnimations()
    }
}
