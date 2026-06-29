import UIKit
import CoreLocation

final class AppCoordinator {

    private let navigationController: UINavigationController
    private var mainCoordinator: MainCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        let isShown = UserDefaults.standard.bool(forKey: "isOnboardingShown")
        isShown ? showMain(name: "Москва", lat: 55.7558, lon: 37.6176) : showOnboarding()
    }

    private func showOnboarding() {
        let vc = OnboardingViewController()
        vc.onFinish = { [weak self] lat, lon in
            // Геокодируем координаты в название
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: lat, longitude: lon)) { placemarks, _ in
                DispatchQueue.main.async {
                    let name = placemarks?.first?.locality ?? "Мой город"
                    self?.showMain(name: name, lat: lat, lon: lon)
                }
            }
        }
        navigationController.setViewControllers([vc], animated: false)
    }

    private func showMain(name: String, lat: Double, lon: Double) {
        let coordinator = MainCoordinator(
            navigationController: navigationController,
            name: name,
            lat: lat,
            lon: lon
        )
        self.mainCoordinator = coordinator
        coordinator.start()
    }
}
