//
//  CalibrateWatch.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//
import SwiftUI

struct CalibrateWatchView: View {
    @State private var navigateToWatchCheck = false
    @State private var strumDirection: StrumBeat = .up
    
    @StateObject private var vm: GuitarValidationViewModel
    @ObservedObject private var receiver: WatchReceiver
    @ObservedObject private var audioMonitor: AudioMonitor
    
    init() {
        let viewModel = GuitarValidationViewModel()
        _vm = StateObject(wrappedValue: viewModel)
        _receiver = ObservedObject(wrappedValue: viewModel.receiver)
        _audioMonitor = ObservedObject(wrappedValue: viewModel.receiver.audioMonitor)
    }
    var body: some View {
        ZStack {
            Color.backgroundPrimaryBlack
                .ignoresSafeArea()

            PrepareGuitarBackgroundLines()
                .ignoresSafeArea()

            Group {
                if vm.isCalibrated {
                    CalibrateCompleteView(onReset: vm.recalibrate)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    calibratingContent
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 24)
            .animation(.easeInOut(duration: 0.35), value: vm.isCalibrated)
        }
        .onAppear {
            vm.startCalibration()
        }
        .onDisappear {
            vm.stop()
        }
    }

    private var calibratingContent: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Let’s calibrate your watch first")
                    .font(AppFont.largeTitleBold)
                    .foregroundStyle(.textPrimaryWhite)

                Text("Strum \(strumDirection == .up ? "up" : "down") 5 times on your guitar")
                    .font(AppFont.title3Regular)
                    .foregroundColor(.textPrimaryWhite)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack(spacing: Spacing.xl) {
                Image(systemName: "arrow.up.arrow.down")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.brandColorAccentGreen)
                    .frame(width: 168)
                        .fontWeight(.bold)
                        .symbolRenderingMode(.hierarchical)
                    
                    VStack(spacing: Spacing.sm) {
                        Text(receiver.calibrationStatusText)
                            .font(AppFont.title3Bold)
                            .foregroundStyle(.textPrimaryWhite)
                            .multilineTextAlignment(.center)
                        
                        if receiver.isCalibrating {
                            ProgressView(
                                value: Double(receiver.recordedSamplesCount),
                                total: Double(receiver.targetSamples)
                            )
                            .tint(.brandColorAccentGreen)
                            
                            Text("\(receiver.recordedSamplesCount) / \(receiver.targetSamples)")
                                .font(AppFont.bodyRegular.monospacedDigit())
                                .foregroundStyle(.textPrimaryWhite)
                        } else {
                            Text("Make sure the guitar sound is detected while strumming.")
                                .font(AppFont.caption1Regular)
//                                .foregroundStyle(.textSecondaryWhite)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                HStack {
                    ForEach(0..<receiver.targetSamples, id: \.self) { index in
                        if index > 0 { Spacer() }
                        ArrowIcon(
                            direction: strumDirection,
                            isCompleted: index < receiver.recordedSamplesCount
                        )
                    }
                    Spacer()
                }
            }

            Spacer()

            Button {
                vm.recalibrate()
            } label: {
                Text("Reset")
                    .font(AppFont.bodyRegular)
                    .foregroundColor(.brandColorPrimaryPurple)
            }
        }
    }
}

//#Preview {
//    CalibrateWatchView()
//}
