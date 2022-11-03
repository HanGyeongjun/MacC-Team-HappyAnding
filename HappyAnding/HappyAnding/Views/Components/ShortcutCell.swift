//
//  ShortcutCell.swift
//  HappyAnding
//
//  Created by 이지원 on 2022/10/20.
//

import SwiftUI

/**
 단축어를 재사용하기 위한 뷰입니다. (추후 단축어 모델이 생기면 변경될 예정입니다)
 
 단축어 정보를 전달해주세요. 클릭시 단축어 상세 뷰로 이동합니다.
 
 - parameters:
 - shortcut : 단축어 리스트에서 접근 시 Shortcuts  형태로 전달해주세요
 - shortcutCell: 큐레이션에서 접근 시 ShortcutCellModel 형태로 전달해주세요
 
 ShortcutCell에서는 Shortcuts의 형태로 데이터를 전달받아도 ShortcutCellModel의 형태로 변환하여 사용하며, 전달 시에만 shortcut을 전달합니다.
 
 - description:
 - 해당 뷰를 리스트로 사용할 때 다음과 같은 속성을 작성해주세요
 
 ```
 .listRowInsets(EdgeInsets())
 .listRowSeparator(.hidden)
 ```
 - list의 경우, plain으로 설정해주세요
 */


struct ShortcutCell: View {
    
    @Environment(\.openURL) private var openURL
    var shortcut: Shortcuts?
    
    @State var shortcutCell = ShortcutCellModel(
        id: "",
        sfSymbol: "",
        color: "",
        title: "",
        subtitle: "",
        downloadLink: ""
    )
    
    var rankNumber: Int = -1
    
    var body: some View {
        
        ZStack {
            NavigationLink(destination: ReadShortcutView(shortcut: shortcut, shortcutCell: shortcutCell)) {
                EmptyView()
            }
            .opacity(0)
            
            Color.Background
            
            HStack {
                icon
                shortcutInfo
                Spacer()
                downloadInfo
                    .onTapGesture {
                        
                        // TODO: 앱 여는 기능 추가
                        if let url = URL(string: shortcutCell.downloadLink) {
                            openURL(url)
                        }
                    }
            }
            .padding(.vertical, 20)
            .background( background )
            .padding(.horizontal, 20)
        }
        .padding(.top, 12)
        .background(Color.Background)
        .onAppear() {
            if let shortcut  {
                self.shortcutCell = ShortcutCellModel(
                    id: shortcut.id,
                    sfSymbol: shortcut.sfSymbol,
                    color: shortcut.color,
                    title: shortcut.title,
                    subtitle: shortcut.subtitle,
                    downloadLink: shortcut.downloadLink.last!
                )
            }
        }
    }
    
    var icon: some View {
        
        ZStack(alignment: .center) {
            Rectangle()
                .fill(Color.fetchGradient(color: shortcutCell.color))
                .cornerRadius(8)
                .frame(width: 52, height: 52)
            
            Image(systemName: shortcutCell.sfSymbol)
                .foregroundColor(.white)
        }
        .padding(.leading, 20)
    }
    
    var shortcutInfo: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            if rankNumber != -1 {
                Text("\(rankNumber)")
                    .Subtitle()
                    .foregroundColor(.Gray4)
                    .padding(0)
            }
            Text(shortcutCell.title)
                .Headline()
                .foregroundColor(.Gray5)
                .lineLimit(1)
            Text(shortcutCell.subtitle)
                .Footnote()
                .foregroundColor(.Gray3)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
    }
    
    var downloadInfo: some View {
        
        VStack(alignment: .center, spacing: 0) {
            Image(systemName: "arrow.down.app.fill")
                .foregroundColor(.Gray4)
                .font(.system(size: 24, weight: .medium))
                .frame(height: 32)
        }
        .padding(.leading, 12)
        .padding(.trailing, 18)
    }
    
    var background: some View {
        
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.White)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.Gray1)
            )
    }
}


//struct ShortcutCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ShortcutCell(color: "Red", sfSymbol: "books.vertical.fill", name: "Name", description: "Description", numberOfDownload: 102, downloadLink: "https")
//    }
//}
