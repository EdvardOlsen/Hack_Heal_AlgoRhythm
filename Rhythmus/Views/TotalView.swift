//
//  AlgoRhythmView.swift
//  Rhythmus
//
//  Created by Andrei Rychkov on 26.03.2022.
//

import UIKit

final class TotalView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 27, weight: .semibold)
        label.textColor = .white
        return label
    }()

    let totalTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17, weight: .semibold)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.isEditable = false
        return textView
    }()

    let doneButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 27, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Done", for: .normal)
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

    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(totalTextView)
        addSubview(doneButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        totalTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalTextView.centerXAnchor.constraint(equalTo: centerXAnchor),
            totalTextView.centerYAnchor.constraint(equalTo: centerYAnchor),
            totalTextView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),
            totalTextView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8)
        ])

        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            doneButton.topAnchor.constraint(equalTo: totalTextView.bottomAnchor, constant: 16),
        ])
    }
}
