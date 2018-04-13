//
//  SeasonDropdownViewController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 28/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import Firebase

class SeasonDropdownViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var seasonArray:Array<SFSeason>?
    private var backButton:UIButton?
    private var titleLabel:UILabel?
    private var selectedSeasonNumber:Int?
    private var seasonSelectorTableView:UITableView?
    private let closeButtonDimension: CGFloat = 40.0 * Utility.getBaseScreenHeightMultiplier()

    /// Closure used as a callback for auto play. Acts as the interface between calling class and this class.
    var completionHandler : ((Bool, Int) -> Void)?
    
    init(seasonArray:Array<SFSeason>, selectedSeasonNumber:Int) {
        
        self.seasonArray = seasonArray
        self.selectedSeasonNumber = selectedSeasonNumber
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.createSubView()
        // Do any additional setup after loading the view.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.trackAnaylyticsEvent()
    }
    
    
    //MARK: Method to track analytics event
    private func trackAnaylyticsEvent() {
        
        let pageTitle = "Season Selector Screen"
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            FIRAnalytics.setScreenName(pageTitle, screenClass: nil)
        }
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.allowIDFACollection = true
        tracker.set(kGAIScreenName, value: pageTitle)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    //MARK: Method to create subviews
    private func createSubView() {
        
        self.createButtonView()
        self.createTitleView(minXAxis: backButton?.frame.maxX ?? 0)
        self.createTableView(minYAxis: titleLabel?.frame.maxY ?? backButton?.frame.maxY ?? 0)
    }
    
    
    //MARK: Method to create buttonView
    private func createButtonView() {
        
        backButton = UIButton(type: .custom)
        
        var backButtonYAxis:CGFloat = 20
        
        if Utility.sharedUtility.isIphoneX() {
            
            backButtonYAxis = 30
        }
        
        backButton?.frame = CGRect.init(x: 10, y: (backButtonYAxis * Utility.getBaseScreenHeightMultiplier()), width: closeButtonDimension, height: closeButtonDimension)
        let cancelButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "cancelIcon.png"))
        
        backButton?.setImage(cancelButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton?.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        
        backButton?.addTarget(self, action: #selector(backButtonTapped(sender:)), for: .touchUpInside)
        backButton?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        self.view.addSubview(backButton!)
    }
    
    
    //MARK: Method to create title view
    private func createTitleView(minXAxis:CGFloat) {
        
        var yAxis:CGFloat = 20
        
        if Utility.sharedUtility.isIphoneX() {
            
            yAxis = 30
        }
        
        titleLabel = UILabel(frame: CGRect(x: minXAxis + 10, y: yAxis, width: self.view.frame.width - ((minXAxis + 10) * 2), height: closeButtonDimension))
        titleLabel?.backgroundColor = .clear
        titleLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        titleLabel?.textAlignment = .center
        titleLabel?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased(){
            
            titleLabel?.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 20)
        }
        else {
            
            titleLabel?.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 20)
        }
        
        self.titleLabel?.text = "SEASONS"
        
        self.view.addSubview(titleLabel!)
    }
    
    
    //MARK: Method to create table view
    private func createTableView(minYAxis:CGFloat) {
        
        seasonSelectorTableView = UITableView(frame: CGRect(x: 0, y: minYAxis + 10, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - ((minYAxis + 10) * 2)), style: .plain)
        seasonSelectorTableView?.backgroundColor = .clear
        seasonSelectorTableView?.separatorStyle = .none
        seasonSelectorTableView?.delegate = self
        seasonSelectorTableView?.dataSource = self
        seasonSelectorTableView?.register(SFSeasonSelectionCell.self, forCellReuseIdentifier: "Cell")
        seasonSelectorTableView?.register(UINib(nibName: "SFSeasonSelectionCell", bundle: nil), forCellReuseIdentifier: "Cell")
        seasonSelectorTableView?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin]
        self.view.addSubview(seasonSelectorTableView!)
    }
    

    //MARK: TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return seasonArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let seasonSelectorCell:SFSeasonSelectionCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SFSeasonSelectionCell
        
        seasonSelectorCell.backgroundColor = .clear
        seasonSelectorCell.contentView.backgroundColor = .clear
        seasonSelectorCell.selectionStyle = .none
        
        if (selectedSeasonNumber ?? 0) == indexPath.row {
            
            seasonSelectorCell.updateCellContent(seasonObject: seasonArray![indexPath.row], isCellSelected: true, seasonNumber: Int(indexPath.row + 1))
        }
        else {
            
            seasonSelectorCell.updateCellContent(seasonObject: seasonArray![indexPath.row], isCellSelected: false, seasonNumber: Int(indexPath.row + 1))
        }

        return seasonSelectorCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 43.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (selectedSeasonNumber ?? 0) != indexPath.row {
            
            self.dismiss(success: true, selectedSeason: indexPath.row)
        }
    }
    
    /// Master method. Called when the view gets dismissed for both should auto play and shouldn't auto play cases.
    ///
    /// - Parameter success: pass true, if the video should get autoplayed and false otherwise.
    private func dismiss(success: Bool, selectedSeason:Int) {
        
        if let completionHandler = completionHandler {
            
            self.dismiss(animated: true, completion: {
                completionHandler(success, selectedSeason)
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: Button event handler
    func backButtonTapped(sender: UIButton) {
        
        self.dismiss(success: false, selectedSeason: selectedSeasonNumber ?? 1)
    }
    
    
    //Orientation Delegates
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    
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
