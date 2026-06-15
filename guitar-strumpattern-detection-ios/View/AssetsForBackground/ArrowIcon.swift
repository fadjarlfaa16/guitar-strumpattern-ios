//
//  UpArrowIcon.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 15/06/26.
//

import SwiftUI

struct ArrowIcon: View {
    var foregroundStyle: Color = .gray
    let direction: StrumBeat
    
    var body: some View {
        Image(systemName: direction == .up ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
            .resizable()
            .scaledToFit()
            .fontWeight(.bold)
            .foregroundStyle(foregroundStyle)
            .symbolRenderingMode(.hierarchical)
            .animation(.easeInOut(duration: 0.3), value: foregroundStyle)
    }
}

#Preview {
    ArrowIcon(direction: .up)
}
