import SwiftUI
import WebKit

struct EntryDetailView: View {
    let entry: JournalEntry

    var body: some View {
        ArticleWebView(html: Self.page(for: entry), baseURL: URL(string: entry.url))
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle(entry.title)
            .navigationBarTitleDisplayMode(.inline)
    }

    // ponytail: WKWebView instead of NSAttributedString's HTML importer. The importer
    // turns <img> into an NSTextAttachment, and SwiftUI's Text renders *nothing* for an
    // AttributedString containing one — every post starting with a banner image came up
    // blank. A web view also gets images, code blocks and links for free.
    private static func page(for entry: JournalEntry) -> String {
        """
        <!doctype html><html><head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="supported-color-schemes" content="light dark">
        <style>
          :root { color-scheme: light dark; }
          /* Feed HTML is arbitrary: fixed-width cards, wide tables and long
             unbroken URLs all used to push the body past the viewport and clip
             at the right edge. Clamp every element to its parent and let the
             genuinely wide blocks scroll inside themselves instead. */
          * { max-width: 100%; box-sizing: border-box; }
          body {
            font: -apple-system-body;
            font-family: -apple-system, system-ui;
            font-size: 17px; line-height: 1.5;
            margin: 0; padding: 16px 20px 40px;
            -webkit-text-size-adjust: 100%;
            overflow-wrap: break-word;
          }
          h1 { font-size: 24px; margin: 0 0 4px; }
          h2 { font-size: 20px; margin: 24px 0 8px; }
          h3 { font-size: 18px; margin: 20px 0 8px; }
          p { margin: 0 0 14px; }
          img { max-width: 100%; height: auto; border-radius: 8px; }
          pre, table, blockquote { display: block; overflow-x: auto; }
          code { font-size: 15px; }
          .date { color: gray; font-size: 13px; margin: 0 0 20px; }
        </style></head><body>
        <h1>\(escape(entry.title))</h1>
        <p class="date">\(entry.date.formatted(date: .long, time: .omitted))</p>
        \(entry.htmlContent)
        </body></html>
        """
    }

    private static func escape(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}

private struct ArticleWebView: UIViewRepresentable {
    let html: String
    let baseURL: URL?

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.isOpaque = false
        view.backgroundColor = .clear
        view.loadHTMLString(html, baseURL: baseURL)
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView,
                     decidePolicyFor action: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Tapped links go to Safari; the web view only ever shows the article itself.
            if action.navigationType == .linkActivated, let url = action.request.url {
                UIApplication.shared.open(url)
                return decisionHandler(.cancel)
            }
            decisionHandler(.allow)
        }
    }
}
