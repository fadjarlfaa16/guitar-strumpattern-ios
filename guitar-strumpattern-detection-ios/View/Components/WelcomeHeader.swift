//
//  WelcomeHeader.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Eka Feby Ronauli Lubis on 12/06/26.
//

import SwiftUI

struct WelcomeHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Welcome")
                .font(AppFont.largeTitleBold)
                .foregroundColor(.textPrimaryWhite)
                .lineSpacing(2)

            Text("Let's Try Our Demo Song First")
                .font(AppFont.title3Regular)
                .foregroundColor(.textPrimaryWhite)
        }
        .padding(.top, Spacing.md)
        .padding(.horizontal, Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    } 
}

#Preview {
    WelcomeHeader()
        .background(Color.backgroundPrimaryBlack)
}
