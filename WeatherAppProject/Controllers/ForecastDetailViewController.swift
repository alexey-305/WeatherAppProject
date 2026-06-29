import UIKit

final class ForecastDetailViewController: UIViewController {

    private let item: ForecastItem

    init(item: ForecastItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupUI()
    }

    private func setupUI() {

        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 22, weight: .bold)

        let tempLabel = UILabel()
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.font = .systemFont(ofSize: 18)

        let conditionLabel = UILabel()
        conditionLabel.translatesAutoresizingMaskIntoConstraints = false
        conditionLabel.font = .systemFont(ofSize: 16)
        conditionLabel.textColor = .gray

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"

        dateLabel.text = formatter.string(from: item.date)
        tempLabel.text = "Температура: \(item.temperature)°C"
        conditionLabel.text = "Состояние: \(item.condition)"

        view.addSubview(dateLabel)
        view.addSubview(tempLabel)
        view.addSubview(conditionLabel)

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tempLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            conditionLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 12),
            conditionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
