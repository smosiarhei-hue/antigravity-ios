import SwiftUI
import WebKit

public struct LivePreviewView: View {
    @Environment(AgentSession.self) private var session
    @State private var urlString: String = "http://localhost:3000"
    @State private var webView = WKWebView()
    @State private var isLoading: Bool = false

    public var body: some View {
        NavigationStack {
            ZStack {
                AntigravityTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Browser Control Bar
                    controlBar

                    // Port Switcher
                    portsRow

                    // WebView Container
                    ZStack {
                        WebViewWrapper(webView: webView, urlString: $urlString, isLoading: $isLoading)

                        if isLoading {
                            ProgressView()
                                .tint(AntigravityTheme.accent)
                                .scaleEffect(1.2)
                        }
                    }
                }
            }
            .navigationTitle("Live Превью")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let url = URL(string: urlString) {
                        Link(destination: url) {
                            Image(systemName: "safari")
                                .foregroundStyle(AntigravityTheme.accent)
                        }
                    }
                }
            }
        }
    }

    private var controlBar: some View {
        HStack(spacing: 8) {
            Button {
                webView.reload()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14))
                    .foregroundStyle(AntigravityTheme.textPrimary)
                    .padding(8)
                    .background(AntigravityTheme.surfaceSecondary)
                    .clipShape(Circle())
            }

            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(AntigravityTheme.success)

                TextField("URL dev-сервера...", text: $urlString)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(AntigravityTheme.textPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onSubmit {
                        loadCurrentUrl()
                    }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(AntigravityTheme.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Button("Go") {
                loadCurrentUrl()
            }
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(AntigravityTheme.accent)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AntigravityTheme.surface)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(AntigravityTheme.border), alignment: .bottom)
    }

    private var portsRow: some View {
        HStack(spacing: 8) {
            Text("Dev Ports:")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AntigravityTheme.textSecondary)

            ForEach(["3000", "5173", "8080"], id: \.self) { port in
                Button {
                    urlString = "http://localhost:\(port)"
                    loadCurrentUrl()
                } label: {
                    Text(":\(port)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(urlString.contains(port) ? .white : AntigravityTheme.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(urlString.contains(port) ? AntigravityTheme.accent : AntigravityTheme.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(AntigravityTheme.background)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(AntigravityTheme.border), alignment: .bottom)
    }

    private func loadCurrentUrl() {
        var str = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !str.hasPrefix("http://") && !str.hasPrefix("https://") {
            str = "https://" + str
            urlString = str
        }
        if let url = URL(string: str) {
            webView.load(URLRequest(url: url))
        }
    }
}

struct WebViewWrapper: UIViewRepresentable {
    let webView: WKWebView
    @Binding var urlString: String
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewWrapper

        init(_ parent: WebViewWrapper) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}
