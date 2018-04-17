//
//  CustomSlider.swift
//  VideoPlayer
//
//  Created by Abhinav Saldi on 15/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class CustomSlider: UISlider
{
    enum SliderType
    {
        case liveVideoSlider
        case streamVideoSlider
    }
    
    var cuePoints: Array<AnyObject> = []
    var duration: TimeInterval!
    var sliderColor: String!
    var viewType: SliderType
    
    init(sliderType: SliderType, frame: CGRect) {
        self.viewType = sliderType
        super.init(frame: CGRect.zero)
        self.setThumbImage(#imageLiteral(resourceName: "NoKnob.png"), for: .normal)
        
        if sliderType == .liveVideoSlider {
            
            self.value = 1.0
        }
        else {
            
            self.value = 0.0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        var mainView: UIView = UIView.init()
        self.maximumTrackTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4322559932)
        self.minimumTrackTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff")

        switch self.viewType {
        case .liveVideoSlider:
            if (self.duration != nil) && self.duration > 0
            {
                self.setThumbImage(#imageLiteral(resourceName: "NoKnob.png"), for: .normal)
                self.isUserInteractionEnabled = false
                self.value = 1.0
            }
            break
        case .streamVideoSlider:
            if (self.duration != nil) && self.duration > 0 && self.cuePoints.count > 0 {
                for view in self.subviews {
                    if view.tag == 0 && (view.isMember(of: UIView.self)){
                        mainView = view
                    }
                }
                
                for view in self.subviews {
                    if view.tag != 0
                    {
                        view.removeFromSuperview()
                    }
                }
                
                
                let factor: Double = Double(rect.size.width)/self.duration
                
                print("-------", factor)
                
                for cuePoint in self.cuePoints {
                    let pos: CGFloat = CGFloat(cuePoint as! Double) * CGFloat(factor)
                    let view: UIView = UIView.init(frame: CGRect.init(x: pos, y: 14.2, width: 2, height: mainView.frame.size.height))
                    view.tag = 11
                    view.backgroundColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
                    self.addSubview(view)
                    self.bringSubview(toFront: view)
                    
                }
            }
            self.setThumbImage(#imageLiteral(resourceName: "Knob.png"), for: .normal)
            break
        }

    }
    
    func setCuePoints(cuePoints: Array<AnyObject>, duration: TimeInterval) -> Void {
        switch self.viewType {
        case .liveVideoSlider:
            break
        case .streamVideoSlider:
            self.cuePoints = cuePoints
            self.duration = duration
            self.setNeedsDisplay()
            break
        }
        
    }
    
    
    
    
}
