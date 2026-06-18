//
//  CalibrateWatch.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//
import SwiftUI
////s
struct CalibrateWatchView: View {
    let isRecalibrating: Bool
    
    @State private var navigateToWatchCheck = false
    @StateObject private var vm = GuitarValidationViewModel()
    
    private var strumDirection: StrumBeat {
        vm.receiver.calibrationPhase == "up" ? .up : .down
    }
    
    init(isRecalibrating: Bool = false) {
        self.isRecalibrating = isRecalibrating
    }
    
    var body: some View {
        ZStack {
            Color.backgroundPrimaryBlack
                .ignoresSafeArea()

        BackgroundLines(style:.prepareGuitar)
                .ignoresSafeArea()

            Group {
                if vm.isCalibrated {
                    CalibrateCompleteView(isRecalibrating: isRecalibrating, onReset: vm.recalibrate)
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
            WatchReceiver.shared.requiresSoundValidation = true
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
                WatchStatusView()
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
                    .scaleEffect(
                        x: strumDirection == .up ? -1 : 1,
                        y: strumDirection == .down ? -1 : 1
                    )
                    .animation(.easeInOut(duration: 0.3), value: strumDirection)
                    
                HStack {
                    ForEach(0..<vm.receiver.targetSamples, id: \.self) { index in
                        if index > 0 { Spacer() }
                        ArrowIcon(
                            direction: strumDirection,
                            isCompleted: index < vm.receiver.recordedSamplesCount
                        )
                    }
                    Spacer()
                }
            }

            Spacer()

            HStack(spacing: 24) {
                SecondaryTextButton(title: "Wake Watch") {
                    WatchSessionManager.shared.requestWatchAppLaunch()
                }
                
                SecondaryTextButton(title: "Sync Watch") {
                    vm.receiver.syncAppState(state: "calibrating")
                    vm.receiver.startCalibration()
                }
                
                SecondaryTextButton(title: "Reset") {
                    vm.recalibrate()
                }
            }
        }
    }
}

#Preview {
    CalibrateWatchView()
}
