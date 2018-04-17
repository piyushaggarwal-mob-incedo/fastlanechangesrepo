//
//  SFVerticalArticleGridViewController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 25/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import UIKit

class SFVerticalArticleGridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var verticalArticleViewObject:SFVerticalArticleViewObject
    var collectionGrid:UICollectionView?
    var relativeViewFrame:CGRect?
    var moduleAPIObject:SFModuleObject?
    var collectionGridObject:SFCollectionGridObject?

    init(verticalArticleViewObject:SFVerticalArticleViewObject) {
        
        self.verticalArticleViewObject = verticalArticleViewObject
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Method to create subview
    func createSubViews() {
        
        for component in verticalArticleViewObject.components {
            
            if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject)
            }
            else if component is SFSeparatorViewObject {
                
                createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
            }
            else if component is SFCollectionGridObject {
                
                collectionGridObject = component as? SFCollectionGridObject
                createCollectionView(collectionGridObject: collectionGridObject!)
            }
        }
    }
    
    //MARK: Method to create label
    private func createLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.relativeViewFrame = relativeViewFrame!
        label.labelLayout = labelLayout
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        
        if labelObject.key == "trayTitle" {
            
            label.text = moduleAPIObject?.moduleTitle?.uppercased()
        }
        
        self.view.addSubview(label)
        label.createLabelView()
        
        if labelObject.key == "trayTitle" {
            
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? AppConfiguration.sharedAppConfiguration.appPageTitleColor ?? "ffffff")
        }
    }
    
    //MARK: Method to create separator view
    private func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        let separatorView:SFSeparatorView = SFSeparatorView(frame: CGRect.zero)
        separatorView.separtorViewObject = separatorViewObject
        separatorView.relativeViewFrame = relativeViewFrame!
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject))
        self.view.addSubview(separatorView)
    }
    
    //MARK: Method to create collection view
    private func createCollectionView(collectionGridObject:SFCollectionGridObject) {
     
        let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject)
        let collectionViewFlowLayout:SFCollectionGridFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!) * Utility.getBaseScreenWidthMultiplier(), height: CGFloat(collectionGridLayout.gridHeight!) * Utility.getBaseScreenHeightMultiplier()), isHorizontalScroll: collectionGridObject.isHorizontalScroll ?? false, gridPadding: collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0)
        
        collectionGrid = UICollectionView(frame: Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!), collectionViewLayout: collectionViewFlowLayout)
        collectionGrid?.changeFrameHeight(height: (collectionGrid?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
        collectionGrid?.changeFrameYAxis(yAxis: (collectionGrid?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
        collectionGrid?.isPagingEnabled = collectionGridObject.supportPagination != nil ? (collectionGridObject.supportPagination)! : false
        collectionGrid?.register(SFVerticalArticleGrid.self, forCellWithReuseIdentifier: "Grids")
        collectionGrid?.delegate = self
        collectionGrid?.isScrollEnabled = false
        collectionGrid?.dataSource = self
        collectionGrid?.backgroundColor = UIColor.clear
        collectionGrid?.clipsToBounds = true
        collectionGrid?.showsVerticalScrollIndicator = false
        collectionGrid?.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionGrid!)
        self.view.sendSubview(toBack: collectionGrid!)
    }
    
    //MARK: Collection View Delegates
    //MARK: CollectionView Delegates
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (moduleAPIObject?.moduleData?.count)!
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let gridCell:SFVerticalArticleGrid = collectionView.dequeueReusableCell(withReuseIdentifier: "Grids", for: indexPath) as! SFVerticalArticleGrid
        gridCell.gridComponents = (collectionGridObject?.trayComponents)!
        gridCell.thumbnailImageType = verticalArticleViewObject.settings?.thumbnailType
        gridCell.gridObject = moduleAPIObject?.moduleData?[indexPath.row] as? SFGridObject
//        gridCell.collectionGridCellDelegate = self
        gridCell.updateGridSubviews()
        
        return gridCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        if delegate != nil && (delegate?.responds(to: #selector(VerticalCollectionGridDelegate.didSelectVideo(gridObject:))))! {
//
//            let gridObject = moduleAPIObject?.moduleData?[indexPath.row] as? SFGridObject
//            delegate?.didSelectVideo(gridObject: gridObject)
//        }
    }

    
    //MARK: Need to reuse this delegate
//    @available(iOS 6.0, *)
//    optional public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
//
//    @available(iOS 6.0, *)
//    optional public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
//
//    @available(iOS 6.0, *)
//    optional public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    
    //MARK: Orientation delegate
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
//        if !Constants.IPHONE {
//
//            let rowHeight:CGFloat = CGFloat(Utility.sharedUtility.calculateCellHeightFromCellComponents(trayObject: verticalArticleViewObject!, noOfData: Float(moduleAPIObject?.moduleData?.count ?? 0))) * Utility.getBaseScreenHeightMultiplier()
//
//            self.view.changeFrameHeight(height: rowHeight)
//            self.view.changeFrameWidth(width: UIScreen.main.bounds.size.width)
//
//            relativeViewFrame = self.view.frame
//
//            for subview:Any in self.view.subviews {
//
//                if subview is SFLabel {
//
//                    let label:SFLabel = subview as! SFLabel
//                    label.relativeViewFrame = relativeViewFrame
//                    label.initialiseLabelFrameFromLayout(labelLayout: Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!))
//                }
//                else if subview is UICollectionView {
//
//                    let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
//
//                    let collectionViewFlowLayout:SFCollectionGridFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!) * Utility.getBaseScreenWidthMultiplier(), height: CGFloat(collectionGridLayout.gridHeight!) * Utility.getBaseScreenHeightMultiplier()), isHorizontalScroll: (collectionGridObject?.isHorizontalScroll)!, gridPadding: collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0)
//
//                    collectionGrid?.collectionViewLayout = collectionViewFlowLayout
//                    collectionGrid?.frame = Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!)
//                    collectionGrid?.changeFrameHeight(height: (collectionGrid?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
//                    collectionGrid?.changeFrameYAxis(yAxis: (collectionGrid?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
//
//                    self.collectionGrid?.reloadData()
//                }
//                else if subview is SFSeparatorView {
//
//                    let separatorView:SFSeparatorView = subview as! SFSeparatorView
//                    separatorView.relativeViewFrame = relativeViewFrame
//                    separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject:separatorView.separtorViewObject!))
//                }
//            }
//        }
    }
}
