//
//  StrumBlock.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 05/06/26.
//

import SwiftUI

struct StrumBlock: View {
    var body: some View {
        Image(systemName: AppIcon.upArrow)
            .font(.system(size: 55).bold())
            .padding()
            .foregroundStyle(.textPrimaryWhite)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.brandColorPrimaryPurple.opacity(0.35))
            )
            
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        StrumBlock()
    }
}
