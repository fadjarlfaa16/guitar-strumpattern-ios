//
//  GreatIllustrationView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 07/06/26.
//


// GreatIllustrationView.swift
// Komponen ilustrasi tengah: icon musik + icon upload file

import SwiftUI

// MARK: - Great Illustration View
struct GreatIllustration: View {
    var body: some View {
        Image("AddSong")
            .resizable()
            .scaledToFit()
            .frame(width: 120)
    }
}

struct FileUploadIcon: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {

            // Panah upload di tengah
            Image(systemName: "arrow.up")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 72, height: 84)
                .offset(y: 6)
        }
    }
}

          



// MARK: - Preview
#Preview {
    GreatIllustration()
        .padding(Spacing.xxl)
        .background(Color.backgroundPrimaryBlack)
}
