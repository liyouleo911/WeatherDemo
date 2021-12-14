//
//  LocationManager.swift
//  WeatherDemo
//
//  Created by Liyou on 2021/12/10.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject, ObservableObject {
    
    private let locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        return locationManager
    }()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var isLoading = false
    
    var isLocationServiceDenied: Bool {
        locationManager.authorizationStatus == .denied ||
        locationManager.authorizationStatus == .restricted
    }
     
    var isLocationServiceAvailable: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse ||
        locationManager.authorizationStatus == .authorizedAlways
    }

    func requestLocation() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
            locationManager.delegate = self
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            } else {
                isLoading = true
                locationManager.requestLocation()
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        debugPrint(#function)
        if status != .notDetermined {
            isLoading = true
            manager.requestLocation()
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
