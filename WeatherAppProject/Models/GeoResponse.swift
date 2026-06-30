import Foundation

struct GeoResponse: Decodable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String?
    let localNames: [String: String]?

    enum CodingKeys: String, CodingKey {
        case name, lat, lon, country
        case localNames = "local_names"
    }

    /// Русское название если есть в local_names, иначе оригинальное name
    var displayName: String {
        localNames?["ru"] ?? name
    }
}
