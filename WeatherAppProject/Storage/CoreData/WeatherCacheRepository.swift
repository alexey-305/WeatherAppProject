import CoreData

final class WeatherCacheRepository {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }

    // MARK: - Save

    func save(items: [ForecastItem]) {
        clear()

        items.forEach { item in
            let entity = WeatherCacheEntity(context: context)
            entity.date        = item.date
            entity.temperature = item.temperature
            entity.condition   = item.condition
            entity.timestamp   = Date()
        }

        do {
            try context.save()
        } catch {
            print("CoreData save error:", error)
        }
    }

    // MARK: - Load

    func load() -> [ForecastItem] {
        let request: NSFetchRequest<WeatherCacheEntity> = WeatherCacheEntity.fetchRequest()
        // Сортируем по дате прогноза
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        do {
            return try context.fetch(request).map {
                ForecastItem(
                    date:        $0.date ?? Date(),
                    temperature: $0.temperature,
                    condition:   $0.condition ?? ""
                )
            }
        } catch {
            print("CoreData fetch error:", error)
            return []
        }
    }

    // MARK: - Clear

    private func clear() {
        let request: NSFetchRequest<NSFetchRequestResult> = WeatherCacheEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("CoreData clear error:", error)
        }
    }
}
