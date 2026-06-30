import UIKit

final class MainViewController: UIViewController {

    weak var coordinator: MainCoordinator?

    private let cityRepository = CityRepository()
    private var cities: [(name: String, lat: Double, lon: Double)] = []
    private var pageViewControllers: [CityWeatherViewController] = []
    private var currentIndex = 0

    // MARK: - UI

    private let pageVC = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )

    private let pageControl: UIPageControl = {
        let p = UIPageControl()
        p.currentPageIndicatorTintColor = UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 1)
        p.pageIndicatorTintColor = UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 0.3)
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()

    // MARK: - Init

    /// Начальный (геолокационный или дефолтный) город — добавляется только если
    /// в CoreData ещё ничего не сохранено
    func configure(cities: [(name: String, lat: Double, lon: Double)]) {
        self.cities = cities
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)
        setupNavigation()
        setupPageVC()
        loadPersistedCities()
        buildPages()
    }

    // MARK: - Persistence

    private func loadPersistedCities() {
        let saved = cityRepository.fetchCities()
        if !saved.isEmpty {
            // CoreData главнее дефолтного города из координатора
            cities = saved.map { (name: $0.name, lat: $0.lat, lon: $0.lon) }
        } else if let first = cities.first {
            // Первый запуск — сохраняем геолокационный город в CoreData
            cityRepository.addCity(CityModel(name: first.name, lat: first.lat, lon: first.lon))
        }
    }

    // MARK: - Navigation

    private func setupNavigation() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.tintColor = UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 1)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "location"),
            style: .plain,
            target: self,
            action: #selector(addCityTapped)
        )
    }

    // MARK: - PageVC Setup

    private func setupPageVC() {
        addChild(pageVC)
        view.addSubview(pageVC.view)
        view.addSubview(pageControl)
        pageVC.didMove(toParent: self)

        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        pageVC.dataSource = self
        pageVC.delegate = self

        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            pageVC.view.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 4),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func buildPages() {
        pageViewControllers = cities.map { city in
            let vc = CityWeatherViewController()
            vc.cityName = city.name
            vc.coordinator = coordinator
            let vm = WeatherViewModel()
            vm.setLocation(lat: city.lat, lon: city.lon)
            vc.viewModel = vm
            return vc
        }

        pageControl.numberOfPages = pageViewControllers.count
        pageControl.currentPage = 0

        if let first = pageViewControllers.first {
            pageVC.setViewControllers([first], direction: .forward, animated: false)
            navigationItem.title = cities.first?.name ?? ""
        }
    }

    func addCity(name: String, lat: Double, lon: Double) {
        cities.append((name: name, lat: lat, lon: lon))

        // Сохраняем в CoreData — переживёт перезапуск приложения
        cityRepository.addCity(CityModel(name: name, lat: lat, lon: lon))

        let vc = CityWeatherViewController()
        vc.cityName = name
        vc.coordinator = coordinator
        let vm = WeatherViewModel()
        vm.setLocation(lat: lat, lon: lon)
        vc.viewModel = vm
        pageViewControllers.append(vc)

        pageControl.numberOfPages = pageViewControllers.count

        currentIndex = pageViewControllers.count - 1
        pageVC.setViewControllers([vc], direction: .forward, animated: true)
        pageControl.currentPage = currentIndex
        navigationItem.title = name
    }

    // MARK: - Actions

    @objc private func settingsTapped() {
        coordinator?.showSettings()
    }

    @objc private func addCityTapped() {
        coordinator?.showAddCity { [weak self] city in
            self?.addCity(name: city.name, lat: city.lat, lon: city.lon)
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension MainViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? CityWeatherViewController,
              let index = pageViewControllers.firstIndex(of: vc),
              index > 0 else { return nil }
        return pageViewControllers[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? CityWeatherViewController,
              let index = pageViewControllers.firstIndex(of: vc),
              index < pageViewControllers.count - 1 else { return nil }
        return pageViewControllers[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension MainViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let current = pageViewController.viewControllers?.first as? CityWeatherViewController,
              let index = pageViewControllers.firstIndex(of: current) else { return }
        currentIndex = index
        pageControl.currentPage = index
        navigationItem.title = cities[index].name
    }
}
