//
//  AnalysisLoadingView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 19/06/26.
//

import SwiftUI

struct AnalysisLoadingView: View {

    let progress: Double
    let stage: String

    @State private var animatingIndex: Int = 0

    var body: some View {
        VStack(spacing: 24) {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .brandColorAccentGreen))
                .scaleEffect(y: 2, anchor: .center)

            VStack(spacing: 8) {
                Text(stage)
                    .font(AppFont.bodyRegular)
                    .foregroundStyle(.textPrimaryWhite)

                Text(String(format: "%.0f%%", progress * 100))
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.brandColorAccentGreen)
            }

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.brandColorAccentGreen)
                        .frame(width: 4, height: 24)
                        .opacity(animatingIndex == index ? 1 : 0.3)
                }
            }
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    withAnimation {
                        animatingIndex = (animatingIndex + 1) % 3
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.6).ignoresSafeArea()
        AnalysisLoadingView(progress: 0.45, stage: "Analyzing BPM & Time Signature...")
            .padding(24)
            .padding(.horizontal, 20)
    }
}
