import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
class LeadWebViewScreen extends StatefulWidget {
  final String url;

  const LeadWebViewScreen({super.key, required this.url});

  @override
  State<LeadWebViewScreen> createState() => _LeadWebViewScreenState();
}

class _LeadWebViewScreenState extends State<LeadWebViewScreen> {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lead Viewer"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setBackgroundColor(const Color(0x00000000))
              ..setNavigationDelegate(
                NavigationDelegate(
                  onPageStarted: (url) => setState(() => isLoading = true),
                  onPageFinished: (url) => setState(() => isLoading = false),
                ),
              )
              ..loadRequest(Uri.parse(widget.url)),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
