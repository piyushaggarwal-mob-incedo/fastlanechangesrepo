//
//  SFMorePopUpView.swift
//  AppCMS
//
//  Created by Gaurav Vig on 07/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol SFMorePopUpViewDelegate:NSObjectProtocol {
    @objc optional func buttonClicked(button:UIButton, buttonAction:MorePopUpOptions, externalWebLink: String?) -> Void
}

class SFMorePopUpView: UIView, UITableViewDataSource, UITableViewDelegate, SFMorePopUpTableCellDelegate {

    var morePopUpViewTable:UITableView?
    var morePopUpOptions:Array<Dictionary<String, Any>>?
//    var watchListStatus:Bool = false
    private var videoId:String?
    private let viewPadding = 40
    private let cellHeight = 60
    private let moreBackgroundViewMinYAxis = UIScreen.main.bounds.origin.y + (Constants.kAPPDELEGATE.window?.rootViewController?.navigationController?.navigationBar.frame.size.height ?? 0) + 10
    private let moreBackgroundViewMaxHeight = UIScreen.main.bounds.size.height - (Constants.kAPPDELEGATE.tabBar?.tabBar.frame.size.height ?? 0) - 10
    private let backgroundViewMobileMargin:Float = 7.47
    private let backgroundViewTabletLandscapeMargin:Float = 34.38
    private let backgroundViewTabletPortraitMargin:Float = 28.52
    private let tableViewMobileMargin:Float = 18.13
    private let tableViewTabletLandscapeMargin:Float = 38.28
    private let tableViewTabletPortraitMargin:Float = 33.72
    weak var viewDelegate:SFMorePopUpViewDelegate?
    var watchListStatus : WatchListActions?
    var readListStatus:ReadListActions?
    var downloadStatus : Bool = false
    var fileDownloadState:downloadObjectState?
    // lazy loading more pop up background view
    private(set) lazy var morePopUpView: UIView = {
        
        let view = UIView()
        view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        
        return view
    }()
    
    
    func createMorePopUpView() {
        
        self.addSubview(self.morePopUpView)
        self.createTableView()
        //self.updateSubViewFrames()
    }
    
    
    //MARK: Method to create table view
    private func createTableView() {
        
        morePopUpViewTable = UITableView(frame: .zero, style: .plain)
        morePopUpViewTable?.dataSource = self
        morePopUpViewTable?.delegate = self
        morePopUpViewTable?.separatorStyle = .none
        morePopUpViewTable?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        morePopUpViewTable?.backgroundView = nil
        morePopUpViewTable?.backgroundColor = UIColor.clear
        morePopUpViewTable?.showsVerticalScrollIndicator = false
        morePopUpViewTable?.isScrollEnabled = false
        morePopUpViewTable?.register(SFMorePopUpTableCell.self, forCellReuseIdentifier: "MorePopUpCell")
        self.addSubview(morePopUpViewTable!)
    }
    
    
    //MARK: Method to update more pop view subview frames
    func updateSubViewFrames() {
        
        if(self.subviews.contains(self.morePopUpView))
        {
            self.updateTableViewFrame()
            
            var minXAxis:CGFloat = 0
            
            if Constants.IPHONE {
                
                minXAxis = CGFloat(Utility.calculateCoordinateForSubView(marginPercent: backgroundViewMobileMargin, relativeViewCoordinate: Float(self.frame.size.width)))
            }
            else {
                
                if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                    
                    minXAxis = CGFloat(Utility.calculateCoordinateForSubView(marginPercent: backgroundViewTabletLandscapeMargin, relativeViewCoordinate: Float(self.frame.size.width)))
                }
                else {
                    
                    minXAxis = CGFloat(Utility.calculateCoordinateForSubView(marginPercent: backgroundViewTabletPortraitMargin, relativeViewCoordinate: Float(self.frame.size.width)))
                }
            }
            
            self.morePopUpView.frame = CGRect(x: minXAxis, y: ((self.morePopUpViewTable?.frame.minY)! - CGFloat(viewPadding)), width: UIScreen.main.bounds.size.width - (minXAxis * 2), height: ((self.morePopUpViewTable?.frame.maxY)! - (self.morePopUpViewTable?.frame.minY)! + CGFloat(viewPadding * 2)))
        }
    }
    
    
    //MARK: Method to update table view frame
    private func updateTableViewFrame() {
        
        if let moreOptionCount = morePopUpOptions?.count {
            
            var tableHeight:CGFloat = CGFloat((moreOptionCount + 1) * cellHeight)
            
            if tableHeight > (moreBackgroundViewMaxHeight - CGFloat(viewPadding * 2)) {
                
                tableHeight = (moreBackgroundViewMaxHeight - CGFloat(viewPadding * 2))
                morePopUpViewTable?.isScrollEnabled = true
            }
            
            var tableMinXAxis:CGFloat = 0
            
            if Constants.IPHONE {
                
                tableMinXAxis = CGFloat(Utility.calculateCoordinateForSubView(marginPercent: tableViewMobileMargin, relativeViewCoordinate: Float(self.frame.size.width)))
            }
            else {
                
                if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                    
                    tableMinXAxis = CGFloat(Utility.calculateCoordinateForSubView(marginPercent: tableViewTabletLandscapeMargin, relativeViewCoordinate: Float(self.frame.size.width)))
                }
                else {
                    
                    tableMinXAxis = CGFloat(Utility.calculateCoordinateForSubView(marginPercent: tableViewTabletPortraitMargin, relativeViewCoordinate: Float(self.frame.size.width)))
                }
            }
            
            morePopUpViewTable?.frame = CGRect(x: tableMinXAxis, y: (UIScreen.main.bounds.size.height - tableHeight)/2, width: UIScreen.main.bounds.size.width - (tableMinXAxis * 2), height: tableHeight)
        }
    }
    
    
    //MARK: Method to update more pop up view status
    func updateMorePopUpViewStatus() {
        DispatchQueue.main.async {
            self.morePopUpViewTable?.reloadData()
        }
    }
    
    //MARK: - Table view Delegates
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return morePopUpOptions?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell:SFMorePopUpTableCell = tableView.dequeueReusableCell(withIdentifier: "MorePopUpCell", for: indexPath) as! SFMorePopUpTableCell
        
        tableViewCell.contentView.backgroundColor = .clear
        tableViewCell.backgroundColor = .clear
        tableViewCell.cellFrame = CGRect(x: 0, y: 0, width: tableViewCell.frame.size.width, height: 40)
        tableViewCell.createCellView()
        tableViewCell.selectionStyle = .none
        tableViewCell.cellDelegate = self
        self.createCellViewText(tableViewCell: tableViewCell, moreOptionDictionary: morePopUpOptions![indexPath.row])
        
        return tableViewCell
    }
    
    
    private func createCellViewText(tableViewCell:SFMorePopUpTableCell, moreOptionDictionary:Dictionary<String, Any>) {
        
        if let moreOption = moreOptionDictionary["option"] as? String {
            
            switch moreOption {
                
            case "watchlist":
                
                if watchListStatus == WatchListActions.removeFromWatchListAction {
                    
                    tableViewCell.createButtonText(buttonText: Constants.kRemoveFromWatchlist)
                }
                else {
                    
                    tableViewCell.createButtonText(buttonText: Constants.kAddToWatchlist)
                }
                
                tableViewCell.buttonAction = MorePopUpOptions.watchlistAction
                break
            case "readlist":
                
                if readListStatus == ReadListActions.removeFromReadListAction {
                    
                    tableViewCell.createButtonText(buttonText: Constants.kRemoveFromReadlist)
                }
                else {
                    
                    tableViewCell.createButtonText(buttonText: Constants.kAddToReadlist)
                }
                
                tableViewCell.buttonAction = MorePopUpOptions.readlistAction
                
            case "download":
                if let downloadState = self.fileDownloadState{
                    switch downloadState {
                    case .eDownloadStateInProgress:
                        tableViewCell.createButtonText(buttonText: Constants.kPauseDownload)
                    case .eDownloadStateFinished:
                        tableViewCell.createButtonText(buttonText: Constants.kDownloaded)
                    case .eDownloadStateQueued:
                        tableViewCell.createButtonText(buttonText: Constants.kQueuedDownload)
                    case .eDownloadStatePaused:
                        tableViewCell.createButtonText(buttonText: Constants.kResumeDownload)
                    case .eDownloadStateForcePaused:
                        tableViewCell.createButtonText(buttonText: Constants.kResumeDownload)
                    default:
                        break
                    }
                }
                else{
                    tableViewCell.createButtonText(buttonText: Constants.kDownload)
                }
                tableViewCell.buttonAction = MorePopUpOptions.downloadAction
                break
            default:
                tableViewCell.createButtonText(buttonText: moreOption)
                tableViewCell.externalWebLinkUrl = moreOptionDictionary["navLink"] as? String
                tableViewCell.buttonAction = MorePopUpOptions.externalWebViewAction
                break
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }


    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 60
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: CGFloat(cellHeight)))
        footerView.backgroundColor = .clear
        footerView.autoresizingMask = [.flexibleWidth]
        
        let footerButton = UIButton(type: .custom)
        footerButton.backgroundColor = .clear
        footerButton.autoresizingMask = [.flexibleWidth]
        footerButton.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff").cgColor
        footerButton.layer.borderWidth = 1.0
        footerButton.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        footerButton.setTitle(Constants.kStrClose.uppercased(), for: .normal)
        footerButton.frame = CGRect(x: 0, y: 20, width: tableView.frame.size.width, height: 40)
        footerButton.addTarget(self, action: #selector(footerButtonClicked(sender:)), for: .touchUpInside)
        footerButton.titleLabel?.font = UIFont(name: "Lato-Bold", size: 16)
        footerView.addSubview(footerButton)
        return footerView
    }


    func footerButtonClicked(sender:UIButton) {
        
        if self.viewDelegate != nil {
            
            if (self.viewDelegate?.responds(to: #selector(buttonClicked(button:buttonAction:externalWebLink:))))! {
                
                self.viewDelegate?.buttonClicked!(button: sender, buttonAction: MorePopUpOptions.closeAction, externalWebLink: nil)
            }
        }
    }
    
    
    //MARK: More Popover view cell delegate
    func buttonClicked(button: UIButton, buttonAction: MorePopUpOptions, externalWebLink: String?) {
        
        if self.viewDelegate != nil {
            
            if (self.viewDelegate?.responds(to: #selector(buttonClicked(button:buttonAction:externalWebLink:))))! {
                
                self.viewDelegate?.buttonClicked!(button: button, buttonAction: buttonAction, externalWebLink: externalWebLink)
            }
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
