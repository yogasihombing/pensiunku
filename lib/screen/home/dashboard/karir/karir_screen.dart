import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KarirScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/karir_screen';

  @override
  State<KarirScreen> createState() => _KarirScreenState();
}

class _KarirScreenState extends State<KarirScreen> {
  late final WebViewController _controller;
  final String _initialUrl =
      'https://www.nabasa.co.id/marsitacademy/Pekerjaan/Lamar?id=1';

  @override
  void initState() {
    super.initState();
    // Untuk Android, diperlukan:
    // WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Karir',
        ),
        backgroundColor: const Color(0xFF017964),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: WebView(
        initialUrl: _initialUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (ctrl) {
          _controller = ctrl;
        },
        navigationDelegate: (nav) {
          // Jika mau batasi navigasi hanya ke domain nabasa.co.id
          if (nav.url.startsWith('https://www.nabasa.co.id/')) {
            return NavigationDecision.navigate;
          }
          return NavigationDecision.prevent;
        },
        onPageStarted: (url) {
          // bisa tampilkan loading spinner jika perlu
        },
        onPageFinished: (url) {
          // sembunyikan loading spinner
        },
      ),
    );
  }
}
