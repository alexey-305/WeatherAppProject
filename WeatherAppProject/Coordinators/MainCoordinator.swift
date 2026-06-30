import UIKit

final class MainCoordinator: Coordinator {

    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let initialLat: Double
    private let initialLon: Double
    private let initialName: String
    private weak var mainVC: MainViewController?

    init(navigationController: UINavigationController, name: String, lat: Double, lon: Double) {
        self.navigationController = navigationController
        self.initialName = name
        self.initialLat = lat
        self.initialLon = lon
    }

    func start() {
        let vc = MainViewController()
        vc.coordinator = self
        vc.configure(cities: [(name: initialName, lat: initialLat, lon: initialLon)])
        self.mainVC = vc

        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.setViewControllers([vc], animated: true)
    }

    // MARK: - Settings

    func showSettings() {
        let vc = SettingsViewController()
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.visibleViewController?.present(vc, animated: true)
    }

    // MARK: - Add City (через WeatherService.geocode, не CLGeocoder)

    func showAddCity(onAdded: @escaping (CityModel) -> Void) {
        let alert = UIAlertController(
            title: "Добавить город",
            message: "Введите название города",
            preferredStyle: .alert
        )
        alert.addTextField { tf in
            tf.placeholder = "Например: Москва"
            tf.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Добавить", style: .default) { [weak self, weak alert] _ in
            guard let self,
                  let text = alert?.textFields?.first?.text,
                  !text.isEmpty else { return }

            WeatherService.shared.geocode(city: text) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let geo):
                        onAdded(CityModel(name: geo.displayName, lat: geo.lat, lon: geo.lon))
                    case .failure(let error):
                        print("❌ Геокодинг ошибка:", error)
                        let err = UIAlertController(
                            title: "Город не найден",
                            message: "Проверьте название и попробуйте снова",
                            preferredStyle: .alert
                        )
                        err.addAction(UIAlertAction(title: "OK", style: .default))
                        self.navigationController.visibleViewController?.present(err, animated: true)
                    }
                }
            }
        })
        navigationController.visibleViewController?.present(alert, animated: true)
    }
}
