import Foundation

final class WeatherViewModel {

    private let network = APIClient.shared
    private let cache = WeatherCacheRepository()

    private(set) var items: [ForecastItem] = []

    var onDataUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?

    private var lat: Double?
    private var lon: Double?

    // MARK: - Public

    func setLocation(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }

    func loadInitialData() {
        loadFromCache()

        guard let lat, let lon else {
            onError?(NSError(domain: "WeatherViewModel", code: -1))
            return
        }

        loadFromNetwork(lat: lat, lon: lon)
    }

    // MARK: - Cache

    private func loadFromCache() {
        let cached = cache.load()

        if !cached.isEmpty {
            self.items = cached
            self.onDataUpdate?()
        }
    }

    private func saveToCache(_ items: [ForecastItem]) {
        cache.save(items: items)
    }

    // MARK: - Network

    private func loadFromNetwork(lat: Double, lon: Double) {

        guard let url = URL(string:
            "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(SecretsManager.shared.getAPIKey(for: "OpenWeatherAPIKey") ?? "")&units=metric&lang=ru"
        ) else {
            return
        }

        network.request(url: url) { [weak self] (result: Result<WeatherDTO, Error>) in
            guard let self else { return }

            switch result {
            case .success(let dto):
                let mapped = WeatherMapper.map(dto)

                self.items = mapped
                self.saveToCache(mapped)
                self.onDataUpdate?()

            case .failure(let error):
                self.onError?(error)
            }
        }
    }

    // MARK: - Access

    func item(at index: Int) -> ForecastItem? {
        guard index >= 0, index < items.count else { return nil }
        return items[index]
    }

    var numberOfItems: Int {
        items.count
    }
}

// MARK: - Daily grouping
extension WeatherViewModel {
    func dailyItems() -> [[ForecastItem]] {
        var groups: [String: [ForecastItem]] = [:]
        let df = DateFormatter()
        df.dateFormat = "dd.MM"
        for item in items {
            let key = df.string(from: item.date)
            groups[key, default: []].append(item)
        }
        return groups.keys.sorted().compactMap { groups[$0] }
    }
}
