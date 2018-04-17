//
//  DownloadQualityViewController.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/24/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import Firebase

class DownloadQualityViewController: UIViewController {
    var modulesListArray:Array<AnyObject> = []
    var downloadQualityObject : SFDownloadQualityObject!
    var downloadQualityView : SfDownloadQualityView?
    var film: SFFilm?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createModuleListForDownloadQuality()
        self.createNavigationBar()
         NotificationCenter.default.addObserver(self, selector: #selector(backButtonTapped(sender:)), name: NSNotification.Name(rawValue: "dismissDownloaQualityView"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            FIRAnalytics.setScreenName("Download Quality Screen", screenClass: nil)
        }
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "Download Quality Screen")
        tracker.allowIDFACollection = true
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }


    func createNavigationBar() -> Void {
        self.navigationController?.navigationBar.barTintColor=UIColor.clear

        self.navigationItem.leftBarButtonItems = nil
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15

        let image = UIImage(named: "Back")
        let backButton = UIButton(type: .custom)
        backButton.setTitle("BACK", for: UIControlState.normal)
        backButton.setImage(image, for: .normal)
        backButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (image?.size.height)!/2)
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(backButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItems = [negativeSpacer, backButtonItem]
    }

    func backButtonTapped(sender: UIButton) -> Void {
        self.dismiss(animated: true, completion: nil)
    }

    func createModuleListForDownloadQuality() {

        var filePath:String!

        guard let pageID: String = Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Download Settings") else {
            return
        }
        filePath = AppSandboxManager.getpageFilePath(fileName: pageID)

        if FileManager.default.fileExists(atPath: filePath)
        {
            let jsonData:Data = FileManager.default.contents(atPath: filePath)!

            let responseStarJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, Any>
            let responseJson:Array<Dictionary<String, AnyObject>>? = responseStarJson["moduleList"] as? Array<Dictionary<String, AnyObject>>

            if responseJson != nil {
                
                let moduleUIParser = ModuleUIParser()
                
                modulesListArray = moduleUIParser.parseModuleConfigurationJson(modulesConfigurationArray: responseJson!) as Array<AnyObject>
                
                createModules()
            }
        }
    }

    func createModules() -> Void {
        for module:AnyObject in self.modulesListArray {

            if module is SFDownloadQualityObject {
                let layout = Utility.fetchDownloadQualityLayoutDetails(downloadQualityViewObject:module as! SFDownloadQualityObject)

                let frame: CGRect = CGRect(x: CGFloat(layout.xAxis!), y: CGFloat(layout.yAxis!), width: CGFloat(layout.width!) * Utility.getBaseScreenWidthMultiplier(), height: self.view.frame.size.height)

                let downloadView: SfDownloadQualityView = SfDownloadQualityView.init(frame: frame, downloadQualityObject: module as! SFDownloadQualityObject, filmObject:self.film ?? nil )

                downloadQualityObject = module as! SFDownloadQualityObject
                self.view.addSubview(downloadView)
                self.downloadQualityView = downloadView
            }
        }
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")

        if self.downloadQualityObject.viewAlpha != nil {
            
            self.view.alpha = self.downloadQualityObject.viewAlpha!
        }
    }

    //MARK: Orientation Method
    override func viewDidLayoutSubviews() {
        UIView.performWithoutAnimation {
            if self.downloadQualityView != nil {
                let layout = Utility.fetchDownloadQualityLayoutDetails(downloadQualityViewObject:downloadQualityObject)
                let frame: CGRect = CGRect(x: CGFloat(layout.xAxis!), y: CGFloat(layout.yAxis!), width: CGFloat(layout.width!) * Utility.getBaseScreenWidthMultiplier(), height: self.view.frame.size.height)
                self.downloadQualityView?.frame = frame
                self.downloadQualityView?.updateView()
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        
        if self.downloadQualityObject.viewAlpha != nil {
            
            self.view.alpha = self.downloadQualityObject.viewAlpha!
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
}
