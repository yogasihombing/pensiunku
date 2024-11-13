import 'package:flutter/material.dart';

class TextButtonLoading extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final bool disabled;

  const TextButtonLoading({
    Key? key,
    required this.text,
    required this.onTap,
    required this.isLoading,
    required this.disabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: !disabled ? onTap : null,
      child: !isLoading
          ? Text(text)
          : SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
    );
  }
}
