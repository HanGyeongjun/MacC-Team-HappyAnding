//
//  LaunchScreenView.swift
//  HappyAnding
//
//  Created by 전지민 on 2022/11/29.
//

import SwiftUI

struct LaunchScreenView: View {
    @StateObject var userAuth = UserAuth.shared
    @StateObject var shorcutsZipViewModel = ShortcutsZipViewModel()
    @AppStorage("signInStatus") var signInStatus = false
    @AppStorage("isReauthenticated") var isReauthenticated = false
    
    var body: some View {
        if signInStatus {
            ShortcutTabView()
                .environmentObject(userAuth)
                .environmentObject(shorcutsZipViewModel)
        }  else {
            if userAuth.isLoggedIn {
                WriteNicknameView()
                    .environmentObject(shorcutsZipViewModel)
                    .onDisappear() {
                        if shorcutsZipViewModel.userInfo == nil {
                            shorcutsZipViewModel.fetchUser(userID: shorcutsZipViewModel.currentUser()) { user in
                                shorcutsZipViewModel.userInfo = user
                            }
                        }
                    }
            } else {
                SignInWithAppleView()
                    .onDisappear() {
                        if shorcutsZipViewModel.userInfo == nil {
                            shorcutsZipViewModel.fetchUser(userID: shorcutsZipViewModel.currentUser()) { user in
                                shorcutsZipViewModel.userInfo = user
                                shorcutsZipViewModel.initUserShortcut(user: user)
                                shorcutsZipViewModel.curationsMadeByUser = shorcutsZipViewModel.fetchCurationByAuthor(author: user.id)
                            }
                        }
                    }
            }
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}
