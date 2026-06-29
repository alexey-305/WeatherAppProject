import UIKit

final class SettingsViewController: UIViewController {

    var onContinue: (() -> Void)?

    // MARK: - State

    private var tempUnit: Int = UserDefaults.standard.integer(forKey: SettingsKeys.temperatureUnit) // 0=C 1=F
    private var windUnit: Int = UserDefaults.standard.integer(forKey: SettingsKeys.windUnit)        // 0=Mi 1=Km
    private var timeFormat: Int = UserDefaults.standard.integer(forKey: SettingsKeys.timeFormat)    // 0=12 1=24
    private var notifOn: Int = UserDefaults.standard.integer(forKey: SettingsKeys.notifications)    // 0=On 1=Off

    // MARK: - UI

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1)
        v.layer.cornerRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Настройки"
        l.font = .boldSystemFont(ofSize: 22)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Установить", for: .normal)
        b.backgroundColor = UIColor(red: 0.95, green: 0.55, blue: 0.12, alpha: 1)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 17)
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // Кнопки для каждой настройки
    private lazy var tempButtons   = makeToggleButtons(["C", "F"],       selected: tempUnit)
    private lazy var windButtons   = makeToggleButtons(["Mi", "Km"],     selected: windUnit)
    private lazy var timeButtons   = makeToggleButtons(["12", "24"],     selected: timeFormat)
    private lazy var notifButtons  = makeToggleButtons(["On", "Off"],    selected: notifOn)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 1.0)
        setupUI()
    }

    // MARK: - Layout

    private func setupUI() {
        view.addSubview(containerView)

        let rows = UIStackView(arrangedSubviews: [
            makeRow(title: "Температура",    buttons: tempButtons),
            makeRow(title: "Скорость ветра", buttons: windButtons),
            makeRow(title: "Формат времени", buttons: timeButtons),
            makeRow(title: "Уведомления",    buttons: notifButtons),
            saveButton,
        ])
        rows.axis = .vertical
        rows.spacing = 20
        rows.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(titleLabel)
        containerView.addSubview(rows)

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),

            rows.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            rows.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            rows.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            rows.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),

            saveButton.heightAnchor.constraint(equalToConstant: 52),
        ])

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    // MARK: - Builders

    private func makeToggleButtons(_ titles: [String], selected: Int) -> [UIButton] {
        titles.enumerated().map { index, title in
            let b = UIButton(type: .system)
            b.setTitle(title, for: .normal)
            b.titleLabel?.font = .boldSystemFont(ofSize: 15)
            b.layer.cornerRadius = 10
            b.widthAnchor.constraint(equalToConstant: 52).isActive = true
            b.heightAnchor.constraint(equalToConstant: 36).isActive = true
            b.tag = index
            updateButton(b, isSelected: index == selected)
            b.addTarget(self, action: #selector(toggleTapped(_:)), for: .touchUpInside)
            return b
        }
    }

    private func makeRow(title: String, buttons: [UIButton]) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel

        let btnStack = UIStackView(arrangedSubviews: buttons)
        btnStack.axis = .horizontal
        btnStack.spacing = 6

        let row = UIStackView(arrangedSubviews: [label, UIView(), btnStack])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    private func updateButton(_ button: UIButton, isSelected: Bool) {
        button.backgroundColor = isSelected
            ? UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 1)
            : UIColor(red: 0.85, green: 0.87, blue: 0.92, alpha: 1)
        button.setTitleColor(isSelected ? .white : .label, for: .normal)
    }

    // MARK: - Actions

    @objc private func toggleTapped(_ sender: UIButton) {
        // Определяем группу по наличию кнопки
        let groups: [[UIButton]] = [tempButtons, windButtons, timeButtons, notifButtons]
        for (i, group) in groups.enumerated() {
            if group.contains(sender) {
                group.forEach { updateButton($0, isSelected: $0 == sender) }
                switch i {
                case 0: tempUnit   = sender.tag
                case 1: windUnit   = sender.tag
                case 2: timeFormat = sender.tag
                case 3: notifOn    = sender.tag
                default: break
                }
                return
            }
        }
    }

    @objc private func saveTapped() {
        UserDefaults.standard.set(tempUnit,   forKey: SettingsKeys.temperatureUnit)
        UserDefaults.standard.set(windUnit,   forKey: SettingsKeys.windUnit)
        UserDefaults.standard.set(timeFormat, forKey: SettingsKeys.timeFormat)
        UserDefaults.standard.set(notifOn,    forKey: SettingsKeys.notifications)
        dismiss(animated: true)
        onContinue?()
    }
}
