import WidgetKit
import SwiftUI
// MARK: - Timeline Entry
struct WeatherEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetWeatherSnapshot?
}
// MARK: - Provider
struct WeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), snapshot: WidgetWeatherSnapshot(
            cityName: "Москва",
            temperature: 22,
            condition: "Ясно",
            tempMin: 18,
            tempMax: 25,
            updatedAt: Date()
        ))
    }
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        completion(WeatherEntry(date: Date(), snapshot: WidgetDataStore.load()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        let entry = WeatherEntry(date: Date(), snapshot: WidgetDataStore.load())
        // Просим систему обновить виджет через час
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}
// MARK: - Widget View
struct WeatherWidgetView: View {
    let entry: WeatherEntry
    @Environment(\.widgetFamily) var family
    var body: some View {
        if let snapshot = entry.snapshot {
            switch family {
            case .systemSmall:
                SmallWidgetView(snapshot: snapshot)
            case .systemMedium:
                MediumWidgetView(snapshot: snapshot)
            default:
                SmallWidgetView(snapshot: snapshot)
            }
        } else {
            NoDataView()
        }
    }
}
// MARK: - Small Widget (2x2)
struct SmallWidgetView: View {
    let snapshot: WidgetWeatherSnapshot
    var body: some View {
        ZStack {
            // Синий градиент как в основном приложении
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.33, blue: 0.60),
                    Color(red: 0.18, green: 0.45, blue: 0.75)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(alignment: .leading, spacing: 4) {
                // Город
                Text(snapshot.cityName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
                Spacer()
                // Иконка погоды
                Text(weatherEmoji(for: snapshot.condition))
                    .font(.system(size: 36))
                Spacer()
                // Температура
                Text("\(Int(snapshot.temperature))°")
                    .font(.system(size: 44, weight: .thin))
                    .foregroundColor(.white)
                // Условие
                Text(snapshot.condition)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                // Мин/Макс
                Text("Мин: \(Int(snapshot.tempMin))° Макс: \(Int(snapshot.tempMax))°")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(12)
        }
    }
}
// MARK: - Medium Widget (4x2)
struct MediumWidgetView: View {
    let snapshot: WidgetWeatherSnapshot
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.33, blue: 0.60),
                    Color(red: 0.18, green: 0.45, blue: 0.75)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            HStack(spacing: 0) {
                // Левая часть — температура и город
                VStack(alignment: .leading, spacing: 4) {
                    Text(snapshot.cityName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                    Spacer()
                    Text("\(Int(snapshot.temperature))°")
                        .font(.system(size: 52, weight: .thin))
                        .foregroundColor(.white)
                    Text(snapshot.condition)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                .padding(12)
                Spacer()
                // Правая часть — иконка и мин/макс
                VStack(alignment: .trailing, spacing: 8) {
                    Text(weatherEmoji(for: snapshot.condition))
                        .font(.system(size: 48))
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Макс: \(Int(snapshot.tempMax))°")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        Text("Мин: \(Int(snapshot.tempMin))°")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(12)
            }
        }
    }
}
// MARK: - No Data View
struct NoDataView: View {
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.33, blue: 0.60)
            VStack(spacing: 8) {
                Text("🌤")
                    .font(.system(size: 32))
                Text("Откройте приложение\nдля загрузки погоды")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
}
// MARK: - Helpers
private func weatherEmoji(for condition: String) -> String {
    let lower = condition.lowercased()
    if lower.contains("ясно") || lower.contains("clear") { return "☀️" }
    if lower.contains("небольшая облачность") { return "🌤" }
    if lower.contains("переменная") { return "⛅️" }
    if lower.contains("облачно") || lower.contains("пасмурно") { return "☁️" }
    if lower.contains("дождь") || lower.contains("rain") { return "🌧" }
    if lower.contains("гроза") || lower.contains("thunder") { return "⛈" }
    if lower.contains("снег") || lower.contains("snow") { return "❄️" }
    if lower.contains("туман") || lower.contains("fog") { return "🌫" }
    return "🌤"
}
// MARK: - Widget Configuration
struct WeatherWidget: Widget {
    let kind = "WeatherWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Погода")
        .description("Текущая погода для вашего города")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
