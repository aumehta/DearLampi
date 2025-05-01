//
//  GIFView.swift
//  Dear Lampi
//
//  Created by Arohi Mehta on 4/27/25.
//
//Helper file for showing the animated GIF on the home page
import SwiftUI
import WebKit

struct GIFView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = false

        if let path = Bundle.main.path(forResource: gifName, ofType: "gif") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            webView.load(data!, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: path))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
