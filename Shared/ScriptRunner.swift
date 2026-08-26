import Foundation
import WebKit

/// Runs user JavaScript with a `main()` entry point inside a hidden WKWebView,
/// mirroring the original app's script engine. A built-in `otterRequest`
/// function (async, returns `{statusCode, body}`) is injected for network access.
public final class ScriptRunner: NSObject {
    public static let shared = ScriptRunner()

    public static let template = """
    // Define a main() function; it may return a String or an Array of Strings.
    async function main() {
        return "Hello from Otter Keyboard Tool";
    }
    """

    /// JavaScript source for the built-in network helper injected before user code.
    private static let otterRequestSource = """
    async function otterRequest(url, method, params, headers) {
        method = (method || 'GET').toUpperCase();
        headers = headers || {};
        var target = url;
        var opts = { method: method, headers: headers };
        if (params && (method === 'POST' || method === 'PUT' || method === 'PATCH' || method === 'DELETE')) {
            opts.body = typeof params === 'string' ? params : JSON.stringify(params);
            if (!opts.headers['Content-Type'] && !opts.headers['content-type']) {
                opts.headers['Content-Type'] = 'application/json';
            }
        } else if (params) {
            try {
                var u = new URL(url);
                Object.keys(params).forEach(function (k) { u.searchParams.set(k, params[k]); });
                target = u.toString();
            } catch (e) {}
        }
        var resp = await fetch(target, opts);
        var text = await resp.text();
        return { statusCode: resp.status, body: text };
    }
    """

    private let webView: WKWebView
    private let delegate = NavDelegate()
    private var ready = false
    private var pending: [(code: String, arg: String?, completion: (Result<[String], Error>) -> Void)] = []
    private let lock = NSLock()

    private override init() {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        webView = WKWebView(frame: .zero, configuration: config)
        super.init()
        delegate.onFinish = { [weak self] in self?.markReady() }
        webView.navigationDelegate = delegate
        webView.loadHTMLString("<html><body></body></html>", baseURL: nil)
    }

    private func markReady() {
        lock.lock()
        ready = true
        let items = pending
        pending.removeAll()
        lock.unlock()
        for item in items { execute(code: item.code, arg: item.arg, completion: item.completion) }
    }

    public func run(_ code: String, arg: String? = nil,
                    completion: @escaping (Result<[String], Error>) -> Void) {
        lock.lock()
        if !ready {
            pending.append((code, arg, completion))
            lock.unlock()
            return
        }
        lock.unlock()
        execute(code: code, arg: arg, completion: completion)
    }

    private func execute(code: String, arg: String?,
                         completion: @escaping (Result<[String], Error>) -> Void) {
        let source = ScriptRunner.otterRequestSource + "\n" + code + """
        ;
        return await main(typeof __arg === 'undefined' || __arg === null ? undefined : __arg);
        """
        let arguments: [String: Any] = ["__arg": arg.map { $0 as Any } ?? NSNull()]

        webView.callAsyncJavaScript(source, arguments: arguments, in: nil,
                                     in: .defaultClientWorld) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let value):
                    completion(.success(Self.normalize(value)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    private static func normalize(_ value: Any) -> [String] {
        if let str = value as? String { return [str] }
        if let arr = value as? [Any] {
            return arr.map { item -> String in
                if let s = item as? String { return s }
                if let d = item as? [String: Any] { return (try? JSONSerialization.data(withJSONObject: d)).flatMap { String(data: $0, encoding: .utf8) } ?? "" } ?? ""
                return String(describing: item)
            }
        }
        if let d = value as? [String: Any] {
            return (try? JSONSerialization.data(withJSONObject: d)).flatMap { String(data: $0, encoding: .utf8) }.map { [$0] } ?? []
        }
        return [String(describing: value)]
    }
}

private final class NavDelegate: NSObject, WKNavigationDelegate {
    var onFinish: (() -> Void)?
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { onFinish?() }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { onFinish?() }
}
