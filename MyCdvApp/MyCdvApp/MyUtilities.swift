let DEBUG = 1, INFO = 2, ERROR = 3


//类似Log.e()的功能
func myLog(_ lvl: Int, _ msg: String) {
    NSLog(msg)
    var lApplicationDelegate = UIApplication.shared.delegate as! ApplicationDelegate
    var lDateFormatter = DateFormatter()
    lDateFormatter.dateFormat = "HH:mm:ss.SSS"
    lApplicationDelegate.mLogs.append([lvl, "\(lDateFormatter.string(from: Date())) \(msg)"])
}

extension Notification.Name {
    static let MyCdvAppStateChanged = Notification.Name("com.zpf.mycdvapp.appstate")
    static let MyCdvModelStateChanged = Notification.Name("com.zpf.mycdvapp.modelstate")
    static let MyCdvAlertMessage = Notification.Name("com.zpf.mycdvapp.alertmessage")
    static let MyCdvScreenOn = Notification.Name("com.zpf.mycdvapp.screenon")
}
