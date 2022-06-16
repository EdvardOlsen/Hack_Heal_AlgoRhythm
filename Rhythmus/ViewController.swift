//
//  ViewController.swift
//  Rhythmus
//
//  Created by Andrei Rychkov on 25.03.2022.
//

import UIKit
import AVFAudio
import AVFoundation
import AudioToolbox

func generatePattern(_ pauses: [Int]) -> String {
    var pattern = "1"
    pauses.forEach { pauseTimes in
        (0 ..< pauseTimes).forEach { pause in
            pattern += "0"
        }
        pattern += "1"
    }
    return pattern
}

let patterns: [[String]] = [
    [
        generatePattern([4,4,2,2])
    ],
    [
        generatePattern([4,2,4,2]), // 1011011
        generatePattern([2,2,4,4,6]), // 1110101001
        generatePattern([2,4,4,6,6,2]), // 1101010010011
        generatePattern([6,4,2,4,2,6,6,2]), // 10010110110010011
        generatePattern([2,2,2,8,4,4,2,4,4,8]) // 111100010101101010001
    ]
]

struct Level: Hashable {
    let major: Int
    let minor: Int
}

class ViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    let player = AVPlayer()

    let rhythmContainer = UIView()

    private var isPlaying: Bool { player.timeControlStatus != .paused }
    private var playedTimings = [TimeInterval]()
    private var isRecording: Bool = false
    private var currentLevel = Level(major: 0, minor: 0)

    private var results = [Level: Float]()

    private var currentRhythm: Rhythm {
        Rhythm(
            pattern: patterns[currentLevel.major][currentLevel.minor]
        )
    }

    private var rootView: AlgoRhythmView {
        view as! AlgoRhythmView
    }

    private var playerToken: Any?

    override func loadView() {
        view = AlgoRhythmView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        playerToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.01, preferredTimescale: 1000),
            queue: .main
        ) { [unowned self] time in
            self.currentRhythm.timings.forEach { timing in
                if time.seconds > timing && !self.playedTimings.contains(timing) {
                    self.playedTimings.append(timing)
                    self.rootView.recordingView.playCircleAnimation()
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.player.pause()
            self?.updatePlaybackButtonState()
            print("Paused")
        }

        rootView.recordingView.playbackButton.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        rootView.recordingView.rhythmButton.addTarget(self, action: #selector(handleRhythmButtonTap), for: .touchDown)

        playCurrentRhythm()

        updatePlaybackButtonState()
        updateLevelLabel()
        rootView.toggleViews(rootView.recordingView, animated: false)
    }

    private func playCurrentRhythm() {
        do {
            let asset = try RhythmMaker().makeRhythmAudio(for: currentRhythm)
            playedTimings = []
            player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
            player.play()
        } catch {
            print(error.localizedDescription)
        }
    }

    @objc
    func togglePlayback() {
        if isPlaying {
            player.pause()
        } else {
            playCurrentRhythm()
        }
        updatePlaybackButtonState()
    }

    private func updatePlaybackButtonState() {
        rootView.recordingView.playbackButton.isSelected = isPlaying
        rootView.recordingView.tryToRepeatLabel.text = isPlaying ? "Listening..." : "Try to repeat!"
        rootView.recordingView.rhythmButton.isEnabled = !isPlaying
    }

    private var recordingStartTime: CFAbsoluteTime?
    private var rhythmResult = [TimeInterval]()

    private func stopRecording() {
        isRecording = false
        evaluate(rhythmResult)
    }

    private func startRecording() {
        if isPlaying { togglePlayback() }
        recordingStartTime = CFAbsoluteTimeGetCurrent()
        rhythmResult = [0.0]
        isRecording = true
    }

    private func resetLevel() {
        rhythmResult = [0.0]
        recordingStartTime = nil
    }

    @objc
    private func handleRhythmButtonTap() {
        rootView.recordingView.playCircleAnimation()

        guard let recordingStartTime = recordingStartTime else {
            startRecording()
            return
        }

        let currentTime = CFAbsoluteTimeGetCurrent() - recordingStartTime
        rhythmResult.append(currentTime)

        if rhythmResult.count == currentRhythm.bamsCount {
            stopRecording()
        }
    }

    private func evaluate(_ results: [TimeInterval]) {
        let timings = currentRhythm.timings
        let maxStepEvaluation = 1.0 / Double(timings.count - 1)
        var evaluation = 0.0

        results.enumerated().forEach { index, resultTiming in
            if index == 0 { return }
            let curResult = resultTiming - results[index - 1]
            let curTiming = timings[index] - timings[index - 1]
            let stepError = abs(curTiming - curResult)
            let stepEvaluation = max(0.0, 1.0 - max(0.0, stepError - 0.05) / 0.25)
            print("\(curResult) - \(curTiming), \(stepEvaluation)")
            evaluation += Double(stepEvaluation * maxStepEvaluation)
        }

        var titleText: String
        var imageName: String

        titleText = "Next Level!"
        imageName = "done"

        rootView.resultsView.titleLabel.text = titleText
        rootView.resultsView.resultImageView.image = UIImage(named: imageName)

        rootView.resultsView.nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        rootView.resultsView.retryButton.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)

        self.results[currentLevel] = Float(evaluation)
        resetLevel()

        rootView.toggleViews(rootView.resultsView, animated: true)
    }

    @objc
    private func handleNext() {
        let isLastMajor = currentLevel.major == patterns.count - 1
        let isLastMinor = currentLevel.minor == patterns[currentLevel.major].count - 1
        let isLastLevel = isLastMajor && isLastMinor

        goToNextLevel()
        updateLevelLabel()

        if isLastLevel {
            var resultText = "TOTAL"
            resultText += "\n\n"
            let valuableResults = results.filter { $0.key.major != 0 }
            let sortedResults = valuableResults.keys.sorted { lhs, rhs in
                if lhs.major > rhs.major { return false }
                if lhs.major < rhs.major { return true }
                return lhs.minor < rhs.minor
            }
            sortedResults.forEach { key in
                let value = valuableResults[key]!
                resultText.append("Level \(key.major):\(key.minor + 1): \(value)\n")
            }
            resultText.append("Average: \(valuableResults.values.reduce(0, +) / Float(valuableResults.values.count))")
            rootView.totalView.totalTextView.text = resultText
            self.rootView.toggleViews(self.rootView.totalView, animated: true)
            self.rootView.totalView.doneButton.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        } else {
            self.rootView.toggleViews(self.rootView.recordingView, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.togglePlayback()
            }
        }
    }

    @objc
    private func handleRetry() {
        self.rootView.toggleViews(self.rootView.recordingView, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.togglePlayback()
        }
    }

    private func goToNextLevel() {
        var majorIndex = currentLevel.major
        var minorIndex = currentLevel.minor
        if minorIndex < patterns[majorIndex].count - 1 {
            minorIndex += 1
        } else if majorIndex < patterns.count - 1 {
            majorIndex += 1
            minorIndex = 0
        } else {
            majorIndex = 0
            minorIndex = 0
        }
        currentLevel = Level(major: majorIndex, minor: minorIndex)
    }

    private func updateLevelLabel() {
        if currentLevel.major == 0 { // test level
            rootView.recordingView.levelLabel.text = "Training \(currentLevel.minor + 1)"
        } else {
            rootView.recordingView.levelLabel.text = "Level \(currentLevel.major) : \(currentLevel.minor + 1)"
        }
    }
}

extension UIColor {
    convenience init(hex6: UInt32, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green = CGFloat((hex6 & 0x00FF00) >> 8) / divisor
        let blue = CGFloat( hex6 & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
