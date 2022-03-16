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
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), latitude: "", longitude: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), latitude: "", longitude: "")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        if widgetLocationManager.locationManager == nil {
            widgetLocationManager.locationManager = CLLocationManager()
        }
        widgetLocationManager.fetchLocation(handler: { clLocation in
            print(clLocation)
            var entries: [SimpleEntry] = []
            
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            let currentDate = Date()
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, latitude: String(format: "%.2lf", clLocation.coordinate.latitude), longitude: String(format: "%.2lf", clLocation.coordinate.longitude))
                entries.append(entry)
            }
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        })
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let latitude: String
    let longitude: String
}

struct WeatherDemo_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.date, style: .time)
            Text(entry.latitude)
            Text(entry.longitude)
        }
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
        WeatherDemo_WidgetEntryView(entry: SimpleEntry(date: Date(), latitude: "", longitude: ""))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
