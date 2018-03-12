//
//  ArticleDetailViewController.swift
//  AppCMS
//
//  Created by  Diksha Goyal on 15/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import Foundation

class ArticleDetailViewController: UIViewController,UIScrollViewDelegate {
    
    private var modulesListArray:Array<AnyObject> = []
    var contentId:String?
    var networkUnavailableAlert:UIAlertController?
    var articleDeatilObject : SFArticleDetailObject?
     var progressIndicator:MBProgressHUD?
    var webView = SFWebView()
    
    init (frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        self.view.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //   if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
//          createNavigationBar()
//          self.createLeftNavItems()
//          self.createRightNavItemsForPage()
    //    }
        self.fetchArticleURL(contentId: contentId!)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- createNavigationBar
    func createNavigationBar() -> Void {
        self.navigationController?.navigationBar.barTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        self.navigationItem.titleView = Utility.createNavigationTitleView(navBarHeight: (self.navigationController?.navigationBar.frame.size.height)!)
    }
    //MARK: Creation of right nav items for sports template
    private func createRightNavItemsForPage() {
        
        let searchImage = UIImage(named: "icon-search")
        let searchButton = UIButton(type: .custom)
        searchButton.sizeToFit()
        searchButton.setImage(searchImage, for: .normal)
        searchButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (searchImage?.size.height)!/2)
        searchButton.addTarget(self, action: #selector(searchButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        
        let searchButtonItem = UIBarButtonItem(customView: searchButton)
        
        self.navigationItem.rightBarButtonItems = [searchButtonItem]
    }
    @objc private func searchButtonClicked(sender: AnyObject) {
        
        let searchViewController: SearchViewController = SearchViewController()
        searchViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        searchViewController.shouldDisplayBackButtonOnNavBar = true
        
        if let topController = Utility.sharedUtility.topViewController() {
            
            topController.navigationController?.pushViewController(searchViewController, animated: true)
        }
    }
    //MARK: Creation of left nav items for sports template
    private func createLeftNavItems() {
        
        let image = UIImage(named: "Back")
        
        let backButton = UIButton(type: .custom)
        backButton.sizeToFit()
        backButton.setImage(image, for: .normal)
        backButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (image?.size.height)!/2)
        backButton.addTarget(self, action: #selector(backButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        
        let backButtonItem = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItems = [backButtonItem]
    }
    @objc private func backButtonClicked(sender:AnyObject) {
          if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
        self.navigationController?.popViewController(animated: true)
        }
        else
          {
            self.dismiss(animated: true, completion: nil)
        }
    }
   
    //MARK : Create WebView
   private func createWebView(webViewObject : SFWebViewObject ) -> Void {
        let webLayout = Utility.fetchWebViewLayoutDetails(webViewObject: webViewObject)
        webView = SFWebView(frame: CGRect.zero)
        webView.webViewObject = webViewObject
        webView.webViewLayout = webLayout
        webView.scrollView.delegate=self
        webView.relativeViewFrame = self.view.frame
        webView.initialiseWebViewFrameFromLayout(webViewLayout: webLayout)
        self.view.addSubview(webView)
    }
    //In Progress
  /*  func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            print("BOTTOM REACHED")
            let htmlPath = Bundle.main.path(forResource: "filename", ofType: "html")
            let url = URL(fileURLWithPath: htmlPath!)
            webView.openUrlOnWebView(webUrl:url )
        }
        if scrollView.contentOffset.y <= 0.0 {
            print("TOP REACHED")
        }
    }*/
    //MARK:- LoadWebUrl
    private func loadWebUrl(htmlUrl : String)
   {
    let url = URL(string: htmlUrl)
    webView.openUrlOnWebView(webUrl:url! )
   }
    //MARK : Create Modules
    func createModules() -> Void {
        
        if articleDeatilObject != nil {
            for component:AnyObject in (self.articleDeatilObject?.components)! {
                
                if component is SFWebViewObject {
                    let webObject : SFWebViewObject = component as! SFWebViewObject
                    createWebView(webViewObject: webObject)
                }
                
            }
        }
    }
    
    //MARK: Method to fetch Video URL to play
   private func fetchArticleURL(contentId:String) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
             showAlertForAlertType(alertType: .AlertTypeNoInternetFound, isAlertForVideoDetailAPI: false, contentId: contentId, alertTitle: nil, alertMessage: nil)
        }
        else {
            
             self.showActivityIndicator(loaderText: nil)
            DataManger.sharedInstance.fetchURLDetailsForVideo(apiEndPoint: "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/article?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&id=\(contentId)") { (videoURLWithStatusDict) in
                
                DispatchQueue.main.async {
                    let articleURL:Dictionary<String,String>? = videoURLWithStatusDict?["urls"]! as? Dictionary<String,String>
                    self.progressIndicator?.hide(animated: true)
                    if let url = articleURL!["articleUrl"]
                    {
                         self.loadWebUrl(htmlUrl: url)
                    }
                    else
                    {
                        let alertController = UIAlertController(title: "Error", message: "Url not available", preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: Constants.kStrOk, style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                        }
                        
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                   
                }
            }
        }
    }
    //MARK: Display Network Error Alert
    func showAlertForAlertType(alertType: AlertType, isAlertForVideoDetailAPI:Bool, contentId:String?, alertTitle:String?, alertMessage:String?) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                    if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {

                        self.navigationController?.popViewController(animated: true)
                    }
                    else {

                        self.dismiss(animated: true, completion: nil)
                    }
            }
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                self.fetchArticleURL(contentId: contentId!)
            }
        }
        
        var alertTitleString:String = alertTitle ?? "No Response Received"
        var alertMessage:String = alertMessage ?? "Unable to fetch data!\nDo you wish to Try Again?"
        
        if alertType == .AlertTypeNoInternetFound {
            alertTitleString = Constants.kInternetConnection
            alertMessage = Constants.kInternetConntectionRefresh
        }
        
        networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString, alertMessage: alertMessage, alertActions: [closeAction, retryAction])
        
        self.present(networkUnavailableAlert!, animated: true, completion: nil)
    }
    //MARK - Show/Hide Activity Indicator
    func showActivityIndicator(loaderText:String?) {
        
        progressIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        if loaderText != nil {
            
            progressIndicator?.label.text = loaderText!
        }
    }
    func hideActivityIndicator() {
        progressIndicator?.hide(animated: true)
    }
}

