//
//  SFRoundProgressIndicatorLayer.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/17/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import QuartzCore

class SFRoundProgressIndicatorLayer: CALayer {
    var progress: Float = 0.0
    var startAngle: Float = 0.0
    var tintColor: UIColor?
    var trackColor: UIColor?

    override class func needsDisplay(forKey key: String) -> Bool {
        if (key == "progress") {
            return true
        }
        else {
            return super.needsDisplay(forKey: key)
        }
    }
    override init() {
        super.init()
    }
    override init(layer: Any) {
        super.init(layer: layer)

        // Typically, the method is called to create the Presentation layer.
        // We must copy the parameters to look the same.
        if (layer is SFRoundProgressIndicatorLayer) {
            let otherLayer: SFRoundProgressIndicatorLayer? = layer as? SFRoundProgressIndicatorLayer
            progress = (otherLayer?.progress)!
            startAngle = (otherLayer?.startAngle)!
            tintColor = otherLayer?.tintColor
            trackColor = otherLayer?.trackColor
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        tintColor = nil
        trackColor = nil
    }

    override func draw(in context: CGContext?) {
        let radius: CGFloat = min(bounds.size.width, bounds.size.height) / 2.0
        let center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        // Background circle
        let circleRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2.0, height: radius * 2.0)
        context?.addEllipse(in: circleRect)
        context?.setFillColor((trackColor?.cgColor)!)
        context?.fillPath()
        // Elapsed arc
        context?.addArc(center: CGPoint(x: center.x, y: center.y), radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(startAngle + progress * 2.0 * .pi), clockwise: false)
        context?.addLine(to: CGPoint(x: center.x, y: center.y))
        context?.closePath()
        context?.setFillColor((tintColor?.cgColor)!)
        context?.fillPath()
    }
}
