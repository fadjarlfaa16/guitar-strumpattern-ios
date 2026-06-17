//
//  NoteBlockView.swift
//  guitar-strumpattern-detection-ios
//
//  Created by muhammad aqil zaki on 17/06/26.
//

import SwiftUI

struct NoteBlockView: View {

    let note: ActiveNote

    var body: some View {
        let state: NoteState = {
            if note.isHit || note.isExpired {
                return note.hitResult == .miss ? .missState : .successState
            }
            return .defaultState
        }()

        StrumBlock(
            direction: note.input.direction,
            noteState: state
        )
    }
}
