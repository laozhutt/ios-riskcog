//
//  ViewController.swift
//  Sensor
//
//  Created by SH-DEV-5021 on 2017/5/25.
//  Copyright © 2017年 SH-DEV-5021. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lblUserName.text = IMEI.shared.value
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private lazy var sensorManager: SensorManager = { return SensorManager() }()
    
    @IBAction func autoIdentifyAction(_ sender: UIButton) {
        let loadingView = LoadingView.show(toParent: view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        sensorManager.getSensorData() { userState in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print(userState)
            OperationQueue.main.addOperation {
                loadingView.hide()
                switch userState {
                case .unknown:
                    self.performSegue(withIdentifier: SegueIdentifiers.identifyFail.rawValue, sender: nil)
                default:
                    self.performSegue(withIdentifier: SegueIdentifiers.identifySucceed.rawValue, sender: nil)
                }
            }
        }
    }
    
    var imeiString: String?
    @IBOutlet weak var lblUserName: UILabel!
}

// MARK: - Segue
extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.inputIMEI.rawValue {
            if let newNavigationController = segue.destination as? UINavigationController, let loginViewController = newNavigationController.viewControllers.last as? LoginViewController {
                loginViewController.isInitialLogin = true
            }
        }
    }
    
    @IBAction func unwindSegueToViewController(segue: UIStoryboardSegue) {
        
    }
}

