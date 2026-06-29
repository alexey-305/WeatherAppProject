import Foundation

final class WeatherService {

    static let shared = WeatherService()

    private init() {}

    private var apiKey: String {
        SecretsManager.shared.getAPIKey(for: "OpenWeatherAPIKey") ?? ""
    }

    func fetchForecast(
        lat: Double,
        lon: Double,
        completion: @escaping (Result<ForecastResponse, Error>) -> Void
    ) {
        let urlString =
        "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=ru"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "URL", code: -1)))
            return
        }

        APIClient.shared.request(url: url, completion: completion)
    }

    func geocode(
        city: String,
        completion: @escaping (Result<GeoResponse, Error>) -> Void
    ) {

        let encoded =
            city.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ) ?? city

        let urlString =
        "https://api.openweathermap.org/geo/1.0/direct?q=\(encoded)&limit=1&appid=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "URL", code: -1)))
            return
        }

        APIClient.shared.request(url: url) {
            (result: Result<[GeoResponse], Error>) in

            switch result {
            case .success(let items):
                if let first = items.first {
                    completion(.success(first))
                } else {
                    completion(
                        .failure(
                            NSError(domain: "Geo", code: -2)
                        )
                    )
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
