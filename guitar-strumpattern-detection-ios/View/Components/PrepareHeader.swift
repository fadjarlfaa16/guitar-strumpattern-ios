//
//  PrepareHeader.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Eka Feby Ronauli Lubis on 12/06/26.
//

import SwiftUI

struct PrepareHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Prepare Your Guitar and Apple Watch")
                .font(AppFont.largeTitleBold)
                .foregroundColor(.textPrimaryWhite)
                .lineSpacing(2)
            
            Text("You'll need a guitar and an Apple Watch to practice your strumming")
                .font(AppFont.title3Regular)
                .foregroundColor(.textPrimaryWhite)
        }
        .padding(.top, Spacing.md)
        .padding(.horizontal, Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    PrepareHeader()
        .background(Color.backgroundPrimaryBlack)
}
