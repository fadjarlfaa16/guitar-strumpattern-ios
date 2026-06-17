//
//  PauseOverlay.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//
import SwiftUI


struct PauseOverlay: View {

    let tutorialPauseStep: Int

    let onExit: () -> Void
        let onReplay: () -> Void
        let onChangePattern: () -> Void
        let onResume: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.6).ignoresSafeArea()
            
            HStack {
                pauseActionButton(icon: .arrowBackward, label: "Exit", color:.textPrimaryWhite ) {
                    onExit()
                }
                Spacer()
                pauseActionButton(icon: .replay, label: "Replay",color:.textPrimaryWhite) {
                    onReplay()
                }
                Spacer()
                pauseActionButton(icon: .musicnotelist, label: "Change Pattern",color:.textPrimaryWhite) {
                    onChangePattern()
                }
            }
            
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 40)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(Color(hue: 0.75, saturation: 0.4, brightness: 0.2))
            )
            .shadow(color: .black.opacity(0.5), radius: 20)
            
            // Pause Tutorial Step 2
            if tutorialPauseStep == 2 {
                VStack {
                    Spacer()
                    Text("Tap again to unpause")
                        .font(AppFont.title3Regular)
                        .foregroundStyle(.textPrimaryWhite)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.backgroundPrimaryBlack.opacity(0.8)))
                    Spacer()
                }
                .allowsHitTesting(false)
            }
        }
        .onTapGesture {
            onResume()
        }
    }
    
    private func pauseActionButton(
        icon: Image,
        label: String,
        color: Color = .textPrimaryWhite,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
                    .foregroundStyle(color)

                Text(label)
                    .font(.caption)
                    .foregroundStyle(color)
            }
        }
    }
}

