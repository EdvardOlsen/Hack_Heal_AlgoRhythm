//
//  AlgoRhythmView.swift
//  Rhythmus
//
//  Created by Andrei Rychkov on 26.03.2022.
//

import UIKit

final class AlgoRhythmView: UIView {
    let recordingView = RecordingView()
    let resultsView = ResultsView()
    let totalView = TotalView()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Background"))
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()


    }

    func toggleViews(_ currentView: UIView, animated: Bool) {
        UIView.animate(
            withDuration: animated ? 0.25 : 0.0,
            delay: 0.0,
            options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseInOut],
            animations: {
                self.recordingView.alpha = currentView === self.recordingView ? 1.0 : 0.0
                self.resultsView.alpha = currentView === self.resultsView ? 1.0 : 0.0
                self.totalView.alpha = currentView === self.totalView ? 1.0 : 0.0
            },
            completion: nil
        )
    }

    private func setupSubviews() {
        addSubview(backgroundImageView)
        addSubview(recordingView)
        addSubview(resultsView)
        addSubview(totalView)

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        recordingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recordingView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            recordingView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            recordingView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            recordingView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])

        resultsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultsView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            resultsView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            resultsView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            resultsView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])

        totalView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            totalView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            totalView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            totalView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}
