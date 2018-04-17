//
//  CustomPlayerSettingsScreenViewController.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 16/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import UIKit

@objc protocol StreamSelectorDelegate: NSObjectProtocol
{
    @objc func streamQualityDidChanged(selectedIndex: Int, selectedKey: String) -> Void
    @objc func streamSelectorViewRemovedFromSuperView() -> Void
}

class CustomPlayerSettingsScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var streamSelectorArray: Array<String> = []
    var streamSelectorTableView: UITableView = UITableView.init()
    var streamSelectorDelegate: StreamSelectorDelegate?
    var tableViewHeight: CGFloat = 0.0
    var selectedKey: String = ""
    private let tableViewWidth: CGFloat = 100.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewHeight = CGFloat(self.streamSelectorArray.count * 35)
        self.streamSelectorTableView.frame = CGRect.init(x: (self.view.frame.width - tableViewWidth)/2, y: (self.view.frame.height - tableViewHeight)/2, width: tableViewWidth, height: tableViewHeight)
        self.view.addSubview(self.streamSelectorTableView)
        self.streamSelectorTableView.delegate = self
        self.streamSelectorTableView.dataSource = self
        self.streamSelectorTableView.backgroundColor = .clear//Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        // Do any additional setup after loading the view.
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if self.streamSelectorDelegate != nil && (self.streamSelectorDelegate?.responds(to: #selector(self.streamSelectorDelegate?.streamSelectorViewRemovedFromSuperView)))!
        {
            self.streamSelectorDelegate?.streamSelectorViewRemovedFromSuperView()
        }
        self.view.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.streamSelectorTableView.frame = CGRect.init(x: (self.view.frame.width - tableViewWidth)/2, y: (self.view.frame.height - tableViewHeight)/2, width: tableViewWidth, height: tableViewHeight)
    }
    
    //MARK: Table View delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.streamSelectorDelegate != nil && (self.streamSelectorDelegate?.responds(to: #selector(self.streamSelectorDelegate?.streamQualityDidChanged(selectedIndex:selectedKey:))))!
        {
            self.streamSelectorDelegate?.streamQualityDidChanged(selectedIndex: indexPath.row, selectedKey: self.streamSelectorArray[indexPath.row])
        }
        self.view.removeFromSuperview()
    }
    
    //MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.streamSelectorArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier:String = "streamSelectorCell"
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil
        {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell?.backgroundColor = .clear//Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
            cell?.contentView.backgroundColor = .clear//Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
            cell?.selectionStyle = .none
            cell?.changeFrameWidth(width: 100)
            cell?.changeFrameHeight(height: 35)
            
            let cellLabel: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 35))
            cellLabel.textAlignment = .center
            cellLabel.font = UIFont.init(name: "OpenSans-Bold", size: 18)
            cellLabel.text = self.streamSelectorArray[indexPath.row]
            
            if self.streamSelectorArray[indexPath.row] == self.selectedKey
            {
                cellLabel.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "000000")
            }
            else
            {
                cellLabel.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "000000")
            }
            cell?.addSubview(cellLabel)
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
    }
}
