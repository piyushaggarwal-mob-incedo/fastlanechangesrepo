//
//  SFRoundProgressIndicator.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/17/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFRoundProgressIndicator: UIView {
    var progress: Float {
        let layer: SFRoundProgressIndicatorLayer? = (self.layer as? SFRoundProgressIndicatorLayer)
        return (layer?.progress ?? 0)
    }

    var startAngle: Float {
        let layer: SFRoundProgressIndicatorLayer? = (self.layer as? SFRoundProgressIndicatorLayer)
        return (layer?.startAngle)!
    }

    var tintsColor : UIColor {
        let layer: SFRoundProgressIndicatorLayer? = (self.layer as? SFRoundProgressIndicatorLayer)
        return (layer?.tintColor!)!
    }
    var trackColor : UIColor{
        let layer: SFRoundProgressIndicatorLayer? = (self.layer as? SFRoundProgressIndicatorLayer)
        return (layer?.trackColor!)!
    }

    var animationDuration = CFTimeInterval()
    let CERoundProgressLayerDefaultAnimationDuration: TimeInterval = 0.25
    private func _initIVars() {
        animationDuration = CERoundProgressLayerDefaultAnimationDuration
        backgroundColor = UIColor.clear
        isOpaque = false
        self.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        self.setTrackColor(UIColor.black)
        // On Retina displays, the layer must have its resolution doubled so it does not look blocky.
        layer.contentsScale = UIScreen.main.scale
    }


    override class var layerClass: AnyClass {
        return SFRoundProgressIndicatorLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _initIVars()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        _initIVars()

    }
    func setProgress(_ progress: Float) {
        let growing: Bool = progress > self.progress
        setProgress(progress, animated: growing)
    }

    func setProgress(_ progress: Float, animated: Bool) {
        var progresses = progress
        // Coerce the value
        if progress < 0.0 {
            progresses = 0.0
        }
        else if progress > 1.0 {
            progresses = 1.0
        }

        // Apply to the layer
        let layer: SFRoundProgressIndicatorLayer? = (self.layer as? SFRoundProgressIndicatorLayer)
        if animated {
            let animation = CABasicAnimation(keyPath: "progress")
            animation.duration = animationDuration
            animation.fromValue = Float((layer?.progress) ?? 0)
            animation.toValue = Float(progresses)
            layer?.add((animation as CAAnimation), forKey: "progressAnimation")
            layer?.progress = progresses
        }
        else {
            layer?.progress = progresses
            layer?.setNeedsDisplay()
        }

    }
    override func tintColorDidChange(){
        let layer: SFRoundProgressIndicatorLayer? = (self.layer as? SFRoundProgressIndicatorLayer)
        layer?.tintColor = tintColor
        layer?.setNeedsDisplay()
    }

    func setTrackColor(_ trackColor: UIColor) {
        let layer: SFRoundProgressIndicatorLayer? = (self.layer as? SFRoundProgressIndicatorLayer)
        layer?.trackColor = trackColor
        layer?.setNeedsDisplay()
    }

     func setStartAngle(_ startAngle: Float) {
        let layer: SFRoundProgressIndicatorLayer? = (self.layer as? SFRoundProgressIndicatorLayer)
        layer?.startAngle = startAngle
        layer?.setNeedsDisplay()
    }
}
