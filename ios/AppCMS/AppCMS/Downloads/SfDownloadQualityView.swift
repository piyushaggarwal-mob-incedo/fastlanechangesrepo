//
//  SfDownloadQualityView.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/24/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol SFDownloadQualityDelegate:NSObjectProtocol {
    @objc func dismissDownloadQualityView(button:SFButton) -> Void
}

class SfDownloadQualityView: UIView,SFButtonDelegate,UITableViewDataSource, UITableViewDelegate{

    weak var loginViewDelegate: LoginViewDelegate?
    var downQualityObject: SFDownloadQualityObject!
    weak var downloadQualityDelegate:SFDownloadQualityDelegate?
    var tableView:SFTableView?
    var relativeViewFrame:CGRect?
    var apiModuleListArray:Array<AnyObject> = []
    var film: SFFilm?

    init(frame: CGRect, downloadQualityObject: SFDownloadQualityObject, filmObject:SFFilm?) {
        super.init(frame: frame)
        relativeViewFrame = frame
        self.downQualityObject = downloadQualityObject
        self.film = filmObject
        self.backgroundColor=UIColor.clear
        if self.film != nil {
            for filmUrl in (self.film?.filmUrl)! {
                let filmUrlObject: SFFilmURL = filmUrl as! SFFilmURL
                let qualityObj = SFQualityObject()
                qualityObj.isSelected = false
                qualityObj.title = filmUrlObject.renditionValue.replacingOccurrences(of: "_", with: "");
                if DownloadManager.sharedInstance.downloadQuality == qualityObj.title {
                    qualityObj.isSelected = true
                }
                apiModuleListArray.append(qualityObj)
            }
        }
        else{

            var qualityObj = SFQualityObject()
            qualityObj = SFQualityObject()
            qualityObj.title = "720p";
            if DownloadManager.sharedInstance.downloadQuality == "" || DownloadManager.sharedInstance.downloadQuality == qualityObj.title{
                DownloadManager.sharedInstance.setDownloadQualityForDownload("720p")
                qualityObj.isSelected = true
            }
            apiModuleListArray.append(qualityObj)
            
            qualityObj = SFQualityObject()
            qualityObj.title = "360p";
            if DownloadManager.sharedInstance.downloadQuality == qualityObj.title {
                qualityObj.isSelected = true
            }
            apiModuleListArray.append(qualityObj)

        }

        createView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createView() -> Void {
        createAutoPlayView(containerView: self, itemIndex: 0)
    }

    //MARK: Creation of View Components
    func createAutoPlayView(containerView: UIView, itemIndex:Int) -> Void{

        for component:AnyObject in self.downQualityObject.components {

            if component is SFButtonObject {

                let buttonObject:SFButtonObject = component as! SFButtonObject

                createButtonView(buttonObject: buttonObject, containerView: self, itemIndex: itemIndex, type: component.key!!)
            }
            else if component is SFLabelObject {

                createLabelView(labelObject: component as! SFLabelObject, containerView: containerView, type: component.key!!)
            }
            else if component is SFTableViewObject {

                createTableView(tableViewObject: component as! SFTableViewObject, containerView: containerView)
            }
        }
    }

    func createButtonView(buttonObject:SFButtonObject, containerView:UIView, itemIndex:Int, type: String) -> Void {

        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)

        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.buttonLayout = buttonLayout
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.buttonDelegate = self
        button.tag = itemIndex
        button.createButtonView()

        button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!, size: (button.titleLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())

        if buttonObject.key == "continueButton" {
            
            button.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000")
            button.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor ?? AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        }
        containerView.addSubview(button)
        containerView.bringSubview(toFront: button)
    }

    func createLabelView(labelObject:SFLabelObject, containerView:UIView, type: String) {

        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)

        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.createLabelView()
        label.text = labelObject.text
        containerView.addSubview(label)
        containerView.bringSubview(toFront: label)
        label.font = UIFont(name: label.font.fontName, size: label.font.pointSize * Utility.getBaseScreenHeightMultiplier())
        label.center = CGPoint(x: containerView.center.x, y:label.frame.origin.y)
    }

    //method to create table view
    func createTableView(tableViewObject:SFTableViewObject, containerView:UIView) {

        let tableViewLayout = Utility.sharedUtility.fetchTableViewLayoutDetails(tableViewObject: tableViewObject)
        tableView = SFTableView(frame: CGRect.zero, style: .plain)
        tableView?.relativeViewFrame = containerView.frame
        tableView?.tableObject = tableViewObject
        tableView?.tableLayout = tableViewLayout
        tableView?.initialiseTableViewFrameFromLayout(tableViewLayout: tableViewLayout)
        tableView?.changeFrameYAxis(yAxis: (tableView?.frame.minY)! + 20)
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.updateTableView()
        tableView?.register(SFDownloadQualityCell.self, forCellReuseIdentifier: "tableViewCustomCell")
        self.addSubview(tableView!)
        self.tableView?.backgroundColor = UIColor.clear
    }

    //MARK: TableView delegates
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var customTableViewCell:SFDownloadQualityCell? = tableView.dequeueReusableCell(withIdentifier: "tableViewCustomCell") as? SFDownloadQualityCell

        if customTableViewCell == nil {

            customTableViewCell = SFDownloadQualityCell(style: .default, reuseIdentifier: "tableViewCustomCell")
        }

        customTableViewCell?.cellRowValue = indexPath.row
        
        addCustomTableViewCellToTable(customTableViewCell: customTableViewCell!, gridObject: apiModuleListArray[indexPath.row] as? SFQualityObject)
        return customTableViewCell!
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return apiModuleListArray.count
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return CGFloat(((self.tableView?.tableLayout?.gridHeight) ?? 44 )) * Utility.getBaseScreenHeightMultiplier()
    }

    func setSelectedForIndex(row: NSInteger) -> Void {
        let qualityobject:SFQualityObject = (apiModuleListArray[row] as? SFQualityObject)!
        qualityobject.isSelected = true
        self.apiModuleListArray[row] = qualityobject
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        for (index, element) in self.apiModuleListArray.enumerated() {
            let qualityobject:SFQualityObject = element as! SFQualityObject
            qualityobject.isSelected = false
            self.apiModuleListArray[index] = qualityobject
        }
        self.setSelectedForIndex(row: indexPath.row)
        self.tableView?.reloadData()
    }

    //MARK: method to custom table view cell
    func addCustomTableViewCellToTable(customTableViewCell:SFDownloadQualityCell, gridObject:SFQualityObject?) {

        customTableViewCell.backgroundColor = UIColor.clear
        customTableViewCell.selectionStyle = .none
        customTableViewCell.relativeViewFrame = CGRect(x: 0, y: 0, width: (tableView?.frame.size.width)!, height: CGFloat(tableView?.tableLayout?.gridHeight ?? 44) * Utility.getBaseScreenHeightMultiplier())
        customTableViewCell.tableComponents = (tableView?.tableObject?.trayComponents)!
        customTableViewCell.gridObject = gridObject!
        customTableViewCell.updateGridSubView()
    }

    //method to update table view frames
    func updateTableView(tableView:SFTableView, containerView:UIView) {

        tableView.relativeViewFrame = containerView.frame
        let tableViewLayout = Utility.sharedUtility.fetchTableViewLayoutDetails(tableViewObject: tableView.tableObject!)
        tableView.initialiseTableViewFrameFromLayout(tableViewLayout: tableViewLayout)
        tableView.changeFrameYAxis(yAxis: (tableView.frame.minY) + 20)
    }

    func updateButtonViewFrame(button:SFButton, containerView:UIView) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: button.buttonObject!)
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        
        button.changeFrameWidth(width: button.frame.size.width * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameHeight(height: button.frame.size.height * Utility.getBaseScreenHeightMultiplier())
        
        if buttonLayout.height != nil {
            
            button.changeFrameYAxis(yAxis: button.frame.origin.y - (button.frame.size.height - CGFloat(buttonLayout.height!))/2)
        }
        
        if button.buttonObject?.key == "cancelButton" {
            
            if buttonLayout.width != nil {
                
                button.changeFrameXAxis(xAxis: button.frame.origin.x + ((button.frame.size.width - CGFloat(buttonLayout.width!)) * -1))
            }
        }
        if button.buttonObject?.key == "continueButton" || button.buttonObject?.key == "cancelButton" {
            if #available(iOS 11.0, *) {
                if ((UIApplication.shared.keyWindow?.safeAreaInsets.bottom)! > CGFloat(0.0)){
                    button.changeFrameYAxis(yAxis: button.frame.minY - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)! + 20)
                }
            }
        }
    }

    //MARK: Update Video Description Subviews
    func updateLabelViewFrame(label:SFLabel, containerView:UIView) {

        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!)
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        
        label.changeFrameWidth(width: label.frame.size.width * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameHeight(height: label.frame.size.height * Utility.getBaseScreenHeightMultiplier())
        label.center = CGPoint(x: containerView.center.x, y:label.frame.origin.y)

        if labelLayout.height != nil {
            
            label.changeFrameYAxis(yAxis: label.frame.origin.y * Utility.getBaseScreenHeightMultiplier() - (label.frame.size.height - CGFloat(labelLayout.height!)))
        }
    }

    func getDownloadQuality() -> String {
        var downloadQuality : String = ""
        for qualityobject in self.apiModuleListArray {
            if qualityobject.isSelected == true {
                downloadQuality = qualityobject.title.replacingOccurrences(of: "_", with: "")
                break;
            }
        }
        return downloadQuality
    }

    @objc func buttonClicked(button:SFButton) -> Void{
        if button.buttonObject?.key == "continueButton"{
            DownloadManager.sharedInstance.setDownloadQualityForDownload(self.getDownloadQuality())
        }
        NotificationCenter.default.post(name: Notification.Name("dismissDownloaQualityView"), object: button.buttonObject?.key)
    }

    func updateView() -> Void
    {
        for component: AnyObject in self.subviews {

            if component is SFButton {

                updateButtonViewFrame(button: component as! SFButton, containerView: self)
            }
            else if component is SFLabel {

                updateLabelViewFrame(label: component as! SFLabel, containerView: self)
            }
            else if component is SFTableView {

                updateTableView(tableView: component as! SFTableView, containerView: self)
            }
        }
    }

}
