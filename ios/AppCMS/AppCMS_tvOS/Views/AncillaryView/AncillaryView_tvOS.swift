
//
//  AncillaryView_tvOS.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 10/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class AncillaryView_tvOS: UIViewController, SFButtonDelegate { //UIViewController{ //
    
    var relativeViewFrame:CGRect?
    var modulesArray:Array<AnyObject> = []
    var moduleAPIObject:SFModuleObject?
    private  var acitivityIndicator : UIActivityIndicatorView?
    ///Displays empty message label
    private var emptyMessageLbl : UILabel?
    
    init(frame: CGRect, ancillaryObject: AncillaryViewObject_tvOS) {
        super.init(nibName: nil, bundle: nil)
//        super.init(nibName: nil, bundle: nil)
        self.relativeViewFrame = frame
        let loginLayout = Utility.fetchAncillaryViewLayoutDetails(ancillaryViewObject: ancillaryObject)
        self.view.frame = Utility.initialiseViewLayout(viewLayout: loginLayout, relativeViewFrame: relativeViewFrame!)
        self.modulesArray = ancillaryObject.components
        createView(containerView: self.view, itemIndex: 0)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonClicked(button: SFButton) {
        if button.buttonObject?.action == "scrollUp" {
            let textView: UITextView = self.view.viewWithTag(101) as! UITextView
            var scrollPosition = textView.contentOffset
            if scrollPosition.y < textView.contentSize.height - (textView.bounds.height - 200) {
                scrollPosition = CGPoint(x: scrollPosition.x, y: scrollPosition.y + 100)
                textView.setContentOffset(scrollPosition, animated: true)
            }
        } else if button.buttonObject?.action == "scrollDown" {
            let textView: UITextView = self.view.viewWithTag(101) as! UITextView
            var scrollPosition = textView.contentOffset
            if scrollPosition.y > 0 {
                scrollPosition = CGPoint(x: scrollPosition.x, y: scrollPosition.y - 100)
                if scrollPosition.y < 0.0 {
                    scrollPosition = CGPoint(x: scrollPosition.x, y: 0)
                }
                textView.setContentOffset(scrollPosition, animated: true)
            }
        }
    }
    
    func showTheUpDownButtons() {
        for subView in self.view.subviews {
            if subView is SFButton {
                let button:SFButton = subView as! SFButton
                if button.buttonObject?.key == "upButton" || button.buttonObject?.key == "downButton"  {
                    button.isHidden = false
                    button.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    //MARK: Creation of View Components
    func createView(containerView: UIView, itemIndex:Int) {
        for component:AnyObject in self.modulesArray {

                if component is SFTextViewObject {
                    
                    createTextView(textViewObject: component as! SFTextViewObject)
                }
                else if component is SFSeparatorViewObject {
                    
                    createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
                }
                else if component is SFLabelObject {
                    
                    createLabelView(labelObject: component as! SFLabelObject)
                }
                else if component is SFButtonObject {
                    
                    createButtonView(buttonObject: component as! SFButtonObject)
            }
        }
    }


    //method to create buttonview
    func createButtonView(buttonObject:SFButtonObject) {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        
        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.relativeViewFrame = relativeViewFrame!
        button.buttonLayout = buttonLayout
        button.buttonDelegate = self
        button.createButtonView()
        
        if button.buttonObject?.key == "upButton"{
            button.tag = 8888
            button.setImage(UIImage(named: "arrowDownUnfocused")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState.normal)
            button.imageView?.tintColor = UIColor.gray
            button.isHidden = true
            button.isUserInteractionEnabled = false
            button.buttonShowsAnImage = true
        }
        else if button.buttonObject?.key == "downButton" {
            button.tag = 9999
            button.setImage(UIImage(named: "arrowUpUnfocused")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState.normal)
            button.imageView?.tintColor = UIColor.gray
            button.isHidden = true
            button.isUserInteractionEnabled = false
            button.buttonShowsAnImage = true
        }
        
        self.view.addSubview(button)
        updateButtonView(button: button)
    }
    
    //MARK: Helper Methods.
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        //Next focus views handling.
        if context.nextFocusedView != nil && context.nextFocusedView is SFButton {
            if context.nextFocusedView?.tag == 8888 || context.nextFocusedView?.tag == 9999{
                let button = context.nextFocusedView as! SFButton
                if let textColor = AppConfiguration.sharedAppConfiguration.primaryButton.backgroundColor {
                    button.imageView?.tintColor = Utility.hexStringToUIColor(hex: textColor)
                }
            }
        }
        //Previous focus views handling.
        if (context.previouslyFocusedView?.tag == 8888 || context.previouslyFocusedView?.tag == 9999) &&  context.previouslyFocusedView is SFButton{
            let button = context.previouslyFocusedView as! SFButton
            button.imageView?.tintColor = UIColor.gray
        }
        
    }
    
    //method to update button view frames
    func updateButtonView(button:SFButton) {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: button.buttonObject!)
        
        button.relativeViewFrame = relativeViewFrame!
        button.buttonLayout = buttonLayout
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
    }
    
    //method to create textview
    private func createTextView(textViewObject:SFTextViewObject) {
        
        let textViewLayout = Utility.fetchTextViewLayoutDetails(textViewObject: textViewObject)
        let textView:SFTextView = SFTextView(frame: CGRect.zero)
        textView.textViewObject = textViewObject
        textView.textViewLayout = textViewLayout
        textView.relativeViewFrame = relativeViewFrame!
        textView.updateView()
        textView.tag = 101
        textView.showsVerticalScrollIndicator = true
        textView.flashScrollIndicators()
        self.view.addSubview(textView)
        updateTextView(textView: textView)
    }

    
    //method to create separator view
  private func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        let separatorView:SFSeparatorView = SFSeparatorView(frame: CGRect.zero)
        separatorView.separtorViewObject = separatorViewObject
        separatorView.relativeViewFrame = relativeViewFrame!
        self.view.addSubview(separatorView)
        separatorView.tag = 301
        updateSeparatorView(separatorView: separatorView)
        
        separatorView.isHidden = true
    }


  private func createLabelView(labelObject:SFLabelObject){
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = self.view.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
    ///Text 
//        label.text = labelObject.text
        label.tag = 201
        self.view.addSubview(label)
        self.view.bringSubview(toFront: label)
        label.createLabelView()
        
        if labelObject.key == "title" {
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor!)
        } else {
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
    }
    
    
    //method to update separator view frames
    private func updateSeparatorView(separatorView:SFSeparatorView) {
        
        separatorView.relativeViewFrame = relativeViewFrame!
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorView.separtorViewObject!))
    }
    
    
    //method to update textview frames
    private func updateTextView(textView:SFTextView) {
        let textViewLayout = Utility.fetchTextViewLayoutDetails(textViewObject: textView.textViewObject!)
        textView.relativeViewFrame = relativeViewFrame!
        textView.initialiseTextViewFrameFromLayout(textViewLayout: textViewLayout)
    }
    
    
    //MARK: - Activity Indicator Methods
     func addActivityIndicator(){
        if acitivityIndicator == nil {
            self.acitivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        }
        self.acitivityIndicator?.center = self.view.center
        self.acitivityIndicator?.startAnimating()
        self.view.addSubview(acitivityIndicator!)
    }
    
    func removeActivityIndicator(){
        if let tempActivityIndicatorView = self.acitivityIndicator
        {
            tempActivityIndicatorView.removeFromSuperview()
            tempActivityIndicatorView.stopAnimating();
        }
    }
    
//    override weak var preferredFocusedView: UIView? {
//        let textView : UITextView = self.view.viewWithTag(101) as! UITextView
//        return textView
//    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let viewToBeFocused = view.viewWithTag(101) {
            return [viewToBeFocused]
        } else {
            return super.preferredFocusEnvironments
        }
    }
    
    
    /* getEmptyMessageLbl method is used for creating label and displaying message in absense of network and data is not available to display.*/
    func getEmptyMessageLbl() -> UILabel{
        emptyMessageLbl = UILabel.init(frame: CGRect(x: 0, y: 0, width: 900, height: 100))
        var fontFamily:String?
        if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
            fontFamily = _fontFamily
        }
        if fontFamily == nil {
            fontFamily = "OpenSans"
        }
        emptyMessageLbl?.font = UIFont(name: "\(fontFamily!)-Semibold", size: 28)
        emptyMessageLbl?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")//UIColor.white
        emptyMessageLbl?.textAlignment = .center
        emptyMessageLbl?.numberOfLines = 0
        emptyMessageLbl?.text = Constants.kInternetConntectionRefresh
        return emptyMessageLbl!
    }
    
    /*removeEmptyMessageLbl method is used for removing label from view if label is displaying*/
    func removeEmptyMessageLbl(){
        emptyMessageLbl?.removeFromSuperview()
    }
    
    func showEmptyLabelOnAncillaryView() {
        
        let emptyMsglbl = self.getEmptyMessageLbl()
        emptyMsglbl.center = CGPoint(x: UIScreen.main.bounds.width/2, y: (UIScreen.main.bounds.height/2)-100)
        self.view.addSubview(emptyMsglbl)
    }
    

}
