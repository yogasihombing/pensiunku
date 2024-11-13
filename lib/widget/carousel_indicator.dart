import 'package:flutter/material.dart';

/// Indicator for carousels.
///
/// Contains [length] indicators. Inactive indicators will be colored grey
/// and active ones will be colored with [ThemeData.colorScheme.secondary].
class CarouselIndicator extends StatelessWidget {
  final int length;
  final int currentIndex;
  final TickerProvider vsync;
  final Duration duration;
  final MainAxisAlignment mainAxisAlignment;

  const CarouselIndicator({
    Key? key,
    required this.length,
    required this.currentIndex,
    required this.vsync,
    this.duration = const Duration(milliseconds: 300),
    this.mainAxisAlignment = MainAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        ...List.generate(
          length,
          (index) => _buildCircle(currentIndex == index, theme),
        ),
      ],
    );
  }

  Widget _buildCircle(bool isActive, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.secondary
            : theme.disabledColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: AnimatedSize(
        curve: Curves.ease,
        duration: Duration(milliseconds: 300),
        child: Container(
          height: 6.0,
          width: isActive ? 24.0 : 12.0,
        ),
      ),
    );
  }
}
