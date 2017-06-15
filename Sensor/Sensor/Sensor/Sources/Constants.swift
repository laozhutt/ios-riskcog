//
//  Constants.swift
//  Sensor
//
//  Created by SH-DEV-5021 on 2017/5/25.
//  Copyright © 2017年 SH-DEV-5021. All rights reserved.
//

import Foundation

enum SegueIdentifiers : String {
    case inputIMEI
    case identifySucceed
    case identifyFail
    case loginSucceed
    case loginFail
}

struct IMEI {
    var value = UserDefaults.standard.string(forKey: "imei") ?? ""
    
    static var shared: IMEI {
        return IMEI()
    }
}

let imeiPattern = "^\\d{2}( \\d{6}){2} \\d$"
