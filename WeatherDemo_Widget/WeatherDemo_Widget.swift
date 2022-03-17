//
//  WeatherDemo_Widget.swift
//  WeatherDemo_Widget
//
//  Created by Liyou on 2022/3/16.
//

import WidgetKit
import SwiftUI
import CoreLocation

struct Provider: TimelineProvider {
    
    var widgetLocationManager = WidgetLocationManager()
    var weatherManager = WeatherManager()
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), location: "", temp: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), location: "", temp: "")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        if widgetLocationManager.locationManager == nil {
            widgetLocationManager.locationManager = CLLocationManager()
        }
        widgetLocationManager.fetchLocation(handler: { clLocation in
            guard let clLocation = clLocation else {
                let currentDate = Date()
                let timeline = Timeline(entries: [SimpleEntry(date: currentDate, location: "", temp: "")], policy: .after(currentDate.addingTimeInterval(5 * 60)))
                completion(timeline)
                return
            }
            Task {
                do {
                    let weather = try await weatherManager.getCurrentWeather(latitude: clLocation.coordinate.latitude, longitude: clLocation.coordinate.longitude)
                    var entries: [SimpleEntry] = []
                    
                    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
                    let currentDate = Date()
                    for hourOffset in 0 ..< 5 {
                        let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                        let entry = SimpleEntry(date: entryDate, location: weather.name, temp: weather.main.feelsLike.roundDouble())
                        entries.append(entry)
                    }
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    completion(timeline)
                } catch {
                    print("Error getting weather: \(error)")
                    let currentDate = Date()
                    let timeline = Timeline(entries: [SimpleEntry(date: currentDate, location: "", temp: "")], policy: .after(currentDate.addingTimeInterval(5 * 60)))
                    completion(timeline)
                }
            }
        })
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let location: String
    let temp: String
}

struct WeatherDemo_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.date, style: .time)
            Spacer()
            Text(entry.location)
            Text(entry.temp + "°")
                .font(.system(size: 50))
                .fontWeight(.bold)
        }
        .padding()
    }
}

@main
struct WeatherDemo_Widget: Widget {
    let kind: String = "WeatherDemo_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherDemo_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct WeatherDemo_Widget_Previews: PreviewProvider {
    static var previews: some View {
        WeatherDemo_WidgetEntryView(entry: SimpleEntry(date: Date(), location: "Huai'an", temp: "20"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
