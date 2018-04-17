//
//  SFProgressView_tvOS.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 15/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFProgressView_tvOS: UIView {
    
    var progressViewObject:SFProgressViewObject?
    var relativeViewFrame:CGRect?
    
    /// Animated flag. Set to show animation for progress.
    var animated: Bool = false
    
    private var _progress: CGFloat?
    var progress: CGFloat? {
        get {
            return _progress
        }
        set(progress) {
            _progress = progress
            self.setNeedsLayout()
        }
    }
    
    var totalAnimationDuration: TimeInterval = 2.0
    var time : Float = 0.0
    var timer: Timer?
    private var completionHandler: (() -> Void)?
    
    /// lazily loading the progress bar view.
    private(set) lazy var progressBar: UIView = {
        let view = UIView()
        return view
    }()
    
    func initialiseProgressViewFrameFromLayout(progressViewLayout:LayoutObject) {
        
        let progressViewFrame = Utility.initialiseViewLayout(viewLayout: progressViewLayout, relativeViewFrame: relativeViewFrame!)
        self.frame = progressViewFrame
        updateViewColors()
    }
    
    private func updateViewColors() {
        self.backgroundColor = Utility.hexStringToUIColor(hex: progressViewObject?.unprogressColor ?? "ffffff").withAlphaComponent(0.59)
        self.progressBar.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "ffffff")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(progressBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        if _progress != nil {
            var frame: CGRect = self.bounds
            self.progressBar.frame = frame
            self.progressBar.changeFrameWidth(width: 0)
            _progress = min(_progress!, 1.0)
            frame.size.width *= _progress!
            if animated {
                UIView.animate(withDuration: 0.5, animations: {
                    self.progressBar.changeFrameWidth(width: frame.size.width)
                })
            } else {
                self.progressBar.changeFrameWidth(width: frame.size.width)
            }
        }
    }
    
    func stopAnimating() {
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    func animateProgressFill(duration: TimeInterval, completion: @escaping (() -> Void)) {
        completionHandler = completion
        totalAnimationDuration = duration
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector:#selector(SFProgressView_tvOS.setProgress), userInfo: nil, repeats: true)
    }
    
    @objc private func setProgress() {
        time += 0.001
        progress = CGFloat((time / Float(totalAnimationDuration)))
        if time >= Float(totalAnimationDuration) || progress! >= CGFloat(1.0) {
            timer!.invalidate()
            timer = nil
            if let handler = completionHandler {
                handler()
            }
        }
    }
}
