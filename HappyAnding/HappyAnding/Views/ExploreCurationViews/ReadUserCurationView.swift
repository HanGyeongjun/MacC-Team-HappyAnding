//
//  ReadUserCurationView.swift
//  HappyAnding
//
//  Created by HanGyeongjun on 2022/10/22.
//

import SwiftUI

struct ReadUserCurationView: View {
    
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    
    @EnvironmentObject var shortcutsZipViewModel: ShortcutsZipViewModel
    @StateObject var writeCurationNavigation = WriteCurationNavigation()
    @State var authorInformation: User? = nil
    
    @State var isWriting = false
    @State var isTappedEditButton = false
    @State var isTappedShareButton = false
    @State var isTappedDeleteButton = false
    @State var data: NavigationReadUserCurationType
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack(alignment: .bottom) {
                
                GeometryReader { geo in
                    let yOffset = geo.frame(in: .global).minY
                    
                    Color.White
                        .frame(width: geo.size.width, height: 371 + (yOffset > 0 ? yOffset : 0))
                        .offset(y: yOffset > 0 ? -yOffset : 0)
                }
                .frame(minHeight: 371)
                
                VStack {
                    userInformation
                        .padding(.top, 103)
                        .padding(.bottom, 22)
                    
                    UserCurationCell(curation: data.userCuration,
                                     navigationParentView: data.navigationParentView)
                    .padding(.bottom, 12)
                }
            }
            VStack(spacing: 0){
                ForEach(Array(self.data.userCuration.shortcuts.enumerated()), id: \.offset) { index, shortcut in
                    let data = NavigationReadShortcutType(shortcutID: shortcut.id,
                                                          navigationParentView: self.data.navigationParentView)
                    
                    NavigationLink(value: data) {
                        ShortcutCell(shortcutCell: shortcut,
                                     navigationParentView: self.data.navigationParentView)
                        .padding(.bottom, index == self.data.userCuration.shortcuts.count - 1 ? 44 : 0)
                    }
                }
            }
            
        }
        .onChange(of: isWriting) { _ in
            if !isWriting {
                if let updatedCuration = shortcutsZipViewModel.fetchCurationDetail(curationID: data.userCuration.id) {
                    data.userCuration = updatedCuration
                }
            }
        }
        .navigationDestination(for: NavigationReadShortcutType.self) { data in
            ReadShortcutView(data: data)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .background(Color.Background.ignoresSafeArea(.all, edges: .all))
        .scrollContentBackground(.hidden)
        .edgesIgnoringSafeArea([.top])
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: readCurationViewButtonByUser())
        .fullScreenCover(isPresented: $isWriting) {
            NavigationStack(path: $writeCurationNavigation.navigationPath) {
                WriteCurationSetView(isWriting: $isWriting,
                                     curation: self.data.userCuration,
                                     isEdit: true)
            }
            .environmentObject(writeCurationNavigation)
        }
    }
    
    var userInformation: some View {
        ZStack {
            HStack {
                Image(systemName: "person.fill")
                    .frame(width: 28, height: 28)
                    .foregroundColor(.White)
                    .background(Color.Gray3)
                    .clipShape(Circle())
                
                Text(authorInformation?.nickname ?? "닉네임")
                    .Headline()
                    .foregroundColor(.Gray4)
                Spacer()
            }
            .padding(.horizontal, 30)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .frame(height: 48)
                    .foregroundColor(.Gray1)
                    .padding(.horizontal, 16)
            ).alert(isPresented: $isTappedDeleteButton) {
                Alert(title: Text("글 삭제")
                    .foregroundColor(.Gray5),
                      message: Text("글을 삭제하시겠습니까?")
                    .foregroundColor(.Gray5),
                      primaryButton: .default(Text("닫기"),
                      action: {
                    self.isTappedDeleteButton.toggle()
                }),
                      secondaryButton: .destructive(
                        Text("삭제")
                        , action: {
                            shortcutsZipViewModel.deleteData(model: self.data.userCuration)
                            shortcutsZipViewModel.curationsMadeByUser = shortcutsZipViewModel.curationsMadeByUser.filter { $0.id != self.data.userCuration.id }
                            presentation.wrappedValue.dismiss()
                }))
            }
        }
        .onAppear {
            shortcutsZipViewModel.fetchUser(userID: self.data.userCuration.author) { user in
                authorInformation = user
            }
        }
    }
    var BackButton: some View {
        Button(action: {
        self.presentation.wrappedValue.dismiss()
        }) {
            //TODO: 위치와 두께, 색상 조정 필요
            Image(systemName: "chevron.backward")
                .foregroundColor(Color.Gray5)
                .bold()
        }
    }
}


extension ReadUserCurationView {
    
    @ViewBuilder
    private func readCurationViewButtonByUser() -> some View {
        if self.data.userCuration.author == shortcutsZipViewModel.currentUser() {
            myCurationMenu
        } else {
            shareButton
        }
    }
    
    private var myCurationMenu: some View {
        Menu(content: {
            Section {
                shareButton
                deleteButton
            }
        }, label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.Gray4)
        })
    }
    
    private var shareButton: some View {
        Button(action: {
            shareCuration()
        }) {
            Label("공유", systemImage: "square.and.arrow.up")
        }
    }
    
    private var deleteButton: some View {
        Button(role: .destructive, action: {
            isTappedDeleteButton.toggle()
            // TODO: firebase delete function
            
        }) {
            Label("삭제", systemImage: "trash.fill")
        }
    }
    
    private func shareCuration() {
        guard let deepLink = URL(string: "ShortcutsZip://myPage/CurationDetailView?curationID=\(data.userCuration.id)") else { return }
        
        let activityVC = UIActivityViewController(activityItems: [deepLink], applicationActivities: nil)
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return }
        window.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}

