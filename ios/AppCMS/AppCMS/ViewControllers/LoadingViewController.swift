//
//  LoadingViewController.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 10/03/17.
//
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var configLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startConfiguringData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startConfiguringData() {
        
        configLabel?.isHidden = false
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
    }

    func stopConfiguringData() {
        
        configLabel?.isHidden = true
        activityIndicator?.isHidden = true
        activityIndicator?.stopAnimating()
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
