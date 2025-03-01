import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewLoad extends StatefulWidget {
  const WebViewLoad({super.key});

  @override
  State<WebViewLoad> createState() => _WebViewLoadState();
}

class _WebViewLoadState extends State<WebViewLoad> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize the controller
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() {
                  isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  isLoading = false;
                });
              },
              onWebResourceError: (WebResourceError error) {
                // Handle errors
                debugPrint('WebView error: ${error.description}');
              },
            ),
          )
          ..loadRequest(
            Uri.parse(
              'https://sigparent.orison.school/ParentPortal/dashboardmobile?AccountId=95793&Key=SIG-ORSN-458',
            ),
          );
    // ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
