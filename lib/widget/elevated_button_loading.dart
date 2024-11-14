import 'package:flutter/material.dart';

class ElevatedButtonLoading extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final bool disabled;

  const ElevatedButtonLoading({
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
        backgroundColor: Color(0xff16826e), // Background color
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