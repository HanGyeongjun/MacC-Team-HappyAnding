//
//  WebView.swift
//  HappyAnding
//
//  Created by HanGyeongjun on 2023/01/17.
//

import SwiftUI
import WebKit

struct MyWebView: UIViewRepresentable {
    var urlToLoad: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<MyWebView>) {
        DispatchQueue.main.async {
            guard let url = URL(string: self.urlToLoad) else {
                return
            }
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

//struct WebView_Previews: PreviewProvider {
//    static var previews: some View {
//        WebView()
//    }
//}
