import Foundation

final class CityStorageService {

    private let key = "saved_cities"

    func loadCities() -> [CityModel] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        return (try? JSONDecoder().decode([CityModel].self, from: data)) ?? []
    }

    func saveCities(_ cities: [CityModel]) {
        guard let data = try? JSONEncoder().encode(cities) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func addCity(_ city: CityModel) {
        var cities = loadCities()
        cities.append(city)
        saveCities(cities)
    }
}
