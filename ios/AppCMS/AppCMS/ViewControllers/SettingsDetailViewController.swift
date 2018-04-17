//
//  SettingsDetailViewController.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 06/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import GoogleCast
import Firebase

let updatePasswordAction: String = "changePassword"
let updateProfileAction: String = "editProfile"

class SettingsDetailViewController: UIViewController, UITextFieldDelegate, GCKUIMiniMediaControlsViewControllerDelegate, UIAlertViewDelegate, dropDownProtocol, UIPickerViewDelegate, UIPickerViewDataSource{
    
    enum ProfileTypeUpdate {
        case Email
        case UserName
        case Mobile
        case EmailAndUserName
    }
    
    var action: String?
    var emailTextField: UITextField?
    var nameTextField: UITextField?
    var countryCode: SFDropDown?
    var mobileTextField: UITextField?
    var emailLabel: UILabel?
    var nameLabel: UILabel?
    var mobileLabel: UILabel?
    var oldPasswordLabel: UILabel?
    var newPasswordLabel: UILabel?
    var confNewPasswordLabel: UILabel?
    var oldPasswordTextField: UITextField?
    var newPasswordTextField: UITextField?
    var confNewPasswordTextField: UITextField?
    var userDetails: SFUserDetails?
    var failureAlertType:PageLoadAfterFailureAlert?
    var progressIndicator:MBProgressHUD?
    var networkUnavailableAlert:UIAlertController?
    var updateButton: UIButton?
    var navigationTitle: String?
    let navBarPadding:CGFloat = 70
    var countryPicker: UIPickerView!
    var mobileHiphenLabel: UILabel!
    var selectedCountry: SFCountryDialModel!
    var _miniMediaControlsContainerView: UIView!
    var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!

    
    // MARK: - Internal methods
    func updateControlBarsVisibility() {
        if (self.miniMediaControlsViewController != nil){
            _miniMediaControlsContainerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - (64), width: UIScreen.main.bounds.width, height: 0)

            if self.miniMediaControlsViewController.active && CastPopOverView.shared.isConnected(){
                _miniMediaControlsContainerView.changeFrameHeight(height: 64)
                self.view.bringSubview(toFront: _miniMediaControlsContainerView)
            } else {
                _miniMediaControlsContainerView.changeFrameHeight(height: 0)
            }
        }
        
    }
    
    // MARK: - GCKUIMiniMediaControlsViewControllerDelegate
    func miniMediaControlsViewController(_ miniMediaControlsViewController: GCKUIMiniMediaControlsViewController,
                                         shouldAppear: Bool) {
        self.updateControlBarsVisibility()
        
    }
    
    func addMiniCastControllerToViewController(viewController: UIViewController){
        // Do any additional setup after loading the view.
        
        _miniMediaControlsContainerView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - (64), width: UIScreen.main.bounds.width, height: 0))
        
        viewController.view.addSubview(_miniMediaControlsContainerView)
        
        self.miniMediaControlsViewController = GCKCastContext.sharedInstance().createMiniMediaControlsViewController()
        self.miniMediaControlsViewController.delegate = self
        self.miniMediaControlsViewController.view.frame = _miniMediaControlsContainerView.bounds
        _miniMediaControlsContainerView.addSubview(self.miniMediaControlsViewController.view)
        
        self.updateControlBarsVisibility()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addMiniCastControllerToViewController(viewController: self)

        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        createNavigationBar()
        if action == updatePasswordAction
        {
            createUpdatePassword()
        }
        else
        {
            createEditProfile()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.updateControlBarsVisibility()
        fetchUserDetailModuleContent()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)

        self.triggerFireBaseEvent()
    }
    
    
    func triggerFireBaseEvent() {
        
        var pageScreenName:String = "Update Settings Screen"
        
        if action == updatePasswordAction
        {
            pageScreenName = "Change Password Screen"
        }
        else if action == updateProfileAction
        {
            pageScreenName = "Edit Profile Screen"
        }
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            FIRAnalytics.setScreenName(pageScreenName, screenClass: nil)
        }
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.allowIDFACollection = true
        tracker.set(kGAIScreenName, value: pageScreenName)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getPosition(position:CGFloat) -> CGFloat {
        var value = position
        if (Constants.IPHONE && Utility.sharedUtility.isIphoneX()) {
            value = value + 24;
        }
        return value;
    }
    override func viewDidLayoutSubviews()
    {
        if Constants.IPHONE
        {
            
            if emailLabel != nil
            {
                emailLabel?.frame = CGRect.init(x: 10, y: getPosition(position: 0), width: 50, height: 30)
            }
            if emailTextField != nil {
                emailTextField?.frame = CGRect.init(x: (emailLabel?.frame.maxX)! + 10, y: getPosition(position: 0), width: 300, height: 30)
            }

            if nameLabel != nil
            {
                nameLabel?.frame = CGRect.init(x: 10, y: getPosition(position: 40), width: 50, height: 30)
            }
            
            if nameTextField != nil {
                nameTextField?.frame = CGRect.init(x: (nameLabel?.frame.maxX)! + 10, y: getPosition(position: 40), width: 300, height: 30)
            }
            
            if mobileLabel != nil
            {
                mobileLabel?.frame = CGRect.init(x: 10, y: getPosition(position: 80), width: 50, height: 30)
            }
            
            if countryCode != nil {
                countryCode?.frame = CGRect.init(x: (mobileLabel?.frame.maxX)! + 10, y: getPosition(position: 80), width: 50, height: 30)
            }
            
            if mobileHiphenLabel != nil {
                mobileHiphenLabel?.frame = CGRect.init(x: (countryCode?.frame.maxX)!, y: getPosition(position: 80), width: 10, height: 30)
            }
            
            if mobileTextField != nil {
                mobileTextField?.frame = CGRect.init(x: (countryCode?.frame.maxX)! + 10, y: getPosition(position: 80), width: 240, height: 30)
            }

            if updateButton != nil {
                updateButton?.frame = CGRect.init(x: (Int(self.view.frame.width) - 173)/2, y: Int(self.view.frame.height) - 300, width: 173, height: 40)
            }
            
            if oldPasswordLabel != nil {
                oldPasswordLabel?.frame = CGRect.init(x: 10, y: getPosition(position: 0), width: 125, height: 30)
            }
            if oldPasswordTextField != nil {
                oldPasswordTextField?.frame = CGRect.init(x: (oldPasswordLabel?.frame.maxX)! + 10, y: getPosition(position: 0), width: 235, height: 30)
            }
            
            if newPasswordLabel != nil {
                newPasswordLabel?.frame = CGRect.init(x: 10, y: getPosition(position: 40), width: 125, height: 30)
            }
            
            if newPasswordTextField != nil {
                newPasswordTextField?.frame = CGRect.init(x: (newPasswordLabel?.frame.maxX)! + 10, y: getPosition(position: 40), width: 235, height: 30)
            }

            if confNewPasswordLabel != nil {
                confNewPasswordLabel?.frame = CGRect.init(x: 10, y: getPosition(position: 80), width: 125, height: 30)
            }
            
            if confNewPasswordTextField != nil {
                
                confNewPasswordTextField?.frame = CGRect.init(x: (confNewPasswordLabel?.frame.maxX)! + 10, y: getPosition(position: 80), width: 235, height: 30)
            }
            
            
            for subView in self.view.subviews
            {
                if subView.tag > 0
                {
                    subView.frame = CGRect.init(x: 0, y: ((subView.tag - 1) * 40 ), width: Int(self.view.frame.width), height: 1)
                    subView.changeFrameYAxis(yAxis: subView.frame.origin.y * Utility.getBaseScreenHeightMultiplier())
                    subView.changeFrameYAxis(yAxis: subView.frame.origin.y + getPosition(position: 64))
                }
                else {
                    
                    if subView is UILabel || subView is UITextField {
                        
                        subView.changeFrameXAxis(xAxis: subView.frame.origin.x * Utility.getBaseScreenWidthMultiplier())
                        subView.changeFrameYAxis(yAxis: subView.frame.origin.y * Utility.getBaseScreenHeightMultiplier())
                        subView.changeFrameWidth(width: subView.frame.size.width * Utility.getBaseScreenWidthMultiplier())
                        subView.changeFrameHeight(height: subView.frame.size.height * Utility.getBaseScreenHeightMultiplier())
                        
                        subView.changeFrameYAxis(yAxis: subView.frame.origin.y + navBarPadding)
                    }
                }
            }
        }
        else
        {
            self.updateControlBarsVisibility()

            if emailLabel != nil
            {
                emailLabel?.frame = CGRect.init(x: (Int(self.view.frame.width) - 375) / 2, y: 0, width: 50, height: 30)
            }
            if emailTextField != nil {
                emailTextField?.frame = CGRect.init(x: (emailLabel?.frame.maxX)! + 10, y: 0, width: 300, height: 30)
            }
            
            if nameLabel != nil
            {
                nameLabel?.frame = CGRect.init(x: (Int(self.view.frame.width) - 375) / 2, y: 40, width: 50, height: 30)
            }
            
            if nameTextField != nil {
                nameTextField?.frame = CGRect.init(x: (nameLabel?.frame.maxX)! + 10, y: 40, width: 300, height: 30)
            }
            
            if mobileLabel != nil
            {
                mobileLabel?.frame = CGRect.init(x: (Int(self.view.frame.width) - 375) / 2, y: 80, width: 50, height: 30)
            }
            
            if countryCode != nil {
                countryCode?.frame = CGRect.init(x: (mobileLabel?.frame.maxX)! + 10, y: 80, width: 50, height: 30)
            }
            
            if mobileHiphenLabel != nil {
                mobileHiphenLabel?.frame = CGRect.init(x: (countryCode?.frame.maxX)!, y: 80, width: 10, height: 30)
            }
            
            if mobileTextField != nil {
                mobileTextField?.frame = CGRect.init(x: (countryCode?.frame.maxX)! + 10, y: 80, width: 240, height: 30)
            }
            
            if updateButton != nil {
                updateButton?.frame = CGRect.init(x: (Int(self.view.frame.width) - 173 )/2, y: Int(self.view.frame.height) - 440, width: 173, height: 40)
            }
            
            if oldPasswordLabel != nil {
                oldPasswordLabel?.frame = CGRect.init(x: (Int(self.view.frame.width) - 375) / 2, y: 0, width: 125, height: 30)
            }
            
            if oldPasswordTextField != nil {
                oldPasswordTextField?.frame = CGRect.init(x: (oldPasswordLabel?.frame.maxX)! + 10, y: 0, width: 235, height: 30)
            }
            
            if newPasswordLabel != nil {
                newPasswordLabel?.frame = CGRect.init(x: (Int(self.view.frame.width) - 375) / 2, y: 40, width: 125, height: 30)
            }
            
            if newPasswordTextField != nil {
                newPasswordTextField?.frame = CGRect.init(x: (newPasswordLabel?.frame.maxX)! + 10, y: 40, width: 235, height: 30)
            }
            
            if confNewPasswordLabel != nil
            {
                confNewPasswordLabel?.frame = CGRect.init(x: (Int(self.view.frame.width) - 375) / 2, y: 80, width: 125, height: 30)
            }
            
            if confNewPasswordTextField != nil
            {
                confNewPasswordTextField?.frame = CGRect.init(x: (confNewPasswordLabel?.frame.maxX)! + 10, y: 80, width: 235, height: 30)
            }
            
            for subView in self.view.subviews
            {
                if subView.tag > 0
                {
                    subView.frame = CGRect.init(x: (Int(self.view.frame.width) - 375) / 2, y: ((subView.tag - 1) * 40 ), width: 375, height: 1)
                    subView.changeFrameYAxis(yAxis: subView.frame.origin.y * Utility.getBaseScreenHeightMultiplier())
                    
                    subView.changeFrameYAxis(yAxis: subView.frame.origin.y + 64)
                    
                }
                else {
                    
                    if subView is UILabel || subView is UITextField {
                        
                        subView.changeFrameYAxis(yAxis: subView.frame.origin.y * Utility.getBaseScreenHeightMultiplier())
                        subView.changeFrameWidth(width: subView.frame.size.width * Utility.getBaseScreenWidthMultiplier())
                        subView.changeFrameHeight(height: subView.frame.size.height * Utility.getBaseScreenHeightMultiplier())
                        
                        subView.changeFrameYAxis(yAxis: subView.frame.origin.y + navBarPadding)
                    }
                }
            }
        }
    }
    
    func createNavigationBar() -> Void
    {
        self.navigationController?.navigationBar.barTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        let editLabel: UILabel = UILabel()
        editLabel.text = self.navigationTitle
        editLabel.frame = CGRect.init(x: 0, y: 0, width: 130, height: 44)
        editLabel.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 18)
        editLabel.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        editLabel.backgroundColor = .clear
        editLabel.textAlignment = .center
        self.navigationItem.titleView = editLabel
        
        let backButton: UIButton = UIButton.init(type: .custom)
        let backButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "Back.png"))
        
        backButton.setImage(backButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        

        backButton.frame = CGRect.init(x: 0, y: 0, width: 40, height: 22)
        backButton.tintColor = .clear
        //        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 50)
        backButton.addTarget(self, action: #selector(backButtonTapped(sender:)), for: .touchUpInside)
        let backBarButtonItem: UIBarButtonItem = UIBarButtonItem.init(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    func backButtonTapped(sender: UIButton) -> Void {
        self.dismiss(animated: false) { 
        }
    }
    

    func createEditProfile() -> Void
    {
        countryPicker = UIPickerView()
        countryPicker.dataSource = self
        countryPicker.delegate = self
        
        mobileHiphenLabel = createLabel(labelText: "-")
        self.view.addSubview(mobileHiphenLabel)
        
        createSaperatorView(viewTag: 1)
        nameLabel = createLabel(labelText: "Name")
        self.view.addSubview(nameLabel!)
        
        createSaperatorView(viewTag: 2)
        emailLabel = createLabel(labelText: "Email")
        self.view.addSubview(emailLabel!)
        
        createSaperatorView(viewTag: 3)
        mobileLabel = createLabel(labelText: "Mobile")
        self.view.addSubview(mobileLabel!)
        
        createSaperatorView(viewTag: 4)

        countryCode = createDropDown(dropDownText: "Country")
        countryCode?.placeholder = "Country"
        countryCode?.textAlignment = .left

        nameTextField = createTextField(isProtected: false)
        nameTextField?.keyboardType = .namePhonePad
        emailTextField = createTextField(isProtected: false)
        emailTextField?.keyboardType = .emailAddress
        mobileTextField = createTextField(isProtected: false)
        mobileTextField?.keyboardType = .numberPad
        
        self.view.addSubview(nameTextField!)
        self.view.addSubview(emailTextField!)
        self.view.addSubview(countryCode!)
        self.view.addSubview(mobileTextField!)

        updateButton = createButton(buttonText: "UPDATE")
        self.view.addSubview(updateButton!)
        
        nameTextField?.delegate = self
        emailTextField?.delegate = self
        countryCode?.delegate = self
        mobileTextField?.delegate = self
    }
    
    func createUpdatePassword() -> Void
    {
        createSaperatorView(viewTag: 1)
        oldPasswordLabel = createLabel(labelText: "Old Password")
        self.view.addSubview(oldPasswordLabel!)
        createSaperatorView(viewTag: 2)
        newPasswordLabel = createLabel(labelText: "New Password")
        self.view.addSubview(newPasswordLabel!)
        createSaperatorView(viewTag: 3)
        confNewPasswordLabel = createLabel(labelText: "Confirm New Pass.")
        self.view.addSubview(confNewPasswordLabel!)
        createSaperatorView(viewTag: 4)

        oldPasswordTextField = createTextField(isProtected: true)
        newPasswordTextField = createTextField(isProtected: true)
        confNewPasswordTextField = createTextField(isProtected: true)
        self.view.addSubview(oldPasswordTextField!)
        self.view.addSubview(newPasswordTextField!)
        self.view.addSubview(confNewPasswordTextField!)

        updateButton = createButton(buttonText: "CHANGE PASSWORD")
        self.view.addSubview(updateButton!)
        
        oldPasswordTextField?.delegate = self
        confNewPasswordTextField?.delegate = self
    }
    
    func createSaperatorView(viewTag: Int) -> Void {
        let saperatorView: UIView = UIView.init()
        saperatorView.backgroundColor = Utility.hexStringToUIColor(hex: "6C7074")
        saperatorView.alpha = 0.48
        saperatorView.tag = viewTag
        self.view.addSubview(saperatorView)
    }
    
    func createLabel(labelText: String) -> UILabel {
        let editLabel: UILabel = UILabel()
        editLabel.text = labelText
        editLabel.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 12)
        editLabel.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        editLabel.backgroundColor = .clear
        editLabel.textAlignment = .left
        return editLabel
    }
    
    func createTextField(isProtected: Bool) -> UITextField {
        let editTextField: UITextField = UITextField()
        editTextField.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 12)
        editTextField.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        editTextField.backgroundColor = .clear
        editTextField.textAlignment = .left
        editTextField.isSecureTextEntry = isProtected
        editTextField.autocorrectionType = .no
        editTextField.autocapitalizationType = .none
        editTextField.delegate = self
        return editTextField
    }
    
    func createDropDown(dropDownText: String) -> SFDropDown
    {
        let dropDown:SFDropDown = SFDropDown()
        dropDown.dropDownDelegate = self
        dropDown.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 12)
        dropDown.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        dropDown.inputView = countryPicker
        dropDown.backgroundColor = UIColor.clear
        dropDown.textColor = .white
                
        return dropDown
    }
    
    func createButton(buttonText: String) -> UIButton {
        let editButton: UIButton = UIButton.init(type: .custom)
        editButton.titleLabel?.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Semibold", size: 12)
        editButton.setTitle(buttonText, for: .normal)
        editButton.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000")
        editButton.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor ?? AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        editButton.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        return editButton
    }
    
    func buttonTapped(sender: UIButton) -> Void
    {
        
        if self.action == updatePasswordAction
        {
            updatePassword()
        }
        else
        {
            updateProfileDetails()
        }
    }
    
    func updatePassword() -> Void
    {
        if (oldPasswordTextField?.text?.characters.count == 0) || (newPasswordTextField?.text?.characters.count == 0) || (confNewPasswordTextField?.text?.characters.count == 0)
        {
            let alertView: UIAlertView = UIAlertView.init(title: self.navigationTitle, message: "Please fill all details to continue.", delegate: nil, cancelButtonTitle: Constants.kStrOk)
            alertView.show()
            return
        }
        
        if (newPasswordTextField?.text != confNewPasswordTextField?.text)
        {
            let alertView: UIAlertView = UIAlertView.init(title: self.navigationTitle, message: "New password should match with confirm password.", delegate: nil, cancelButtonTitle: Constants.kStrOk)
            alertView.show()
            return
        }
        else if Utility.isValidPassword(passwordString: (newPasswordTextField?.text)!, emailAddress: userDetails?.emailID) != nil {
            
            let alertView: UIAlertView = UIAlertView.init(title: self.navigationTitle, message: Utility.isValidPassword(passwordString: (newPasswordTextField?.text)!, emailAddress: userDetails?.emailID), delegate: nil, cancelButtonTitle: Constants.kStrOk)
            alertView.show()
            return
        }
        
        showActivityIndicator(loaderText: nil)
        
        let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/password?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"

        DispatchQueue.global(qos: .userInitiated).async {
            
            DataManger.sharedInstance.updateUserPassword(apiEndPoint: apiRequest, newPassword: (self.newPasswordTextField?.text)!, oldPassword: (self.oldPasswordTextField?.text)!) { (updateUserPasswordResponse, success: Bool) in
                
                DispatchQueue.main.async {
                    
                    self.hideActivityIndicator()
                    
                    if success
                    {
                        self.resignKeyboard()
                        self.oldPasswordTextField?.text = ""
                        self.newPasswordTextField?.text = ""
                        self.confNewPasswordTextField?.text = ""
                        let alertView: UIAlertView = UIAlertView.init(title: self.navigationTitle, message: "Password changed successfully", delegate: self, cancelButtonTitle: "OK")
                        alertView.tag = 1111
                        alertView.show()
                        return
                    }
                    else
                    {
                        
                        var alertMessage = "Error in updating password"
                        
                        if updateUserPasswordResponse != nil {
                            
                            let errorAlertMessage:String? = updateUserPasswordResponse?["error"] as? String
                            
                            if errorAlertMessage != nil {
                                
                                alertMessage = errorAlertMessage!
                            }
                        }
                        
                        self.resignKeyboard()
                        let alertView: UIAlertView = UIAlertView.init(title: self.navigationTitle, message: alertMessage, delegate: self, cancelButtonTitle: Constants.kStrOk)
                        alertView.show()
                    }
                }
            }
        }
    }
    
    func updateProfileDetails() -> Void
    {
        if (emailTextField?.text?.characters.count == 0)
        {
            let alertView: UIAlertView = UIAlertView.init(title: self.navigationTitle, message: "Please add email to continue.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
        
        if !isValidEmailAddress(emailAddressString: (emailTextField?.text)!) {
            let alertView: UIAlertView = UIAlertView.init(title: self.navigationTitle, message: "Please add valid email address to continue.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
                
        if emailTextField?.text == self.userDetails?.emailID && nameTextField?.text == self.userDetails?.name && mobileTextField?.text == self.userDetails?.mobile
        {
            if self.selectedCountry != nil {
                
                if self.selectedCountry.countryDialCode == self.userDetails?.mobileCountryCode
                {
                    return
                }
            }
            else {
                
                return
            }
        }
        
        if emailTextField?.text != self.userDetails?.emailID && nameTextField?.text != self.userDetails?.name && mobileTextField?.text != self.userDetails?.mobile && self.selectedCountry.countryDialCode != self.userDetails?.mobileCountryCode
        {
            self.promptUserToEnterPasswordToUpdateProfile(profileTypeUpdate: .EmailAndUserName)
        }
        else if self.emailTextField?.text != self.userDetails?.emailID {
            
            self.promptUserToEnterPasswordToUpdateProfile(profileTypeUpdate: .Email)
        }
        else if nameTextField?.text != self.userDetails?.name {
            
            self.promptUserToEnterPasswordToUpdateProfile(profileTypeUpdate: .UserName)
        }
        else if mobileTextField?.text != self.userDetails?.mobile || self.selectedCountry.countryDialCode != self.userDetails?.mobileCountryCode {
            
            self.promptUserToEnterPasswordToUpdateProfile(profileTypeUpdate: .Mobile)
        }
    }
    
    
    func promptUserToEnterPasswordToUpdateProfile(profileTypeUpdate:ProfileTypeUpdate) {
        
        if (mobileTextField?.text?.characters.count)! > 0 {
            if (countryCode?.text?.characters.count)! == 0 || countryCode?.text == "Country"
            {
                let alertView: UIAlertView = UIAlertView.init(title: "Sign Up", message: Constants.kCoutryDialCodeError, delegate: nil, cancelButtonTitle: Constants.kStrOk)
                alertView.show()
                return
            }
        }
        
        var passwordTextField:UITextField?
        
        let okAction = UIAlertAction(title: Constants.kStrOk, style: .default) { (okAction) in
            
            if passwordTextField != nil {
                
                self.updateUserProfile(password: passwordTextField?.text, profileTypeUpdate: profileTypeUpdate)
            }
        }
        
        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
            
            
        }
        
        var alertMessage:String = "Please enter your password to update your "
        
        if profileTypeUpdate == .Email {
            
            alertMessage = alertMessage.appending("email")
        }
        else if profileTypeUpdate == .UserName {
            
            alertMessage = alertMessage.appending("name")
        }
        else if profileTypeUpdate == .Mobile {
            
            alertMessage = alertMessage.appending("mobile")
        }
        else if profileTypeUpdate == .EmailAndUserName {
            
            alertMessage = alertMessage.appending("name, email and mobile")
        }
        else {
            
            alertMessage = alertMessage.appending("profile")
        }
        
        let passwordPromptAlert = Utility.sharedUtility.presentAlertController(alertTitle: self.navigationTitle ?? "", alertMessage: alertMessage, alertActions: [cancelAction, okAction])
        
        passwordPromptAlert.addTextField { (textField) in
            
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            passwordTextField = textField
        }
        
        self.present(passwordPromptAlert, animated: true, completion: nil)
    }
    
    
    func updateUserProfile(password:String?, profileTypeUpdate:ProfileTypeUpdate) {
        
        if password != nil {
            
            if !password!.isEmpty {
                showActivityIndicator(loaderText: nil)
                
                let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/user?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
                
                var userDetailDict:[String: Any] = [:]
                userDetailDict["email"] = emailTextField?.text
                userDetailDict["password"] = password
                userDetailDict["name"] = nameTextField?.text
                
                var mobileDict:[String: Any] = [:]
                if self.selectedCountry != nil{
                    if self.selectedCountry.countryCode != nil
                    {
                        mobileDict["country"] = self.selectedCountry.countryCode
                    }
                    else
                    {
                        mobileDict["country"] = self.userDetails?.mobileCountryCode
                    }
                }
                else
                {
                    mobileDict["country"] = self.userDetails?.mobileCountryCode
                }
                mobileDict["number"] = mobileTextField?.text
                
                
                if mobileTextField?.text == ""
                {
                    mobileDict = ["country": "", "number": ""]
                }
                
                userDetailDict["phone"] = mobileDict

                DispatchQueue.global(qos: .userInitiated).async {
                    
                    DataManger.sharedInstance.updateUserPageDetails(apiEndPoint: apiRequest, userDictionary: userDetailDict) { (updateUserPageResponse, success) in
                        
                        DispatchQueue.main.async {
                            
                            self.hideActivityIndicator()

                            self.resignKeyboard()

                            if updateUserPageResponse != nil {

                                if success
                                {
                                    let refreshToken:String? = updateUserPageResponse?["refreshToken"] as? String
                                    let authorizationToken: String? = updateUserPageResponse?["authorizationToken"] as? String
                                    let id:String? = updateUserPageResponse?["userId"] as? String
                                    
                                    if authorizationToken != nil && refreshToken != nil
                                    {
                                        Constants.kSTANDARDUSERDEFAULTS.setValue(refreshToken, forKey: Constants.kRefreshToken)
                                        Constants.kSTANDARDUSERDEFAULTS.setValue(authorizationToken!, forKey: Constants.kAuthorizationToken)
                                    }
                                    
                                    if id != nil {
                                        
                                        Constants.kSTANDARDUSERDEFAULTS.setValue(id, forKey: Constants.kUSERID)
                                    }
                                    
                                    Constants.kSTANDARDUSERDEFAULTS.synchronize()

                                    self.displayUserProfileAlert(alertMessage: "User details changed successfully", shouldDismissView: true)
                                }
                                else
                                {
                                    let errorMessage:String? = updateUserPageResponse?["error"] as? String
                                    
                                    self.displayUserProfileAlert(alertMessage: errorMessage ?? "Error in updating user details", shouldDismissView: false)
                                }
                            }
                            else {
                                
                                self.displayUserProfileAlert(alertMessage: "Error in updating user details", shouldDismissView: false)
                            }
                        }
                    }
                }
            }
            else {
                
                self.noPasswordAlert(profileTypeUpdate: profileTypeUpdate)
            }
        }
        else {
            
            self.noPasswordAlert(profileTypeUpdate: profileTypeUpdate)
        }
    }
    
    
    func displayUserProfileAlert(alertMessage:String, shouldDismissView:Bool) {
    
        let okAction = UIAlertAction(title: Constants.kStrOk, style: .default) { (okAction) in
            
            if shouldDismissView {
                
                AppConfiguration.sharedAppConfiguration.isUserDetailUpdated = true

                self.dismiss(animated: true, completion: nil)
            }
        }
        
        let profileAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: self.navigationTitle ?? "", alertMessage: alertMessage, alertActions: [okAction])
        
        self.present(profileAlert, animated: true, completion: nil)
    }
    
    
    func noPasswordAlert(profileTypeUpdate:ProfileTypeUpdate) {
        
        let okAction = UIAlertAction(title: Constants.kStrOk, style: .default) { (okAction) in
            
            
        }
        
        var alertMessage:String = "Please enter password to update "
        
        if profileTypeUpdate == .Email {
            
            alertMessage = alertMessage.appending("email")
        }
        else if profileTypeUpdate == .UserName {
            
            alertMessage = alertMessage.appending("name")
        }
        else if profileTypeUpdate == .EmailAndUserName {
            
            alertMessage = alertMessage.appending("name and email")
        }
        else {
            
            alertMessage = alertMessage.appending("profile")
        }
        
        let passwordPromptErrorAlert = Utility.sharedUtility.presentAlertController(alertTitle: self.navigationTitle ?? "", alertMessage: alertMessage, alertActions: [okAction])
        
        self.present(passwordPromptErrorAlert, animated: true, completion: nil)
    }
    
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        AppConfiguration.sharedAppConfiguration.isUserDetailUpdated = true
        
        if alertView.tag == 1111
        {
            self.dismiss(animated: false) {
            }
        }
    }
    
    
    func fetchUserDetailModuleContent() {
        
        let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/user?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        showActivityIndicator(loaderText: nil)
        
        DispatchQueue.global(qos: .userInitiated).async {
         
            DataManger.sharedInstance.fetchUserPageDetails(apiEndPoint: apiRequest) { (userResult, isSuccess) in
                
                self.hideActivityIndicator()
                self.resignKeyboard()

                if userResult != nil && isSuccess {
                    self.userDetails = userResult
                    self.updatePageValues()
                }
                else {
                    self.updatePageValues()
                }
            }
        }
    }
    
    func updatePageValues() -> Void {
        self.nameTextField?.text = userDetails?.name
        self.emailTextField?.text = userDetails?.emailID
        self.mobileTextField?.text = userDetails?.mobile
        
        var countryCodeSting: String = ""
        for countryVal in AppConfiguration.sharedAppConfiguration.countryDialCodesArray
        {
            let localCountry: SFCountryDialModel = countryVal
            if userDetails?.mobileCountryCode == localCountry.countryCode!
            {
                countryCodeSting = localCountry.countryDialCode!
                break
            }
        }

        self.countryCode?.text = countryCodeSting
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
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
    
    func showAlertForAlertType(alertType: AlertType) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                    self.fetchUserDetailModuleContent()
            }
        }
        
        var alertTitleString:String?
        var alertMessage:String?
        
        if alertType == .AlertTypeNoInternetFound {
            alertTitleString = Constants.kInternetConnection
            alertMessage = Constants.kInternetConntectionRefresh
        }
        else {
            alertTitleString = "No Response Received"
            alertMessage = "Unable to fetch data!\nDo you wish to Try Again?"
        }
        
        networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction, retryAction])
        
        self.present(networkUnavailableAlert!, animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        resignKeyboard()
        return true
    }
    
    
    func resignKeyboard()
    {
        if oldPasswordTextField != nil {
            
            if (oldPasswordTextField?.isFirstResponder)! {
                
                oldPasswordTextField?.resignFirstResponder()
            }
        }
        
        if newPasswordTextField != nil {
            
            if (newPasswordTextField?.isFirstResponder)! {
                
                newPasswordTextField?.resignFirstResponder()
            }
        }
        
        if emailTextField != nil {
            
            if (emailTextField?.isFirstResponder)! {
                
                emailTextField?.resignFirstResponder()
            }
        }
        
        if nameTextField != nil {
            
            if (nameTextField?.isFirstResponder)! {
                
                nameTextField?.resignFirstResponder()
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return AppConfiguration.sharedAppConfiguration.countryDialCodesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (AppConfiguration.sharedAppConfiguration.countryDialCodesArray[row].countryName! + "  \(AppConfiguration.sharedAppConfiguration.countryDialCodesArray[row].countryDialCode ?? "" )")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        countryCode?.text = AppConfiguration.sharedAppConfiguration.countryDialCodesArray[row].countryDialCode
        self.selectedCountry = AppConfiguration.sharedAppConfiguration.countryDialCodesArray[row]
        self.view.endEditing(true)
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
