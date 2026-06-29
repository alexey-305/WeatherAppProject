import UIKit
import CoreLocation

final class OnboardingViewController: UIViewController {

    var onFinish: ((Double, Double) -> Void)?
    private let locationManager = CLLocationManager()

    // MARK: - UI

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "onboarding_bg")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Разрешите приложению Weather использовать данные о местоположении вашего устройства"
        l.textColor = .white
        l.font = .boldSystemFont(ofSize: 20)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.text = "Чтобы получать более точный прогноз погоды во время движения или путешествия.\n\nВы можете изменить свой выбор в любое время в меню приложения."
        l.textColor = .white
        l.font = .systemFont(ofSize: 14)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let allowButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("ИСПОЛЬЗОВАТЬ МЕСТОПОЛОЖЕНИЕ УСТРОЙСТВА", for: .normal)
        b.backgroundColor = .white
        b.setTitleColor(UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 1), for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 14)
        b.titleLabel?.adjustsFontSizeToFitWidth = true
        b.titleLabel?.minimumScaleFactor = 0.7
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let laterButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("НЕТ, Я БУДУ ДОБАВЛЯТЬ ЛОКАЦИИ", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 1.0)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        setupUI()
        setupActions()
    }

    // MARK: - Layout

    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(allowButton)
        view.addSubview(laterButton)

        NSLayoutConstraint.activate([
            // Картинка сверху
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            // Заголовок — опустили ниже
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Описание под заголовком
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Кнопка "Нет" — подняли выше
            laterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            laterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Кнопка "Разрешить" — над кнопкой "Нет"
            allowButton.bottomAnchor.constraint(equalTo: laterButton.topAnchor, constant: -12),
            allowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            allowButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            allowButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

    private func setupActions() {
        allowButton.addTarget(self, action: #selector(didTapAllow), for: .touchUpInside)
        laterButton.addTarget(self, action: #selector(didTapLater), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func didTapAllow() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            finish(lat: 55.7558, lon: 37.6176)
        @unknown default:
            finish(lat: 55.7558, lon: 37.6176)
        }
    }

    @objc private func didTapLater() {
        finish(lat: 55.7558, lon: 37.6176)
    }

    private func finish(lat: Double, lon: Double) {
        UserDefaults.standard.set(true, forKey: "isOnboardingShown")
        onFinish?(lat, lon)
    }
}

// MARK: - CLLocationManagerDelegate

extension OnboardingViewController: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            finish(lat: 55.7558, lon: 37.6176)
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            finish(lat: 55.7558, lon: 37.6176)
            return
        }
        finish(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(lat: 55.7558, lon: 37.6176)
    }
}
