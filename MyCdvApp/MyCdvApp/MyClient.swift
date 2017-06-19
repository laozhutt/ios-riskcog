import CoreFoundation
import CoreMotion
import CoreLocation
import Alamofire
import WatchConnectivity
import UserNotifications

class MyClient: NSObject {
    var mClientInfo: NSMutableDictionary!
    var mUsername: String!
    var mPassword: String!

    enum MyDataSource: String { case PHONE = "Phone", WATCH = "Watch" }
    var mDataSource: MyDataSource!
    enum MyDetectMode: String { case ONLINE = "Online", OFFLINE = "Offline" }
    var mDetectMode: MyDetectMode!

    //采集数据的数量15s 每秒采集50次
    let DATA_COUNT_MAX = 50 * 3
    var mDataCount: Int!
    var mAccelerationData: [Double]!
    var mRotationRateData: [Double]!
    var mGravityData: [Double]!

    var mServerURL: String!
    enum MyAppState: Int { case IDLE = 1, COLLECT, SAVE, UPLOAD, ASK, QUERY, CHECK, FIX }
    var mAppState: MyAppState!
    enum MyModelState: Int { case NONE = 1, SIT_MODEL_EXIST, WALK_MODEL_EXIST, MODEL_EXIST, SIT_TRAINED, WALK_TRAINED, TRAINED }
    var mModelState: MyModelState!
    var mOperationQueue: OperationQueue!
    var mPath: String!
    var mVersion: String!

    override init() {
        super.init()
        mLoadInfo()

        mDataSource = .PHONE
        mDetectMode = .ONLINE

        mAccelerationData = [Double](repeating: 0, count: 3 * DATA_COUNT_MAX)
        mRotationRateData = [Double](repeating: 0, count: 3 * DATA_COUNT_MAX)
        mGravityData = [Double](repeating: 0, count: 3 * DATA_COUNT_MAX)

        // mServerURL = "http://garuda.cs.northwestern.edu:8081"
        mServerURL = "http://139.224.207.24:8000"
        mAppState = .IDLE
        mOperationQueue = OperationQueue()
        mOperationQueue.maxConcurrentOperationCount = 1
        //状态机申明
        NotificationCenter.default.addObserver(forName: .MyCdvAppStateChanged, object: nil, queue: mOperationQueue, using: {
            (pNotification: Notification) in
            var lAppState = pNotification.object as! MyAppState
            switch lAppState {
            case .IDLE: break
            case .COLLECT:
                self.mCollectData()
            case .SAVE:
                self.mSaveData()
            case .UPLOAD:
                var lFile = pNotification.userInfo!["file"] as! URL
                self.mUploadData(lFile)
            case .ASK:
                var lVersion = pNotification.userInfo!["version"] as! String
                self.mAskTrained(lVersion)
            case .QUERY:
                var lVersion = pNotification.userInfo!["version"] as! String
                self.mQueryData(lVersion, 0)
            case .CHECK:
                break
            case .FIX:
                var lSignal = pNotification.userInfo!["signal"] as! String
                self.mManualFix(lSignal)
            }
        })
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: {
            (pBool: Bool, pError: Error?) in
        })
    }

    func mLoadInfo() {
        var lDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var lFil = lDir.appendingPathComponent("ClientInfo.txt")
        
        //post
        
        if FileManager.default.fileExists(atPath: lFil.path) {
            mClientInfo = NSMutableDictionary(contentsOfFile: lFil.path)!
            mUsername = mClientInfo["Username"] as! String
            mPassword = mClientInfo["Password"] as! String
            mModelState = MyModelState(rawValue: mClientInfo["ModelState"] as! Int)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
                () in
                NotificationCenter.default.post(name: .MyCdvModelStateChanged, object: self.mModelState)
            })
        } else {
            mClientInfo = NSMutableDictionary()
            mUsername = ""
            mPassword = ""
            mModelState = .NONE
        }
    }
    
    //对用户名 密码进行认证的函数
    func auth(userid:String , passwd:String) -> Int
    {
        NSLog("\(#function)")
        let codeKey     = "Code"
        let messageKey  = "Massage"
        let loginManager = RequestManager(type: .auth)
        loginManager.userId = userid
        loginManager.password = passwd
        //        print(userid);
        var ret = -10
        do{
            try loginManager.request(){jsonData in
                guard let json = jsonData else {
                    return
                }
                guard let object = try? JSONSerialization.jsonObject(with: json, options: []), let dic = object as? [AnyHashable:Any] else {
                    return
                }
                guard let code = dic[codeKey] as? Int else {
                    return
                }
                if (code==0) {
                    ret = code
                }
            }
        }catch{
            
        }
        return ret;
    }
    

    func mSaveInfo() {
        var lDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var lFil = lDir.appendingPathComponent("ClientInfo.txt")
        mClientInfo["Username"] = mUsername as NSString
        mClientInfo["Password"] = mPassword as NSString
        mClientInfo["ModelState"] = mModelState.rawValue as NSNumber
        mClientInfo.write(toFile: lFil.path, atomically: true)
    }

    //响应状态机Collect的函数
    func mCollectData() {
        var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
        switch mDataSource! {
        case .PHONE:
            lApplicationDelegate.mMotion.mCollectData()
        case .WATCH:
            WCSession.default().sendMessage(["Command": "Collect"], replyHandler: {
                (pMessage: [String : Any]) in
                myLog(DEBUG, "Watch Receive: \(pMessage)")
            }, errorHandler: {
                (pError: Error) in
                myLog(ERROR, "\(pError)")
                self.mAppState = .IDLE
                NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState)
            })
        }
    }

    func mSaveData() {
        var lDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var lFil = lDir.appendingPathComponent("\(Date()).txt")
        var lStr = ""
        for i in 0 ..< mDataCount {
            lStr += "\(mAccelerationData[3 * i])\n\(mAccelerationData[3 * i + 1])\n\(mAccelerationData[3 * i + 2])\n"
            lStr += "\(mRotationRateData[3 * i])\n\(mRotationRateData[3 * i + 1])\n\(mRotationRateData[3 * i + 2])\n"
            lStr += "\(mGravityData[3 * i])\n\(mGravityData[3 * i + 1])\n\(mGravityData[3 * i + 2])\n"
        }
        try! lStr.write(toFile: lFil.path, atomically: true, encoding: .utf8)
        NSLog("\(#function)")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
            () in
            self.mAppState = .UPLOAD
            //self.mAppState = .IDLE
            NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState, userInfo: ["file": lFil])
        })
    }

    func mUploadData(_ pFile: URL) {
        switch mModelState! {
        case .NONE, .SIT_MODEL_EXIST, .WALK_MODEL_EXIST:
            mPath = "/train/"
        case .MODEL_EXIST, .SIT_TRAINED, .WALK_TRAINED:
            if mPath == nil {
                mPath = "/train"
            }
            if mPath == "/train/" {
                mPath = "/test/"
            } else /* if path == "/test/" */ {
                mPath = "/train/"
            }
        case .TRAINED:
            mPath = "/test/"
        }
        upload(multipartFormData: {
            (pMultipartFormData: MultipartFormData) in
            pMultipartFormData.append(self.mUsername.data(using: .utf8)!, withName: "imei")
            pMultipartFormData.append(pFile, withName: "path")
        }, to: mServerURL + mPath, encodingCompletion: {
            (pMultipartFormDataEncodingResult: SessionManager.MultipartFormDataEncodingResult) in
            switch pMultipartFormDataEncodingResult {
            case var .success(pUploadRequest, pBool, pURL):
                pUploadRequest.validate().validate(statusCode: 200 ..< 300).validate(contentType: ["application/json"])
                pUploadRequest.responseJSON(queue: DispatchQueue.global(qos: .utility), completionHandler: {
                    (pDataResponse: DataResponse) in
                    if pDataResponse.result.isSuccess {
                        var lRes = pDataResponse.result.value as! [String: Any]
                        myLog(INFO, "\(lRes)")
                        print (lRes)
                        var lVersion: String
                        var lResult : String = "-1"
                        
                        //lResult = String(lRes["result"] as! Int)
                        //lVersion = String(lRes["max_version"] as! Int)
                        //print (lResult)
                        
                        
                        if (!(lRes.keys.contains("result") || lRes.keys.contains("max_version"))) {
                            self.mAppState = .IDLE
                            NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState)
                        }else {
                            if (lRes.keys.contains("result")){
                                lResult = String(lRes["result"] as! Int)
                            }
                            if (lRes.keys.contains("result") && lResult == "-1"){
                                self.mAppState = .IDLE
                                NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState)
                            }else {
                                switch self.mModelState! {
                                case .NONE, .SIT_MODEL_EXIST, .WALK_MODEL_EXIST, .MODEL_EXIST, .SIT_TRAINED, .WALK_TRAINED:
                                    self.mAppState = .ASK
                                    if self.mPath == "/train/" {
                                        lVersion = String(lRes["numfiles"] as! Int)
                                    } else /* if path == "/test/" */ {
                                        lVersion = String(lRes["max_version"] as! Int)
                                    }
                                case .TRAINED:
                                    self.mAppState = .QUERY
                                    lVersion = String(lRes["max_version"] as! Int)
                                    print (lVersion)
                                }
                        
                            NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState, userInfo: ["version": lVersion])
                            }
                        }
                    } else {
                        myLog(ERROR, "\(pDataResponse.result.error!)")
                        self.mAppState = .IDLE
                        NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState)
                    }
                })
            case var .failure(pError):
                myLog(INFO, "\(pError)")
            }
        })
    }

    func mAskTrained(_ pVersion: String) {
        upload(multipartFormData: {
            (pMultipartFormData: MultipartFormData) in
            pMultipartFormData.append(self.mUsername.data(using: .utf8)!, withName: "imei")
            pMultipartFormData.append(pVersion.data(using: .utf8)!, withName: "version")
        }, to: mServerURL + "/ask_trained/", encodingCompletion: {
            (pMultipartFormDataEncodingResult: SessionManager.MultipartFormDataEncodingResult) in
            switch pMultipartFormDataEncodingResult {
            case var .success(pUploadRequest, pBool, pURL):
                pUploadRequest.validate().validate(statusCode: 200 ..< 300).validate(contentType: ["application/json"])
                pUploadRequest.responseJSON(queue: DispatchQueue.global(qos: .utility), completionHandler: {
                    (pDataResponse: DataResponse) in
                    if pDataResponse.result.isSuccess {
                        var lRes = pDataResponse.result.value as! [String: Any]
                        myLog(INFO, "\(lRes)")
                        if lRes["sit_model_exist"] as! Bool {
                            if self.mModelState == .NONE {
                                self.mModelState = .SIT_MODEL_EXIST
                            } else if self.mModelState == .WALK_MODEL_EXIST {
                                self.mModelState = .MODEL_EXIST
                            }
                        }
                        if lRes["walk_model_exist"] as! Bool {
                            if self.mModelState == .NONE {
                                self.mModelState = .WALK_MODEL_EXIST
                            } else if self.mModelState == .SIT_MODEL_EXIST {
                                self.mModelState = .MODEL_EXIST
                            }
                        }
                        if lRes["sit_trained"] as! Bool {
                            if self.mModelState == .MODEL_EXIST {
                                self.mModelState = .SIT_TRAINED
                            } else if self.mModelState == .WALK_TRAINED {
                                self.mModelState = .TRAINED
                            }
                        }
                        if lRes["walk_trained"] as! Bool {
                            if self.mModelState == .MODEL_EXIST {
                                self.mModelState = .WALK_TRAINED
                            } else if self.mModelState == .SIT_TRAINED {
                                self.mModelState = .TRAINED
                            }
                        }
                        NotificationCenter.default.post(name: .MyCdvModelStateChanged, object: self.mModelState)
                        self.mAppState = .IDLE
                        NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState)
                    } else {
                        myLog(ERROR, "\(pDataResponse.result.error!)")
                        self.mAppState = .IDLE
                        NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState)
                    }
                })
            case var .failure(pError):
                myLog(INFO, "\(pError)")
            }
        })
    }
    
    
//查询结果
    func mQueryData(_ pVersion: String, _ pCount: Int) {
        print ("xxx")
        print (pVersion)
        
        upload(multipartFormData: {
            (pMultipartFormData: MultipartFormData) in
            pMultipartFormData.append(self.mUsername.data(using: .utf8)!, withName: "imei")
            pMultipartFormData.append(pVersion.data(using: .utf8)!, withName: "version")
        }, to: mServerURL + "/query/", encodingCompletion: {
            (pMultipartFormDataEncodingResult: SessionManager.MultipartFormDataEncodingResult) in
            switch pMultipartFormDataEncodingResult {
            case var .success(pUploadRequest, pBool, pURL):
                pUploadRequest.validate().validate(statusCode: 200 ..< 300).validate(contentType: ["application/json"])
                pUploadRequest.responseJSON(queue: DispatchQueue.global(qos: .utility), completionHandler: {
                    (pDataResponse: DataResponse) in
                    if pDataResponse.result.isSuccess {
                        var lRes = pDataResponse.result.value as! [String: Any]
                        myLog(INFO, "\(lRes)")
                        if lRes["version"] != nil {
                            var lResult = lRes["result"] as! String
                            var lIndex1 = lResult.range(of: "sit_accuracy=")!
                            var lIndex2 = lResult.range(of: ",walk_accuracy=")!
                            var lIndex3 = lResult.range(of: "\n")!
                            var lSubStr1 = lResult.substring(with: lIndex1.upperBound ..< lIndex2.lowerBound)
                            var lSubStr2 = lResult.substring(with: lIndex2.upperBound ..< lIndex3.lowerBound)
                            var lSitAccuracy = Double(lSubStr1)!
                            var lWalkAccuracy = Double(lSubStr2)!
                            var lAccuracy = max(lSitAccuracy, lWalkAccuracy)
                            if lAccuracy < 0.7 {
                                self.mVersion = pVersion
                                self.mCheckAndSelect()
                                self.mAppState = .CHECK
                                NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState)
                            } else {
                                self.mAppState = .IDLE
                                NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState)
                            }
                        } else if pCount < 5 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                () in
                                self.mQueryData(pVersion, pCount + 1)
                            })
                        } else {
                            self.mAppState = .IDLE
                            NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState)
                        }
                    } else {
                        myLog(ERROR, "\(pDataResponse.result.error!)")
                        self.mAppState = .IDLE
                        NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState)
                    }
                })
            case var .failure(pError):
                myLog(ERROR, "\(pError)")
            }
        })
    }

    func mCheckAndSelect() {
        NotificationCenter.default.post(name: .MyCdvAlertMessage, object: nil)
        if UIApplication.shared.applicationState == .background {
            let lUNMutableNotificationContent = UNMutableNotificationContent()
            lUNMutableNotificationContent.title = "Alert!"
            lUNMutableNotificationContent.body = "Detect Malicious User! Please Check Identity!"
            let lUNTimeIntervalNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let lUNNotificationRequest = UNNotificationRequest(identifier: "Alert", content: lUNMutableNotificationContent, trigger: lUNTimeIntervalNotificationTrigger)
            let lUNUserNotificationCenter = UNUserNotificationCenter.current()
            lUNUserNotificationCenter.add(lUNNotificationRequest)
        }
    }

    func mManualFix(_ pSignal: String) {
        upload(multipartFormData: {
            (pMultipartFormData: MultipartFormData) in
            pMultipartFormData.append(self.mUsername.data(using: .utf8)!, withName: "imei")
            pMultipartFormData.append(self.mVersion.data(using: .utf8)!, withName: "version")
            pMultipartFormData.append(pSignal.data(using: .utf8)!, withName: "signal")
        }, to: mServerURL + "/manual_fix/", encodingCompletion: {
            (pMultipartFormDataEncodingResult: SessionManager.MultipartFormDataEncodingResult) in
            switch pMultipartFormDataEncodingResult {
            case var .success(pUploadRequest, pBool, pURL):
                
                //去掉注释可以实现manul fix功能
                
                /*
                pUploadRequest.validate().validate(statusCode: 200 ..< 300).validate(contentType: ["application/json"])
                pUploadRequest.responseJSON(queue: DispatchQueue.global(qos: .utility), completionHandler: {
                    (pDataResponse: DataResponse) in
                    if pDataResponse.result.isSuccess {
                        var lRes = pDataResponse.result.value as! [String: Any]
                        myLog(INFO, "\(lRes)")
                        self.mAppState = .IDLE
                        NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState)
                    } else {
                        myLog(ERROR, "\(pDataResponse.result.error!)")
                        self.mAppState = .IDLE
                        NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState)
                    }
                })
                */
                self.mAppState = .IDLE
                NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mAppState)
            case var .failure(pError):
                myLog(ERROR, "\(pError)")
            }
        })
    }

    func mOfflineDetect() {
        
    }


}
