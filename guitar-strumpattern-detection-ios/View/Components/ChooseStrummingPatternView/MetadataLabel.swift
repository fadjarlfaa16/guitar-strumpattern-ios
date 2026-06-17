//
//  MetadataLabel.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//


import SwiftUI

struct MetadataLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(AppFont.bodyRegular)
            .foregroundColor(.brandColorSecondaryPink)
    }
}