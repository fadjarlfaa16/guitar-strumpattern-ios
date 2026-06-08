//
//  Untitled.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 08/06/26.
//

import SwiftUI
/// Draws a pill background that spans from the first note to the last note
/// in the group (time-based width). BPM directly controls how wide the pill is.
/// A small floating chord label appears above the pill's leading edge.
struct ChordGroupPillView: View {
    
    let group: ChordGroup
    let leadX: CGFloat
    let pillW: CGFloat
    let laneH: CGFloat
    let hitZoneX: CGFloat
    
    private let blockSize = RhythmGameViewModel.noteBlockSize
    
    private var pillCX: CGFloat {
        leadX + pillW / 2
    }
    
    private var pillCY: CGFloat {
        laneH / 2
    }
    
    private var labelY: CGFloat {
        pillCY - blockSize / 2 - 10
    }
    
    private var labelOpacity: Double {
        let distance = leadX - hitZoneX
        let fadeDistance: CGFloat = 60.0
        
        if distance > fadeDistance { return 1.0 }
        if distance < 10.0 { return 0.0 } // Disappear slightly before it perfectly touches
        
        return Double((distance - 10.0) / (fadeDistance - 10.0))
    }
    
    var body: some View {
        ZStack {
            
            // ── Pill background ──
//            RoundedRectangle(cornerRadius: 12)
//                .fill(.brandColorPrimaryPurple.opacity(0.4))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .strokeBorder(
//                            .brandColorPrimaryPurple.opacity(0.45),
//                            lineWidth: 1
//                        )
//                )
//                .frame(width: pillW, height: blockSize)
//                .position(x: pillCX, y: pillCY)
//            
            // ── Floating chord label ──
            HStack(spacing: 0) {
                Text(group.chord)
                    .font(AppFont.title3Bold)
                    .foregroundStyle(.brandColorAccentGreen)
                
                Spacer(minLength: 0)
            }
            .frame(width: pillW)
            .position(x: pillCX, y: labelY)
            .opacity(labelOpacity)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ChordGroupPillView(
            group: ChordGroup(
                chord: "Am",
                notes: []
            ),
            leadX: 40,
            pillW: 220,
            laneH: 120,
            hitZoneX: 20
        )
    }
}
