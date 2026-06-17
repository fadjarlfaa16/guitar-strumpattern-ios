//
//  AudioMetadataService.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//


//
// AudioMetadataService.swift
//

import Foundation
import AVFoundation

final class AudioMetadataService {

    static let shared = AudioMetadataService()

    private init() {}

    func duration(
        url: URL,
        timeoutSeconds: Int = 8
    ) async -> TimeInterval {

        enum DurationResult {
            case value(TimeInterval)
            case timeout
            case failed(Error)
        }

        let result = await withTaskGroup(of: DurationResult.self) { group in

            group.addTask {
                do {
                    let seconds = try await AVURLAsset(url: url)
                        .load(.duration)
                        .seconds

                    return .value(seconds)

                } catch {
                    return .failed(error)
                }
            }

            group.addTask {
                try? await Task.sleep(
                    nanoseconds: UInt64(timeoutSeconds) * 1_000_000_000
                )
                return .timeout
            }

            let first = await group.next() ?? .timeout
            group.cancelAll()
            return first
        }

        switch result {

        case .value(let seconds):
            return seconds.isFinite ? seconds : 0

        case .timeout:
            return 0

        case .failed:
            return 0
        }
    }
}