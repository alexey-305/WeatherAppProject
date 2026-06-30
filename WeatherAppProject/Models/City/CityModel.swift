import Foundation

struct CityModel: Codable, Equatable, Identifiable {
    let id: UUID
    let name: String
    let lat: Double
    let lon: Double

    init(id: UUID = UUID(), name: String, lat: Double, lon: Double) {
        self.id = id
        self.name = name
        self.lat = lat
        self.lon = lon
    }
}
