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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
        }
        .tint(Color.brandColorPrimaryPurple)
        .buttonStyle(.glassProminent)
    }
}

#Preview {
    CustomButton(
        title: "Halo")
}

