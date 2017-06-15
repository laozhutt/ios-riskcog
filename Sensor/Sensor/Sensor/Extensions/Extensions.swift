//
//  Extensions.swift
//  Sensor
//
//  Created by John on 2017/5/25.
//  Copyright © 2017年 SH-DEV-5021. All rights reserved.
//

import Foundation

extension Date {
    static var timeStampString: String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddhhmmss"
        return dateFormatter.string(from: now)
    }
}

protocol MultiPartFormData {
    func appendPart(withFilePath path: String, name: String, fileName: String, mimeType: MIMEType) -> Self
    func appendPart(WithText text: String, name: String, mimeType: MIMEType) -> Self
}

extension Data: MultiPartFormData {
    func appendPart(withFilePath path: String, name: String, fileName: String, mimeType: MIMEType = .stream) -> Data {
        return self
    }
    
    func appendPart(WithText text: String, name: String, mimeType: MIMEType = .text) -> Data {
        return self
    }
    
}
