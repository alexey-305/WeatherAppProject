import UIKit

final class MainViewController: UIViewController {

    weak var coordinator: MainCoordinator?

    private let cityRepository = CityRepository()

    // Теперь храним полноценные CityModel (с id) вместо анонимных кортежей,
    // чтобы можно было находить и удалять конкретный город в CoreData
    private var cities: [CityModel] = []
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

    /// Начальный (геолокационный или дефолтный) город — используется только если
    /// в CoreData ещё ничего не сохранено
    func configure(cities: [(name: String, lat: Double, lon: Double)]) {
        self.cities = cities.map { CityModel(name: $0.name, lat: $0.lat, lon: $0.lon) }
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
            cities = saved
        } else if let first = cities.first {
            // Первый запуск — сохраняем геолокационный город в CoreData
            cityRepository.addCity(first)
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
        pageViewControllers = cities.map { makePage(for: $0) }

        pageControl.numberOfPages = pageViewControllers.count
        pageControl.currentPage = 0

        if let first = pageViewControllers.first {
            pageVC.setViewControllers([first], direction: .forward, animated: false)
            navigationItem.title = cities.first?.name ?? ""
        }
    }

    /// Единая точка создания страницы города — используется и при первой
    /// сборке, и при добавлении нового города, чтобы не дублировать конфигурацию
    private func makePage(for city: CityModel) -> CityWeatherViewController {
        let vc = CityWeatherViewController()
        vc.cityName = city.name
        vc.coordinator = coordinator
        let vm = WeatherViewModel()
        vm.setLocation(lat: city.lat, lon: city.lon)
        vc.viewModel = vm
        vc.onDeleteRequested = { [weak self, weak vc] in
            guard let self, let vc else { return }
            self.deleteCity(city, pageVC: vc)
        }
        return vc
    }

    func addCity(name: String, lat: Double, lon: Double) {
        let city = CityModel(name: name, lat: lat, lon: lon)
        cities.append(city)

        // Сохраняем в CoreData — переживёт перезапуск приложения
        cityRepository.addCity(city)

        let vc = makePage(for: city)
        pageViewControllers.append(vc)

        pageControl.numberOfPages = pageViewControllers.count

        currentIndex = pageViewControllers.count - 1
        pageVC.setViewControllers([vc], direction: .forward, animated: true)
        pageControl.currentPage = currentIndex
        navigationItem.title = name
    }

    // MARK: - Delete

    private func deleteCity(_ city: CityModel, pageVC removedVC: CityWeatherViewController) {
        guard let index = pageViewControllers.firstIndex(of: removedVC) else { return }

        // Не даём удалить последний оставшийся город — приложению нужен хотя бы один
        guard cities.count > 1 else {
            let alert = UIAlertController(
                title: "Нельзя удалить",
                message: "Должен остаться хотя бы один город",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        cityRepository.deleteCity(withId: city.id)
        cities.remove(at: index)
        pageViewControllers.remove(at: index)

        pageControl.numberOfPages = pageViewControllers.count

        // После удаления показываем соседнюю страницу — предыдущую, если есть,
        // иначе следующую (если удаляли первую)
        let newIndex = min(index, pageViewControllers.count - 1)
        currentIndex = newIndex
        pageControl.currentPage = newIndex

        let direction: UIPageViewController.NavigationDirection = index == 0 ? .forward : .reverse
        pageVC.setViewControllers([pageViewControllers[newIndex]], direction: direction, animated: true)
        navigationItem.title = cities[newIndex].name
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
