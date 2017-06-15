//
//  RequestManager.swift
//  Sensor
//
//  Created by SH-DEV-5021 on 2017/5/26.
//  Copyright © 2017年 SH-DEV-5021. All rights reserved.
//

//处理request
import Foundation

let serverURL = "http://139.224.207.24:8000/"
let boundaryStr = "--"
let boundaryID = "silentjohn"

enum RequestError: Error, CustomStringConvertible {
    case invalidIMEI
    case invalidFilePath
    case invalidURL
    case invalidVersion
    case invalidUserId
    case invalidPassword
    
    public var description: String {
        switch self {
        case .invalidIMEI:
            return "Invalid IMEI"
        case .invalidFilePath:
            return "Invalid file path"
        case .invalidURL:
            return "Invalid URL"
        case .invalidVersion:
            return "Invalid version"
        case .invalidUserId:
            return "Invalid userid"
        case .invalidPassword:
            return "Invalid password"
        }
    }
}

class RequestManager {
    public enum RequestType {
        case auth
        case register
        
        fileprivate var urlForType: String {
            switch self {
            case .auth:
                return serverURL + "auth/"
            case .register:
                return serverURL + "register/"
            }
        }
    }
    
    private(set) var type: RequestType
    var filePath: String?
    var imei: String?
    var version: String?
    var userId: String?
    var password: String?
    
    init(type: RequestType) {
        self.type = type
    }
    
    func request(completion: @escaping (Data?) -> ()) throws {
        // construct request
        guard let requestURL = URL(string: type.urlForType) else {
            throw RequestError.invalidURL
        }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundaryID)", forHTTPHeaderField: "Content-Type")
        // construct POST body
        // 由于register和auth的post的body段都是userid和password，所以只有url不同，其他一致就能post，采用同一个post段就能发送信息
        // 返回结果，manager的回调函数中实现

            var requestData = Data()
            // Userid
            guard let userId = userId, userId != "" else {
                throw RequestError.invalidUserId
            }
            var userIdTop = String()
            userIdTop.append("\(boundaryStr)\(boundaryID)\r\n")
            userIdTop.append("Content-Disposition: form-data; name=\"userid\"\r\n\r\n")
            guard let userIdTopData = userIdTop.data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(userIdTopData)
            guard let userIdData = (userId + "\r\n").data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(userIdData)
            // Password
            guard let password = password, password != "" else {
                throw RequestError.invalidPassword
            }
            var passwordTop = String()
            passwordTop.append("\(boundaryStr)\(boundaryID)\r\n")
            passwordTop.append("Content-Disposition: form-data; name=\"password\"\r\n\r\n")
            guard let passwordTopData = passwordTop.data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(passwordTopData)
            guard let passwordData = (password + "\r\n").data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(passwordData)
            // bottom
            var bottom = String()
            bottom.append("\(boundaryStr)\(boundaryID)\(boundaryStr)\r\n")
            guard let bottomData = bottom.data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(bottomData)
            urlRequest.httpBody = requestData

        
        //这里需要加个互斥锁，当用户auth时，获得结果再考虑是否注册
        let semaphore = DispatchSemaphore(value: 0)
        
        let uploadTask = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if error == nil {
                print(urlResponse!)
            }
            if let rawData = data {
                completion(rawData);
            }
            semaphore.signal()
        }
        uploadTask.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
}

