//
//  CollectionGridViewController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 24/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol PlanCollectionGridViewDelegate:NSObjectProtocol {

    @objc optional func selectedPlanClicked(paymentModelObject:PaymentModel)
}

class PlanCollectionGridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SFCollectionGridCellDelegate, SFProductListViewDelegate {

    var moduleObject:AnyObject?
    var collectionGrid:UICollectionView?
    var collectionGridObject:SFCollectionGridObject?
    var relativeViewFrame:CGRect?
    var moduleAPIObject:SFModuleObject?
    weak var delegate:PlanCollectionGridViewDelegate?
    var isCollectionGridScrollEnabled:Bool = false
    var isVeriticalCollectionView:Bool = true
    var isAnyPlanSelected:Bool = false
    var cellModuleDict:Dictionary<String, AnyObject> = [:]

    
    init(moduleObject:AnyObject, moduleAPIObject:SFModuleObject) {
        
        self.moduleObject = moduleObject
        self.moduleAPIObject = moduleAPIObject
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func createSubViews() {
        
        var cellComponents:Array<Any> = []
        
        if moduleObject is SFProductListObject {
            
            cellComponents = (moduleObject as! SFProductListObject).components
        }
        else if moduleObject is SFProductFeatureListObject {
            
            cellComponents = (moduleObject as! SFProductFeatureListObject).components
        }
        
        for component:Any in cellComponents {
            
            if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject)
            }
            else if component is SFCollectionGridObject {
                
                collectionGridObject = component as? SFCollectionGridObject
                createGridView()
            }
            else if component is SFSeparatorViewObject {
                
                createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
            }
        }
    }

    
    //MARK: Creation of Label View
    func createLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.relativeViewFrame = relativeViewFrame!
        label.labelLayout = labelLayout
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        
        if labelObject.key == "title" {
            label.text = moduleAPIObject?.moduleTitle ?? ""
        }
        else if labelObject.key == "subTitle" {
            
            label.text = moduleAPIObject?.moduleDescription ?? ""
        }
        
        self.view.addSubview(label)
        label.createLabelView()
        
        if labelObject.key == "title" {
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
        
        label.font = UIFont(name: label.font.fontName, size: label.font.pointSize * Utility.getBaseScreenHeightMultiplier())
        label.changeFrameHeight(height: label.frame.size.height * Utility.getBaseScreenHeightMultiplier())
        label.changeFrameYAxis(yAxis: label.frame.origin.y * Utility.getBaseScreenHeightMultiplier())
    }
    
    
    //MARK: Creation of Separtor View
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        let separatorView:SFSeparatorView = SFSeparatorView(frame: CGRect.zero)
        separatorView.separtorViewObject = separatorViewObject
        separatorView.relativeViewFrame = relativeViewFrame!
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject))
        self.view.addSubview(separatorView)
    }
    
    
    //MARK: Creation of Grid View
    func createGridView() {
        
        let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
        createCollectionView(collectionGridLayout: collectionGridLayout)
    }
    
    
    func createCollectionView(collectionGridLayout:LayoutObject) {
        
        var collectionViewFlowLayout:SFCollectionGridFlowLayout?
        
        if moduleObject is SFProductListObject {
            
            collectionViewFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!) * Utility.getBaseScreenWidthMultiplier(), height: CGFloat(collectionGridLayout.gridHeight!) * Utility.getBaseScreenHeightMultiplier()), isHorizontalScroll: self.isVeriticalCollectionView, gridPadding: (collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0) * Utility.getBaseScreenHeightMultiplier())
        }
        else if moduleObject is SFProductFeatureListObject {
         
            collectionViewFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!) * Utility.getBaseScreenWidthMultiplier(), height: CGFloat(collectionGridLayout.gridHeight!)), isHorizontalScroll: self.isVeriticalCollectionView, gridPadding: collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0)
        }
        
        collectionGrid = UICollectionView(frame: Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!), collectionViewLayout: collectionViewFlowLayout!)
        
        if collectionGridLayout.yAxis != nil {
            
            collectionGrid?.changeFrameYAxis(yAxis: (collectionGrid?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
        }
        
//        if Constants.IPHONE {
        
//            collectionGrid?.changeFrameHeight(height: (collectionGrid?.frame.size.height)! - (CGFloat(collectionGridLayout.trayPadding ?? 0) * Utility.getBaseScreenHeightMultiplier())
//        }
        
        collectionGrid?.isScrollEnabled = self.isCollectionGridScrollEnabled
        
        if !Constants.IPHONE {
            
            if moduleObject is SFProductListObject {
                
                if (moduleObject as! SFProductListObject).type == "AC SelectPlan 01" || (moduleObject as! SFProductListObject).viewName == "AC SelectPlan 01" {
                    
                    let rowCount:Int = (moduleAPIObject?.moduleData?.count)!
                    let rowSize:CGFloat = CGFloat(rowCount) * ((collectionViewFlowLayout?.itemSize.width)!) + (rowCount > 1 ? CGFloat(rowCount - 1) * Utility.getBaseScreenHeightMultiplier() * (collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0) : 0.0)
                    
                    if ((collectionGrid?.frame.size.width)!) > rowSize {
                        
                        collectionGrid?.changeFrameXAxis(xAxis: (collectionGrid?.frame.origin.x)! + (((collectionGrid?.frame.size.width)!))/2 - rowSize/2)
                        collectionGrid?.changeFrameWidth(width: rowSize)
                        collectionGrid?.isScrollEnabled = false
                    }
                    
                    if ((collectionGrid?.frame.size.width)!) > rowSize - 5 {
                        
                        collectionGrid?.isScrollEnabled = false
                    }
                }
                else {
                    
                    collectionGrid?.changeFrameHeight(height: (collectionGrid?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
                }
            }
        }
        
        collectionGrid?.isPagingEnabled = collectionGridObject?.supportPagination != nil ? (collectionGridObject?.supportPagination)! : false
        collectionGrid?.register(SFProductListViewCell.self, forCellWithReuseIdentifier: "ProductListCell")
        collectionGrid?.register(SFProductGridViewCell.self, forCellWithReuseIdentifier: "ProductGridCell")
        collectionGrid?.register(SFProductFeatureListViewCell.self, forCellWithReuseIdentifier: "ProductFeatureListCell")
        collectionGrid?.delegate = self
        collectionGrid?.dataSource = self
        collectionGrid?.backgroundColor = UIColor.clear
        collectionGrid?.clipsToBounds = true
        collectionGrid?.showsVerticalScrollIndicator = false
        collectionGrid?.showsHorizontalScrollIndicator = false
        
        self.view.addSubview(collectionGrid!)
        self.view.sendSubview(toBack: collectionGrid!)
    }
    
    
    //MARK: CollectionView Delegates
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var rowCount:Int = 0
        
        if moduleObject is SFProductListObject {
            
            rowCount = (moduleAPIObject?.moduleData?.count)!
        }
        else if moduleObject is SFProductFeatureListObject {
            
            let productFeatureListObject = moduleObject as! SFProductFeatureListObject
            
            rowCount = productFeatureListObject.featureListArray.count
        }
        
        return rowCount
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if moduleObject is SFProductListObject {
            
            if (moduleObject as! SFProductListObject).type == "AC SelectPlan 01" || (moduleObject as! SFProductListObject).viewName == "AC SelectPlan 01" {
                
                var productListCell:SFProductListViewCell? = cellModuleDict["\(String(indexPath.row))"] as? SFProductListViewCell
                
                if productListCell == nil {
                    
                    productListCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductListCell", for: indexPath) as? SFProductListViewCell
                    
                    productListCell?.cellComponents = (collectionGridObject?.trayComponents)!
                    productListCell?.paymentModelObject = moduleAPIObject?.moduleData?[indexPath.row] as? PaymentModel
                    productListCell?.cellRowValue = indexPath.row
                    productListCell?.delegate = self
                    
                    if isAnyPlanSelected == false && indexPath.row == 0 {
                        
                        isAnyPlanSelected = true
                        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
                        productListCell?.planSelectionButton?.isSelected = true
                        productListCell?.updatePlanSelectorButtonViewOnSelectionStatus(selectionStatus: true)
                    }
                    
                    productListCell?.updateGridSubView()
                    productListCell?.layer.borderWidth = 2.0
                    
                    cellModuleDict["\(String(indexPath.row))"] = productListCell!
                }
                
                return productListCell!
            }
            else {
                
                var productGridCell:SFProductGridViewCell?
                
                productGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductGridCell", for: indexPath) as? SFProductGridViewCell
                
                productGridCell?.cellComponents = (collectionGridObject?.trayComponents)!
                productGridCell?.paymentModelObject = moduleAPIObject?.moduleData?[indexPath.row] as? PaymentModel
                productGridCell?.cellRowValue = indexPath.row
                productGridCell?.delegate = self
                
                productGridCell?.updateGridSubView()
                
                return productGridCell!
            }
        }
        else if moduleObject is SFProductFeatureListObject {
            
            let productFeatureListObject = moduleObject as! SFProductFeatureListObject
            
            let productFeatureListCell:SFProductFeatureListViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductFeatureListCell", for: indexPath) as! SFProductFeatureListViewCell
            
            productFeatureListCell.cellComponents = (collectionGridObject?.trayComponents)!
            productFeatureListCell.featureListModel = productFeatureListObject.featureListArray[indexPath.row]
            
            productFeatureListCell.updateGridSubView()

            return productFeatureListCell
        }
        else {
            
            let tempCell:UICollectionViewCell = UICollectionViewCell(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            
            return tempCell
        }
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if moduleObject is SFProductListObject {
            
            if (moduleObject as! SFProductListObject).type == "AC SelectPlan 01" || (moduleObject as! SFProductListObject).viewName == "AC SelectPlan 01" {
                
                let planCell:SFProductListViewCell = cellModuleDict["\(String(indexPath.row))"] as! SFProductListViewCell
                planCell.planSelectionButton?.isSelected = true
                planCell.updatePlanSelectorButtonViewOnSelectionStatus(selectionStatus: true)
                
            }
            else {
                
                let paymentModel:PaymentModel? = (moduleAPIObject?.moduleData![indexPath.row])! as? PaymentModel
                
                if paymentModel != nil {
                    
                    if (delegate?.responds(to: #selector(PlanCollectionGridViewDelegate.selectedPlanClicked(paymentModelObject:))))! {
                        
                        delegate?.selectedPlanClicked!(paymentModelObject: paymentModel!)
                    }
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if moduleObject is SFProductListObject {
            
            if (moduleObject as! SFProductListObject).type == "AC SelectPlan 01" || (moduleObject as! SFProductListObject).viewName == "AC SelectPlan 01" {
                
                let planCell:SFProductListViewCell = cellModuleDict["\(String(indexPath.row))"] as! SFProductListViewCell
                planCell.planSelectionButton?.isSelected = false
                planCell.updatePlanSelectorButtonViewOnSelectionStatus(selectionStatus: false)
            }
        }
    }
    
    
    //MARK:ScrollView Delegate Method
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    
    
    //MARK: View orientation delegates
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if !Constants.IPHONE {
            
            relativeViewFrame?.size.width = UIScreen.main.bounds.size.width
            
            for subview:Any in self.view.subviews {
                
                if subview is SFLabel {
                    
                    let label:SFLabel = subview as! SFLabel
                    label.relativeViewFrame = relativeViewFrame
                    label.initialiseLabelFrameFromLayout(labelLayout: Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!))
                    
                    label.changeFrameHeight(height: label.frame.size.height * Utility.getBaseScreenHeightMultiplier())
                    label.changeFrameYAxis(yAxis: label.frame.origin.y * Utility.getBaseScreenHeightMultiplier())
                }
                else if subview is UICollectionView {
                    
                    let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
                    collectionGrid?.frame = Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!)
                    
                    if collectionGridLayout.yAxis != nil {
                        
                        collectionGrid?.changeFrameYAxis(yAxis: (collectionGrid?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
                    }
                    
                    if !Constants.IPHONE {
                        
                        if moduleObject is SFProductListObject {
                            
                            if (moduleObject as! SFProductListObject).type == "AC SelectPlan 01" || (moduleObject as! SFProductListObject).viewName == "AC SelectPlan 01" {
                                
                                let rowCount:Int = (moduleAPIObject?.moduleData?.count)!
                                let rowSize:CGFloat = CGFloat(rowCount) * (CGFloat(collectionGridLayout.gridWidth!)) * Utility.getBaseScreenWidthMultiplier() + (rowCount > 1 ? CGFloat(rowCount - 1) * (collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0) : 0.0) * Utility.getBaseScreenWidthMultiplier()
                                
                                if ((collectionGrid?.frame.size.width)!) > rowSize {
                                    
                                    collectionGrid?.changeFrameXAxis(xAxis: (collectionGrid?.frame.origin.x)! + (((collectionGrid?.frame.size.width)!))/2 - rowSize/2)
                                    collectionGrid?.changeFrameWidth(width: rowSize)
                                }
                            }
                            else {
                                
                                collectionGrid?.changeFrameHeight(height: (collectionGrid?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
                            }
                        }
                    }
                }
                else if subview is SFSeparatorView {
                    
                    let separatorView:SFSeparatorView = subview as! SFSeparatorView
                    separatorView.relativeViewFrame = relativeViewFrame
                    separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject:separatorView.separtorViewObject!))
                }
            }
        }
    }
    
    
    //MARK: Collection Grid Cell Delegates
    func buttonClicked(button: UIButton, cellRowValue: Int) {
        
        if delegate != nil {
            
            let paymentModel:PaymentModel? = (moduleAPIObject?.moduleData![cellRowValue])! as? PaymentModel
            
            if paymentModel != nil {
                
                if (delegate?.responds(to: #selector(PlanCollectionGridViewDelegate.selectedPlanClicked(paymentModelObject:))))! {
                    
                    delegate?.selectedPlanClicked!(paymentModelObject: paymentModel!)
                }
            }
        }
    }
    
    
    //MARK: Memory Warning methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
