import AVFoundation

struct Rhythm {
    typealias Pattern = String

    let pattern: Pattern
    let stepTime: TimeInterval = 0.1
    let audioDuration: TimeInterval = 0.1
    let soundName: String = "bam"

    var bamsCount: Int {
        pattern.filter { $0 == "1" }.count
    }

    var timings: [TimeInterval] {
        return pattern
            .enumerated()
            .filter { $0.1 == "1" }
            .map { TimeInterval($0.0) * stepTime }
    }
}

final class RhythmMaker {
    func makeRhythmAudio(for rhythm: Rhythm) throws -> AVAsset {
        guard !rhythm.pattern.isEmpty else { throw Error.noPattern }

        let mixComposition = AVMutableComposition()

        guard let audioTrack = mixComposition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw Error.cantAddAudioTrack
        }

        let audioAsset = AVURLAsset(
            url: Bundle.main.url(forResource: rhythm.soundName, withExtension: "mp3")!,
            options: [
                AVURLAssetPreferPreciseDurationAndTimingKey: true
            ]
        )

        guard let audioAssetTrack = audioAsset.tracks(withMediaType: .audio).first else {
            throw Error.noAudioTrack
        }

        try rhythm.timings
            .forEach { timing in
                try audioTrack.insertTimeRange(
                    CMTimeRangeMake(
                        start: CMTime.zero,
                        duration: CMTime(
                            seconds: rhythm.audioDuration,
                            preferredTimescale: audioAssetTrack.timeRange.duration.timescale
                        )
                    ),
                    of: audioAssetTrack,
                    at: CMTime(
                        seconds: timing,
                        preferredTimescale: audioAssetTrack.timeRange.duration.timescale
                    )
                )
            }

        return mixComposition
    }
}

private extension RhythmMaker {
    enum Error: LocalizedError {
        case noPattern
        case cantAddAudioTrack
        case noAudioTrack
        case cantCreateExportSession
        case exportError
    }
}
