//
//  StarRatingViewController.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 13/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import Cosmos

let rateItButton = "rateButton"
let cancelButton = "cancelButton"

class StarRatingViewController: UIViewController, SFButtonDelegate {

    var modulesListArray:Array<AnyObject> = []
    var film: SFFilm?
    var show: SFShow?
    
    init(film: SFFilm?, show: SFShow?) {
        self.film = film
        self.show = show
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createModuleListForStarRatingView()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        if Constants.IPHONE {
            return
        }
        for component: AnyObject in self.view.subviews {
            
            if component is SFButton {
                
                updateButtonViewFrame(button: component as! SFButton, containerView: self.view)
            }
            else if component is SFLabel {
                
                updateLabelViewFrame(label: component as! SFLabel, containerView: self.view)
            }
            else if component is CosmosView {
                
                updateStarViewFrame(starView: component as! CosmosView, containerView: self.view)
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Method to create Module list
    func createModuleListForStarRatingView() {
        
        let filePath:String = (Bundle.main.resourcePath?.appending("/StarView.json"))!
        
        if FileManager.default.fileExists(atPath: filePath){
            let jsonData:Data = FileManager.default.contents(atPath: filePath)!
            
            let responseStarJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, Any>
            let responseJson:Array<Dictionary<String, AnyObject>> = responseStarJson["moduleList"] as! Array<Dictionary<String, AnyObject>>
            
            let moduleParser = ModuleUIParser()
            modulesListArray = moduleParser.parseModuleConfigurationJson(modulesConfigurationArray: responseJson) as Array<AnyObject>
            createModules()
        }
        
    }

    func createModules() -> Void {
        for module:AnyObject in self.modulesListArray {
            
            if module is SFButtonObject {
                
                let buttonObject:SFButtonObject = module as! SFButtonObject
                createButtonView(buttonObject: buttonObject, containerView: self.view, type: buttonObject.key!)
            }
            else if module is SFStarRatingObject
            {
                createStarView(starObject: module as! SFStarRatingObject, containerView: self.view)
            }
            else if module is SFLabelObject
            {
                createLabelView(labelObject: module as! SFLabelObject, containerView: self.view)
            }
        }
    }
    
    
    func createButtonView(buttonObject:SFButtonObject, containerView:UIView, type: String) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        
        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.buttonDelegate = self
        button.createButtonView()
        
        button.changeFrameXAxis(xAxis: button.frame.minX * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameYAxis(yAxis: button.frame.minY * Utility.getBaseScreenHeightMultiplier())
        button.changeFrameWidth(width: button.frame.width * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameHeight(height: button.frame.height * Utility.getBaseScreenHeightMultiplier())
        if type == closeButtonString
        {
            let closeButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "cancelIcon.png"))
            
            button.setImage(closeButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        }
        else if type == rateItButton
        {
            
        }
        else if type == cancelButton
        {
            
        }
        containerView.addSubview(button)
        containerView.bringSubview(toFront: button)
    }

    func createStarView(starObject:SFStarRatingObject, containerView:UIView) {
        
        let starLayoutObject: LayoutObject = Utility.fetchStarRatingLayoutDetails(starRatingObject: starObject)
        let starFrame: CGRect = Utility.initialiseViewLayout(viewLayout: starLayoutObject, relativeViewFrame: containerView.frame)
        let starView: CosmosView = CosmosView.init(frame: starFrame)
        starView.settings.starSize = Double(starFrame.size.height * Utility.getBaseScreenHeightMultiplier())
        starView.settings.emptyBorderColor = starObject.clearBorderColor != nil ? Utility.hexStringToUIColor(hex:(starObject.clearBorderColor)!) : (starObject.fillBorderColor != nil ?  Utility.hexStringToUIColor(hex:(starObject.fillBorderColor)!) : UIColor.red )
        starView.settings.filledBorderColor = starObject.fillBorderColor != nil ?  Utility.hexStringToUIColor(hex:(starObject.fillBorderColor)!) : UIColor.red
        starView.settings.emptyColor = UIColor.clear
        starView.settings.filledColor = starObject.fillColor != nil ? Utility.hexStringToUIColor(hex:(starObject.fillColor)!) : UIColor.red
        starView.settings.totalStars = 5

        if self.film != nil {
            
            starView.rating = (self.film?.viewerGrade)!
        }
        else if self.show != nil {
            
            starView.rating = (self.show?.viewerGrade)!
        }
        starView.settings.starMargin = Double(CGFloat(starObject.margin!) * Utility.getBaseScreenHeightMultiplier())
        starView.settings.fillMode = StarFillMode(rawValue: 2)!
        starView.settings.emptyBorderWidth = 2.0
        starView.didFinishTouchingCosmos = self.didFinishTouchingCosmos
        starView.settings.minTouchRating = 0
        
        starView.changeFrameXAxis(xAxis: starView.frame.minX * Utility.getBaseScreenHeightMultiplier())
        starView.changeFrameYAxis(yAxis: starView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        starView.changeFrameWidth(width: starView.frame.width * Utility.getBaseScreenWidthMultiplier())
        starView.changeFrameHeight(height: starView.frame.height * Utility.getBaseScreenHeightMultiplier())

        
        self.view.addSubview(starView)
    }
    
    func createLabelView(labelObject:SFLabelObject, containerView:UIView) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        
        if self.film != nil {
            
            label.text = "RATE " + (self.film?.title ?? "")
        }
        else if self.show != nil {
            
            label.text = "RATE " + (self.show?.showTitle ?? "")
        }
        label.createLabelView()
        label.changeFrameXAxis(xAxis: label.frame.minX * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameYAxis(yAxis: label.frame.minY * Utility.getBaseScreenHeightMultiplier())
        label.changeFrameWidth(width: label.frame.width * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameHeight(height: label.frame.height * Utility.getBaseScreenHeightMultiplier())
        containerView.addSubview(label)
    }
    
    //MARK: Update Video Description Subviews
    func updateLabelViewFrame(label:SFLabel, containerView:UIView) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!)
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.changeFrameXAxis(xAxis: label.frame.minX * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameYAxis(yAxis: label.frame.minY * Utility.getBaseScreenHeightMultiplier())
        label.changeFrameWidth(width: label.frame.width * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameHeight(height: label.frame.height * Utility.getBaseScreenHeightMultiplier())
    }
    
    func updateButtonViewFrame(button:SFButton, containerView:UIView) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: button.buttonObject!)
        
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        
        button.changeFrameXAxis(xAxis: button.frame.minX * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameYAxis(yAxis: button.frame.minY * Utility.getBaseScreenHeightMultiplier())
        button.changeFrameWidth(width: button.frame.width * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameHeight(height: button.frame.height * Utility.getBaseScreenHeightMultiplier())
    }
    
    func updateStarViewFrame(starView:CosmosView, containerView:UIView) {
        
        for module:AnyObject in self.modulesListArray {
            if module is SFStarRatingObject
            {
                let starLayoutObject: LayoutObject = Utility.fetchStarRatingLayoutDetails(starRatingObject: module as! SFStarRatingObject)
                starView.frame =  Utility.initialiseViewLayout(viewLayout: starLayoutObject, relativeViewFrame: containerView.frame)
                starView.changeFrameXAxis(xAxis: starView.frame.minX * Utility.getBaseScreenHeightMultiplier())
                starView.changeFrameYAxis(yAxis: starView.frame.minY * Utility.getBaseScreenHeightMultiplier())
                starView.changeFrameWidth(width: starView.frame.width * Utility.getBaseScreenWidthMultiplier())
                starView.changeFrameHeight(height: starView.frame.height * Utility.getBaseScreenHeightMultiplier())
            }
        }
    }

    
    //MARK: Actions
    func didFinishTouchingCosmos(rating: Double)
    {
        
    }
    
    @objc func buttonClicked(button:SFButton) -> Void
    {
        if button.buttonObject?.key == rateItButton {
            
        }
        else if button.buttonObject?.key == cancelButton || button.buttonObject?.key == closeButtonString
        {
            self.dismiss(animated: true) {
                
            }
        }
        
    }
}
