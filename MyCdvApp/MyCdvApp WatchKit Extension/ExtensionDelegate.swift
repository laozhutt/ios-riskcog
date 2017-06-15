import WatchKit
import HealthKit

var gScreenOn = true
class ExtensionDelegate: NSObject, WKExtensionDelegate {
    var mLogs: [[Any]]!
    var mWatch: MyWatch!
    var mWorkout: MyWorkout!
    var mMotion: MyMotion!

    var mOperationQueue: OperationQueue!

    // WKExtensionDelegate
    func applicationDidFinishLaunching() {
        // MyRmtLog("\(#function)")
        mLogs = [[Any]]()
        mWatch = MyWatch()
        mWorkout = MyWorkout()
        mMotion = MyMotion()

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), nil, {
            (pCFNotificationCenter: CFNotificationCenter?, pUnsafeMutableRawPointer: UnsafeMutableRawPointer?, pCFNotificationName: CFNotificationName?, pUnsafeRawPointer: UnsafeRawPointer?, pCFDictionary: CFDictionary?) in
            gScreenOn = !gScreenOn
            if gScreenOn {
                NotificationCenter.default.post(name: .MyCdvScreenOn, object: nil)
            }
            // myLog(DEBUG, "CFNotificationCenter: \(gScreenOn)")
        }, "com.apple.springboard.lockstate" as CFString, nil, .deliverImmediately)
        mOperationQueue = OperationQueue()
        mOperationQueue.maxConcurrentOperationCount = 1
        NotificationCenter.default.addObserver(forName: .MyCdvScreenOn, object: nil, queue: mOperationQueue, using: {
            (pNotification: Notification) in
            // self.mMotion.mCollectAndTransferMotionData()
        })

    }
    func applicationWillEnterForeground() {
        // MyRmtLog("\(#function)")
    }
    func applicationDidBecomeActive() {
        // MyRmtLog("\(#function)")
    }
    func applicationWillResignActive() {
        // MyRmtLog("\(#function)")
    }
    func applicationDidEnterBackground() {
        // MyRmtLog("\(#function)")
    }
}
