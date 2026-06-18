//
//  AnalysisErrorView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 19/06/26.
//

import SwiftUI

struct AnalysisErrorView: View {

    let error: String
    var onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.brandColorSecondaryPink)

            Text("Analysis Failed")
                .font(AppFont.title3Bold)
                .foregroundStyle(.textPrimaryWhite)

            Text(error)
                .font(AppFont.bodyRegular)
                .foregroundStyle(.textPrimaryWhite.opacity(0.7))
                .multilineTextAlignment(.center)

            Button(action: onRetry) {
                Text("Retry")
                    .font(AppFont.bodyBold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.brandColorPrimaryPurple)
                    )
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.6).ignoresSafeArea()
        AnalysisErrorView(error: "Audio file tidak ditemukan. Coba upload ulang.", onRetry: {})
            .padding(24)
            .padding(.horizontal, 20)
    }
}
