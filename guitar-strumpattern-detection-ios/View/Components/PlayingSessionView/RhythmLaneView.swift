//
//  RhythmLaneView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//

import SwiftUI

struct RhythmLaneView: View {

    @ObservedObject var vm: RhythmGameViewModel

    @Binding var screenWidth: CGFloat

    let hitZoneX: CGFloat

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let blockSize = RhythmGameViewModel.noteBlockSize

            ZStack(alignment: .leading) {
                laneBackground(width: w, height: 150)
                hitZoneLine(height: 150)
                    .zIndex(100)

                ForEach(vm.chordGroups) { group in
                    let leadX = vm.groupLeadingX(for: group)
                    let pillW = vm.groupPillWidth(for: group)
                    let trailX = leadX + pillW

                    if trailX > 0 && leadX < w {
                        ChordGroupPillView(
                            group: group,
                            leadX: leadX,
                            pillW: pillW,
                            laneH: h,
                            hitZoneX: hitZoneX
                        )
                    }
                }

                // ── Individual note blocks (on top of pills) ──
                ForEach(vm.activeNotes) { note in
                    let x = vm.noteXPosition(for: note)
                    NoteBlockView(note: note)
                        .position(x: x, y: h / 2)
                }

                // ── Sticky chord label pinned at the timing line ──
                // Shows the current chord name fixed at the hit zone
                // while the group scrolls past.
                if let chord = vm.currentChord {
                    let labelY = h / 2 - blockSize / 2 - 14
                    Text(chord)
                        .font(AppFont.title3Bold)
                        .foregroundStyle(.brandColorAccentGreen)
                        .position(
                            x: w * RhythmGameViewModel.hitZoneFraction - 20,
                            y: labelY
                        )
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.15), value: vm.currentChord)
                }
            }
            .clipped()
            .onAppear {
                screenWidth    = w
                vm.screenWidth = w
            }
            .onChange(of: geo.size.width) { _, newW in
                screenWidth    = newW
                vm.screenWidth = newW
            }
        }
    }
    private func laneBackground(width: CGFloat, height: CGFloat) -> some View {
        Rectangle()
               .fill(Color(hex: "9E9E9E").opacity(0.06))
               .frame(width: width, height: height)
       }

    // MARK: Hit Zone Line

    private func hitZoneLine(height: CGFloat) -> some View {
        ZStack {
            // Sharp line
            Rectangle()
                .fill(.textPrimaryWhite)
                .frame(width: 4, height: height)
        }
        .offset(x: hitZoneX - 1)
    }

    private var diamondAccent: some View {
        Rectangle()
            .fill(.brandColorPrimaryPurple)
            .frame(width: 9, height: 9)
            .rotationEffect(.degrees(45))
            .shadow(color: .brandColorPrimaryPurple, radius: 4)
    }
}
