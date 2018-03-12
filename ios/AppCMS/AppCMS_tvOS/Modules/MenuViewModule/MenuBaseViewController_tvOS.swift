//
//  MenuBaseViewController_tvOS.swift
//  AppCMS
//
//  Created by Rajni Pathak on 03/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//



import UIKit

protocol MenuViewControllerDelegate: class {
    func menuSelected(menuSelectedAtIndex: Int)
}

class MenuBaseViewController_tvOS: UIViewController{
    
    //MARK: - Delegate property
    //Create  delegate property of MenuViewControllerDelegate.
    weak var delegate:MenuViewControllerDelegate?

    
    //MARK: - Make User Interaction enable/disable for collectionView
    func toggleUserInteraction(_ value : Bool) -> Void {
        self.view?.isUserInteractionEnabled = value
    }
    
    /// Method meant to be overridden.
    func fetchPageModuleList() {
        
    }
}

