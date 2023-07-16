//
//  ReadShortcutViewModel.swift
//  HappyAnding
//
//  Created by kimjimin on 2023/07/15.
//

import SwiftUI

final class ReadShortcutViewModel: ObservableObject {
    
    var shortcutsZipViewModel = ShortcutsZipViewModel.share
    
    @Published var shortcut: Shortcuts
    
    @Published var isDeletingShortcut = false
    @Published var isEditingShortcut = false
    @Published var isUpdatingShortcut = false
    
    @Published var isMyLike = false
    @Published var isMyFirstLike = false
    @Published var isDownloadingShortcut = false
    @Published var isDowngradingUserLevel = false
    
    @Published var currentTab: Int = 0
    @Published var comments: Comments = Comments(id: "", comments: [])
    @Published var comment: Comment = Comment(user_nickname: "", user_id: "", date: "", depth: 0, contents: "")
    @Published var nestedCommentTarget: String = ""
    @Published var commentText = ""
    
    @Published var isEditingComment = false
    @Published var isUndoingCommentEdit = false
    
    /// UpdateShortcutView
    @Published var updatedLink = ""
    @Published var updateDescription = ""
    @Published var isLinkValid = false
    @Published var isDescriptionValid = false
    
    init(data: Shortcuts) {
        self.shortcut = shortcutsZipViewModel.fetchShortcutDetail(id: data.id) ?? data
        self.isMyLike = shortcutsZipViewModel.checkLikedShortrcut(shortcutID: data.id)
        self.isMyFirstLike = isMyLike
        self.comments = shortcutsZipViewModel.fetchComment(shortcutID: data.id)
    }
    
    func checkIfDownloaded() {
        if (shortcutsZipViewModel.userInfo?.downloadedShortcuts.firstIndex(where: { $0.id == shortcut.id })) == nil {
            shortcut.numberOfDownload += 1
        }
        self.isDownloadingShortcut = true
    }
    
    func updateNumberOfDownload() {
        shortcutsZipViewModel.updateNumberOfDownload(shortcut: shortcut, downloadlinkIndex: 0)
    }
    
    func onViewDissapear() {
        if isMyLike != isMyFirstLike {
            shortcutsZipViewModel.updateNumberOfLike(isMyLike: isMyLike, shortcut: shortcut)
        }
    }
    
    func deleteShortcut() {
        shortcutsZipViewModel.deleteShortcutIDInUser(shortcutID: shortcut.id)
        shortcutsZipViewModel.deleteShortcutInCuration(curationsIDs: shortcut.curationIDs, shortcutID: shortcut.id)
        shortcutsZipViewModel.deleteData(model: shortcut)
        shortcutsZipViewModel.shortcutsMadeByUser = shortcutsZipViewModel.shortcutsMadeByUser.filter { $0.id != shortcut.id }
        shortcutsZipViewModel.updateShortcutGrade()
    }
    
    func cancelEditingComment() {
        self.isEditingComment.toggle()
        self.comment = self.comment.resetComment()
        self.commentText = ""
    }
    
    func postComment() {
        if !isEditingComment {
            comment.contents = commentText
            comment.date = Date().getDate()
            comment.user_id = shortcutsZipViewModel.userInfo!.id
            comment.user_nickname = shortcutsZipViewModel.userInfo!.nickname
            comments.comments.append(comment)
        } else {
            if let index = comments.comments.firstIndex(where: { $0.id == comment.id }) {
                comments.comments[index].contents = commentText
            }
            isEditingComment = false
        }
        shortcutsZipViewModel.setData(model: comments)
        commentText = ""
        comment = comment.resetComment()
    }
    
    func cancelNestedComment() {
        comment.bundle_id = "\(Date().getDate())_\(UUID().uuidString)"
        comment.depth = 0
    }
    
    func checkAuthor() -> Bool {
        return self.shortcut.author == shortcutsZipViewModel.currentUser()
    }
    
    func shareShortcut() {
        guard let deepLink = URL(string: "ShortcutsZip://myPage/detailView?shortcutID=\(shortcut.id)") else { return }
        let activityVC = UIActivityViewController(activityItems: [deepLink], applicationActivities: nil)
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return }
        window.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    func checkDowngrade() {
        isDeletingShortcut.toggle()
        isDowngradingUserLevel = shortcutsZipViewModel.isShortcutDowngrade()
    }
    
    func updateShortcut() {
        shortcutsZipViewModel.updateShortcutVersion(shortcut: shortcut,
                                                    updateDescription: updateDescription,
                                                    updateLink: updatedLink)
        self.shortcut = shortcutsZipViewModel.fetchShortcutDetail(id: shortcut.id) ?? shortcut
        isUpdatingShortcut.toggle()
    }
}
