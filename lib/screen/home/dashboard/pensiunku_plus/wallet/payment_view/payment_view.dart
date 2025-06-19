import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class PaymentView extends StatefulWidget {
  final String transactionToken;

  const PaymentView({Key? key, required this.transactionToken}) : super(key: key);

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  // Untuk webview_flutter 3.x.x, WebViewController tidak diinisialisasi dengan
  // late final seperti di v4. Ini adalah objek yang dikelola oleh widget WebView.
  // Anda bisa menggunakan _controller untuk memanggil metode setelah onWebViewCreated.
  WebViewController? _controller;
  bool _isLoading = true;
  String _initialUrl = ''; // Menyimpan URL awal

  @override
  void initState() {
    super.initState();
    // URL Snap Midtrans
    _initialUrl = 'https://app.sandbox.midtrans.com/snap/v1/embed/${widget.transactionToken}';
    // Untuk produksi, gunakan: 'https://app.midtrans.com/snap/v1/embed/${widget.transactionToken}'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Midtrans'),
        backgroundColor: const Color(0xFFFFC950),
        foregroundColor: const Color(0xFF017964),
      ),
      body: Stack(
        children: [
          // Gunakan widget WebView untuk webview_flutter 3.x.x
          WebView(
            initialUrl: _initialUrl,
            javascriptMode: JavascriptMode.unrestricted,
            // backgroundColor: const Color(0x00000000), // Tidak ada properti background di v3
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
            },
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  _isLoading = progress < 100;
                });
              }
              print('WebView sedang memuat (progress: $progress%)');
            },
            onPageStarted: (String url) {
              print('Halaman mulai dimuat: $url');
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
            onPageFinished: (String url) {
              print('Halaman selesai dimuat: $url');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              print('Kesalahan sumber daya web: ${error.description}');
              Navigator.pop(context, 'error');
            },
            navigationDelegate: (NavigationRequest request) {
              print('Navigasi ke: ${request.url}');

              if (request.url.contains('transaction_status=settlement') || request.url.contains('status_code=200')) {
                // Pembayaran kemungkinan berhasil dari sisi klien
                Navigator.pop(context, 'success'); // Pop dengan hasil 'success'
                return NavigationDecision.prevent; // Mencegah pemuatan URL ini di WebView
              } else if (request.url.contains('transaction_status=deny') || 
                         request.url.contains('transaction_status=cancel') ||
                         request.url.contains('transaction_status=expire')) {
                // Pembayaran gagal atau dibatalkan atau kadaluarsa
                Navigator.pop(context, 'failed'); // Pop dengan hasil 'failed'
                return NavigationDecision.prevent; // Mencegah pemuatan URL ini di WebView
              }

              return NavigationDecision.navigate;
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
