import CoreLocation
import CoreMotion

struct Sample: Encodable {
    let timestamp: Date
    let pressure: Double
    let relativeAltitude: Double
    let altitude: Double
    let latitude: Double
    let longitude: Double
    let horizontalAccuracy: Double
    let verticalAccuracy: Double
    let name: String
}

extension Sample {
    init(data: CMAltitudeData, location: CLLocation, name: String = "", timestamp: Date = Date()) {
        self.timestamp = timestamp
        pressure = data.pressure.doubleValue
        relativeAltitude = data.relativeAltitude.doubleValue
        altitude = location.altitude
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        horizontalAccuracy = location.horizontalAccuracy
        verticalAccuracy = location.verticalAccuracy
        self.name = name
    }
}
