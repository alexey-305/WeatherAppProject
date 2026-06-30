import Foundation

final class WeatherMapper {

    static func map(_ response: ForecastResponse) -> [ForecastItem] {
        response.list.map { item in
            ForecastItem(
                date: Date(timeIntervalSince1970: item.dt),
                temperature: item.main.temp,
                condition: item.weather.first?.description ?? ""
            )
        }
    }
}
