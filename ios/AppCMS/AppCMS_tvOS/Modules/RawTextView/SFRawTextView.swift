//
//  SFRawTextView.swift
//  AppCMS
//
//  Created by Rajni Pathak on 19/12/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
class SFRawTextView: UIView {
    
    
    var relativeViewFrame:CGRect?
    var modulesArray:Array<AnyObject> = []
    private  var acitivityIndicator : UIActivityIndicatorView?
    
    
    init(frame: CGRect, rawTextObject: SFRawTextViewObject, pageModuleObject: SFModuleObject) {
        super.init(frame: frame)
        //        super.init(nibName: nil, bundle: nil)
        self.relativeViewFrame = frame
        let loginLayout = Utility.fetchRawTextViewLayoutDetails(RawTextViewObject: rawTextObject)
        self.frame = Utility.initialiseViewLayout(viewLayout: loginLayout, relativeViewFrame: relativeViewFrame!)
        self.modulesArray = rawTextObject.components
        createView(containerView: self, itemIndex: 0, pageModuleObject: pageModuleObject)
        addTemporaryFocusButton()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Creation of View Components
    func createView(containerView: UIView, itemIndex:Int, pageModuleObject: SFModuleObject) {
        for component:AnyObject in self.modulesArray {
            if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject, pageModuleObject: pageModuleObject)
            }
            else if component is SFImageObject {
                
                createImageView(imageObject: component as! SFImageObject, containerView: self, pageModuleObject: pageModuleObject)
            }
        }
    }
    
    private func addTemporaryFocusButton() {
        let focusButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(focusButton)
        focusButton.backgroundColor = .clear
    }
    //method to create separator view
   
    private func createImageView(imageObject:SFImageObject, containerView:UIView, pageModuleObject: SFModuleObject) {
        let imageView:SFImageView = SFImageView()
        imageView.imageViewObject = imageObject
        imageView.relativeViewFrame = containerView.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
        imageView.updateView()
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.image = UIImage(named: imageObject.imageName!)
        if(imageObject.key == "team_Logo"){
            
            //var imageURL = Regex.Match(htmlRawText, "<img.+?src=[\"'](.+?)[\"'].+?>", RegexOptions.IgnoreCase).Groups[1].Value//imgString
            
            let htmlString = pageModuleObject.moduleRawText
            let types: NSTextCheckingResult.CheckingType = .link
            let detector = try? NSDataDetector(types: types.rawValue)
            
            guard let detect = detector else {
                return
            }
            
            let matches = detect.matches(in: htmlString!, options: .reportCompletion, range: NSMakeRange(0, (htmlString?.characters.count)!))
            var imageURL = ""
            for match in matches {
                imageURL = match.url!.absoluteString
            }
            
            imageURL = imageURL.trimmingCharacters(in: .whitespaces)
            if imageURL.isEmpty == false {
                imageView.af_setImage(
                    withURL: URL(string: imageURL)!,
                    placeholderImage: nil,
                    filter: nil,
                    imageTransition: .crossDissolve(0.2)
                )
            }
        }
        
        containerView.addSubview(imageView)
    }
    
    private func createLabelView(labelObject:SFLabelObject, pageModuleObject: SFModuleObject){
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = self.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.text = pageModuleObject.moduleTitle?.capitalized
        self.addSubview(label)
        self.bringSubview(toFront: label)
        label.createLabelView()
        label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appBlockTitleColor!)
    }
        
}
