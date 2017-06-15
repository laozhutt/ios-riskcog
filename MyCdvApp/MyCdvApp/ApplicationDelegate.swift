import UIKit
import CoreMotion
import CoreLocation
import Alamofire

var gScreenOn = true
@UIApplicationMain
class ApplicationDelegate: CDVAppDelegate {
    var mLogs: [[Any]]!
    var mPhone: MyPhone!
    var mLocation: MyLocation!
    var mMotion: MyMotion!
    var mClient: MyClient!

    var mOperationQueue: OperationQueue!

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        NSLog("\(#function)")
        mLogs = [[Any]]()
        mPhone = MyPhone()
        mLocation = MyLocation()
        mMotion = MyMotion()
        mClient = MyClient()

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), nil, {
            (pCFNotificationCenter: CFNotificationCenter?, pUnsafeMutableRawPointer: UnsafeMutableRawPointer?, pCFNotificationName: CFNotificationName?, pUnsafeRawPointer: UnsafeRawPointer?, pCFDictionary: CFDictionary?) in
            gScreenOn = !gScreenOn
            if gScreenOn {
                NotificationCenter.default.post(name: .MyCdvScreenOn, object: nil)
            }
        }, "com.apple.springboard.lockstate" as CFString, nil, .deliverImmediately)
        mOperationQueue = OperationQueue()
        mOperationQueue.maxConcurrentOperationCount = 1
        NotificationCenter.default.addObserver(forName: .MyCdvScreenOn, object: nil, queue: mOperationQueue, using: {
            (pNotification: Notification) in
            //亮屏检测在下面三行代码定义，去掉注释可以实现
            
            /*
            if self.mClient.mDataSource == .PHONE && self.mClient.mAppState == .IDLE {
                self.mClient.mAppState = .COLLECT
                NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: self.mClient.mAppState)
            }
            */
            
        })

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func applicationWillEnterForeground(_ application: UIApplication) {
        NSLog("\(#function)")
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        NSLog("\(#function)")
    }

    override func applicationWillResignActive(_ application: UIApplication) {
        NSLog("\(#function)")
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        NSLog("\(#function)")
        NSLog("backgroundTimeRemaining: \(UIApplication.shared.backgroundTimeRemaining)")
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        NSLog("\(#function)")
        mClient.mSaveInfo()
    }
}
