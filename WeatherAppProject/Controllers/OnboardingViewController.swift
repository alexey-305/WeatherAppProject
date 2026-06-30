import UIKit

final class OnboardingViewController: UIViewController {

    var onFinish: ((Double, Double) -> Void)?

    // Теперь через сервисный слой, не напрямую CLLocationManager
    private let locationService = LocationService()

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
        setupUI()
        setupActions()
        setupLocationBindings()
    }

    // MARK: - Layout

    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(allowButton)
        view.addSubview(laterButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            laterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            laterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

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

    // MARK: - LocationService bindings

    private func setupLocationBindings() {
        locationService.onLocationUpdate = { [weak self] lat, lon in
            self?.finish(lat: lat, lon: lon)
        }
        locationService.onError = { [weak self] _ in
            // Отказ в доступе или сбой геолокации — идём с fallback
            self?.finish(lat: 55.7558, lon: 37.6176)
        }
    }

    // MARK: - Actions

    @objc private func didTapAllow() {
        // Сервис сам разруливает текущий статус: запросит разрешение если notDetermined,
        // или сразу вызовет requestLocation если уже разрешено (через
        // locationManagerDidChangeAuthorization внутри LocationService)
        locationService.requestPermission()
    }

    @objc private func didTapLater() {
        finish(lat: 55.7558, lon: 37.6176)
    }

    private func finish(lat: Double, lon: Double) {
        UserDefaults.standard.set(true, forKey: "isOnboardingShown")
        onFinish?(lat, lon)
    }
}
