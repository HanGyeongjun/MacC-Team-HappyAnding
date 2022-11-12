//
//  ExploreShortcutView.swift
//  HappyAnding
//
//  Created by 이지원 on 2022/10/19.
//

import SwiftUI

struct ExploreShortcutView: View {
    
    @EnvironmentObject var shortcutsZipViewModel: ShortcutsZipViewModel
    @StateObject var navigation = ShortcutNavigation()
    
    var body: some View {
        NavigationStack(path: $navigation.shortcutPath) {
            ScrollView {
                MyShortcutCardListView(navigationParentView: .shortcuts,
                                       shortcuts: shortcutsZipViewModel.shortcutsMadeByUser)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                DownloadRankView(shortcuts: $shortcutsZipViewModel.sortedShortcutsByDownload,
                                 navigationParentView: .shortcuts)
                    .padding(.bottom, 32)
                
                CategoryView()
                    .padding(.bottom, 32)
                LovedShortcutView(shortcuts: $shortcutsZipViewModel.sortedShortcutsByLike,
                                  navigationParentView: .shortcuts)
                    .padding(.bottom, 44)
            }
            .navigationBarTitle(Text("단축어 둘러보기"))
            .navigationBarTitleDisplayMode(.large)
            .scrollIndicators(.hidden)
            .background(Color.Background)
        }
        .environmentObject(navigation)
    }
}

struct ExploreShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreShortcutView()
    }
}

