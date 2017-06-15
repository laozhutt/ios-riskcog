import CoreFoundation
import CoreMotion
import WatchConnectivity

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

    let DATA_COUNT_MAX = 50 * 15
    var mDataCount: Int!
    var mUserAccelerationData: [Double]!
    var mRotationRateData: [Double]!
    var mGravityData: [Double]!
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

        mUserAccelerationData = [Double](repeating: 0, count: 3 * DATA_COUNT_MAX)
        mRotationRateData = [Double](repeating: 0, count: 3 * DATA_COUNT_MAX)
        mGravityData = [Double](repeating: 0, count: 3 * DATA_COUNT_MAX)
        mCollecting = false
    }

    func mCollectAndTransferMotionData() {
        if mCollecting == true {
            return
        }
        mCollecting = true
        mDataCount = 0
        mDispatchSourceTimer = DispatchSource.makeTimerSource()
        mDispatchSourceTimer.setEventHandler(handler: {
            () in
            if (self.mDataCount < self.DATA_COUNT_MAX) {
                self.mUserAccelerationData[3 * self.mDataCount] = self.mDeviceMotion.mAcceleration.x
                self.mUserAccelerationData[3 * self.mDataCount + 1] = self.mDeviceMotion.mAcceleration.y
                self.mUserAccelerationData[3 * self.mDataCount + 2] = self.mDeviceMotion.mAcceleration.z
                self.mRotationRateData[3 * self.mDataCount] = self.mDeviceMotion.mRotationRate.x
                self.mRotationRateData[3 * self.mDataCount + 1] = self.mDeviceMotion.mRotationRate.y
                self.mRotationRateData[3 * self.mDataCount + 2] = self.mDeviceMotion.mRotationRate.z
                self.mGravityData[3 * self.mDataCount] = self.mDeviceMotion.mGravity.x
                self.mGravityData[3 * self.mDataCount + 1] = self.mDeviceMotion.mGravity.y
                self.mGravityData[3 * self.mDataCount + 2] = self.mDeviceMotion.mGravity.z
                self.mDataCount! += 1
            } else {
                self.mDispatchSourceTimer.cancel()
                WCSession.default().sendMessage([
                    "DataCount": self.mDataCount,
                    "UserAccelerationData": self.mUserAccelerationData,
                    "RotationRateData": self.mRotationRateData,
                    "GravityData": self.mGravityData
                ], replyHandler: {
                    (pMessage: [String : Any]) in
                    myLabelSetText("Phone Receive: \(pMessage)")
                }, errorHandler: {
                    (pError: Error) in
                    myLabelSetText("\(pError)")
                })
                self.mCollecting = false
            }
        })
        mDispatchSourceTimer.scheduleRepeating(deadline: .now(), interval: .milliseconds(1000 / 50))
        mDispatchSourceTimer.resume()
    }
}
