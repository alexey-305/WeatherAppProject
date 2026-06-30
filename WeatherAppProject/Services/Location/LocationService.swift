import Foundation
import CoreLocation

final class LocationService: NSObject {

    private let manager = CLLocationManager()

    var onLocationUpdate: ((Double, Double) -> Void)?
    var onError: ((Error) -> Void)?

    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            // Уже разрешено ранее — locationManagerDidChangeAuthorization
            // может не сработать повторно на некоторых версиях iOS, дёргаем явно
            requestLocation()
        case .denied, .restricted:
            onError?(NSError(domain: "Location", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Доступ к геолокации запрещён"]))
        @unknown default:
            onError?(NSError(domain: "Location", code: -2))
        }
    }

    func requestLocation() {
        manager.requestLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        onLocationUpdate?(location.coordinate.latitude, location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onError?(error)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        case .denied, .restricted:
            onError?(NSError(domain: "Location", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Доступ запрещён"]))
        default:
            break
        }
    }
}
