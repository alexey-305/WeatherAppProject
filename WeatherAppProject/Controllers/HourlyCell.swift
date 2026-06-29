import UIKit

final class HourlyCell: UICollectionViewCell {
    static let id = "HourlyCell"

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let iconLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let tempLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.addSubview(timeLabel)
        contentView.addSubview(iconLabel)
        contentView.addSubview(tempLabel)

        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            timeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            iconLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            tempLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            tempLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: ForecastItem, isSelected: Bool) {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        timeLabel.text = df.string(from: item.date)
        iconLabel.text = "⛅"
        tempLabel.text = "\(Int(item.temperature))°"

        if isSelected {
            contentView.backgroundColor = UIColor(red: 0.12, green: 0.33, blue: 0.60, alpha: 1)
            timeLabel.textColor = .white
            iconLabel.textColor = .white
            tempLabel.textColor = .white
            contentView.layer.borderColor = UIColor.clear.cgColor
        } else {
            contentView.backgroundColor = .white
            timeLabel.textColor = .label
            iconLabel.textColor = .label
            tempLabel.textColor = .label
            contentView.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
}
