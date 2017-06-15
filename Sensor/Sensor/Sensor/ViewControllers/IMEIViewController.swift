//
//  IMEIViewController.swift
//  Sensor
//
//  Created by SH-DEV-5021 on 2017/6/1.
//  Copyright © 2017年 SH-DEV-5021. All rights reserved.
//

import UIKit

class IMEIViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    var imeiString: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txtInput.text = imeiString ?? nil
        btnConfirm.isEnabled = true
        btnConfirm.alpha = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var txtInput: UITextField!
    
    @IBAction func confirmAction(_ sender: Any?) {
        UserDefaults.standard.set(txtInput.text?.replacingOccurrences(of: " ", with: ""), forKey: "imei")
        UserDefaults.standard.synchronize()
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

extension IMEIViewController: UITextFieldDelegate {
    // MARK: - TextField event
    @IBAction func textDidChange(_ sender: UITextField) {
        guard let text = sender.text else {
            btnConfirm.isEnabled = false
            btnConfirm.alpha = 0.5
            return
        }
        if let sitAccuracyRegEx = try? NSRegularExpression(pattern: imeiPattern) {
            let matches = sitAccuracyRegEx.matches(in: text, range: NSMakeRange(0, text.characters.count))
            if matches.count == 1, let range = matches.last?.range {
                let imeiString = text.substring(with: text.index(text.startIndex, offsetBy: range.location)..<text.index(text.startIndex, offsetBy: range.location + range.length))
                if imeiString.characters.count == 18 {
                    btnConfirm.isEnabled = true
                    btnConfirm.alpha = 1.0
                    return
                }
            }
        }
        btnConfirm.isEnabled = false
        btnConfirm.alpha = 0.5
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            switch text.characters.count {
            case 2, 9, 16:
                if string != "" {
                    textField.text = text + " "
                }
            case 3, 10, 17:
                if string == "" {
                    textField.text = text.trimmingCharacters(in: .whitespaces)
                }
            case 18:
                if string != "" {
                    return false
                }
            default:
                break
            }
            return true
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        confirmAction(nil)
    }
}
