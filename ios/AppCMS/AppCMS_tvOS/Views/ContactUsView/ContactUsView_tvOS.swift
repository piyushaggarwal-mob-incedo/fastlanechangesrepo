//
//  ContactUsView_tvOS.swift
//  AppCMS
//
//  Created by Rajni Pathak on 23/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//



import UIKit

class ContactUsView_tvOS: UIView  {
    
    
    var relativeViewFrame:CGRect?
    var modulesArray:Array<AnyObject> = []
    private  var acitivityIndicator : UIActivityIndicatorView?
    
    
    init(frame: CGRect, contactUsObject: ContactUsViewObject_tvOS) {
        super.init(frame: frame)
        //        super.init(nibName: nil, bundle: nil)
        self.relativeViewFrame = frame
        let loginLayout = Utility.fetchContactUsViewLayoutDetails(ContactUsViewObject: contactUsObject)
        self.frame = Utility.initialiseViewLayout(viewLayout: loginLayout, relativeViewFrame: relativeViewFrame!)
        self.modulesArray = contactUsObject.components
        createView(containerView: self, itemIndex: 0)
        let focusButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(focusButton)
        focusButton.backgroundColor = .clear
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Creation of View Components
    func createView(containerView: UIView, itemIndex:Int) {
        for component:AnyObject in self.modulesArray {
            if component is SFSeparatorViewObject {
                
                createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
            }
            else if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject)
            }
            else if component is SFImageObject {
                
                createImageView(imageObject: component as! SFImageObject, containerView: self)
            }
        }
    }
    
    //method to create separator view
    private func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        let separatorView:SFSeparatorView = SFSeparatorView(frame: CGRect.zero)
        separatorView.separtorViewObject = separatorViewObject
        separatorView.relativeViewFrame = relativeViewFrame!
        self.addSubview(separatorView)
        updateSeparatorView(separatorView: separatorView)
        
        separatorView.isHidden = false
    }
    
    private func createImageView(imageObject:SFImageObject, containerView:UIView) {
        let imageView:SFImageView = SFImageView()
        imageView.imageViewObject = imageObject
        imageView.relativeViewFrame = containerView.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
        imageView.updateView()
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.image = UIImage(named: imageObject.imageName!)
        if(imageObject.key == "call_Icon"){
            if (AppConfiguration.sharedAppConfiguration.customerServicePhone == nil || AppConfiguration.sharedAppConfiguration.customerServicePhone == ""){
                imageView.isHidden = true
            }
        }
        if(imageObject.key == "email_Icon"){
            if (AppConfiguration.sharedAppConfiguration.customerServiceEmail == nil || AppConfiguration.sharedAppConfiguration.customerServiceEmail == ""){
                imageView.isHidden = true
            }
        }
        containerView.addSubview(imageView)
    }
    
    private func createLabelView(labelObject:SFLabelObject){
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = self.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.text = labelObject.text?.uppercased()
        self.addSubview(label)
        self.bringSubview(toFront: label)
        label.createLabelView()
        
        if labelObject.key == "title" {
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor!)
        } else {
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
        if(labelObject.key == "emailId"){
            if (AppConfiguration.sharedAppConfiguration.customerServiceEmail != nil && AppConfiguration.sharedAppConfiguration.customerServiceEmail != ""){
                label.text = label.text!+" \(AppConfiguration.sharedAppConfiguration.customerServiceEmail!)"
            }
            else{
                label.text = ""
            }
        }
        if(labelObject.key == "contactNumber"){
            if (AppConfiguration.sharedAppConfiguration.customerServicePhone != nil && AppConfiguration.sharedAppConfiguration.customerServicePhone != ""){
                label.text = label.text!+" \(AppConfiguration.sharedAppConfiguration.customerServicePhone!)"
            }
            else{
                label.text = ""
            }
        }        
    }
    
    
    //method to update separator view frames
    private func updateSeparatorView(separatorView:SFSeparatorView) {
        
        separatorView.relativeViewFrame = relativeViewFrame!
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorView.separtorViewObject!))
    }
    
    
    
    
    //MARK: - Activity Indicator Methods
    func addActivityIndicator(){
        self.acitivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.acitivityIndicator!.center = self.center
        self.addSubview(self.acitivityIndicator!)
        self.acitivityIndicator!.startAnimating();
    }
    
    func removeActivityIndicator(){
        if let tempActivityIndicatorView = self.acitivityIndicator
        {
            tempActivityIndicatorView.removeFromSuperview()
            tempActivityIndicatorView.stopAnimating();
        }
    }
    
    
}
