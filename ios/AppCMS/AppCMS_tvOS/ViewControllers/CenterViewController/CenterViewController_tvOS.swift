//
//  CenterViewController_tvOS.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 29/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class CenterViewController_tvOS: UIViewController {

    var navigationItemsArray : Array<PageTuple>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateViewControllerWithViewController(viewController: UIViewController) {

        self.navigationController?.popToRootViewController(animated: false)
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    func ignoreMenu(presses: Set<NSObject>) -> Bool {
        return (presses.first! as! UIPress).type == .menu
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if self.ignoreMenu(presses: presses) {
            super.pressesBegan(presses, with: event)
        }
    }

}
