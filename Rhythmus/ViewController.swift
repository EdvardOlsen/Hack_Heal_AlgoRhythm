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
        generatePattern([9,9]),
        generatePattern([4,4,9]),
        generatePattern([4,9,4])
    ],
    [
        generatePattern([9,9,4,4,4]),
        generatePattern([9,4,9,4,4]),
        generatePattern([9,9,9,4,4,4])
    ],
    [
        generatePattern([9,4,9,4,4,4,9]),
        generatePattern([6,6,9,9,6,6,4,6,6]),
        generatePattern([9,9,6,9,6,6,4,6,9,9,6,9,9])
    ],
]


class ViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    let player = AVPlayer()
    var soundId: SystemSoundID = 0

    let rhythmContainer = UIView()

    private var isPlaying: Bool { player.timeControlStatus != .paused }
    private var playedTimings = [TimeInterval]()
    private var isRecording: Bool = false
    private var currentIndex: (Int, Int) = (0, 0)

    private var currentRhythm: Rhythm {
        Rhythm(
            pattern: patterns[currentIndex.0][currentIndex.1]
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

        let clapUrl = Bundle.main.url(forResource: "bam", withExtension: "mp3")!
        AudioServicesCreateSystemSoundID(clapUrl as CFURL, &soundId)

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
        AudioServicesPlaySystemSound(soundId)

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
        if evaluation > 0.85 {
            goToNextLevel()
            titleText = "Congratulations!"
            updateLevelLabel()
            imageName = "done"
        } else {
            titleText = "So close!"
            imageName = "retry"
        }
        rootView.resultsView.titleLabel.text = titleText
        rootView.resultsView.subtitleLabel.text = "Your score is \(Int(evaluation * 100))%"
        rootView.resultsView.resultImageView.image = UIImage(named: imageName)

        resetLevel()

        rootView.toggleViews(rootView.resultsView, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [unowned self] in
            self.rootView.toggleViews(self.rootView.recordingView, animated: true)
            self.togglePlayback()
        }
    }

    private func goToNextLevel() {
        var majorIndex = currentIndex.0
        var minorIndex = currentIndex.1
        if minorIndex < patterns[majorIndex].count - 1 {
            minorIndex += 1
        } else if majorIndex < patterns.count - 1 {
            majorIndex += 1
            minorIndex = 0
        } else {
            majorIndex = 0
            minorIndex = 0
        }
        currentIndex = (majorIndex, minorIndex)
    }

    private func updateLevelLabel() {
        rootView.recordingView.levelLabel.text = "Level \(currentIndex.0 + 1):\(currentIndex.1 + 1)"
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
