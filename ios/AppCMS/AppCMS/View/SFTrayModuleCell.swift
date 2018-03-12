//
//  SFTrayModuleCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 08/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol CollectionGridViewDelegate1:NSObjectProtocol {
    
    @objc func didSelectVideo(gridObject:SFGridObject?) -> Void
    @objc optional func collectionViewDidScroll(scrollView:UIScrollView, offsetValue:Int)
}

class SFTrayModuleCell: UITableViewCell, UICollectionViewDelegate,UICollectionViewDataSource {

    var trayObject:SFTrayObject?
    var collectionGrid:UICollectionView?
    var collectionGridObject:SFCollectionGridObject?
    var relativeViewFrame:CGRect?
    var moduleAPIObject:SFModuleObject?
    weak var delegate:CollectionGridViewDelegate1?
    var isFromSearch:Bool = false
    var trayTitle:SFLabel?
    var trayTitleSeparatorView:SFSeparatorView?
    var offSetValue:Int?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        createCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func createCellView() {
        
        createLabelView()
        createSeparatorView()
        createGridView()
    }
    
    
    //MARK: Creation of Label View
    func createLabelView() {
        
        trayTitle = SFLabel(frame: CGRect.zero)
        self.contentView.addSubview(trayTitle!)
    }
    
    
    //MARK: Creation of Separtor View
    func createSeparatorView() {
        
        trayTitleSeparatorView = SFSeparatorView(frame: CGRect.zero)
        self.contentView.addSubview(trayTitleSeparatorView!)
    }
    
    
    //MARK: Creation of Grid View
    func createGridView() {
        
        let flowLayout:SFCollectionGridFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: 100.0, height: 100.0), isHorizontalScroll: true, gridPadding: 5.0)
        
        collectionGrid = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 170), collectionViewLayout: flowLayout)
        #if os(iOS)
            collectionGrid?.register(SFCollectionGridCell.self, forCellWithReuseIdentifier: "Grids")
        #else
            collectionGrid?.register(SFCollectionGridCell_tvOS.self, forCellWithReuseIdentifier: "Grids")
        #endif
        collectionGrid?.delegate = self
        collectionGrid?.dataSource = self
        collectionGrid?.backgroundColor = UIColor.clear
        collectionGrid?.clipsToBounds = false
        collectionGrid?.showsVerticalScrollIndicator = false
        collectionGrid?.showsHorizontalScrollIndicator = false
        self.contentView.addSubview(collectionGrid!)
        self.contentView.sendSubview(toBack: collectionGrid!)
    }
    
    
    //MARK: CollectionView Delegates
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return moduleAPIObject != nil ? (moduleAPIObject?.moduleData?.count)! : 0
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        #if os(iOS)
            let gridCell:SFCollectionGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Grids", for: indexPath) as! SFCollectionGridCell
        #else
            let gridCell:SFCollectionGridCell_tvOS = collectionView.dequeueReusableCell(withReuseIdentifier: "Grids", for: indexPath) as! SFCollectionGridCell_tvOS
        #endif
        gridCell.gridComponents = (collectionGridObject?.trayComponents)!
        gridCell.thumbnailImageType = trayObject?.trayImageType
        gridCell.gridObject = moduleAPIObject?.moduleData?[indexPath.row] as? SFGridObject
        gridCell.updateGridSubViewFrames()
        gridCell.offSetValue = offSetValue
        
        return gridCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if delegate != nil && (delegate?.responds(to: #selector(CollectionGridViewDelegate.didSelectVideo(gridObject:))))! {
            
            let gridObject = moduleAPIObject?.moduleData?[indexPath.row] as? SFGridObject
            delegate?.didSelectVideo(gridObject: gridObject)
        }
    }
    

    func updateCellView() {
        
        for component:Any in (trayObject?.trayComponents)! {
            
            if component is SFLabelObject {
                
                updateLabelView(labelObject: component as! SFLabelObject)
            }
            else if component is SFCollectionGridObject {
                
                collectionGridObject = component as? SFCollectionGridObject
                updateGridView()
            }
            else if component is SFSeparatorViewObject {
                
                updateSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
            }
        }
    }
    
    
    //MARK: Creation of Label View
    func updateLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        if labelObject.key == "trayTitle" {
            
            trayTitle?.labelObject = labelObject
            trayTitle?.labelLayout = labelLayout
            
            trayTitle?.text = moduleAPIObject?.moduleTitle?.uppercased()
            
            if isFromSearch {
                
                trayTitle?.text = "Search Results"
            }
        }
        trayTitle?.createLabelView()
    }

    
    //MARK: Creation of Separtor View
    func updateSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        trayTitleSeparatorView?.separtorViewObject = separatorViewObject
    }
    
    
    //MARK: Creation of Grid View
    func updateGridView() {
        
        let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)

        let collectionViewFlowLayout:SFCollectionGridFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!), height: CGFloat(collectionGridLayout.gridHeight!)), isHorizontalScroll: (collectionGridObject?.isHorizontalScroll)!, gridPadding: collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0)
        collectionGrid?.collectionViewLayout = collectionViewFlowLayout

        updateCollectionView(collectionGridLayout: collectionGridLayout)
    }
    
    
    func updateCollectionView(collectionGridLayout:LayoutObject) {
        
        #if os(iOS)
            collectionGrid?.isPagingEnabled = collectionGridObject?.supportPagination != nil ? (collectionGridObject?.supportPagination)! : false
        #endif
    }
    
    //MARK: update the frame for the collection view
    override func layoutSubviews() {
        
        relativeViewFrame?.size.width = UIScreen.main.bounds.size.width
        
        for subview:Any in self.contentView.subviews {
            
            if subview is SFLabel {
                
                let label:SFLabel = subview as! SFLabel
                label.relativeViewFrame = relativeViewFrame
                label.initialiseLabelFrameFromLayout(labelLayout: Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!))
            }
            else if subview is UICollectionView {
                
                let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
                
                collectionGrid?.frame = Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!)
                collectionGrid?.setContentOffset((collectionGrid?.contentOffset)!, animated: false)
            }
            else if subview is SFSeparatorView {
                
                let separatorView:SFSeparatorView = subview as! SFSeparatorView
                separatorView.relativeViewFrame = relativeViewFrame
                separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject:separatorView.separtorViewObject!))
            }
        }
    }

    
    //MARK: Scroll view delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (delegate != nil) && (delegate?.responds(to: #selector(CollectionGridViewDelegate1.collectionViewDidScroll(scrollView:offsetValue:))))! {
            
            delegate?.collectionViewDidScroll!(scrollView: scrollView, offsetValue: offSetValue!)
        }
    }
}
