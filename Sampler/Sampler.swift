import Foundation
import CoreLocation
import CoreMotion

protocol SamplerDelegate: class {
    func sampler(_ sampler: Sampler, didAdd sample: Sample)
}

class Sampler: NSObject {
    weak var delegate: SamplerDelegate?
    var locationName: String = ""

    let queue: OperationQueue
    let altimeter: CMAltimeter
    let locationManager: CLLocationManager
    
    fileprivate(set) var isRecording = false
    fileprivate(set) var recentLocation:CLLocation?
    fileprivate(set) var samples: [Sample] = [] {
        didSet {
            guard let sample = samples.last else { return }
            DispatchQueue.main.async {
                self.delegate?.sampler(self, didAdd: sample)
            }
        }
    }
    
    init(queue: OperationQueue = OperationQueue.AltimeterQueue,
         altimeter: CMAltimeter = CMAltimeter(),
         locationManager: CLLocationManager) {
        self.queue = queue
        self.altimeter = altimeter
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
    }
}

extension Sampler {
    func requestLocationPermissionIfNeeded() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func clearSamples() {
        samples = []
    }
    
    func samplingAvailable() -> Bool {
        return CMAltimeter.isRelativeAltitudeAvailable() &&
            CLLocationManager.locationServicesEnabled()
    }
    
    func startSampling() {
        guard samplingAvailable() else { return }
        requestLocationPermissionIfNeeded()
        isRecording = true
        altimeter.startRelativeAltitudeUpdates(to: queue,
                                               withHandler: { [weak self] in self?.altitudeUpdated($0, $1) })
        locationManager.startUpdatingLocation()
    }
    
    func stopSampling() {
        isRecording = false
        altimeter.stopRelativeAltitudeUpdates()
        locationManager.stopUpdatingLocation()
    }
    
    func altitudeUpdated(_ data: CMAltitudeData?, _ error: Error?) {
        guard error == nil else { print(error!.localizedDescription); return; }
        guard let data = data else { return }
        guard let location = recentLocation else { return }
        let sample = Sample(data: data, location: location, name: locationName)
        samples.append(sample)
    }
}

extension Sampler: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        recentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard isRecording &&
            status == .authorizedAlways ||
            status == .authorizedWhenInUse
            else { return }
        locationManager.startUpdatingLocation()
    }
}
