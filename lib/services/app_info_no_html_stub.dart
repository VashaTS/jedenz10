// Dummy stand-in so “import 'dart:html' as html …” compiles on mobile/desktop.
class _FakeDocument {
  String? getAttribute(String _) => null;
}

class _FakeHtml {
  _FakeDocument? querySelector(String _) => null;
}

final html = _FakeHtml();
