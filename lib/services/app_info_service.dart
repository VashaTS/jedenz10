import 'package:flutter/foundation.dart';

import 'app_info_stub.dart'
// ↙︎ compiled **only** when building for Web
if (dart.library.html) 'app_info_web.dart';

class AppInfoService extends ChangeNotifier {   // ← add mix-in
  String _version = '…';
  String get version => _version;

  Future<void> init() async {
    _version = await readVersion(kIsWeb);
    notifyListeners();          // now widgets will rebuild if version changes
  }
}