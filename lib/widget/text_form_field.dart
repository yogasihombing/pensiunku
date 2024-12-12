import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final bool enabled;
  final String? errorText;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;
  final Color fillColor;
  final int? minLines;
  final int? maxLines;

  CustomTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    this.enabled = true,
    this.errorText,
    this.borderRadius = 36.0,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
    this.fillColor = const Color(0xfff7f7f7),
    this.minLines,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: fillColor,
        contentPadding: contentPadding,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}