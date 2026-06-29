import Foundation

struct ForecastResponse: Decodable {
    let list: [ForecastDTO]
}
