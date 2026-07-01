import UIKit
import WidgetKit

final class CityWeatherViewController: UIViewController {

    var cityName: String = ""
    var viewModel = WeatherViewModel()
    weak var coordinator: MainCoordinator?

    /// Вызывается по долгому нажатию на карточку погоды — родитель показывает
    /// подтверждение и удаляет город
    var onDeleteRequested: (() -> Void)?

    /// Главный (первый) город — только для него пишем снимок в WidgetDataStore,
    /// иначе свайп между городами будет дёргать виджет на каждый
    var isPrimaryCity: Bool = false

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.showsVerticalScrollIndicator = false
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let weatherCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 1.0)
        v.layer.cornerRadius = 16
        v.isUserInteractionEnabled = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let minMaxLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let tempLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 64)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let conditionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let windLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let humidityLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let separatorLine: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let sunriseLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .white
        l.numberOfLines = 2
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateTimeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let sunsetLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .white
        l.numberOfLines = 2
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let detailButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Подробнее на 24 часа", for: .normal)
        b.setTitleColor(UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 1), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 68, height: 90)
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let dailyTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Ежедневный прогноз"
        l.font = .boldSystemFont(ofSize: 18)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let daysButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("25 дней", for: .normal)
        b.setTitleColor(UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 1), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let tableView: UITableView = {
        let t = UITableView()
        t.isScrollEnabled = false
        t.separatorStyle = .none
        t.backgroundColor = .clear
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()

    private var tableHeightConstraint: NSLayoutConstraint?
    private var showAllDays = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)
        setupUI()
        setupBindings()
        setupDeleteGesture()
        viewModel.loadInitialData()
    }

    // MARK: - Layout

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(weatherCard)
        weatherCard.addSubview(minMaxLabel)
        weatherCard.addSubview(tempLabel)
        weatherCard.addSubview(conditionLabel)
        weatherCard.addSubview(windLabel)
        weatherCard.addSubview(humidityLabel)
        weatherCard.addSubview(separatorLine)
        weatherCard.addSubview(sunriseLabel)
        weatherCard.addSubview(dateTimeLabel)
        weatherCard.addSubview(sunsetLabel)

        contentView.addSubview(detailButton)
        contentView.addSubview(hourlyCollectionView)
        contentView.addSubview(dailyTitleLabel)
        contentView.addSubview(daysButton)
        contentView.addSubview(tableView)

        hourlyCollectionView.dataSource = self
        hourlyCollectionView.delegate = self
        hourlyCollectionView.register(HourlyCell.self, forCellWithReuseIdentifier: HourlyCell.id)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DailyCell.self, forCellReuseIdentifier: DailyCell.id)

        let tableHeight = NSLayoutConstraint(
            item: tableView, attribute: .height,
            relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute,
            multiplier: 1, constant: 7 * 72
        )
        tableHeightConstraint = tableHeight

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            weatherCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            weatherCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            weatherCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            minMaxLabel.topAnchor.constraint(equalTo: weatherCard.topAnchor, constant: 16),
            minMaxLabel.centerXAnchor.constraint(equalTo: weatherCard.centerXAnchor),

            tempLabel.topAnchor.constraint(equalTo: minMaxLabel.bottomAnchor, constant: 4),
            tempLabel.centerXAnchor.constraint(equalTo: weatherCard.centerXAnchor),

            conditionLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 4),
            conditionLabel.centerXAnchor.constraint(equalTo: weatherCard.centerXAnchor),

            windLabel.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 12),
            windLabel.centerXAnchor.constraint(equalTo: weatherCard.centerXAnchor, constant: -40),

            humidityLabel.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 12),
            humidityLabel.centerXAnchor.constraint(equalTo: weatherCard.centerXAnchor, constant: 40),

            separatorLine.topAnchor.constraint(equalTo: windLabel.bottomAnchor, constant: 12),
            separatorLine.leadingAnchor.constraint(equalTo: weatherCard.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: weatherCard.trailingAnchor, constant: -16),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),

            sunriseLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
            sunriseLabel.leadingAnchor.constraint(equalTo: weatherCard.leadingAnchor, constant: 16),
            sunriseLabel.bottomAnchor.constraint(equalTo: weatherCard.bottomAnchor, constant: -12),

            dateTimeLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
            dateTimeLabel.centerXAnchor.constraint(equalTo: weatherCard.centerXAnchor),

            sunsetLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
            sunsetLabel.trailingAnchor.constraint(equalTo: weatherCard.trailingAnchor, constant: -16),

            detailButton.topAnchor.constraint(equalTo: weatherCard.bottomAnchor, constant: 8),
            detailButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            hourlyCollectionView.topAnchor.constraint(equalTo: detailButton.bottomAnchor, constant: 4),
            hourlyCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hourlyCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hourlyCollectionView.heightAnchor.constraint(equalToConstant: 100),

            dailyTitleLabel.topAnchor.constraint(equalTo: hourlyCollectionView.bottomAnchor, constant: 20),
            dailyTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            daysButton.centerYAnchor.constraint(equalTo: dailyTitleLabel.centerYAnchor),
            daysButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: dailyTitleLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            tableHeight,
        ])

        detailButton.addTarget(self, action: #selector(detailTapped), for: .touchUpInside)
        daysButton.addTarget(self, action: #selector(daysToggleTapped), for: .touchUpInside)
    }

    // MARK: - Delete gesture

    private func setupDeleteGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        weatherCard.addGestureRecognizer(longPress)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()

        let alert = UIAlertController(
            title: "Удалить город?",
            message: "\(cityName) будет удалён из списка городов",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.onDeleteRequested?()
        })
        present(alert, animated: true)
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.onDataUpdate = { [weak self] in
            DispatchQueue.main.async { self?.updateUI() }
        }
        viewModel.onError = { error in print("Ошибка:", error) }
    }

    func updateUI() {
        guard let first = viewModel.items.first else { return }

        let df = DateFormatter()
        df.dateFormat = "HH:mm, EE d MMMM"
        df.locale = Locale(identifier: "ru_RU")

        tempLabel.text = "\(Int(first.temperature))°"
        conditionLabel.text = first.condition.capitalized
        minMaxLabel.text = "\(Int(first.temperature - 3))°/\(Int(first.temperature + 3))°"
        windLabel.text = "💨 3 м/с"
        humidityLabel.text = "💧 75%"
        dateTimeLabel.text = df.string(from: first.date)
        sunriseLabel.text = "🌅\n05:41"
        sunsetLabel.text = "🌇\n19:31"

        if isPrimaryCity {
            saveSnapshotForWidget(first: first)
        }

        hourlyCollectionView.reloadData()
        tableView.reloadData()
        tableHeightConstraint?.constant = CGFloat(visibleDaysCount()) * 72

        if view.window != nil {
            view.layoutIfNeeded()
        } else {
            view.setNeedsLayout()
        }
    }

    private func visibleDaysCount() -> Int {
        let total = viewModel.dailyItems().count
        return showAllDays ? min(total, 25) : min(total, 7)
    }

    // MARK: - Widget

    /// Пишет лёгкий снимок погоды в App Group, чтобы виджет на главном экране
    /// мог его прочитать, и просит WidgetKit обновить таймлайн прямо сейчас
    private func saveSnapshotForWidget(first: ForecastItem) {
        let snapshot = WidgetWeatherSnapshot(
            cityName: cityName,
            temperature: first.temperature,
            condition: first.condition.capitalized,
            tempMin: first.temperature - 3,
            tempMax: first.temperature + 3,
            updatedAt: Date()
        )
        WidgetDataStore.save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }

    @objc private func detailTapped() {
        let vc = Forecast24ViewController(items: viewModel.items)
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func daysToggleTapped() {
        showAllDays.toggle()
        daysButton.setTitle(showAllDays ? "7 дней" : "25 дней", for: .normal)
        tableHeightConstraint?.constant = CGFloat(visibleDaysCount()) * 72
        tableView.reloadData()
        if view.window != nil {
            UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
        }
    }
}

// MARK: - CollectionView

extension CityWeatherViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        min(viewModel.items.count, 8)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyCell.id, for: indexPath) as! HourlyCell
        if let item = viewModel.item(at: indexPath.row) {
            cell.configure(with: item, isSelected: indexPath.row == 1)
        }
        return cell
    }
}

// MARK: - TableView

extension CityWeatherViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visibleDaysCount()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 72 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DailyCell.id, for: indexPath) as! DailyCell
        let days = viewModel.dailyItems()
        if indexPath.row < days.count {
            cell.configure(with: days[indexPath.row])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let days = viewModel.dailyItems()
        guard indexPath.row < days.count else { return }
        let vc = DailyDetailViewController(items: days[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}
