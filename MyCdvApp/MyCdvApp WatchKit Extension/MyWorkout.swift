import HealthKit

class MyWorkout: NSObject, HKWorkoutSessionDelegate {
    var mWorkoutSession: HKWorkoutSession!
    var mHealthStore: HKHealthStore!

    override init() {
        super.init()
        var lWorkoutConfiguration = HKWorkoutConfiguration()
        lWorkoutConfiguration.activityType = .other
        lWorkoutConfiguration.locationType = .unknown
        mWorkoutSession = try! HKWorkoutSession(configuration: lWorkoutConfiguration)
        mWorkoutSession.delegate = self
        mHealthStore = HKHealthStore()
        mHealthStore.start(mWorkoutSession)
        // mHKHealthStore.end(mWorkoutSession)
    }

    // HKWorkoutSessionDelegate
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // MyRmtLog("\(#function): \(fromState.rawValue) \(toState.rawValue)")
    }
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        // MyRmtLog("\(#function): \(event)")
    }
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // MyRmtLog("\(#function): \(error)")
    }
}
