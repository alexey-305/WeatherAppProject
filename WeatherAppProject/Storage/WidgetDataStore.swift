import Foundation

// MARK: - WidgetWeatherSnapshot

struct WidgetWeatherSnapshot: Codable {
    let cityName: String
    let temperature: Double
    let condition: String
    let tempMin: Double
    let tempMax: Double
    let updatedAt: Date
}

// MARK: - WidgetDataStore

enum WidgetDataStore {

    private static let suiteName = "group.com.yourcompany.WeatherAppProject"
    private static let key = "widget_weather_snapshot"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    static func save(_ snapshot: WidgetWeatherSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults?.set(data, forKey: key)
    }

    static func load() -> WidgetWeatherSnapshot? {
        guard let data = defaults?.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(WidgetWeatherSnapshot.self, from: data)
    }
}
