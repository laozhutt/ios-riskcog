//
//  HttpRequest.swift
//  Sensor
//
//  Created by John on 2017/6/12.
//  Copyright © 2017年 SH-DEV-5021. All rights reserved.
//

import Foundation

public enum HttpMethod: String {
    case POST
    case GET
}

public enum MIMEType: String {
    case stream     = "application/octet-stream"
    case text       = "text/plain"
}

class HttpRequest {
    private var method: HttpMethod
    private var parameters: [[AnyHashable: Any]]
    private var formData: [[AnyHashable: Any]]
    init(method: HttpMethod, parameters: [[AnyHashable: Any]] = [], formData: [[AnyHashable: Any]] = []) {
        self.method = method
        self.parameters = parameters
        self.formData = formData
    }
}
