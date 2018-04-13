//
//  SFTimerLoaderView.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 05/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFTimerLoaderView: UIView {

    /// Completion handler for countdown timer.
    var countdownCompletionHandler : (() -> Void)?
    
    /// Timer instance. Used to time the auto play countdown.
    var countdownTimer: Timer?
    
    /// Associated view object.
    private var _viewObject: SFTimerLoaderViewObject?
    var viewObject: SFTimerLoaderViewObject? {
        set(newValue) {
            _viewObject = newValue
            constructLoaderView()
        } get {
            return _viewObject
        }
    }
    
    /// Associated view layout.
    var viewLayout:LayoutObject?
    
    /// Parent View layout.
    var relativeViewFrame:CGRect?
    
    /// Holds the timer's current value.
    private var currentTimerValue: Int?
    
    /// Lazily initializing the value of loaderImageView.
    private(set) lazy var loaderImage: UIImageView = {
        let image = UIImageView(frame: self.bounds)
        return image
    }()
    
    /// Lazily initializing the value of loader countdown label.
    private(set) lazy var loadTimeLabel: UILabel = {
        let label = UILabel(frame: self.bounds)
        return label
    }()
    
    func initialiseViewFromLayout(viewLayout:LayoutObject) {
        self.viewLayout = viewLayout
        self.frame = Utility.initialiseViewLayout(viewLayout: viewLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    /// Master constructor method.
    private func constructLoaderView() {
        self.addSubview(loaderImage)
        loaderImage.image = UIImage(named: "LoaderImage")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        if let backgroundColor = AppConfiguration.sharedAppConfiguration.appTextColor {
            loaderImage.tintColor = Utility.hexStringToUIColor(hex: backgroundColor)
        }
        
        self.addSubview(loadTimeLabel)
        loadTimeLabel.alpha = 0.5
        loadTimeLabel.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff")
        
        if let timerTextAlignment = viewObject?.textAlignment {
            loadTimeLabel.textAlignment = Utility.getTextAlignment(textAlignmentString: timerTextAlignment)
        }
        
        var fontFamily:String = "OpenSans" //Providing default value.
        var fontSize:Float = 26.0 //Providing default value.
        
        if let timerFontFamily = viewObject?.fontFamily {
            fontFamily = timerFontFamily
        }
        
        if let timerFontWeight = viewObject?.fontWeight {
            fontFamily = "\(fontFamily)-\(timerFontWeight)"
        }
        
        if let timerFontSize = viewObject?.fontSize {
            fontSize = timerFontSize
        }
        //Set Font
        loadTimeLabel.font = UIFont(name: fontFamily, size: CGFloat(fontSize))
        
        if let timerAlpha = viewObject?.alpha {
            loadTimeLabel.alpha = CGFloat(timerAlpha)
        }
        
        if let timerDuration = viewObject?.loaderTimeDuration {
            loadTimeLabel.text = "\(timerDuration)"
            currentTimerValue = timerDuration
            startCountDown()
        }
    }
    
    /// Call this method to start the countdown and animation.
    func startCountDown() {
        startAnimation()
        startTimerForCountdown()
    }
    
    /// Starting the animation.
    private func startAnimation() {
        Animator.animateViewInCircularMotion(view: loaderImage, duration: 1.0)
    }
    
    /// Call this method to stop countdown.
    func stopCountdownTimer() {
        countdownTimer?.invalidate()
        Animator.stopCircularAnimation(view: loadTimeLabel)
        loadTimeLabel.removeFromSuperview()
        loaderImage.removeFromSuperview()
    }
    
    /// Call this method to the start timer of countdown.
    private func startTimerForCountdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector (self.updateTimerValue), userInfo: nil, repeats: true)
    }
    
    /// Scheduled method for countdownTimer.
    @objc private func updateTimerValue() {
        
        if currentTimerValue! <= 1 {
            stopCountdownTimer()
            if let countdownCompletion = countdownCompletionHandler {
                countdownCompletion()
            }
        } else {
            currentTimerValue! -= 1
            loadTimeLabel.text = "\(currentTimerValue!)"
        }
    }

}

