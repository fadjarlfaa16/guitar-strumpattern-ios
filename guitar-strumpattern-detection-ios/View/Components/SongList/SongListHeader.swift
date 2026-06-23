//
//  SongListHeader.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//
import SwiftUI


struct SongListHeader: View {
    var body: some View {
        HStack {
            Text("Song Library")
                .font(.largeTitle)
                .foregroundColor(.textPrimaryWhite)
                .bold()

            Spacer()
        }
    }
}

#Preview {
    ZStack {
        Rectangle()
            .foregroundColor(.green)
        SongListHeader()
    }
}
