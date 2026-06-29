import Foundation

struct GeoResponse: Decodable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String?
}
