//
//  ResultParser.swift
//  Sensor
//
//  Created by SH-DEV-5021 on 2017/5/27.
//  Copyright © 2017年 SH-DEV-5021. All rights reserved.
//

// 将服务器获取的JSON数据处理出相应的精度，并可以通过这个类获取结果

import Foundation

//阈值设置为70%
let accuracyThreshold   = 0.7

let sitAccuracyField    = "sit_accuracy="
let walkAccuracyField   = "walk_accuracy="
let sitAccuracyPattern    = "\(sitAccuracyField)\\d+(\\.\\d+)?"
let walkAccuracyPattern   = "\(walkAccuracyField)\\d+(\\.\\d+)?"

public enum UserState : CustomStringConvertible {
    case unknown
    case sit
    case walk
    
    public var description: String {
        switch self {
        case .unknown:
            return "What are you doing?!"
        case .sit:
            return "You are sitting probably, right?"
        case .walk:
            return "You are walking probably, right?"
        }
    }
}

class ResultParser {
    var userState: UserState {
        if sitAccuracy < accuracyThreshold, walkAccuracy < accuracyThreshold {
            return .unknown
        } else if sitAccuracy > walkAccuracy {
            return .sit
        } else {
            return .walk
        }
    }
    
    var sitAccuracy: Double {
//通过正则表达式处理处sitAccuracy
        if let sitAccuracyRegEx = try? NSRegularExpression(pattern: sitAccuracyPattern) {
            let res = sitAccuracyRegEx.firstMatch(in: resultString, range: NSMakeRange(0, resultString.characters.count))
            if let range = res?.range {
                if let value = Double(resultString[resultString.index(resultString.startIndex, offsetBy: range.location + sitAccuracyField.characters.count)..<resultString.index(resultString.startIndex, offsetBy: range.location + range.length)]) {
                    return value
                }
            }
        }
        return 0
    }
    var walkAccuracy: Double {
//通过正则表达式处理处walkAccuracy
        if let walkAccuracyRegEx = try? NSRegularExpression(pattern: walkAccuracyPattern) {
            let res = walkAccuracyRegEx.firstMatch(in: resultString, range: NSMakeRange(0, resultString.characters.count))
            if let range = res?.range {
                if let value = Double(resultString[resultString.index(resultString.startIndex, offsetBy: range.location + walkAccuracyField.characters.count)..<resultString.index(resultString.startIndex, offsetBy: range.location + range.length)]) {
                    return value
                }
            }
        }
        return 0
    }
    
    private(set) var resultString: String
    
    init(resultString: String) {
        self.resultString = resultString
    }
}
