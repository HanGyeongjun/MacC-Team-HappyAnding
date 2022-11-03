//
//  ListShortcutView.swift
//  HappyAnding
//
//  Created by 이지원 on 2022/10/20.
//

import SwiftUI

/// - parameters:
/// - categoryName: 카테고리에서 접근할 시, 해당 카테고리의 이름을 넣어주시고, 그렇지 않다면 nil을 넣어주세요
/// sectionType: 다운로드 순위에서 접근할 시, .download를, 사랑받는 앱에서 접근시 .popular를 넣어주세요.
struct ListShortcutView: View {
    
    let firebase = FirebaseService()
    @State var shortcuts:[Shortcuts]?
    @State var shortcutsArray: [Shortcuts] = []
    
    @ObservedObject var shortcutData = fetchData()
    @State private var isLastItem = false
    @State var description: String = ""
    
    // TODO: let으로 변경필요, 현재 작업중인 코드들과 충돌될 가능성이 있어 우선 변수로 선언
    var categoryName: Category?
    var sectionType: SectionType?
    
    var body: some View {
        
        List {
            
            if sectionType != .myShortcut {
                header
                    .listRowBackground(Color.Background)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
            }
            
            //TODO: 무한 스크롤을 위한 업데이트 함수 필요
            if let shortcuts {
                ForEach(Array(shortcuts.enumerated()), id: \.offset) { index, shortcut in
                    if sectionType == .download {
                        ShortcutCell(shortcut: shortcut, rankNumber: index + 1)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                        
                    } else {
                        ShortcutCell(shortcut: shortcut)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                    }
                }
            }
            
            
            Rectangle()
                .fill(Color.Background)
                .frame(height: 44)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        }
        .listRowBackground(Color.Background)
        .listStyle(.plain)
        .background(Color.Background.ignoresSafeArea(.all, edges: .all))
        .scrollContentBackground(.hidden)
        .navigationBarTitle((categoryName == nil ? getNavigationTitle(sectionType!) : categoryName?.translateName())!)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            if let categoryName {
                description = categoryName.fetchDescription()
                firebase.fetchCategoryShortcut(category: categoryName.rawValue) { shortcuts in
                    self.shortcuts = shortcuts
                }
            } else if let sectionType {
                description = getDescriptions(sectionType)
            }
        }
    }
    
    var header: some View {
        
            // TODO: 추후 옵셔널 타입 삭제 (무조건 타입이 존재하기 때문)
        
        VStack {
            Text(description)
                .foregroundColor(.Gray5)
                .Body2()
                .padding(16)
                .frame(maxWidth: .infinity, alignment: sectionType == .download ? .center : .leading)
                .background(
                    Rectangle()
                        .foregroundColor(Color.Gray1)
                        .cornerRadius(12)
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.Background)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
    }
    
    
    private func getNavigationTitle(_ sectionType: SectionType) -> String {
        switch sectionType {
        case .download:
            return sectionType.rawValue
        case .popular:
            return "사랑받는 단축어"
        case .myShortcut:
            return "내 단축어"
        case .myLovingShortcut:
            return "좋아요한 단축어"
        case .myDownloadShortcut:
            return "다운로드한 단축어"
        }
    }
    
    private func getDescriptions(_ sectionType: SectionType) -> String {
        switch sectionType {
        case .download:
            return "\(self.categoryName?.translateName() ?? "") 1위 ~ 100위"
        case .popular:
            return "💡 좋아요를 많이 받은 단축어들로 구성 되어 있어요!"
        case .myShortcut:
            return ""
        case .myLovingShortcut:
            return "💗 내가 좋아요를 누른 단축어를 모아볼 수 있어요"
        case .myDownloadShortcut:
            return "💫 내가 다운로드한 단축어를 모아볼 수 있어요"
        }
    }
}

struct ListShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        ListShortcutView(sectionType: .myLovingShortcut)
    }
}


// TODO: 테스트 모델, 추후 삭제 예정

struct ShortcutTestSoiModel {
    var name: String
    var description: String
    var sfSymbol: String
    var color: String
    var numberOfDownload: Int
    var downloadLink: String
}

extension ShortcutTestSoiModel {
    
    static func fetchData(number: Int) -> [ShortcutTestSoiModel] {
        
        var data = [ShortcutTestSoiModel]()
        let name = ["빠른길 찾기", "카카오톡 결제하기", "수면 모드로 설정", "공부하러 가야돼"]
        let description = ["이럴때 사용하면 더 좋아요", "이땐 이런건 어때요", "이것도 해보세요"]
        let sfSymbol = ["graduationcap.fill", "books.vertical.fill", "creditcard.fill",
                        "creditcard.fill", "phone.fill", "cross.fill", "newspaper.fill",
                        "newspaper.fill", "alarm.fill", "calendar", "cloud.sun.fill",
                        "camera.fill", "paintpalette.fill", "paintbrush.fill", "hammer.fill",
                        "tray.fill", "tray.fill", "speaker.wave.2.fill", "gearshape.fill",
                        "command.square.fill", "bubble.left.fill", "headphones",
                        "gamecontroller.fill", "tram.fill", "bag.fill", "music.note",
                        "hourglass.bottomhalf.filled"]
        
        let color = ["Blue", "Brown", "Coral", "Cyan", "Gray", "Green",
                     "Khaki", "LightPurple", "Mint", "Orange", "Pink",
                     "Purple", "Red", "Teal", "Yellow"]
        
        let downloadLink = ["https://www.icloud.com/shortcuts/fef3df84c4ae4bea8a411c8566efe280",
                            "https://www.icloud.com/shortcuts/54a5568f06ef44aabee61260298d088c",
                            "https://www.icloud.com/shortcuts/09721945787b44e3a7d41d14af3d99c9",
                            "https://www.icloud.com/shortcuts/22ba767a852a4d71a90e7e8d334a314a",
                            "https://www.icloud.com/shortcuts/56b0933241ab47b8ac6cb3a6b1e43c47",
                            "https://www.icloud.com/shortcuts/70581f62029b49048aec006eb8713ded"]
        
        for _ in 0..<number {
            data.append(ShortcutTestSoiModel(name: name.randomElement() ?? "name",
                                             description: description.randomElement() ?? "desc",
                                             sfSymbol: sfSymbol.randomElement() ?? "tram.fill",
                                             color: color.randomElement() ?? "Blue",
                                             numberOfDownload: Int.random(in: 0..<9999),
                                             downloadLink: downloadLink.randomElement() ?? "nil"))
        }
        
        return data
    }
}

class fetchData: ObservableObject {
    
    @Published var data = [ShortcutTestSoiModel]()
    @Published var count = 1
    
    init() {
        updateData()
    }
    
    func updateData() {
        self.data += ShortcutTestSoiModel.fetchData(number: 10)
    }
}
