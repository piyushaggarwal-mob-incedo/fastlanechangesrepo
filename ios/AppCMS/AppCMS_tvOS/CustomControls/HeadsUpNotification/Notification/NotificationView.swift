//
//  NotificationView.swift
//  HeadsUpNotification
//
//  Created by Anirudh Vyas on 31/07/17.
//  Copyright © 2017 Anirudh Vyas. All rights reserved.
//

import UIKit

enum DirectionOfAnimation {
    case up
    case down
}

class NotificationView: UIView {
    
    var direction: DirectionOfAnimation = .up
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(view: UIView) {
        self.init(frame: view.bounds)
        self.alpha = 0.0
    }
    
    func fire() {
        Animator.animateViewWithDuration(view: self, duration: 0.6,toHeight: self.bounds.height - 2, direction)
    }
    
    func dismiss() {
        Animator.dismissViewWithAnimation(self,direction)
    }
    
    /// Dismisses the notification with a delay > 0
    func setDismisTimer(delay: Int) {
        if delay > 0 {
            Timer.scheduledTimer(timeInterval: Double(delay), target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)
        }
    }

}
