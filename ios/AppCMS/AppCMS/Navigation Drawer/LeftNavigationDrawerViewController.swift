//
//  LeftNavigationDrawerViewController.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 02/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import DrawerController


class LeftNavigationDrawerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    var tableView: UITableView!
    var drawerWidth: CGFloat = 0.0
    var selectedDrawerIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationDrawer = AppConfiguration.sharedAppConfiguration.navigationMenu
        self.navigationController?.navigationBar.barTintColor = navigationDrawer.navigationBackgroundColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 55 / 255, green: 70 / 255, blue: 77 / 255, alpha: 1.0)]

        drawerWidth = navigationDrawer.navigationDrawerWidth!
        self.evo_drawerController?.maximumLeftDrawerWidth = drawerWidth
        
        self.tableView = UITableView(frame: self.view.bounds, style: .plain)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        
        self.tableView.backgroundColor = navigationDrawer.navigationBackgroundColor
        self.tableView.separatorStyle = .none
        self.view.addSubview(self.tableView)
        
        self.view.backgroundColor = navigationDrawer.navigationBackgroundColor
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.navigationController?.view.setNeedsLayout()
//        
//        self.tableView.reloadSections(IndexSet(integersIn: NSRange(location: 0, length: self.tableView.numberOfSections - 1).toRange() ?? 0..<0), with: .none)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let navigationDrawer = AppConfiguration.sharedAppConfiguration.navigationMenu
        return navigationDrawer.navigationItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell"
        let navigationDrawer = AppConfiguration.sharedAppConfiguration.navigationMenu
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as UITableViewCell?
        
        if cell == nil {
            cell = SideDrawerTableViewCell(style: .default, reuseIdentifier: CellIdentifier)
            cell.selectionStyle = .blue
        }
        
        if selectedDrawerIndex == indexPath.row {
            cell.isSelected = true
        }
        let navigationItem = navigationDrawer.navigationItems[indexPath.row] as NavigationItem
        cell.textLabel?.text = navigationItem.title
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Navigation"
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = SideDrawerSectionHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 56.0))
//        headerView.autoresizingMask = [ .flexibleHeight, .flexibleWidth ]
//        headerView.title = tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: section)
//        return headerView
//    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 56
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0
//    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedDrawerIndex == indexPath.row {
            self.evo_drawerController?.closeDrawer(animated: true, completion: { (Bool) in
            })
        }
        else
        {
            selectedDrawerIndex = indexPath.row
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            self.evo_drawerController?.closeDrawer(animated: true, completion: { (Bool) in
                Constants.kAPPDELEGATE.updateCenterViewController(selectedIndex: indexPath.row)
            })
        }
//        tableView.deselectRow(at: indexPath, animated: true)
    }
}
