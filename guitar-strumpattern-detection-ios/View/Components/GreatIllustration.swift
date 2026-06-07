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
        ZStack(alignment: .bottomTrailing) {
            // Icon musik (kuning, kiri bawah)
            Image(systemName: "music.note")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(Color.brandColorAccentGreen)
                .offset(x: -20, y: 10)

            // Icon file upload (pink, kanan atas)
            FileUploadIcon()
        }
        .frame(width: 140, height: 120)
    }
}

struct FileUploadIcon: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Body dokumen dengan sudut terpotong
            Rectangle()
                .fill(Color.brandColorSecondaryPink)
                .frame(width: 72, height: 84)
                .clipShape(FoldedCorner(cornerSize: 18))

            // Segitiga lipatan di sudut kanan atas
            Triangle()
                .fill(Color.brandColorPrimaryPurple)
                .frame(width: 18, height: 18)

            // Panah upload di tengah
            Image(systemName: "arrow.up")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 72, height: 84)
                .offset(y: 6)
        }
    }
}

// Segitiga untuk efek lipatan
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}



// MARK: - Preview
#Preview {
    GreatIllustration()
        .padding(Spacing.xxl)
        .background(Color.backgroundPrimaryBlack)
}
