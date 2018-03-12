//
//  ListViewController.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 13/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol ListViewControllerDelegate: NSObjectProtocol
{
    @objc optional func didListViewSelected(navigationItem:NavigationItem?) -> Void
}

class ListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var relativeViewFrame:CGRect?
    var moduleObject:AnyObject?
    var subNavItemsArray:Array<NavigationItem>?
    weak var delegate:ListViewControllerDelegate?
    private var isCollectionGridScrollEnabled:Bool = false
    private var isVeriticalCollectionView:Bool = true
    private var cellModuleDict:Dictionary<String, AnyObject> = [:]
    private var collectionGridObject:SFCollectionGridObject?
    
    //MARK: View initializers methods
    init(moduleObject:AnyObject, subNavItemsArray:Array<NavigationItem>) {
        
        self.moduleObject = moduleObject
        self.subNavItemsArray = subNavItemsArray
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    //MARK: Method to create subview
    func createSubViews() {
        
        var cellComponents:Array<Any> = []
        
        if moduleObject is SFListViewObject {
            
            cellComponents = (moduleObject as! SFListViewObject).listViewComponents
        }
        
        for component:Any in cellComponents {
            
            if component is SFCollectionGridObject {
                
                collectionGridObject = component as? SFCollectionGridObject
                createGridView()
            }
        }
    }
    
    
    //MARK: Creation of Grid View
    func createGridView() {
        
        let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
        createCollectionView(collectionGridLayout: collectionGridLayout)
    }
    
    
    func createCollectionView(collectionGridLayout:LayoutObject) {
        
        var collectionViewFlowLayout:SFCollectionGridFlowLayout?
        
        if moduleObject is SFListViewObject {
            
            collectionViewFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!) * Utility.getBaseScreenWidthMultiplier(), height: CGFloat(collectionGridLayout.gridHeight!) * Utility.getBaseScreenHeightMultiplier()), isHorizontalScroll: self.isVeriticalCollectionView, gridPadding: (collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0) * Utility.getBaseScreenHeightMultiplier())
        }
        
        let collectionGrid = UICollectionView(frame: Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!), collectionViewLayout: collectionViewFlowLayout!)
        
        collectionGrid.changeFrameHeight(height: collectionGrid.frame.size.height + 10)
        collectionGrid.changeFrameYAxis(yAxis: collectionGrid.frame.origin.y * Utility.getBaseScreenHeightMultiplier())
        collectionGrid.isScrollEnabled = self.isCollectionGridScrollEnabled
        
        collectionGrid.isPagingEnabled = collectionGridObject?.supportPagination != nil ? (collectionGridObject?.supportPagination)! : false
        collectionGrid.register(SFListViewCell.self, forCellWithReuseIdentifier: "ListViewCell")
        collectionGrid.delegate = self
        collectionGrid.dataSource = self
        collectionGrid.backgroundColor = UIColor.clear
        collectionGrid.clipsToBounds = true
        collectionGrid.showsVerticalScrollIndicator = false
        collectionGrid.showsHorizontalScrollIndicator = false
        
        self.view.addSubview(collectionGrid)
    }
    
    
    //MARK: CollectionView Delegates
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var rowCount:Int = 0
        
        if moduleObject is SFListViewObject {
            
            rowCount = subNavItemsArray?.count ?? 0
        }
        
        return rowCount
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if moduleObject is SFListViewObject {
            
            var listViewCell:SFListViewCell? = cellModuleDict["\(String(indexPath.row))"] as? SFListViewCell
            
            if listViewCell == nil {
                
                listViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListViewCell", for: indexPath) as? SFListViewCell
                
                listViewCell?.cellComponents = (collectionGridObject?.trayComponents)!
                
                if let navItem = subNavItemsArray?[indexPath.row] {
                    
                    listViewCell?.navItem = navItem
                    listViewCell?.updateCellSubView()
                }
                
                cellModuleDict["\(String(indexPath.row))"] = listViewCell!
            }
            
            return listViewCell!
        }
        else {
            
            let tempCell:UICollectionViewCell = UICollectionViewCell(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            
            return tempCell
        }
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if moduleObject is SFListViewObject {
            
            if let navItem = subNavItemsArray?[indexPath.row] {
                
                if delegate != nil {
                    
                    if (delegate?.responds(to: #selector(ListViewControllerDelegate.didListViewSelected(navigationItem:))))! {
                        
                        delegate?.didListViewSelected!(navigationItem: navItem)
                    }
                }
            }
        }
    }


    //MARK: View orientation delegates
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if !Constants.IPHONE {
            
            relativeViewFrame?.size.width = UIScreen.main.bounds.size.width
            
            for subview:Any in self.view.subviews {
                
                if subview is UICollectionView {
                    
                    let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
                    let collectionGrid = subview as! UICollectionView

                    let collectionViewFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!) * Utility.getBaseScreenWidthMultiplier(), height: CGFloat(collectionGridLayout.gridHeight!) * Utility.getBaseScreenHeightMultiplier()), isHorizontalScroll: self.isVeriticalCollectionView, gridPadding: (collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0) * Utility.getBaseScreenHeightMultiplier())
                    
                    collectionGrid.collectionViewLayout = collectionViewFlowLayout
                    collectionGrid.frame = Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!)
                    collectionGrid.changeFrameHeight(height: collectionGrid.frame.size.height + 10)
                    collectionGrid.changeFrameYAxis(yAxis: collectionGrid.frame.origin.y * Utility.getBaseScreenHeightMultiplier())
                }
            }
        }
    }
    
    //MARK: Memory warning method
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
