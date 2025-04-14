import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar untuk membuat tampilan dinamis
    final double screenWidth = MediaQuery.of(context).size.width;
    // Container loading akan mengambil maksimal 80% dari lebar layar
    final double containerWidth = screenWidth * 0.9;
    // Ukuran font disesuaikan untuk layar kecil
    final double fontSize = screenWidth < 360 ? 14 : 20;

    return Stack(
      children: [
        child,
        if (isLoading) ...[
          // Overlay loading dengan ModalBarrier agar tidak bisa disentuh
          Positioned.fill(
            child: ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false,
            ),
          ),
          // Tampilan loading yang responsif
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: containerWidth,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF017964),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mohon tunggu...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
