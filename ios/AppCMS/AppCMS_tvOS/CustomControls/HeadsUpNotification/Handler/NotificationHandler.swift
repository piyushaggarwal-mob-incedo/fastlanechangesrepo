//
//  NotificationHandler.swift
//  HeadsUpNotification
//
//  Created by Anirudh Vyas on 31/07/17.
//  Copyright © 2017 Anirudh Vyas. All rights reserved.
//

import UIKit

class NotificationHandler {
    
    private var notification: NotificationView?
    
    func showNotification(view: UIView, dismissDelay: Int,_ direction: DirectionOfAnimation = .up) {
        notification = NotificationView.init(view: view)
        if direction == .down {
            notification?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: (notification?.frame.size.width)!, height: (notification?.frame.size.height)!)
        }
        notification?.backgroundColor = UIColor.clear
        notification?.addSubview(view)
        notification?.direction = direction
        notification?.fire()
        notification?.setDismisTimer(delay: 5)
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(notification!)
        UIApplication.shared.keyWindow?.rootViewController?.view.bringSubview(toFront: notification!)
    }
    
    func hideNotification() {
        if let notif = notification {
            notif.dismiss()
        }
    }

}
