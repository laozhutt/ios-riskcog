import CoreLocation

class MyLocation: NSObject, CLLocationManagerDelegate {
    var mLocationManager: CLLocationManager!

    override init() {
        super.init()
        mLocationManager = CLLocationManager()
        mLocationManager.requestAlwaysAuthorization()
        mLocationManager.delegate = self
        mLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        mLocationManager.distanceFilter = kCLDistanceFilterNone
        mLocationManager.allowsBackgroundLocationUpdates = true
        mLocationManager.startUpdatingLocation()
        // mLocationManager.stopUpdatingLocation()
    }

    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("\(#function): \(locations.last!)")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("\(#function): \(error)")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        NSLog("\(#function): \(status.rawValue)")
    }
}
