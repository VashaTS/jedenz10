import 'dart:html' as html;

/// Reads the `<meta name="version" content="…">` you inject into index.html.
Future<String> readVersion(bool __) async {
  return html.document
      .querySelector('meta[name="version"]')
      ?.getAttribute('content') ??
      '…';
}
