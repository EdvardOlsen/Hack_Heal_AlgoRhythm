//
//  AlgoRhythmView.swift
//  Rhythmus
//
//  Created by Andrei Rychkov on 26.03.2022.
//

import UIKit

final class RecordingView: UIView {
    let rhythmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        return button
    }()

    let levelLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 27, weight: .medium)
        label.textColor = UIColor(hex6: 0xCE74FF)
        return label
    }()

    let playbackButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex6: 0x9E5BC4)
        button.setImage(UIImage(named: "play_20"), for: .normal)
        button.setImage(UIImage(named: "pause_20"), for: .selected)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.layer.masksToBounds = true
        return button
    }()

    let tryToRepeatLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .white
        return label
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

        rhythmButton.layer.cornerRadius = rhythmButton.bounds.width * 0.5
        playbackButton.layer.cornerRadius = 20
    }

    func playCircleAnimation() {
        let circleView = UIView()
        circleView.backgroundColor = rhythmButton.backgroundColor

        rhythmContainer.addSubview(circleView)
        circleView.frame = rhythmButton.frame
        circleView.layer.cornerRadius = rhythmButton.layer.cornerRadius

        UIView.animate(
            withDuration: 0.4,
            delay: 0.0,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                circleView.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
                circleView.alpha = 0.0
            },
            completion: { _ in
                circleView.removeFromSuperview()
            }
        )
    }

    private func setupSubviews() {
        let headerStackView = UIStackView(arrangedSubviews: [levelLabel, playbackButton])
        headerStackView.spacing = 12
        headerStackView.axis = .horizontal

        addSubview(rhythmContainer)
        addSubview(headerStackView)
        addSubview(rhythmButton)
        addSubview(tryToRepeatLabel)

        NSLayoutConstraint.activate([
            playbackButton.widthAnchor.constraint(equalTo: playbackButton.heightAnchor)
        ])

        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 36),
            headerStackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        rhythmContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rhythmContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            rhythmContainer.topAnchor.constraint(equalTo: topAnchor),
            rhythmContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            rhythmContainer.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        rhythmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rhythmButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            rhythmButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            rhythmButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
            rhythmButton.heightAnchor.constraint(equalTo: rhythmButton.widthAnchor)
        ])

        tryToRepeatLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tryToRepeatLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            tryToRepeatLabel.topAnchor.constraint(equalTo: rhythmButton.bottomAnchor, constant: 20)
        ])
    }
}
