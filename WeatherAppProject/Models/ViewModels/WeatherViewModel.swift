import Foundation

final class WeatherViewModel {

    // Теперь работаем через сервисный слой, а не напрямую с APIClient
    private let weatherService = WeatherService.shared
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
            onError?(NSError(domain: "WeatherViewModel", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Координаты не заданы"]))
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

    // MARK: - Network (через WeatherService)

    private func loadFromNetwork(lat: Double, lon: Double) {
        weatherService.fetchForecast(lat: lat, lon: lon) { [weak self] (result: Result<ForecastResponse, Error>) in
            guard let self else { return }

            switch result {
            case .success(let response):
                let mapped = WeatherMapper.map(response)
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

    var numberOfItems: Int { items.count }
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
