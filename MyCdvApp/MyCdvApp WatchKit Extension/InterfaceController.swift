import WatchKit

class InterfaceController: WKInterfaceController {
    @IBOutlet var mLabel: WKInterfaceLabel!

    // WKInterfaceController
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    override func willActivate() {
        super.willActivate()
    }
    override func didDeactivate() {
        super.didDeactivate()
    }
}
