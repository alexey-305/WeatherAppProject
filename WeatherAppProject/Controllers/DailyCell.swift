import UIKit

final class DailyCell: UITableViewCell {
    static let id = "DailyCell"

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let iconLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 28)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let humidityLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 1)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let conditionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let tempLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let chevron: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .systemGray3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(cardView)
        cardView.addSubview(dateLabel)
        cardView.addSubview(iconLabel)
        cardView.addSubview(humidityLabel)
        cardView.addSubview(conditionLabel)
        cardView.addSubview(tempLabel)
        cardView.addSubview(chevron)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            dateLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            dateLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),

            iconLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 60),
            iconLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            humidityLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 4),
            humidityLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            conditionLabel.leadingAnchor.constraint(equalTo: humidityLabel.trailingAnchor, constant: 8),
            conditionLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            conditionLabel.trailingAnchor.constraint(lessThanOrEqualTo: tempLabel.leadingAnchor, constant: -8),

            tempLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            tempLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            chevron.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 8),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with items: [ForecastItem]) {
        guard let first = items.first else { return }
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateFormat = "EE\ndd/MM"
        dateLabel.text = df.string(from: first.date)
        dateLabel.numberOfLines = 2
        dateLabel.font = .systemFont(ofSize: 12)

        iconLabel.text = "🌧"
        humidityLabel.text = "57%"

        let minT = Int(items.map { $0.temperature }.min() ?? 0)
        let maxT = Int(items.map { $0.temperature }.max() ?? 0)
        tempLabel.text = "\(minT) - \(maxT)°"
        conditionLabel.text = first.condition.capitalized
    }
}
