//
//  UIView+FrameHelper.swift
//  SwiftPOC
//
//  Created by Gaurav Vig on 08/03/17.
//  Copyright © 2017 Gaurav Vig. All rights reserved.
//

import Foundation
import UIKit
extension UIView {
    
    func changeFrameWidth(width: CGFloat) -> Void {
        
        var frame: CGRect = self.frame
        frame.size.width = width
        self.frame = frame
    }
    
    func changeFrameHeight(height: CGFloat) -> Void {
        
        var frame: CGRect = self.frame
        frame.size.height = height
        self.frame = frame
    }

    func changeFrameXAxis(xAxis: CGFloat) -> Void {
        
        var frame: CGRect = self.frame
        frame.origin.x = xAxis
        self.frame = frame
    }
    
    func changeFrameYAxis(yAxis: CGFloat) -> Void {
        
        var frame: CGRect = self.frame
        frame.origin.y = yAxis
        self.frame = frame
    }
    
    func frameStartPointX(frame: CGRect) -> CGFloat {
        let startX: CGFloat = frame.origin.x
        return startX
    }
    
    func frameStartPointY(frame: CGRect) -> CGFloat {
        let startY: CGFloat = frame.origin.y
        return startY
    }
}
