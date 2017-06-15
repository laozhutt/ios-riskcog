import WatchKit
import WatchConnectivity

class MyWatch: NSObject, WCSessionDelegate {
    var mDispatchSourceTimer: DispatchSourceTimer!

    override init() {
        super.init()
        WCSession.default().delegate = self
        WCSession.default().activate()
        
        mDispatchSourceTimer = DispatchSource.makeTimerSource()
        mDispatchSourceTimer.setEventHandler(handler: {
            () in
            var lExtensionDelegate = WKExtension.shared().delegate as! ExtensionDelegate
            if lExtensionDelegate.mLogs.count != 0 {
                var lLogsCount = lExtensionDelegate.mLogs.count
                var lLogs = Array(lExtensionDelegate.mLogs[0 ..< lLogsCount])
                WCSession.default().sendMessage(["Logs": lLogs], replyHandler: {
                    (pMessage: [String : Any]) in
                    var lLogsCount = pMessage["LogsCount"] as! Int
                    lExtensionDelegate.mLogs.removeSubrange(0 ..< lLogsCount)
                }, errorHandler: {
                    (pError: Error) in
                    myLabelSetText("\(pError)")
                })
            }
        })
        mDispatchSourceTimer.scheduleRepeating(deadline: .now(), interval: .seconds(1))
        mDispatchSourceTimer.resume()
    }

    // WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        myLog(DEBUG, "\(#function): \(activationState.rawValue) \(error)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        myLabelSetText("\(message)")
        if message["Command"] != nil {
            var lExtensionDelegate = WKExtension.shared().delegate as! ExtensionDelegate
            var lCommand = message["Command"] as! String
            if lCommand == "Collect" {
                lExtensionDelegate.mMotion.mCollectAndTransferMotionData()
            }
            replyHandler(["Command": lCommand])
        }
    }
}
