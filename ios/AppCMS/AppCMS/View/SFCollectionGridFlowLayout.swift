//
//  SFCollectionGridFlowLayout.swift
//  AppCMS
//
//  Created by Gaurav Vig on 24/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFCollectionGridFlowLayout: UICollectionViewFlowLayout {

    init(gridItemSize:CGSize, isHorizontalScroll:Bool, gridPadding:CGFloat) {
        
        super.init()
        
        self.itemSize = gridItemSize
        self.minimumLineSpacing = gridPadding
        self.minimumInteritemSpacing = 1.0
        
        if isHorizontalScroll {
            self.scrollDirection = .horizontal
        }
        else {
            self.scrollDirection = .vertical
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
