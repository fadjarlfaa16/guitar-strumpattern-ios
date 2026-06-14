//
//  CalibrateView.swift
//  guitar-strumpattern-detection-ios
//

import SwiftUI

struct CalibrateView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm: GuitarValidationViewModel
    @ObservedObject private var receiver: WatchReceiver
    @ObservedObject private var audioMonitor: AudioMonitor

    @State private var strumScale: CGFloat = 1.0
    @State private var flashOpacity: Double = 0.0

    init() {
        let viewModel = GuitarValidationViewModel()
        _vm = StateObject(wrappedValue: viewModel)
        _receiver = ObservedObject(wrappedValue: viewModel.receiver)
        _audioMonitor = ObservedObject(wrappedValue: viewModel.receiver.audioMonitor)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                header
                CalibratePhaseIndicator(isCalibrated: vm.isCalibrated)
                CalibrateAudioSettingsCard(
                    receiver: receiver,
                    audioMonitor: audioMonitor,
                    isCalibrated: vm.isCalibrated,
                    isSoundGateOpen: vm.chordVM.isSoundGateOpen
                )
                CalibrateStrumSection(
                    receiver: receiver,
                    isCalibrated: vm.isCalibrated,
                    onStartCalibration: vm.startCalibration,
                    onRecalibrate: vm.recalibrate
                )
                if vm.isCalibrated {
                    CalibratePlaySection(
                        receiver: receiver,
                        chordVM: vm.chordVM,
                        strumCount: vm.strumCount,
                        lastConfirmedStrum: vm.lastConfirmedStrum,
                        strumScale: strumScale,
                        flashOpacity: flashOpacity
                    )
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
        .background(Color.bgPrimary.ignoresSafeArea())
        .navigationTitle("Kalibrasi Gitar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.textPrimary)
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onChange(of: receiver.strumPulseTrigger) { _, _ in
            triggerStrumFeedback()
        }
        .onDisappear {
            vm.chordVM.stopListening()
        }
    }

    private var header: some View {
        VStack(spacing: Spacing.sm) {
            Text("Validasi Gitar")
                .font(AppFont.largeTitleBold)
                .foregroundColor(.textPrimary)

            Text(vm.isCalibrated
                 ? "Strum dan lihat chord terdeteksi"
                 : "Kalibrasi gerakan strum di Apple Watch")
                .font(AppFont.bodyRegular)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.sm)
    }

    private func triggerStrumFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        withAnimation(.spring(response: 0.1, dampingFraction: 0.4)) {
            strumScale = 1.35
            flashOpacity = 0.45
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.2)) {
                strumScale = 1.0
                flashOpacity = 0.0
            }
        }
    }
}

#Preview {
    NavigationStack {
        CalibrateView()
    }
}
