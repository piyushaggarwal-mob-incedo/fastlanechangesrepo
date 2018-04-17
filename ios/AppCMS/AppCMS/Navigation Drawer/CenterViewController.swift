//
//  CenterViewController.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 02/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import DrawerController

enum CenterViewControllerSection: Int{
    case leftViewState
    case leftDrawerAnimation
}

class CenterViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.restorationIdentifier = "CenterControllerRestorationKey"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.restorationIdentifier = "CenterControllerRestorationKey"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLeftMenuButton()
        
        let barColor = UIColor(red: 247/255, green: 249/255, blue: 250/255, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = barColor
        
        self.navigationController?.view.layer.cornerRadius = 10.0
        
//        self.view.backgroundColor = UIColor(red: 100/255, green: 150/255, blue: 75/255, alpha: 1.0)
        
//        let backView = UIView()
//        backView.backgroundColor = UIColor(red: 208/255, green: 208/255, blue: 208/255, alpha: 1.0)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Center will appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Center did appear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Center will disappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Center did disappear")
    }
    
    func updateNavigationDrawerSelection(selectedIndex: Int) -> Void
    {
        let pageViewController: PageViewController = AppConfiguration.sharedAppConfiguration.pageViewControllers[selectedIndex] as! PageViewController
        self.navigationController?.popToRootViewController(animated: false)
        self.navigationController?.pushViewController(pageViewController, animated: false)
    }
    
    
    func setupLeftMenuButton() {
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: #selector(leftDrawerButtonPress(_:)))
        self.navigationItem.setLeftBarButton(leftDrawerButton, animated: true)
    }
    

    // MARK: - Button Handlers
    
    func leftDrawerButtonPress(_ sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }

    func doubleTap(_ gesture: UITapGestureRecognizer) {
        self.evo_drawerController?.bouncePreview(for: .left, completion: nil)
    }
}
