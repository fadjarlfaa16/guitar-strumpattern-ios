//
//  PrepareYourGuitarView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Eka Feby Ronauli Lubis on 08/06/26.
//

import SwiftUI


struct PrepareYourGuitarView: View {
    var body: some View {
        ZStack {
            // Background
            Color.backgroundPrimaryBlack
                .ignoresSafeArea()
            // Main Content
            VStack {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Prepare Your Guitar")
                        .font(AppFont.largeTitleBold)
                        .foregroundStyle(.textPrimaryWhite)
                    
                    Text("You’ll need a guitar to practice and follow the  preffered strumming pattern")
                        .font(AppFont.title3Regular)
                        .foregroundColor(.textPrimaryWhite)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Image("guitars.fill")
                    .foregroundColor(.brandColorAccentGreen)
                
                Spacer()
                
                // Next Button
                VStack(spacing: 12) {
                    CustomButton(title: "Next")
                    Button(action: {
                    }) {
                        Text("Skip for Now")
                            .font(AppFont.bodyRegular)
                            .foregroundColor(.brandColorPrimaryPurple)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}
#Preview {
    PrepareYourGuitarView()
}
