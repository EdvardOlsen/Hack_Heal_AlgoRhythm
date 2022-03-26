//
//  AlgoRhythmView.swift
//  Rhythmus
//
//  Created by Andrei Rychkov on 26.03.2022.
//

import UIKit

final class ResultsView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 27, weight: .semibold)
        label.textColor = .white
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(hex6: 0xCC76FF)
        label.layer.compositingFilter = "overlayBlendMode"
        return label
    }()

    let resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        return imageView
    }()

    private let rhythmContainer = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        resultImageView.layer.cornerRadius = resultImageView.bounds.width * 0.5
    }

    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(resultImageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        resultImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            resultImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            resultImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
            resultImageView.heightAnchor.constraint(equalTo: resultImageView.widthAnchor)
        ])
    }
}
