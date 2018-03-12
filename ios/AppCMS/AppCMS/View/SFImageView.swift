//
//  SFImageView.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 17/03/17.
//
//

import UIKit

///  Use this to get the type of image view.
///
/// - landscape: If the view is landscapic.
/// - portrait: If the view is portrait.
/// - square: If the view is a square.
enum SFImageViewType {
    case landscape
    case portrait
    case square
}

class SFImageView: UIImageView {

    var imageViewObject:SFImageObject?
    var relativeViewFrame:CGRect?
    private var _imageType: SFImageViewType?
    var imageType: SFImageViewType? {
        get {
            if self.bounds.width > self.bounds.height {
                _imageType = .landscape
            }
            if self.bounds.width == self.bounds.height {
                _imageType = .square
            }
            return _imageType
        }
    }
    
    func initialiseImageViewFrameFromLayout(imageLayout:LayoutObject) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: imageLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    func updateView() -> Void {
        
        if imageViewObject?.action == "backgroundImage" {
            
            self.contentMode = .scaleAspectFill
            
        }
        else {
            
            self.contentMode = .scaleAspectFit
        }
        
        if imageViewObject?.imageName != nil {
            
            self.image = UIImage(named: (imageViewObject?.imageName)!)
        }
        
        #if os(tvOS)
            if imageViewObject?.alpha != nil {
                self.alpha = CGFloat((imageViewObject?.alpha)!)
            }
            
            if imageViewObject?.backgroundColor != nil {
                self.backgroundColor = Utility.hexStringToUIColor(hex: (imageViewObject?.backgroundColor)!)
            }
        #endif
        
    }
    
    #if os(tvOS)
    override var canBecomeFocused: Bool {
        return true
    }
    
    func udpdateBorderColorAndWidth(_ color: UIColor, _ width: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func autoHideImage() {
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let _ = superview {
            if let autoHide = imageViewObject?.autoHide {
                if autoHide {
                    let duration: Float = imageViewObject?.autoHideDuration ?? 3
                    Timer.scheduledTimer(timeInterval: Double(duration), target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    @objc private func dismiss() {
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 0.0
        }) { (completed) in
            self.removeFromSuperview()
        }
    }
    
    #endif
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
