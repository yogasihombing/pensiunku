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
    // Ambil tinggi layar
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // 1. Ganti AppBar dengan PreferredSize untuk menambah tinggi
      appBar: PreferredSize(
        // Tambah misalnya 2% dari tinggi layar pada kToolbarHeight
        preferredSize: Size.fromHeight(kToolbarHeight + screenHeight * 0.02),
        child: AppBar(
          backgroundColor: const Color(0xFF017964),
          elevation: 0,
          // Pastikan toolbarHeight sama dengan preferredSize.height
          toolbarHeight: kToolbarHeight + screenHeight * 0.02,

          // 2. Bungkus leading dengan Padding agar ikon back turun
          leading: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 3. Bungkus title dengan Padding agar teks “Karir” juga turun
          centerTitle: true,
          title: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: const Text(
              'Karir',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),

      body: WebView(
        initialUrl: _initialUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (ctrl) {
          _controller = ctrl;
        },
        navigationDelegate: (nav) {
          // Batasi navigasi hanya ke domain nabasa.co.id
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
