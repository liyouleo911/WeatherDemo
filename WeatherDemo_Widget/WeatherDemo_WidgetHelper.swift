//
//  WeatherDemo_WidgetHelper.swift
//  WeatherDemo_WidgetExtension
//
//  Created by Liyou on 2022/3/16.
//

import Foundation
import CoreLocation

class WidgetLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager? {
        didSet {
            guard let locationManager = locationManager else {
                return
            }
            locationManager.delegate = self
        }
    }
    private var handler: ((CLLocation?) -> Void)?
    func fetchLocation(handler: @escaping (CLLocation?) -> Void) {
        self.handler = handler
        locationManager?.requestLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            handler?(nil)
            return
        }
        handler?(location)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        handler?(nil)
    }
}
