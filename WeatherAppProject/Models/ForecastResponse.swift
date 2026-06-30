import Foundation

struct ForecastResponse: Decodable {
    let list: [ForecastDTO]
    let city: CityDTO?
}

struct ForecastDTO: Decodable {
    let dt: TimeInterval
    let main: MainDTO
    let weather: [WeatherInfoDTO]
    let wind: WindDTO?
    let clouds: CloudsDTO?
    let pop: Double?
    let dtTxt: String?

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, wind, clouds, pop
        case dtTxt = "dt_txt"
    }
}

struct MainDTO: Decodable {
    let temp: Double
    let humidity: Int?
    let pressure: Int?
}

struct WeatherInfoDTO: Decodable {
    let description: String
    let icon: String?
}

struct WindDTO: Decodable {
    let speed: Double
    let deg: Int?
}

struct CloudsDTO: Decodable {
    let all: Int?
}

struct CityDTO: Decodable {
    let name: String
    let sunrise: TimeInterval?
    let sunset: TimeInterval?
}
