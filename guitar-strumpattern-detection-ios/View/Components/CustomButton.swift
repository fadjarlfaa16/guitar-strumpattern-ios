//
//  CustomButton.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Eka Feby Ronauli Lubis on 07/06/26.
//

import SwiftUI

struct CustomButton: View {
    let title: String
    var action: (() -> Void) = {}
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(AppFont.headlineSemibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                
        }
        .tint(.brandColorPrimaryPurple2)
        .buttonStyle(.glassProminent)
    }
}

#Preview {
    CustomButton(
        title: "Halo")
}

