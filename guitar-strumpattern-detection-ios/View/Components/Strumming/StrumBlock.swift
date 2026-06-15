//
//  StrumBlock.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 05/06/26.
//

import SwiftUI

// MARK: - Note Display State
/// Renamed from `State` to avoid conflict with SwiftUI's `State` property wrapper.
enum NoteState {
    case defaultState
    case successState
    case missState
}

// MARK: - StrumBlock View
struct StrumBlock: View {

    /// Strum direction — "up" or "down". Defaults to "up".
    var direction: String = "up"
    /// Visual state of the note block.
    var noteState: NoteState = .defaultState

    // MARK: Derived Properties
    private var icon: String {
        direction == "down" ? AppIcon.downArrow : AppIcon.upArrow
    }

    private var blockColor: Color {
        switch noteState {
        case .defaultState:  return .textPrimaryWhite
        case .successState:  return .green
        case .missState:     return .red
        }
    }

    private var glowColor: Color {
        switch noteState {
        case .defaultState:  return .brandColorPrimaryPurple.opacity(0.6)
        case .successState:  return .brandColorAccentGreen.opacity(0.8)
        case .missState:     return .red.opacity(0.8)
        }
    }

    // MARK: Body
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 55).bold())
            .padding()
            .foregroundStyle(blockColor)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.brandColorPrimaryPurple.opacity(0.35))
            )
            .scaleEffect(noteState == .successState ? 1.12 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: noteState)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()

        HStack(spacing: 20) {
            StrumBlock(direction: "up",   noteState: .defaultState)
            StrumBlock(direction: "down", noteState: .successState)
            StrumBlock(direction: "up",   noteState: .missState)
        }
    }
}
