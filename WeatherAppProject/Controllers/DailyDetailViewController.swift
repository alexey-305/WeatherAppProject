import UIKit

final class DailyDetailViewController: UIViewController {

    private let items: [ForecastItem]

    init(items: [ForecastItem]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Дневная погода"
        navigationController?.navigationBar.tintColor = UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 1)
        setupUI()
    }

    // MARK: - Layout

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

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
        ])

        guard let first = items.first else { return }

        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateFormat = "dd/MM EE"

        let temps = items.map { $0.temperature }
        let minT = Int(temps.min() ?? 0)
        let maxT = Int(temps.max() ?? 0)

        // Стек всего контента
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])

        // День
        stack.addArrangedSubview(makeSectionCard(title: "День", items: [
            ("☀️ По ощущениям", "\(maxT - 2)°"),
            ("💨 Ветер",        "5 м/с ЮЗ"),
            ("☀️ УФ индекс",    "4 (умерен.)"),
            ("🌧 Дождь",        "55%"),
            ("☁️ Облачность",   "72%"),
        ], bigTemp: "\(maxT)°", condition: first.condition.capitalized))

        // Ночь
        stack.addArrangedSubview(makeSectionCard(title: "Ночь", items: [
            ("☀️ По ощущениям", "\(minT)°"),
            ("💨 Ветер",        "5 м/с ЮЗ"),
            ("☀️ УФ индекс",    "4 (умерен.)"),
            ("🌧 Дождь",        "55%"),
            ("☁️ Облачность",   "72%"),
        ], bigTemp: "\(minT)°", condition: "Ливни"))

        // Солнце и Луна
        stack.addArrangedSubview(makeSunMoonCard())

        // Качество воздуха
        stack.addArrangedSubview(makeAQICard())
    }

    // MARK: - Card builders

    private func makeSectionCard(
        title: String,
        items: [(String, String)],
        bigTemp: String,
        condition: String
    ) -> UIView {
        let card = makeCard()

        let titleLabel = makeLabel(bigTemp, font: .boldSystemFont(ofSize: 40))
        let sectionLabel = makeLabel(title, font: .boldSystemFont(ofSize: 16))
        let condLabel = makeLabel(condition, font: .systemFont(ofSize: 14), color: .secondaryLabel)

        let headerStack = UIStackView(arrangedSubviews: [sectionLabel, titleLabel, condLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let sep = makeSeparator()

        let rowsStack = UIStackView()
        rowsStack.axis = .vertical
        rowsStack.spacing = 10
        rowsStack.translatesAutoresizingMaskIntoConstraints = false

        for (key, val) in items {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .equalSpacing
            let k = makeLabel(key, font: .systemFont(ofSize: 14), color: .secondaryLabel)
            let v = makeLabel(val, font: .systemFont(ofSize: 14))
            row.addArrangedSubview(k)
            row.addArrangedSubview(v)
            rowsStack.addArrangedSubview(row)
        }

        let mainStack = UIStackView(arrangedSubviews: [headerStack, sep, rowsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])

        return card
    }

    private func makeSunMoonCard() -> UIView {
        let card = makeCard()

        let title = makeLabel("Солнце и Луна", font: .boldSystemFont(ofSize: 16))
        title.translatesAutoresizingMaskIntoConstraints = false

        let moonLabel = makeLabel("● Полнолуние", font: .systemFont(ofSize: 13), color: UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 1))
        moonLabel.translatesAutoresizingMaskIntoConstraints = false

        let sep = makeSeparator()

        // Восход / Закат
        let sunRow = makeInfoRow(left: ("🌅", "14ч 27 мин", "Восход", "05:19"),
                                  right: ("🌙", "14ч 27 мин", "Закат", "19:46"))

        let mainStack = UIStackView(arrangedSubviews: [
            hstack([title, moonLabel]),
            sep,
            sunRow
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])

        return card
    }

    private func makeAQICard() -> UIView {
        let card = makeCard()

        let aqi = makeLabel("42", font: .boldSystemFont(ofSize: 36))
        let badge = UILabel()
        badge.text = "  хорошо  "
        badge.font = .boldSystemFont(ofSize: 13)
        badge.textColor = .white
        badge.backgroundColor = UIColor(red: 0.18, green: 0.65, blue: 0.35, alpha: 1)
        badge.layer.cornerRadius = 8
        badge.clipsToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false

        let desc = makeLabel(
            "Качество воздуха считается удовлетворительным и загрязнения воздуха представляются незначительными в пределах нормы",
            font: .systemFont(ofSize: 13),
            color: .secondaryLabel
        )
        desc.numberOfLines = 0

        let titleRow = hstack([makeLabel("Качество воздуха", font: .boldSystemFont(ofSize: 16)), UIView()])
        let aqiRow   = hstack([aqi, badge])

        let mainStack = UIStackView(arrangedSubviews: [titleRow, aqiRow, desc])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])

        return card
    }

    // MARK: - Helpers

    private func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.93, green: 0.95, blue: 0.99, alpha: 1)
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private func makeSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray4
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return v
    }

    private func makeLabel(_ text: String, font: UIFont, color: UIColor = .label) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = font
        l.textColor = color
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func hstack(_ views: [UIView]) -> UIStackView {
        let s = UIStackView(arrangedSubviews: views)
        s.axis = .horizontal
        s.spacing = 8
        s.alignment = .center
        return s
    }

    private func makeInfoRow(
        left: (String, String, String, String),
        right: (String, String, String, String)
    ) -> UIView {
        func col(_ icon: String, _ duration: String, _ label: String, _ time: String) -> UIStackView {
            let iconL    = makeLabel(icon, font: .systemFont(ofSize: 24))
            let durL     = makeLabel(duration, font: .systemFont(ofSize: 13))
            let labelL   = makeLabel(label, font: .systemFont(ofSize: 12), color: .secondaryLabel)
            let timeL    = makeLabel(time, font: .systemFont(ofSize: 13))
            let s = UIStackView(arrangedSubviews: [iconL, durL, labelL, timeL])
            s.axis = .vertical
            s.spacing = 2
            s.alignment = .center
            return s
        }

        let row = UIStackView(arrangedSubviews: [
            col(left.0, left.1, left.2, left.3),
            col(right.0, right.1, right.2, right.3)
        ])
        row.axis = .horizontal
        row.distribution = .fillEqually
        return row
    }
}
