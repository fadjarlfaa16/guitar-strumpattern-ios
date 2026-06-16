//
//  UpArrowIcon.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//

import SwiftUI

struct ArrowIcon: View {
    let direction: StrumBeat
    var isCompleted: Bool = false
    
    private var foregroundStyle: Color {
        isCompleted ? .brandColorAccentGreen : .gray
    }
    
    var body: some View {
        Image(systemName: direction == .up ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
            .resizable()
            .scaledToFit()
            .fontWeight(.bold)
            .foregroundStyle(foregroundStyle)
            .symbolRenderingMode(.hierarchical)
            .animation(.easeInOut(duration: 0.3), value: isCompleted)
    }
}
//
#Preview {
    ArrowIcon(direction: .up)
}
