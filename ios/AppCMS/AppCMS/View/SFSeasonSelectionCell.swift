//
//  SFSeasonSelectionCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 28/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFSeasonSelectionCell: UITableViewCell {

    @IBOutlet weak var seasonSelectionImage: UIImageView!
    @IBOutlet weak var seasonName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    //MARK: Method to update cell content
    func updateCellContent(seasonObject:SFSeason, isCellSelected:Bool, seasonNumber:Int) {
        
        if let seasonTitle = seasonObject.title {
            
            self.seasonName.text = seasonTitle
        }
        else {
            
            self.seasonName.text = "Season \(seasonNumber)"
        }
        
        if isCellSelected {
            
            self.seasonName.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.pageTitleColor ?? "ffffff")
        }
        else {
            
            self.seasonName.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        }
        
        seasonSelectionImage.isHidden = !isCellSelected
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
