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

    let nextButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 27, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Next", for: .normal)
        return button
    }()

    let retryButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 27, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Retry", for: .normal)
        return button
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
        addSubview(retryButton)
        addSubview(nextButton)

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

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -16),
            retryButton.topAnchor.constraint(equalTo: resultImageView.bottomAnchor, constant: 16),
        ])

        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            retryButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 16),
            nextButton.topAnchor.constraint(equalTo: resultImageView.bottomAnchor, constant: 16),
        ])
    }
}
