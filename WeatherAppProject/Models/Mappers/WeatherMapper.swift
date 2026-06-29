import Foundation

final class WeatherMapper {

    static func map(_ dto: WeatherDTO) -> [ForecastItem] {
        dto.list.map { item in
            ForecastItem(
                date: Date(timeIntervalSince1970: item.dt),
                temperature: item.main.temp,
                condition: item.weather.first?.description ?? ""
            )
        }
    }
}
