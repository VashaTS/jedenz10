import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class WebViewScreen extends StatelessWidget {
  final String url;
  const WebViewScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    // Windows - open in default browser (because webview isn’t yet stable there)
    if (defaultTargetPlatform == TargetPlatform.windows) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      Navigator.pop(context);
      return const SizedBox.shrink();
    }

    // Mobile / Web / macOS / Linux → in-app web-view
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(title: const Text('Polityka prywatności')),
      body: WebViewWidget(controller: controller),         // 4.x widget
    );
  }
}
