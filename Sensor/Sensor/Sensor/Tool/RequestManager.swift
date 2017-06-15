//
//  RequestManager.swift
//  Sensor
//
//  Created by SH-DEV-5021 on 2017/5/26.
//  Copyright © 2017年 SH-DEV-5021. All rights reserved.
//
//这个文件用来处理http的post请求，通过构造post报文，发给服务器，并获得返回JSON的结果

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
//POST请求包括三种处理，处理test，query，auth
//test 包含一个用户名以及测试文件，返回version
//query 包含一个用户名以及version
//auth  包含一个用户名以及密码
        case test
        case query
        case auth
//设置URL  
        fileprivate var urlForType: String {
            switch self {
            case .test:
                return serverURL + "test/"
            case .query:
                return serverURL + "query/"
            case .auth:
                return serverURL + "auth/"
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

//构造post主体的代码    
    func request(completion: @escaping (Data?) -> ()) throws {
        // construct request
        guard let requestURL = URL(string: type.urlForType) else {
            throw RequestError.invalidURL
        }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundaryID)", forHTTPHeaderField: "Content-Type")
        // construct POST body
        switch type {
            //构造test请求的post头
        case .test:
            guard let imei = imei, imei != "" else {
                throw RequestError.invalidIMEI
            }
            guard let filePath = filePath, FileManager.default.fileExists(atPath: filePath) else {
                throw RequestError.invalidFilePath
            }
            var requestData = Data()
            // imei data
            var imeiTop = String()
            imeiTop.append("\(boundaryStr)\(boundaryID)\r\n")
            imeiTop.append("Content-Disposition: form-data; name=\"imei\"\r\n\r\n")
            guard let imeiTopData = imeiTop.data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(imeiTopData)
            guard let imeiData = (imei + "\r\n").data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(imeiData)
            
            // file data
            var top = String()
            top.append("\(boundaryStr)\(boundaryID)\r\n")
            top.append("Content-Disposition: form-data; name=\"path\"; filename=\"\(filePath.substring(from: filePath.index(filePath.endIndex, offsetBy: -14)))\"\r\n")
            top.append("Content-Type: application/octet-stream\r\n\r\n")
            
            var bottom = String()
            bottom.append("\(boundaryStr)\(boundaryID)\(boundaryStr)\r\n")
            
            guard let topData = top.data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(topData)
            guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
                throw RequestError.invalidFilePath
            }
            requestData.append(fileData)
            guard let bottomData = bottom.data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(bottomData)
            
            urlRequest.httpBody = requestData
        case .query:
            //构造询问post请求
            guard let imei = imei, imei != "" else {
                throw RequestError.invalidIMEI
            }
            guard let version = version else {
                throw RequestError.invalidIMEI
            }
            var requestData = Data()
            // imei data
            var imeiTop = String()
            imeiTop.append("\(boundaryStr)\(boundaryID)\r\n")
            imeiTop.append("Content-Disposition: form-data; name=\"imei\"\r\n\r\n")
            guard let imeiTopData = imeiTop.data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(imeiTopData)
            guard let imeiData = (imei + "\r\n").data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(imeiData)
            
            // version data
            var versionTop = String()
            versionTop.append("\(boundaryStr)\(boundaryID)\r\n")
            versionTop.append("Content-Disposition: form-data; name=\"version\"\r\n\r\n")
            guard let versionTopData = versionTop.data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(versionTopData)
            guard let versionData = (version + "\r\n").data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(versionData)
            
            // bottom
            var bottom = String()
            bottom.append("\(boundaryStr)\(boundaryID)\(boundaryStr)\r\n")
            guard let bottomData = bottom.data(using: .utf8) else {
                print("Stupid error")
                return
            }
            requestData.append(bottomData)
            urlRequest.httpBody = requestData
        case .auth:
            //构造认证请求post
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
        }
        let uploadTask = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if error == nil {
                print(urlResponse!)
            }
            if let rawData = data {
                completion(rawData);
            }
            
        }
        uploadTask.resume()
    }
}
		
