//
//  ReadShortcutView.swift
//  HappyAnding
//
//  Created by 이지원 on 2022/10/19.
//

import SwiftUI

import WrappingHStack

struct ReadShortcutView: View {
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    @Environment(\.openURL) private var openURL
    @Environment(\.loginAlertKey) var loginAlerter
    
    @StateObject var viewModel: ReadShortcutViewModel
    @StateObject var writeNavigation = WriteShortcutNavigation()
    
    @AppStorage("useWithoutSignIn") var useWithoutSignIn: Bool = false
    @FocusState private var isFocused: Bool
    @Namespace var namespace
    @Namespace var bottomID
    
    private let tabItems = [TextLiteral.readShortcutViewBasicTabTitle, TextLiteral.readShortcutViewVersionTabTitle, TextLiteral.readShortcutViewCommentTabTitle]
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        if viewModel.shortcut != nil {
                            
                            StickyHeader(height: 40)
                            
                            /// 단축어 타이틀
                            ReadShortcutViewHeader(shortcut: $viewModel.shortcut, isMyLike: $viewModel.isMyLike)
                            
                            /// 탭뷰 (기본 정보, 버전 정보, 댓글)
                            LazyVStack(pinnedViews: [.sectionHeaders]) {
                                Section(header: tabBarView) {
                                    ZStack {
                                        TabView(selection: $viewModel.currentTab) {
                                            Color.clear
                                                .tag(0)
                                            Color.clear
                                                .tag(1)
                                            Color.clear
                                                .tag(2)
                                        }
                                        .tabViewStyle(.page(indexDisplayMode: .never))
                                        .frame(minHeight: UIScreen.screenHeight / 2)
                                        
                                        switch viewModel.currentTab {
                                        case 0:
                                            ReadShortcutContentView(shortcut: $viewModel.shortcut)
                                        case 1:
                                            ReadShortcutVersionView(shortcut: $viewModel.shortcut, isUpdating: $viewModel.isUpdatingShortcut)
                                        case 2:
                                            ReadShortcutCommentView(isFocused: _isFocused,
                                                                    newComment: $viewModel.comment,
                                                                    comments: $viewModel.comments,
                                                                    nestedCommentTarget: $viewModel.nestedCommentTarget,
                                                                    isEditingComment: $viewModel.isEditingComment,
                                                                    shortcutID: viewModel.shortcut.id)
                                            .id(bottomID)
                                        default:
                                            EmptyView()
                                        }
                                    }
                                    .animation(.easeInOut, value: viewModel.currentTab)
                                    .padding(.top, 4)
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) {
                        notification in
                        withAnimation {
                            if viewModel.currentTab == 2 && !viewModel.isEditingComment && viewModel.comment.depth == 0 {
                                proxy.scrollTo(bottomID, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .scrollDisabled(viewModel.isEditingComment)
            .background(Color.shortcutsZipBackground)
            .navigationBarBackground ({ Color.shortcutsZipWhite })
            .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
            .navigationBarItems(trailing: readShortcutViewNavigationBarItems())
            .toolbar(.hidden, for: .tabBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                
                /// Safe Area에 고정된 댓글창, 다운로드 버튼
                VStack {
                    if !viewModel.isEditingComment {
                        if viewModel.currentTab == 2 {
                            commentTextField
                        }
                        if !isFocused {
                            Button {
                                if !useWithoutSignIn {
                                    if let url = URL(string: viewModel.shortcut.downloadLink[0]) {
                                        viewModel.checkIfDownloaded()
                                        openURL(url)
                                    }
                                    viewModel.updateNumberOfDownload()
                                } else {
                                    loginAlerter.isPresented = true
                                }
                            } label: {
                                Text("다운로드 | \(Image(systemName: "arrow.down.app.fill")) \(viewModel.shortcut.numberOfDownload)")
                                    .shortcutsZipBody1()
                                    .foregroundColor(Color.textIcon)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.shortcutsZipPrimary)
                            }
                        }
                    }
                }
                .ignoresSafeArea(.keyboard)
            }
            .onAppear {
                UINavigationBar.appearance().standardAppearance.configureWithTransparentBackground()
            }
//            .onChange(of: viewModel.isEditingShortcut || viewModel.isUpdatingShortcut) { _ in
//                if !isEditingShortcut || !isUpdatingShortcut {
//                    data.shortcut = shortcutsZipViewModel.fetchShortcutDetail(id: data.shortcutID)
//                }
//            }
//            .onChange(of: viewModel.shortcutsZipViewModel.allComments) { _ in
//                self.comments = shortcutsZipViewModel.fetchComment(shortcutID: data.shortcutID)
//            }
            .onDisappear {
                viewModel.onViewDissapear()
            }
            .alert(TextLiteral.readShortcutViewDeletionTitle, isPresented: $viewModel.isDeletingShortcut) {
                Button(role: .cancel) {
                } label: {
                    Text(TextLiteral.cancel)
                }
                
                Button(role: .destructive) {
                    viewModel.deleteShortcut()
                    self.presentation.wrappedValue.dismiss()
                } label: {
                    Text(TextLiteral.delete)
                }
            } message: {
                Text(viewModel.isDowngradingUserLevel ? TextLiteral.readShortcutViewDeletionMessageDowngrade : TextLiteral.readShortcutViewDeletionMessage)
            }
            .fullScreenCover(isPresented: $viewModel.isEditingShortcut) {
                NavigationRouter(content: writeShortcutView,
                                 path: $writeNavigation.navigationPath)
                .environmentObject(writeNavigation)
            }
            //TODO: update shortcut
            .fullScreenCover(isPresented: $viewModel.isUpdatingShortcut) {
                UpdateShortcutView(isUpdating: $viewModel.isUpdatingShortcut, shortcut: $viewModel.shortcut)
            }
            
            /// 댓글 수정할 때 뒷 배경을 어둡게 만들기 위한 뷰
            if viewModel.isEditingComment {
                Color.black
                    .ignoresSafeArea()
                    .opacity(0.4)
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        commentTextField
                            .ignoresSafeArea(.keyboard)
                            .focused($isFocused, equals: true)
                            .task {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isFocused = true
                                }
                            }
                    }
                    .onAppear {
                        viewModel.commentText = viewModel.comment.contents
                    }
                    .onTapGesture(count: 1) {
                        isFocused.toggle()
                        viewModel.isUndoingCommentEdit.toggle()
                    }
                    .alert(TextLiteral.readShortcutViewDeleteFixesTitle, isPresented: $viewModel.isUndoingCommentEdit) {
                        Button(role: .cancel) {
                            isFocused.toggle()
                        } label: {
                            Text(TextLiteral.readShortcutViewKeepFixes)
                        }
                        
                        Button(role: .destructive) {
                            withAnimation(.easeInOut) {
                                viewModel.cancelEditingComment()
                            }
                        } label: {
                            Text(TextLiteral.delete)
                        }
                    } message: {
                        Text(TextLiteral.readShortcutViewDeleteFixes)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func writeShortcutView() -> some View {
        
        WriteShortcutView(isWriting: $viewModel.isEditingShortcut,
                          shortcut: viewModel.shortcut,
                          isEdit: true)
    }
}

extension ReadShortcutView {
    
    // MARK: - 댓글창
    
    private var commentTextField: some View {
        
        VStack(spacing: 0) {
            if viewModel.comment.depth == 1 && !viewModel.isEditingComment {
                nestedCommentTargetView
            }
            HStack {
                if viewModel.comment.depth == 1 && !viewModel.isEditingComment {
                    Image(systemName: "arrow.turn.down.right")
                        .smallIcon()
                        .foregroundColor(.gray4)
                }
                TextField(useWithoutSignIn ? TextLiteral.readShortcutViewCommentDescriptionBeforeLogin : TextLiteral.readShortcutViewCommentDescription, text: $viewModel.commentText, axis: .vertical)
                    .keyboardType(.twitter)
                    .disabled(useWithoutSignIn)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .shortcutsZipBody2()
                    .lineLimit(viewModel.comment.depth == 1 ? 2 : 4)
                    .focused($isFocused)
                    .onAppear {
                        UIApplication.shared.hideKeyboard()
                    }
                
                Button {
                    viewModel.postComment()
                    isFocused.toggle()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .mediumIcon()
                        .foregroundColor(viewModel.commentText == "" ? Color.gray2 : Color.gray5)
                }
                .disabled(viewModel.commentText == "" ? true : false)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                Rectangle()
                    .fill(Color.gray1)
                    .cornerRadius(12 ,corners: (viewModel.comment.depth == 1) && (!viewModel.isEditingComment) ? [.bottomLeft, .bottomRight] : .allCorners)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
    
    private var nestedCommentTargetView: some View {
        
        HStack {
            Text("@ \(viewModel.nestedCommentTarget)")
                .shortcutsZipFootnote()
                .foregroundColor(.gray5)
            
            Spacer()
            
            Button {
                viewModel.cancelNestedComment()
            } label: {
                Image(systemName: "xmark")
                    .smallIcon()
                    .foregroundColor(.gray5)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .background(
            Rectangle()
                .fill(Color.gray2)
                .cornerRadius(12 ,corners: [.topLeft, .topRight])
        )
        .padding(.horizontal, 16)
    }
    
    // MARK: - 내비게이션바 아이템
    
    @ViewBuilder
    private func readShortcutViewNavigationBarItems() -> some View {
        if viewModel.checkAuthor() {
            Menu {
                Section {
                    editButton
                    updateButton
                    shareButton
                    deleteButton
                }
            } label: {
                Image(systemName: "ellipsis")
                    .mediumIcon()
                    .foregroundColor(.gray4)
            }
        } else {
            shareButton
        }
    }
    
    private var editButton: some View {
        Button {
            viewModel.isEditingShortcut.toggle()
        } label: {
            Label(TextLiteral.edit, systemImage: "square.and.pencil")
        }
    }
    
    private var updateButton: some View {
        Button {
            viewModel.isUpdatingShortcut.toggle()
        } label: {
            Label(TextLiteral.update, systemImage: "clock.arrow.circlepath")
        }
    }
    
    private var shareButton: some View {
        Button {
            viewModel.shareShortcut()
        } label: {
            Label(TextLiteral.share, systemImage: "square.and.arrow.up")
                .foregroundColor(.gray4)
                .fontWeight(.medium)
        }
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            viewModel.checkDowngrade()
        } label: {
            Label(TextLiteral.delete, systemImage: "trash.fill")
        }
    }
    
    // MARK: - 탭바
    
    private var tabBarView: some View {
        HStack(spacing: 20) {
            ForEach(Array(zip(self.tabItems.indices, self.tabItems)), id: \.0) { index, name in
                tabBarItem(string: name, tab: index)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 36)
        .background(Color.shortcutsZipWhite)
    }
    
    private func tabBarItem(string: String, tab: Int) -> some View {
        Button {
            viewModel.currentTab = tab
        } label: {
            VStack {
                if viewModel.currentTab == tab {
                    Text(string)
                        .shortcutsZipHeadline()
                        .foregroundColor(.gray5)
                    Color.gray5
                        .frame(height: 2)
                        .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                    
                } else {
                    Text(string)
                        .shortcutsZipBody1()
                        .foregroundColor(.gray3)
                    Color.clear.frame(height: 2)
                }
            }
            .animation(.spring(), value: viewModel.currentTab)
        }
        .buttonStyle(.plain)
    }
}

extension ReadShortcutView {
    
    //MARK: - 단축어 타이틀
    
    struct ReadShortcutViewHeader: View {
        @Environment(\.loginAlertKey) var loginAlerter
        @EnvironmentObject var shortcutsZipViewModel: ShortcutsZipViewModel
        
        @AppStorage("useWithoutSignIn") var useWithoutSignIn: Bool = false
        
        @Binding var shortcut: Shortcuts
        @Binding var isMyLike: Bool
        
        @State var userInformation: User? = nil
        @State var numberOfLike = 0
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    
                    /// 단축어 아이콘
                    VStack {
                        Image(systemName: shortcut.sfSymbol)
                            .mediumShortcutIcon()
                            .foregroundColor(Color.textIcon)
                    }
                    .frame(width: 52, height: 52)
                    .background(Color.fetchGradient(color: shortcut.color))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    /// 좋아요 버튼
                    Text("\(isMyLike ? Image(systemName: "heart.fill") : Image(systemName: "heart")) \(numberOfLike)")
                        .shortcutsZipBody2()
                        .padding(10)
                        .foregroundColor(isMyLike ? Color.textIcon : Color.gray4)
                        .background(isMyLike ? Color.shortcutsZipPrimary : Color.gray1)
                        .cornerRadius(12)
                        .onTapGesture {
                            if !useWithoutSignIn {
                                isMyLike.toggle()
                                numberOfLike += isMyLike ? 1 : -1
                            } else {
                                loginAlerter.isPresented = true
                            }
                        }
                }
                
                /// 단축어 이름, 한 줄 설명
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(shortcut.title)")
                        .shortcutsZipTitle1()
                        .foregroundColor(Color.gray5)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("\(shortcut.subtitle)")
                        .shortcutsZipBody1()
                        .foregroundColor(Color.gray3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                /// 단축어 작성자 닉네임
                UserNameCell(userInformation: userInformation, gradeImage: shortcutsZipViewModel.fetchShortcutGradeImage(isBig: false, shortcutGrade: shortcutsZipViewModel.checkShortcutGrade(userID: userInformation?.id ?? "!")))
            }
            .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
            .padding(.bottom, 20)
            .padding(.horizontal, 16)
            .background(Color.shortcutsZipWhite)
            .onAppear {
                shortcutsZipViewModel.fetchUser(userID: shortcut.author,
                                                isCurrentUser: false) { user in
                    userInformation = user
                }
                numberOfLike = shortcut.numberOfLike
            }
            .onDisappear {
                self.shortcut.numberOfLike = numberOfLike
            }
        }
    }
    
    //MARK: - 기본 정보 탭
    
    struct ReadShortcutContentView: View {
        
        @Binding var shortcut: Shortcuts
        
        
        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading) {
                    Text(TextLiteral.readShortcutContentViewDescription)
                        .shortcutsZipBody2()
                        .foregroundColor(Color.gray4)
                    Text(shortcut.description)
                        .shortcutsZipBody2()
                        .foregroundColor(Color.gray5)
                        .lineLimit(nil)
                }
                
                splitList(title: TextLiteral.readShortcutContentViewCategory, content: shortcut.category)
                
                if !shortcut.requiredApp.isEmpty {
                    splitList(title: TextLiteral.readShortcutContentViewRequiredApps, content: shortcut.requiredApp)
                }
                
                Spacer()
                    .frame(maxHeight: .infinity)
            }
            .padding(.top, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        private func splitList(title: String, content: [String]) -> some View {
            
            VStack(alignment: .leading) {
                
                Text(title)
                    .shortcutsZipBody2()
                    .foregroundColor(Color.gray4)
                
                WrappingHStack(content, id: \.self, alignment: .leading, spacing: .constant(8), lineSpacing: 8) { item in
                    if Category.allCases.contains(where: { $0.rawValue == item }) {
                        Text(Category(rawValue: item)?.translateName() ?? "")
                            .shortcutsZipBody2()
                            .padding(.trailing, 8)
                            .foregroundColor(Color.gray5)
                    } else {
                        Text(item)
                            .shortcutsZipBody2()
                            .padding(.trailing, 8)
                            .foregroundColor(Color.gray5)
                    }
                    if item != content.last {
                        Divider()
                    }
                }
            }
        }
    }
    
    //MARK: - 버전 정보 탭
    
    struct ReadShortcutVersionView: View {
        
        @Environment(\.openURL) var openURL
        @Environment(\.loginAlertKey) var loginAlerter
        @EnvironmentObject var shortcutsZipViewModel: ShortcutsZipViewModel
        
        @AppStorage("useWithoutSignIn") var useWithoutSignIn: Bool = false
        
        @Binding var shortcut: Shortcuts
        @Binding var isUpdating: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                
                if shortcut.updateDescription.count == 1 {
                    Text(TextLiteral.readShortcutVersionViewNoUpdates)
                        .shortcutsZipBody2()
                        .foregroundColor(.gray4)
                        .padding(.top, 16)
                } else {
                    Text(TextLiteral.readShortcutVersionViewUpdateContent)
                        .shortcutsZipBody2()
                        .foregroundColor(.gray4)
                    
                    versionView
                }
                
                Spacer()
                    .frame(maxHeight: .infinity)
            }
            .padding(.top, 16)
        }
        
        private var versionView: some View {
            
            ForEach(Array(zip(shortcut.updateDescription, shortcut.updateDescription.indices)), id: \.0) { data, index in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Ver \(shortcut.updateDescription.count - index).0")
                            .shortcutsZipBody2()
                            .foregroundColor(.gray5)
                        
                        Spacer()
                        
                        Text(shortcut.date[index].getVersionUpdateDateFormat())
                            .shortcutsZipBody2()
                            .foregroundColor(.gray3)
                    }
                    
                    if data.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                        Text(data)
                            .shortcutsZipBody2()
                            .foregroundColor(.gray5)
                    }
                    
                    if index != 0 {
                        Button {
                            if !useWithoutSignIn {
                                if let url = URL(string: shortcut.downloadLink[index]) {
                                    if (shortcutsZipViewModel.userInfo?.downloadedShortcuts.firstIndex(where: { $0.id == shortcut.id })) == nil {
                                        shortcut.numberOfDownload += 1
                                    }
                                    shortcutsZipViewModel.updateNumberOfDownload(shortcut: shortcut, downloadlinkIndex: index)
                                    openURL(url)
                                }
                            } else {
                                loginAlerter.isPresented = true
                            }
                        } label: {
                            Text(TextLiteral.readShortcutVersionViewDownloadPreviousVersion)
                                .shortcutsZipBody2()
                                .foregroundColor(.shortcutsZipPrimary)
                        }
                    }
                    
                    Divider()
                        .foregroundColor(.gray1)
                }
            }
        }
    }
    
    //MARK: - 댓글 탭
    
    struct ReadShortcutCommentView: View {
        
        @EnvironmentObject var shortcutsZipViewModel: ShortcutsZipViewModel
        
        @AppStorage("useWithoutSignIn") var useWithoutSignIn: Bool = false
        
        @FocusState var isFocused: Bool
        
        @Binding var newComment: Comment                    /// 추가되는 댓글
        @Binding var comments: Comments                     /// 화면에 나타나는 모든 댓글
        @Binding var nestedCommentTarget: String            /// 대댓글 작성 시 텍스트필드 위에 뜨는 작성자 정보
        @Binding var isEditingComment: Bool
        
        @State var isDeletingComment = false
        @State var deletedComment = Comment(user_nickname: "", user_id: "", date: "", depth: 0, contents: "")
        
        let shortcutID: String
        
        var body: some View {
            VStack(alignment: .leading) {
                
                if comments.comments.isEmpty {
                    Text(TextLiteral.readShortcutCommentViewNoComments)
                        .shortcutsZipBody2()
                        .foregroundColor(.gray4)
                        .padding(.top, 16)
                } else {
                    commentView
                }
                
                Spacer()
                    .frame(maxHeight: .infinity)
            }
            .padding(.top, 16)
            .alert(TextLiteral.readShortcutCommentViewDeletionTitle, isPresented: $isDeletingComment) {
                Button(role: .cancel) {
                    
                } label: {
                    Text(TextLiteral.cancel)
                }
                
                Button(role: .destructive) {
                    if deletedComment.depth == 0 {
                        comments.comments.removeAll(where: { $0.bundle_id == deletedComment.bundle_id})
                    } else {
                        comments.comments.removeAll(where: { $0.id == deletedComment.id})
                    }
                    
                    shortcutsZipViewModel.setData(model: comments)
                } label: {
                    Text(TextLiteral.delete)
                }
            } message: {
                Text(TextLiteral.readShortcutCommentViewDeletionMessage)
            }
        }
        
        private var commentView: some View {
            
            ForEach(comments.comments, id: \.self) { comment in
                
                HStack(alignment: .top, spacing: 8) {
                    if comment.depth == 1 {
                        Image(systemName: "arrow.turn.down.right")
                            .smallIcon()
                            .foregroundColor(.gray4)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        /// 유저 정보
                        HStack(spacing: 8) {
                            
                            shortcutsZipViewModel.fetchShortcutGradeImage(isBig: false, shortcutGrade: shortcutsZipViewModel.checkShortcutGrade(userID: comment.user_id ))
                                .font(.system(size: 24, weight: .medium))
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray3)
                            
                            Text(comment.user_nickname)
                                .shortcutsZipBody2()
                                .foregroundColor(.gray4)
                        }
                        .padding(.bottom, 4)
                        
                        
                        /// 댓글 내용
                        Text(comment.contents)
                            .shortcutsZipBody2()
                            .foregroundColor(.gray5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        /// 답글, 수정, 삭제 버튼
                        HStack(spacing: 0) {
                            if !useWithoutSignIn {
                                Button {
                                    nestedCommentTarget = comment.user_nickname
                                    newComment.bundle_id = comment.bundle_id
                                    newComment.depth = 1
                                    isFocused = true
                                } label: {
                                    Text(TextLiteral.readShortcutCommentViewReply)
                                        .shortcutsZipFootnote()
                                        .foregroundColor(.gray4)
                                        .frame(width: 32, height: 24)
                                }
                            }
                            
                            if let user = shortcutsZipViewModel.userInfo {
                                if user.id == comment.user_id {
                                    Button {
                                        withAnimation(.easeInOut) {
                                            isEditingComment.toggle()
                                            newComment = comment
                                        }
                                    } label: {
                                        Text(TextLiteral.readShortcutCommentViewEdit)
                                            .shortcutsZipFootnote()
                                            .foregroundColor(.gray4)
                                            .frame(width: 32, height: 24)
                                    }
                                    
                                    Button {
                                        isDeletingComment.toggle()
                                        deletedComment = comment
                                    } label: {
                                        Text(TextLiteral.delete)
                                            .shortcutsZipFootnote()
                                            .foregroundColor(.gray4)
                                            .frame(width: 32, height: 24)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                            .background(Color.gray1)
                    }
                }
                .padding(.bottom, 16)
            }
        }
    }
}
