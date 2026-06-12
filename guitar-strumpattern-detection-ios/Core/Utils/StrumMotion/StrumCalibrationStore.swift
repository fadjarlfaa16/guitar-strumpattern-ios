//
//  StrumCalibrationStore.swift
//  guitar-strumpattern-detection-ios
//

import Foundation

enum StrumCalibrationStore {
    private static let isCalibratedKey = "strumIsCalibrated"
    private static let micBaseKey = "strumMicBaseThreshold"
    private static let micSpikeKey = "strumMicSpikeThreshold"

    static var isCalibrated: Bool {
        UserDefaults.standard.bool(forKey: isCalibratedKey)
    }

    static func loadThresholds() -> (base: Float, spike: Float) {
        let defaults = UserDefaults.standard
        let base = defaults.object(forKey: micBaseKey) as? Float ?? -45.0
        let spike = defaults.object(forKey: micSpikeKey) as? Float ?? 3.0
        return (base, spike)
    }

    static func saveCalibration(baseDecibels: Float, spikeDecibels: Float) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: isCalibratedKey)
        defaults.set(baseDecibels, forKey: micBaseKey)
        defaults.set(spikeDecibels, forKey: micSpikeKey)
    }

    static func clear() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: isCalibratedKey)
        defaults.removeObject(forKey: micBaseKey)
        defaults.removeObject(forKey: micSpikeKey)
    }
}
