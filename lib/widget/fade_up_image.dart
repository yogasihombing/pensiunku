import 'package:flutter/material.dart';

/// Asset image with fade up animation.
///
/// When [isActive] is true, the image fades up to be displayed.
class FadeUpImage extends StatelessWidget {
  final bool isActive;
  final String assetName;
  final double height;
  final double offsetY;
  final Duration duration;

  const FadeUpImage({
    Key? key,
    required this.isActive,
    required this.assetName,
    this.height = 200.0,
    this.offsetY = 16.0,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: duration,
      top: isActive ? 0.0 : 8.0,
      left: 0.0,
      right: 0.0,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.0,
        duration: duration,
        child: SizedBox(
          height: height,
          child: Image.asset(assetName),
        ),
      ),
    );
  }
}
