import CoreData

final class CityRepository {

    private let context = CoreDataStack.shared.context

    // MARK: - Add

    @discardableResult
    func addCity(_ model: CityModel) -> CityEntity {
        let city = CityEntity(context: context)
        city.id = model.id
        city.name = model.name
        city.lat = model.lat
        city.lon = model.lon
        save()
        return city
    }

    // MARK: - Fetch

    func fetchCities() -> [CityModel] {
        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        let result = (try? context.fetch(request)) ?? []
        return result.map { entity in
            CityModel(id: entity.id ?? UUID(), name: entity.name ?? "", lat: entity.lat, lon: entity.lon)
        }
    }

    // MARK: - Delete

    func deleteCity(withId id: UUID) {
        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            save()
        }
    }

    private func save() {
        CoreDataStack.shared.saveContext()
    }
}
