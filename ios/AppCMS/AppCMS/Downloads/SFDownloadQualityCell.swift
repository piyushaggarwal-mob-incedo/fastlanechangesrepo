//
//  SFDownloadQualityCell.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/25/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFDownloadQualityCell: UITableViewCell {
    var title:SFLabel?
    var btnOption:SFButton?
    var tableComponents:Array<Any> = []
    var relativeViewFrame:CGRect?
    var cellRowValue:Int = 0
    var gridObject:SFQualityObject?
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

    //MARK: Creating CellView
    func createCellView() {

        btnOption = SFButton(frame: CGRect.zero)
        self.addSubview(btnOption!)
        btnOption?.isHidden = true

        title = SFLabel()
        self.addSubview(title!)
        title?.isHidden = true
    }

    //MARK: Create label view
    func createLabelView(labelObject:SFLabelObject) {
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        title?.isHidden = false
        title?.relativeViewFrame = relativeViewFrame!
        title?.labelObject = labelObject
        title?.text = gridObject?.title.replacingOccurrences(of: "_", with: "")
        title?.labelLayout = labelLayout
        title?.createLabelView()
        title?.font = UIFont(name: (title?.font.fontName)!, size: (title?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())

        if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
            title?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
        }
    }

    //MARK: Create Button view
    func createButtonView(buttonObject:SFButtonObject) {
        btnOption?.isHidden = false
        btnOption?.buttonObject = buttonObject
        btnOption?.relativeViewFrame = relativeViewFrame!
        
        let buttonImageViewSelected: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "radio-filled.png"))
        let buttonImageViewNormal: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "radio-unfilled.png"))
        
        btnOption?.setImage(buttonImageViewNormal.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnOption?.setImage(buttonImageViewSelected.image?.withRenderingMode(.alwaysTemplate), for: .selected)
        btnOption?.imageView?.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.themeFontColor ?? AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")

        btnOption?.isUserInteractionEnabled = false
        btnOption?.isSelected = (gridObject?.isSelected)!
    }

    //MARK: Update Cell components
    //Reusing it in tableview cell to update cell contents
    func updateGridSubView() {

        for cellComponent in tableComponents {

            if cellComponent is SFLabelObject {

                createLabelView(labelObject: cellComponent as! SFLabelObject)
            }

            else if cellComponent is SFButtonObject {

                createButtonView(buttonObject: cellComponent as! SFButtonObject)
            }
        }
    }
    //MARK: Update Cell subview frames
    func updateCellSubViewsFrame() {

        for subView in self.subviews {

            if subView is SFLabel {

                updateLabelView(label: subView as! SFLabel)
            }

            else if subView is SFButton {

                updateButtonView(button: subView as! SFButton)
            }
        }
    }

    //MARK: Update label view
    func updateLabelView(label:SFLabel) {

        if label.labelObject != nil {

            let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!)

            label.relativeViewFrame = relativeViewFrame!
            label.labelLayout = labelLayout
            label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
//            label.changeFrameWidth(width: label.frame.size.width * Utility.getBaseScreenWidthMultiplier())
            label.changeFrameHeight(height: label.frame.size.height * Utility.getBaseScreenHeightMultiplier())

            if labelLayout.height != nil {
                label.changeFrameYAxis(yAxis: ceil(label.frame.origin.y + (label.frame.size.height - CGFloat(labelLayout.height!))))
            }
        }
    }

    //MARK: Update Button view frame
    func updateButtonView(button:SFButton) {

        if button.buttonObject != nil {

            let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: button.buttonObject!)

            button.relativeViewFrame = relativeViewFrame!
            button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)

            button.changeFrameWidth(width: button.frame.size.width * Utility.getBaseScreenWidthMultiplier())
            button.changeFrameHeight(height: button.frame.size.height * Utility.getBaseScreenHeightMultiplier())

            if buttonLayout.height != nil {
                button.changeFrameYAxis(yAxis: ceil(button.frame.origin.y + (button.frame.size.height - CGFloat(buttonLayout.height!))))
            }
        }
    }

    //MARK: Layout subview method
    override func layoutSubviews() {

        relativeViewFrame?.size.width = UIScreen.main.bounds.width
        updateCellSubViewsFrame()
    }
}
