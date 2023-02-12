//
//  LovedShortcutView.swift
//  HappyAnding
//
//  Created by KiWoong Hong on 2022/10/22.
//

import SwiftUI

struct LovedShortcutView: View {
    
    @Binding var shortcuts: [Shortcuts]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                SubtitleTextView(text: TextLiteral.lovedShortcutViewTitle)
                
                Spacer()
                
                NavigationLink(value: NavigationListShortcutType(sectionType: .popular,
                                                                 shortcuts: shortcuts,
                                                                 navigationParentView: .shortcuts)) {
                    MoreCaptionTextView(text: TextLiteral.more)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
            if let shortcuts {
                ForEach(Array(shortcuts.enumerated()), id:\.offset) { index, shortcut in
                    if index < 3 {
                        let data = NavigationReadShortcutType(shortcutID: shortcut.id,
                                                              navigationParentView: .shortcuts)
                        
                        NavigationLink(value: data) {
                            ShortcutCell(shortcut: shortcut,
                                         navigationParentView: .shortcuts)
                        }
                    }
                }
            }
            
        }
        .background(Color.shortcutsZipBackground)
    }
}

