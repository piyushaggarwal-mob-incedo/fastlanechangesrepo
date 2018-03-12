//
//  BackgroundImageViewContainer.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 14/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class BackgroundImageViewContainer: UIView {

    var backgroundViewImageView = UIImageView()
    var imageOverlayView = UIView()
    private var _film: SFFilm?
    var film: SFFilm? {
        set (newFilm) {
            _film = newFilm
            setImageForbackgroundImageView()
        }
        get {
            return _film
        }
    }
    
    
    private var _show: SFShow?
    var show: SFShow? {
        set (newShow) {
            _show = newShow
            setImageForbackgroundImageViewForShow()
        }
        get {
            return _show
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createBackgroundImageContainerView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createBackgroundImageContainerView() {
        backgroundViewImageView.frame = self.bounds
        imageOverlayView.frame = self.bounds
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports.uppercased(){
            imageOverlayView.backgroundColor =  Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "191D20")
        }
        else{
            imageOverlayView.backgroundColor =  UIColor.black.withAlphaComponent(0.85) 
        }

        backgroundViewImageView.contentMode = .scaleAspectFill
        self.addSubview(backgroundViewImageView)
        self.addSubview(imageOverlayView)
    }
    
    func setImageForbackgroundImageView() {
        if backgroundViewImageView.image == nil {
            var imagePathString: String?
            for image in (_film?.images)! {
                let imageObj: SFImage = image as! SFImage
                if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO
                {
                    imagePathString = imageObj.imageSource
                    break
                }
            }
            if imagePathString != nil
            {
                imagePathString = imagePathString?.appending("?impolicy=resize&w=\(backgroundViewImageView.frame.size.width)&h=\(backgroundViewImageView.frame.size.height)")
                imagePathString = imagePathString?.trimmingCharacters(in: .whitespaces)
                
                backgroundViewImageView.af_setImage(
                    withURL: URL(string:imagePathString!)!,
                    placeholderImage: nil,
                    filter: nil,
                    imageTransition: .crossDissolve(0.2)
                )
            }
        }
    }
    
    func setImageForbackgroundImageViewForShow() {
        if backgroundViewImageView.image == nil {
            guard var imagePathString: String = _show?.thumbnailImageURL else{
                return
            }

            imagePathString = imagePathString.appending("?impolicy=resize&w=\(backgroundViewImageView.frame.size.width)&h=\(backgroundViewImageView.frame.size.height)")
            imagePathString = imagePathString.trimmingCharacters(in: .whitespaces)
                
                backgroundViewImageView.af_setImage(
                    withURL: URL(string:imagePathString)!,
                    placeholderImage: nil,
                    filter: nil,
                    imageTransition: .crossDissolve(0.2)
                )
        }
    }
    
    func showHideImageView(shouldShow: Bool) {
        backgroundViewImageView.isHidden = !shouldShow
        imageOverlayView.isHidden = !shouldShow
    }
}
