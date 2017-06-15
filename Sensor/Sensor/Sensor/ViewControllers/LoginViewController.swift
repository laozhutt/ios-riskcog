//
//  LoginViewController.swift
//  Sensor
//
//  Created by SH-DEV-5021 on 2017/5/27.
//  Copyright © 2017年 SH-DEV-5021. All rights reserved.
//

import UIKit

let codeKey     = "Code"
let messageKey  = "Massage"

class LoginViewController: UIViewController {
    
    var isInitialLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if IMEI.shared.value != "" {
            txtAccount.text = IMEI.shared.value
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var txtAccount: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Login
extension LoginViewController {
    
    @IBAction func loginAction(_ sender: Any?) {
        let loginManager = RequestManager(type: .auth)
        loginManager.userId = txtAccount.text
        loginManager.password = txtPassword.text
        do {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let loadingView = LoadingView.show(toParent: view)
            try loginManager.request() { jsonData in
                DispatchQueue.main.async {
                    loadingView.hide()
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard let json = jsonData else {
                    return
                }
                guard let object = try? JSONSerialization.jsonObject(with: json, options: []), let dic = object as? [AnyHashable:Any] else {
                    return
                }
                guard let code = dic[codeKey] as? Int else {
                    return
                }
                switch code {
                case -1:
                    print("用户名不存在")
                    let alert = UIAlertController(title: nil, message: "用户名不存在", preferredStyle: .alert)
                    let actionOK = UIAlertAction(title: "好", style: .default) { _ in
                        self.txtAccount.becomeFirstResponder()
                    }
                    alert.addAction(actionOK)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                    if !self.isInitialLogin {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: SegueIdentifiers.loginFail.rawValue, sender: nil)
                        }
                    }
                case 0:
                    if !self.isInitialLogin {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: SegueIdentifiers.loginSucceed.rawValue, sender: nil)
                        }
                    } else {
                        UserDefaults.standard.set(self.txtAccount.text!, forKey: "imei")
                        UserDefaults.standard.synchronize()
                        self.dismiss(animated: true)
                    }
                case 1:
                    print("密码错误")
                    let alert = UIAlertController(title: nil, message: "密码错误", preferredStyle: .alert)
                    let actionOK = UIAlertAction(title: "好", style: .default) { _ in
                        self.txtPassword.becomeFirstResponder()
                    }
                    alert.addAction(actionOK)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                    if !self.isInitialLogin {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: SegueIdentifiers.loginFail.rawValue, sender: nil)
                        }
                    }
                default:
                    break
                }
            }
        } catch {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let requestError = error as? RequestError {
                switch requestError {
                case .invalidUserId:
                    print("请输入用户名")
                case .invalidPassword:
                    print("请输入密码")
                default:
                    break
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtAccount {
            return txtPassword.becomeFirstResponder()
        } else if textField == txtPassword {
            loginAction(nil)
            return textField.resignFirstResponder()
        }
        return true
    }
}
