//
//  CollectionGridView_tvOS.swift
//  AppCMS
//
//  Created by Rajni Pathak on 01/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol PlanCollectionGridViewDelegate:NSObjectProtocol {

    @objc optional func selectedPlanClicked(paymentModelObject:PaymentModel)
    @objc optional func updateCancelButtonFor(hasAnyPlanSelected: Bool)
}

class PlanCollectionGridView_tvOS: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SFCollectionGridCellDelegate {

    var moduleObject:AnyObject?
    private var collectionGrid:UICollectionView?
    private var collectionGridObject:SFCollectionGridObject?
    var relativeViewFrame:CGRect?
    var moduleAPIObject:SFModuleObject?
    weak var delegate:PlanCollectionGridViewDelegate?
    private var isPlanSelectedForConfirmation:Bool = false
    var isVeriticalCollectionView:Bool = false

    private var cellModuleDict:Dictionary<String, AnyObject> = [:]
    private var plansModuleArray:Array<Any> = []
    
    init(moduleObject:AnyObject, moduleAPIObject:SFModuleObject) {
        self.moduleObject = moduleObject
        self.moduleAPIObject = moduleAPIObject
        self.plansModuleArray = (self.moduleAPIObject?.moduleData!)!
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func createSubViews() {
        var cellComponents:Array<Any> = []
        if moduleObject is SubscriptionViewObject_tvOS {
            cellComponents = (moduleObject as! SubscriptionViewObject_tvOS).components
        }
        for component:Any in cellComponents {
            if component is SFCollectionGridObject {
                collectionGridObject = component as? SFCollectionGridObject
                createGridView()
            }
        }
    }

    //MARK: Creation of Grid View
    private func createGridView() {
        let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
        createCollectionView(collectionGridLayout: collectionGridLayout)
    }
    
    private func getCollectionViewFlowLayoutEdgeInsets(collectionGridLayout: LayoutObject) -> SFCollectionGridFlowLayout{
        var collectionViewFlowLayout:SFCollectionGridFlowLayout?
        if moduleObject is SubscriptionViewObject_tvOS {
            collectionViewFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!), height: CGFloat(collectionGridLayout.gridHeight!)), isHorizontalScroll: !self.isVeriticalCollectionView, gridPadding: (collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0))
            
            let productCount = Float(self.plansModuleArray.count)
            if (moduleObject as! SubscriptionViewObject_tvOS).moduleType == "AC SelectPlan 01" || (moduleObject as! SubscriptionViewObject_tvOS).moduleTitle == "AC SelectPlan 01" {
                let totalCellWidth = Float(collectionGridLayout.gridWidth!) * productCount
                let totalSpacingWidth = Float(collectionGridLayout.trayPadding!) * (productCount - 1)
                let sideInset = (relativeViewFrame!.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
                if(sideInset > 0){
                    collectionViewFlowLayout?.sectionInset = UIEdgeInsetsMake(0, sideInset, 0, sideInset)
                }
            }
            else{
                let totalCellHeight = Float(collectionGridLayout.gridHeight!) * productCount
                let totalSpacingHeight = Float(collectionGridLayout.trayPadding!) * (productCount - 1)
                let totalCellWidth = Float(collectionGridLayout.gridWidth!)
                let sideInset = (relativeViewFrame!.height - CGFloat(totalCellHeight + totalSpacingHeight)) / 2
                let leftInset = (relativeViewFrame!.width - CGFloat(totalCellWidth))
                collectionViewFlowLayout?.sectionInset = UIEdgeInsetsMake(0, leftInset, 0, 0)
                if(sideInset > 0){
                    let leftRightInset = (relativeViewFrame!.width - CGFloat(totalCellWidth)) / 2
                    collectionViewFlowLayout?.sectionInset = UIEdgeInsetsMake(sideInset, leftRightInset, sideInset, leftRightInset)
                }
            }
            
        }
        return collectionViewFlowLayout!
    }
    
    private func createCollectionView(collectionGridLayout:LayoutObject) {
       let collectionViewFlowLayout = getCollectionViewFlowLayoutEdgeInsets(collectionGridLayout: collectionGridLayout)
        collectionGrid = UICollectionView(frame: relativeViewFrame!, collectionViewLayout: collectionViewFlowLayout)
        collectionGrid?.isScrollEnabled = true
        collectionGrid?.register(SFProductListViewCell_tvOS.self, forCellWithReuseIdentifier: "ProductListCell")
        collectionGrid?.register(SFProductGridViewCell_tvOS.self, forCellWithReuseIdentifier: "ProductGridCell")
        collectionGrid?.delegate = self
        collectionGrid?.dataSource = self
        collectionGrid?.backgroundColor = UIColor.clear
        collectionGrid?.clipsToBounds = true
        if #available(tvOS 11.0, *) {
            self.collectionGrid?.contentInsetAdjustmentBehavior = .never
            self.collectionGrid?.contentInset = UIEdgeInsets.zero
        }
        //collectionGrid?.changeFrameWidth(width: 539)
        collectionGrid?.showsVerticalScrollIndicator = false
        collectionGrid?.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionGrid!)
        self.view.sendSubview(toBack: collectionGrid!)
    }
    
    //MARK: CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.plansModuleArray.count)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if (moduleObject as! SubscriptionViewObject_tvOS).moduleType == "AC SelectPlan 01" || (moduleObject as! SubscriptionViewObject_tvOS).moduleTitle == "AC SelectPlan 01" {
            var productListCell:SFProductListViewCell_tvOS?
            productListCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductListCell", for: indexPath) as? SFProductListViewCell_tvOS
            productListCell?.cellComponents = (collectionGridObject?.trayComponents)!
            productListCell?.paymentModelObject = self.plansModuleArray[indexPath.row] as? PaymentModel
            productListCell?.cellRowValue = indexPath.row
            productListCell?.updateGridSubView()
            productListCell?.layer.borderWidth = 2.0
            return productListCell!
        }
        else {
            var productGridCell:SFProductGridViewCell_tvOS?
            productGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductGridCell", for: indexPath) as? SFProductGridViewCell_tvOS
            
            productGridCell?.cellComponents = (collectionGridObject?.trayComponents)!
            productGridCell?.paymentModelObject = moduleAPIObject?.moduleData?[indexPath.row] as? PaymentModel
            productGridCell?.cellRowValue = indexPath.row
            productGridCell?.updateGridSubView()
            
            return productGridCell!
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (moduleObject as! SubscriptionViewObject_tvOS).moduleType == "AC SelectPlan 01" || (moduleObject as! SubscriptionViewObject_tvOS).moduleTitle == "AC SelectPlan 01" {
            if isPlanSelectedForConfirmation == false{
                isPlanSelectedForConfirmation = true
                var selectedPlan:Array<Any> = []
                selectedPlan.insert(self.plansModuleArray[indexPath.row] , at: 0)
                self.plansModuleArray.removeAll()
                self.plansModuleArray = selectedPlan as Array<AnyObject>
                let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
                collectionView.reloadData()
                collectionView.setCollectionViewLayout(getCollectionViewFlowLayoutEdgeInsets(collectionGridLayout: collectionGridLayout), animated: false)
                if (delegate?.responds(to: #selector(PlanCollectionGridViewDelegate.updateCancelButtonFor(hasAnyPlanSelected:))))! {
                    delegate?.updateCancelButtonFor!(hasAnyPlanSelected: true)
                }
            }
            else{
                if moduleObject is SubscriptionViewObject_tvOS {
                    if delegate != nil {
                        let paymentModel:PaymentModel? = (self.plansModuleArray[indexPath.row]) as? PaymentModel
                        if paymentModel != nil {
                            if (delegate?.responds(to: #selector(PlanCollectionGridViewDelegate.selectedPlanClicked(paymentModelObject:))))! {
                                delegate?.selectedPlanClicked!(paymentModelObject: paymentModel!)
                            }
                        }
                    }
                }
            }
        }
        else{
            if moduleObject is SubscriptionViewObject_tvOS {
                if delegate != nil {
                    let paymentModel:PaymentModel? = (self.plansModuleArray[indexPath.row]) as? PaymentModel
                    if paymentModel != nil {
                        if (delegate?.responds(to: #selector(PlanCollectionGridViewDelegate.selectedPlanClicked(paymentModelObject:))))! {
                            delegate?.selectedPlanClicked!(paymentModelObject: paymentModel!)
                        }
                    }
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if (moduleObject as! SubscriptionViewObject_tvOS).moduleType == "AC SelectPlan 01" || (moduleObject as! SubscriptionViewObject_tvOS).moduleTitle == "AC SelectPlan 01" {
            if let previousFocusView = context.previouslyFocusedView as? SFProductListViewCell_tvOS {
                let planCell:SFProductListViewCell_tvOS = previousFocusView
                if isPlanSelectedForConfirmation == true{
                    planCell.updatePlanSelectorButtonViewForConfirmation(selectionStatus: false)
                }
                else{
                    planCell.updatePlanSelectorButtonViewOnSelectionStatus(selectionStatus: false)
                }
            }
            
            if let nextFocusView = context.nextFocusedView as? SFProductListViewCell_tvOS {
                let planCell:SFProductListViewCell_tvOS = nextFocusView
                if isPlanSelectedForConfirmation == true{
                    planCell.updatePlanSelectorButtonViewForConfirmation(selectionStatus: true)
                }
                else{
                    planCell.updatePlanSelectorButtonViewOnSelectionStatus(selectionStatus: true)
                }
            }
        }
        else{
            if let previousFocusView = context.previouslyFocusedView as? SFProductGridViewCell_tvOS {
                let planCell:SFProductGridViewCell_tvOS = previousFocusView
                    planCell.updatePlanSelectorViewOnSelectionStatus(selectionStatus: false)
            }
            
            if let nextFocusView = context.nextFocusedView as? SFProductGridViewCell_tvOS {
                let planCell:SFProductGridViewCell_tvOS = nextFocusView
                    planCell.updatePlanSelectorViewOnSelectionStatus(selectionStatus: true)
            }
        }
       
    }



    func reloadPlansOnCancelButtonClick(){
        if(self.moduleAPIObject?.moduleData != nil){
            if(self.plansModuleArray.count <= (self.moduleAPIObject?.moduleData?.count)!){
                self.plansModuleArray.removeAll()
                self.plansModuleArray = (self.moduleAPIObject?.moduleData!)!
                let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
                collectionGrid?.reloadData()
                collectionGrid?.setCollectionViewLayout(getCollectionViewFlowLayoutEdgeInsets(collectionGridLayout: collectionGridLayout), animated: false)
                if isPlanSelectedForConfirmation == true{
                    isPlanSelectedForConfirmation = false
                }
                if (delegate?.responds(to: #selector(PlanCollectionGridViewDelegate.updateCancelButtonFor(hasAnyPlanSelected:))))! {
                    delegate?.updateCancelButtonFor!(hasAnyPlanSelected: false)
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
