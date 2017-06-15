import WatchKit

let DEBUG = 1, INFO = 2, ERROR = 3
func myLog(_ lvl: Int, _ msg: String) {
    NSLog(msg)
    var lExtensionDelegate = WKExtension.shared().delegate as! ExtensionDelegate
    var lDate = Date()
    var lDateFormatter = DateFormatter()
    lDateFormatter.dateFormat = "HH:mm:ss.SSS"
    lExtensionDelegate.mLogs.append([lvl, "\(lDateFormatter.string(from: lDate)) \(msg)"]) 
}

func myLabelSetText(_ text: String) {
    DispatchQueue.main.async(execute: {
        () in
        var lInterfaceController = WKExtension.shared().rootInterfaceController as! InterfaceController
        var lDateFormatter = DateFormatter()
        lDateFormatter.dateFormat = "HH:mm:ss.SSS"
        lInterfaceController.mLabel.setText("\(lDateFormatter.string(from: Date()))\n" + text)
    })
}

extension Notification.Name {
    static let MyCdvScreenOn = Notification.Name("com.zpf.mycdvapp.screenon")
}
