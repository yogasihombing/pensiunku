import 'package:flutter/material.dart';

class ElevatedButtonLoading extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final bool disabled;
   final TextStyle? textStyle; // Tambahkan properti textStyle


  const ElevatedButtonLoading({
    Key? key,
    required this.text,
    required this.onTap,
    required this.isLoading,
    required this.disabled,
    this.textStyle, // Buat opsional agar tidak wajib
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: !disabled ? onTap : null,
      child: !isLoading
          ? Text(
              text,
              textAlign: TextAlign.center,
              style: textStyle ?? TextStyle( // Gunakan default jika null
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            )
          : SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
    );
  }
}

class ElevatedButtonSecond extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final bool disabled;

  const ElevatedButtonSecond({
    Key? key,
    required this.text,
    required this.onTap,
    required this.isLoading,
    required this.disabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: !disabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        primary: Color(0xff16826e), // Background color
      ),
      child: !isLoading
          ? Text(
              text,
              textAlign: TextAlign.center,
            )
          : SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
    );
  }
}
