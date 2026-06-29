import Foundation

final class SecretsManager {

    static let shared = SecretsManager()

    private init() {}

    func getAPIKey(for key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) else {
            print("⚠️ Secrets.plist не найден!")
            return nil
        }

        return dict[key] as? String
    }
}
