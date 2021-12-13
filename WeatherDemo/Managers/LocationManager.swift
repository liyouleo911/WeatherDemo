//
//  LocationManager.swift
//  WeatherDemo
//
//  Created by Liyou on 2021/12/10.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    
    private let locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        return locationManager
    }()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var isLoading = false

    func requestLocation() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
            locationManager.delegate = self
            if locationManager.authorizationStatus != .notDetermined {
                isLoading = true
                locationManager.requestLocation()
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        debugPrint(#function)
        debugPrint("authorization status changed to \(status.rawValue)")
        if status != .notDetermined {
            isLoading = true
            manager.requestLocation()
        } else {
            location = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        debugPrint(#function)
        location = locations.first?.coordinate
        isLoading = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(#function)
        debugPrint("Error getting location: \(String(describing: error))")
        isLoading = false
    }
}
