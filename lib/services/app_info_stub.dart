// Nothing from dart:html here
import 'package:package_info_plus/package_info_plus.dart';

Future<String> readVersion(bool _) async {
  final info = await PackageInfo.fromPlatform();
  // e.g. "1.4.8+15"
  return '${info.version}+${info.buildNumber}';
}
