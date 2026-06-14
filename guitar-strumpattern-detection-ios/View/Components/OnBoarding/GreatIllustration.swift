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
            Image("AddSong")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 120)
        }
    }
}

          



// MARK: - Preview
#Preview {
    GreatIllustration()
        .padding(Spacing.xxl)
        .background(Color.backgroundPrimaryBlack)
}
