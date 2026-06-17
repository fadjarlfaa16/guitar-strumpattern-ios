//
//  AnalysisStage.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 17/06/26.
//
/// Define stages in order. Customize messages here, or load from a config/localization source.
enum AnalysisStage: Int, CaseIterable, Sendable {
    case validating
    case starting
    case loadingAudio
    case analyzingBPM
    case computingCQT
    case buildingMatrix
    case neuralNet
    case combiningOutputs
    case parsingPredictions
    case decodingSequences
    case buildingTimeline
    case processing
    case complete

    static let messages: [AnalysisStage: String] = [
        .validating: "Checking your audio...",
        .starting: "Getting things ready...",
        .loadingAudio: "Loading your song...",
        .analyzingBPM: "Finding the tempo...",
        .computingCQT: "Listening closely...",
        .buildingMatrix: "Preparing the analysis...",
        .neuralNet: "Identifying the chords...",
        .combiningOutputs: "Fine-tuning the results...",
        .parsingPredictions: "Organizing the chords...",
        .decodingSequences: "Putting everything together...",
        .buildingTimeline: "Building your chord timeline...",
        .processing: "Almost done...",
        .complete: "Ready to play!"
    ]

    var message: String {
        Self.messages[self] ?? ""
    }
}
