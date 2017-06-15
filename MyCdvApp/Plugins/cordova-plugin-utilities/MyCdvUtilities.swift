@objc(MyCdvUtilities)
class MyCdvUtilities : CDVPlugin {
    var mLogCallbackId: String!
    var mDispatchSourceTimer: DispatchSourceTimer!

    var mAppStateCallbackId: String!
    var mModelStateCallbackId: String!
    var mAlertMessageCallbackId: String!
    var mOperationQueue: OperationQueue!

    // CDVPlugin，初始化信息
    override func pluginInitialize() {
        NSLog("\(#function)")
        mOperationQueue = OperationQueue()
        mOperationQueue.maxConcurrentOperationCount = 1
    }
    
    //当应用切换或关闭时，调用
    override func onReset() {
        NSLog("\(#function)")
        if mDispatchSourceTimer != nil {
            mDispatchSourceTimer.cancel()
        }
    }
    
    //长函数需要将mLogCallbackId保存下来，之后返回结果时使用mLogCallbackId来获取底层NsLog的结果
    func mRegisterLogListener(_ pCommand: CDVInvokedUrlCommand) {
        NSLog("\(#function)")
        mLogCallbackId = pCommand.callbackId
        mDispatchSourceTimer = DispatchSource.makeTimerSource()
        mDispatchSourceTimer.setEventHandler(handler: {
            () in
            var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
            if lApplicationDelegate.mLogs.count != 0 {
                var lLogsCount = lApplicationDelegate.mLogs.count
                var lLogs = Array(lApplicationDelegate.mLogs[0 ..< lLogsCount])
                var lPluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: lLogs)!
                lPluginResult.setKeepCallbackAs(true)
                self.commandDelegate.send(lPluginResult, callbackId: self.mLogCallbackId)
                lApplicationDelegate.mLogs.removeSubrange(0 ..< lLogsCount)
            }
        })
        mDispatchSourceTimer.scheduleRepeating(deadline: .now(), interval: .seconds(1))
        mDispatchSourceTimer.resume()
    }

    //长函数，会被经常调用，吧setKeepCallbackAs改为true，可以防止id被注销，不用申请过多id，通过mAppStateCallbackId来获取AppState的改变结果
    func mRegisterAppStateListener(_ pCommand: CDVInvokedUrlCommand) {
        NSLog("\(#function)")
        mAppStateCallbackId = pCommand.callbackId
        NotificationCenter.default.addObserver(forName: .MyCdvAppStateChanged, object: nil, queue: mOperationQueue, using: {
            (pNotification: Notification) in
            var lAppState = pNotification.object as! MyClient.MyAppState
            NSLog("CdvAppState: \(lAppState)")
            var lPluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: lAppState.rawValue)!
            lPluginResult.setKeepCallbackAs(true)
            self.commandDelegate.send(lPluginResult, callbackId: self.mAppStateCallbackId)
        })
    }

    //长函数，会被经常调用，吧setKeepCallbackAs改为true，可以防止id被注销，不用申请过多id，通过mAppStateCallbackId来获取modelState的改变结果
    func mRegisterModelStateListener(_ pCommand: CDVInvokedUrlCommand) {
        NSLog("\(#function)")
        mModelStateCallbackId = pCommand.callbackId
        NotificationCenter.default.addObserver(forName: .MyCdvModelStateChanged, object: nil, queue: mOperationQueue, using: {
            (pNotification: Notification) in
            var lModelState = pNotification.object as! MyClient.MyModelState
            var lPluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: lModelState.rawValue)!
            lPluginResult.setKeepCallbackAs(true)
            self.commandDelegate.send(lPluginResult, callbackId: self.mModelStateCallbackId)
        })
    }

    //短函数，只被调用一次，结束会将callBackId注销，不会造成大量资源消耗，每次执行采集操作时被调用（锁屏或button）
    func mStart(_ pCommand: CDVInvokedUrlCommand) {
        NSLog("\(#function)")
        var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
        lApplicationDelegate.mClient.mAppState = .COLLECT
        NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: lApplicationDelegate.mClient.mAppState)
        commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: pCommand.callbackId)
    }
    
    //长函数，注册弹窗警告的callbackid
    func mRegisterAlertMessageListener(_ pCommand: CDVInvokedUrlCommand) {
        NSLog("\(#function)")
        mAlertMessageCallbackId = pCommand.callbackId
        NotificationCenter.default.addObserver(forName: .MyCdvAlertMessage, object: nil, queue: mOperationQueue, using: {
            (pNotification: Notification) in
            var lPluginResult = CDVPluginResult(status: CDVCommandStatus_OK)!
            lPluginResult.setKeepCallbackAs(true)
            self.commandDelegate.send(lPluginResult, callbackId: self.mAlertMessageCallbackId)
        })
    }

    //manul fix按钮触发时响应这个函数
    func mManualFixUserIdentity(_ pCommand: CDVInvokedUrlCommand) {
        NSLog("\(#function)")
        var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
        lApplicationDelegate.mClient.mAppState = .FIX
        var lSignal = pCommand.arguments.first as! String
        NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: lApplicationDelegate.mClient.mAppState, userInfo: ["signal": lSignal])
        commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: pCommand.callbackId)
    }

    //搜集不上传，collect之后通过这个函数回到IDLE
    func mReset(_ pCommand: CDVInvokedUrlCommand) {
        NSLog("\(#function)")
        var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
        lApplicationDelegate.mClient.mAppState = .IDLE
        NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: lApplicationDelegate.mClient.mAppState)
        commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: pCommand.callbackId)
    }

    //data source按钮状态改变时响应这个函数
    func mSetDataSource(_ pCommand: CDVInvokedUrlCommand) {
        NSLog("\(#function)")
        var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
        lApplicationDelegate.mClient.mDataSource = MyClient.MyDataSource(rawValue: pCommand.arguments.first as! String)!
        commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: pCommand.callbackId)
    }
    
    //Detect model按钮状态改变时响应这个函数
    func mSetDetectMode(_ pCommand: CDVInvokedUrlCommand) {
        NSLog("\(#function)")
        var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
        lApplicationDelegate.mClient.mDetectMode = MyClient.MyDetectMode(rawValue: pCommand.arguments.first as! String)!
        commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: pCommand.callbackId)
    }

    //判断用户是否存在，在程序开始时若检测到用户存在（存在文件中），则登陆否则需要输入用户密码账号，在html里
    func mIsUserExist(_ pCommand: CDVInvokedUrlCommand) {
        NSLog("\(#function)")
        var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
        var lPluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: lApplicationDelegate.mClient.mUsername != "")!
        commandDelegate.send(lPluginResult, callbackId: pCommand.callbackId)
    }

    //在检测时（manul fix里面），要检测用户信息时使用
    func mGetUserInfo(_ pCommand: CDVInvokedUrlCommand) {
        NSLog("\(#function)")
        var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
        var lPluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: [lApplicationDelegate.mClient.mUsername, lApplicationDelegate.mClient.mPassword])!
        commandDelegate.send(lPluginResult, callbackId: pCommand.callbackId)
    }
       

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
                ret = code
                
            }
        }catch{
            
        }
        return ret;
    }
    
    func register(userid:String , passwd:String) -> Int
    {
        NSLog("\(#function)")
        let codeKey     = "Code"
        let messageKey  = "Massage"
        let loginManager = RequestManager(type: .register)
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
                ret = code
                
            }
        }catch{
            
        }
        return ret;
    }
    
    //注册用户信息时，需要把用户信息存到文件中
    func mSetUserInfo(_ pCommand: CDVInvokedUrlCommand) {
        NSLog("\(#function)")
        var mUsername : String = pCommand.arguments[0] as! String
        var mPassword : String = pCommand.arguments[1] as! String

        //加入认证过程
        var ret = auth(userid: mUsername, passwd: mPassword)
        print (ret)
        if (ret == 0){
            var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
            lApplicationDelegate.mClient.mUsername = mUsername
            lApplicationDelegate.mClient.mPassword = mPassword
        }
        
        //-1是用户没有注册
        if (ret == -1){
            register(userid: mUsername, passwd: mPassword)
            var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
            lApplicationDelegate.mClient.mUsername = mUsername
            lApplicationDelegate.mClient.mPassword = mPassword
        }
        commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: pCommand.callbackId)


    }

    //已废弃
    func mGetMonitorList(_ pCommand: CDVInvokedUrlCommand) {
        NSLog("\(#function)")
        var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
        var lPluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: [])!
        commandDelegate.send(lPluginResult, callbackId: pCommand.callbackId)
    }
}
