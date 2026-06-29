import UIKit
import CoreLocation

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

    // MARK: - Add City

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

            print("🔍 Геокодируем:", text)

            CLGeocoder().geocodeAddressString(text) { placemarks, error in
                DispatchQueue.main.async {
                    if let place = placemarks?.first, let loc = place.location {
                        let name = place.locality ?? place.name ?? text
                        print("✅ Найден:", name)
                        onAdded(CityModel(name: name, lat: loc.coordinate.latitude, lon: loc.coordinate.longitude))
                    } else {
                        print("❌ Не найден:", error?.localizedDescription ?? "")
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
