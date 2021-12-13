//
//  ContentView.swift
//  WeatherDemo
//
//  Created by Liyou on 2021/12/10.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var locationManager = LocationManager()
    var weatherManager = WeatherManager()
    @State var weather: ResponseBody?
    @State var firstWeather = true
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        VStack {
            if let location = locationManager.location {
                if locationManager.isLoading {
                    if let weather = weather {
                        WeatherView(weather: weather)
                    } else {
                        ProgressView()
                    }
                } else {
                    if let weather = weather {
                        WeatherView(weather: weather)
                            .task {
                                guard !firstWeather else {
                                    firstWeather = false
                                    return
                                }
                                do {
                                    self.weather = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                                } catch {
                                    print("Error getting weather: \(error)")
                                }
                            }
                    } else {
                        ProgressView()
                            .task {
                                do {
                                    weather = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                                } catch {
                                    print("Error getting weather: \(error)")
                                    locationManager.location = nil
                                }
                            }
                    }
                }
            } else {
                if locationManager.isLoading {
                    ProgressView()
                } else {
                    WelcomeView()
                        .environmentObject(locationManager)
                }
            }
        }
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
        .preferredColorScheme(.dark)
        .onChange(of: scenePhase) { newPhase in
            guard let _ = locationManager.location else {
                return
            }
            if scenePhase == .background, newPhase == .inactive {
                locationManager.requestLocation()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
