//
//  SearchContainerViewController_tvOS.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 11/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SearchContainerViewController_tvOS: UISearchContainerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userInfo = [ "value" : true ]
        NotificationCenter.default.post(name: Notification.Name("ToggleMenuBarInteraction"), object: nil , userInfo : userInfo )

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
}
