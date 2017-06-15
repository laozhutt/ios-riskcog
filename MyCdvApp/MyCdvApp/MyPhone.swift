import WatchConnectivity

class MyPhone: NSObject, WCSessionDelegate {
    override init() {
        super.init()
        WCSession.default().delegate = self
        WCSession.default().activate()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("\(#function): \(activationState.rawValue) \(error)")
    }
    func sessionDidBecomeInactive(_ session: WCSession) {
        NSLog("\(#function)")
    }
    func sessionDidDeactivate(_ session: WCSession) {
        NSLog("\(#function)")
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if message["Logs"] != nil {
            var lLogs = message["Logs"] as! [[Any]]
            for lLog in lLogs {
                myLog(lLog[0] as! Int, lLog[1] as! String)
            }
            replyHandler(["LogsCount": lLogs.count])
        } else if message["DataCount"] != nil {
            myLog(DEBUG, "Phone Receive: DataCount = \(message["DataCount"] as! Int)")
            var lDataCount = message["DataCount"] as! Int
            var lUserAccelerationData = message["UserAccelerationData"] as! [Double]
            var lRotationRateData = message["RotationRateData"] as! [Double]
            var lGravityData = message["GravityData"] as! [Double]
            var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
            var lClient = lApplicationDelegate.mClient!
            lClient.mDataCount = lDataCount
            for i in 0 ..< 3 * lDataCount {
                lClient.mAccelerationData[i] = lUserAccelerationData[i]
                lClient.mRotationRateData[i] = lRotationRateData[i]
                lClient.mGravityData[i] = lGravityData[i]
            }
            var lValid = ""
            if lClient.mAppState == .IDLE || lClient.mAppState == .COLLECT {
                if lClient.mDataSource == .WATCH {
                    lValid = "Valid"
                    lClient.mAppState = .SAVE
                    NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: lClient.mAppState)
                } else {
                    lValid = "Unused"
                }
            } else {
                lValid = "Busy"
            }
            replyHandler(["DataCount": lDataCount, "Valid": lValid])
        }
    }
}
