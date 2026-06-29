import CoreData

final class CityRepository {

    private let context = CoreDataStack.shared.context

    func addCity(name: String, lat: Double, lon: Double) {
        let city = CityEntity(context: context)
        city.id = UUID()
        city.name = name
        city.lat = lat
        city.lon = lon
        save()
    }

    func fetchCities() -> [CityEntity] {
        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }

    func deleteCity(_ city: CityEntity) {
        context.delete(city)
        save()
    }

    private func save() {
        CoreDataStack.shared.saveContext()
    }
}
