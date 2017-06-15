import CoreMotion

class MyMotion: NSObject {
    struct MyDeviceMotion {
        var mAcceleration = CMAcceleration()
        var mRotationRate = CMRotationRate()
        var mGravity = CMAcceleration()
    }
    let GRAVITY = -9.81
    var mMotionManager: CMMotionManager!
    var mOperationQueue: OperationQueue!
    var mDeviceMotion: MyDeviceMotion!

    var mDispatchSourceTimer: DispatchSourceTimer!
    var mCollecting: Bool!

    override init() {
        super.init()
        mMotionManager = CMMotionManager()
        mMotionManager.deviceMotionUpdateInterval = 1.0 / 100
        mOperationQueue = OperationQueue()
        mOperationQueue.maxConcurrentOperationCount = 1

        mDeviceMotion = MyDeviceMotion()
        mMotionManager.startDeviceMotionUpdates(to: mOperationQueue, withHandler: {
            (pDeviceMotion: CMDeviceMotion?, pError: Error?) in
            self.mDeviceMotion.mAcceleration.x = (pDeviceMotion!.userAcceleration.x + pDeviceMotion!.gravity.x) * self.GRAVITY
            self.mDeviceMotion.mAcceleration.y = (pDeviceMotion!.userAcceleration.y + pDeviceMotion!.gravity.y) * self.GRAVITY
            self.mDeviceMotion.mAcceleration.z = (pDeviceMotion!.userAcceleration.z + pDeviceMotion!.gravity.z) * self.GRAVITY
            self.mDeviceMotion.mRotationRate.x = pDeviceMotion!.rotationRate.x
            self.mDeviceMotion.mRotationRate.y = pDeviceMotion!.rotationRate.y
            self.mDeviceMotion.mRotationRate.z = pDeviceMotion!.rotationRate.z
            self.mDeviceMotion.mGravity.x = pDeviceMotion!.gravity.x * self.GRAVITY
            self.mDeviceMotion.mGravity.y = pDeviceMotion!.gravity.y * self.GRAVITY
            self.mDeviceMotion.mGravity.z = pDeviceMotion!.gravity.z * self.GRAVITY
        })
        // mMotionManager.stopDeviceMotionUpdates()
        mCollecting = false
    }

    func mCollectData() {
        if mCollecting == true {
            return
        }
        mCollecting = true
        var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
        var lClient = lApplicationDelegate.mClient!
        lClient.mDataCount = 0
        mDispatchSourceTimer = DispatchSource.makeTimerSource()
        mDispatchSourceTimer.setEventHandler(handler: {
            () in
            if lClient.mDataCount < lClient.DATA_COUNT_MAX {
                lClient.mAccelerationData[3 * lClient.mDataCount] = self.mDeviceMotion.mAcceleration.x
                lClient.mAccelerationData[3 * lClient.mDataCount + 1] = self.mDeviceMotion.mAcceleration.y
                lClient.mAccelerationData[3 * lClient.mDataCount + 2] = self.mDeviceMotion.mAcceleration.z
                lClient.mRotationRateData[3 * lClient.mDataCount] = self.mDeviceMotion.mRotationRate.x
                lClient.mRotationRateData[3 * lClient.mDataCount + 1] = self.mDeviceMotion.mRotationRate.y
                lClient.mRotationRateData[3 * lClient.mDataCount + 2] = self.mDeviceMotion.mRotationRate.z
                lClient.mGravityData[3 * lClient.mDataCount] = self.mDeviceMotion.mGravity.x
                lClient.mGravityData[3 * lClient.mDataCount + 1] = self.mDeviceMotion.mGravity.y
                lClient.mGravityData[3 * lClient.mDataCount + 2] = self.mDeviceMotion.mGravity.z
                lClient.mDataCount! += 1
            } else {
                self.mDispatchSourceTimer.cancel()
                self.mCollecting = false
                if lClient.mDataSource == .PHONE && lClient.mAppState == .COLLECT {
                    lApplicationDelegate.mClient.mAppState = .SAVE
                    NotificationCenter.default.post(name: .MyCdvAppStateChanged, object: lApplicationDelegate.mClient.mAppState)
                }
            }
        })
        mDispatchSourceTimer.scheduleRepeating(deadline: .now(), interval: .milliseconds(1000 / 50))
        mDispatchSourceTimer.resume()
    }
}
