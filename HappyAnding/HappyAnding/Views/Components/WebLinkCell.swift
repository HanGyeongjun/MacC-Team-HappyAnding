//
//  WebLinkCell.swift
//  HappyAnding
//
//  Created by HanGyeongjun on 2023/01/17.
//

import SwiftUI

struct WebLinkCell: View {
    var body: some View {
        HStack{
            NavigationLink(destination: MyWebView(urlToLoad: "https://hangyeongjun.github.io/WebPageTest/index.html")) {
                Text("단축어 꿀팁 확인하기")
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.Primary)
                    .foregroundColor(.white)
                    .cornerRadius(16, antialiased: true)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct WebLinkCell_Previews: PreviewProvider {
    static var previews: some View {
        WebLinkCell()
    }
}
