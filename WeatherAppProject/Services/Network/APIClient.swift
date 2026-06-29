import Foundation

final class APIClient {

    static let shared = APIClient()

    private init() {}

    func request<T: Decodable>(
        url: URL,
        completion: @escaping (Result<T, Error>) -> Void
    ) {

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: -1)))
                }
                return
            }

            // DEBUG: печать сырого ответа API
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API RESPONSE:")
                print(jsonString)
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded))
                }
            } catch {
                DispatchQueue.main.async {
                    print("DECODE ERROR:", error)
                    completion(.failure(error))
                }
            }

        }.resume()
    }
}
