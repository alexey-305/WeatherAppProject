import UIKit

final class Forecast24Cell: UITableViewCell {
    static let id = "Forecast24Cell"

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 16)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let tempLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 28)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let conditionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let windRow    = Forecast24Cell.makeRow(icon: "💨", title: "Ветер")
    private let rainRow    = Forecast24Cell.makeRow(icon: "🌧", title: "Атмосферные осадки")
    private let cloudRow   = Forecast24Cell.makeRow(icon: "☁️", title: "Облачность")

    private let windValue  = Forecast24Cell.makeValueLabel()
    private let rainValue  = Forecast24Cell.makeValueLabel()
    private let cloudValue = Forecast24Cell.makeValueLabel()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.93, green: 0.95, blue: 0.99, alpha: 1)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private static func makeRow(icon: String, title: String) -> UILabel {
        let l = UILabel()
        l.text = "\(icon) \(title)"
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private static func makeValueLabel() -> UILabel {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(timeLabel)
        contentView.addSubview(tempLabel)
        contentView.addSubview(conditionLabel)
        contentView.addSubview(cardView)

        cardView.addSubview(windRow);  cardView.addSubview(windValue)
        cardView.addSubview(rainRow);  cardView.addSubview(rainValue)
        cardView.addSubview(cloudRow); cardView.addSubview(cloudValue)

        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            conditionLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 2),
            conditionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            tempLabel.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 2),
            tempLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            cardView.topAnchor.constraint(equalTo: timeLabel.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 110),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            windRow.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            windRow.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            windValue.centerYAnchor.constraint(equalTo: windRow.centerYAnchor),
            windValue.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),

            rainRow.topAnchor.constraint(equalTo: windRow.bottomAnchor, constant: 8),
            rainRow.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            rainValue.centerYAnchor.constraint(equalTo: rainRow.centerYAnchor),
            rainValue.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),

            cloudRow.topAnchor.constraint(equalTo: rainRow.bottomAnchor, constant: 8),
            cloudRow.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            cloudValue.centerYAnchor.constraint(equalTo: cloudRow.centerYAnchor),
            cloudValue.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: ForecastItem) {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        timeLabel.text = df.string(from: item.date)
        tempLabel.text = "\(Int(item.temperature))°"
        conditionLabel.text = item.condition.capitalized
        windValue.text  = "2 м/с ССЗ"
        rainValue.text  = "0%"
        cloudValue.text = "29%"
    }
}
