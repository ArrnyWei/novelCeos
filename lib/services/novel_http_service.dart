import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Fetches HTML from uukanshu.cc using a headless WebView so that
/// Cloudflare's JS challenge is executed by a real browser engine.
class NovelHttpService {
  static const _host = 'https://uukanshu.cc';

  Future<String> _fetch(String url) async {
    final completer = Completer<String>();

    final webView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      initialSettings: InAppWebViewSettings(
        userAgent:
            'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
            'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
        javaScriptEnabled: true,
        cacheEnabled: true,
      ),
      onLoadStop: (controller, _) async {
        if (completer.isCompleted) return;
        // Wait for actual content — Cloudflare challenge pages have minimal text
        final hasContent = await controller.evaluateJavascript(
          source: "document.querySelector('body').innerText.length > 200",
        );
        if (hasContent == true || hasContent == 'true') {
          final html = await controller.evaluateJavascript(
            source: 'document.documentElement.outerHTML',
          );
          completer.complete(html?.toString() ?? '');
        }
        // Otherwise wait for next onLoadStop (after Cloudflare redirect)
      },
      onReceivedError: (controller, request, error) {
        if (!completer.isCompleted) {
          completer.completeError(Exception(error.description));
        }
      },
    );

    await webView.run();

    try {
      final html = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('頁面載入超時', const Duration(seconds: 30)),
      );
      return html;
    } finally {
      await webView.dispose();
    }
  }

  Future<String> fetchHome() => _fetch(_host);

  Future<String> fetchList(String listUrl, int pageIndex) =>
      _fetch('$_host/class_${listUrl}_$pageIndex.html');

  Future<String> fetchNovel(String novelUrl) => _fetch('$_host$novelUrl');

  Future<String> fetchContent(String contentUrl) =>
      _fetch('$_host$contentUrl');

  /// Search via GET URL — e.g. /search/關鍵字/1.html
  Future<String> search(String keyword, {int page = 1}) =>
      _fetch('$_host/search/${Uri.encodeComponent(keyword)}/$page.html');
}
