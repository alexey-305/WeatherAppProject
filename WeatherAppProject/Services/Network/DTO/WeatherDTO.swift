import Foundation

struct WeatherDTO: Decodable {
    let list: [ForecastDTO]
}

struct ForecastDTO: Decodable {
    let dt: TimeInterval
    let main: MainDTO
    let weather: [WeatherInfoDTO]
}

struct MainDTO: Decodable {
    let temp: Double
}

struct WeatherInfoDTO: Decodable {
    let description: String
}
