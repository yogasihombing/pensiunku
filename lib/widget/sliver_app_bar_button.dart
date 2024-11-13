import 'package:flutter/material.dart';

class SliverAppBarButton extends StatefulWidget {
  final String title;
  const SliverAppBarButton({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _SliverAppBarButtonState createState() => new _SliverAppBarButtonState();
}

class _SliverAppBarButtonState extends State<SliverAppBarButton> {
  ScrollPosition? _position;
  double _opacity = 0.0;
  double _horizontalPadding = 24.0;
  double _verticalPadding = 12.0;
  double _bottom = 16.0;

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeListener();
    _addListener();
  }

  void _addListener() {
    _position = Scrollable.of(context)?.position;
    _position?.addListener(_positionListener);
    _positionListener();
  }

  void _removeListener() {
    _position?.removeListener(_positionListener);
  }

  void _positionListener() {
    FlexibleSpaceBarSettings? settings =
        context.dependOnInheritedWidgetOfExactType();
    if (settings != null) {
      double maxExtent = settings.maxExtent;
      double minExtent = settings.maxExtent - 48.0;
      double currentExtent = settings.currentExtent;
      double opacity = (currentExtent - minExtent) / (maxExtent - minExtent);
      if (opacity < 0) opacity = 0;
      double horizontalPadding = 24.0 + (24.0 * (1 - opacity));
      double verticalPadding = 12.0 + (12.0 * (1 - opacity));
      double bottom = 16.0 + (32.0 * (1 - opacity));
      setState(() {
        _opacity = opacity;
        _horizontalPadding = horizontalPadding;
        _verticalPadding = verticalPadding;
        _bottom = bottom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return AnimatedPositioned(
      duration: Duration(milliseconds: 100),
      bottom: _bottom,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 100),
        opacity: _opacity,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 24.0,
          ),
          decoration: BoxDecoration(
            color: Color(0xff00a099),
            borderRadius: BorderRadius.circular(36.0),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4.0,
              ),
            ],
          ),
          child: AnimatedContainer(
            padding: EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
              vertical: _verticalPadding,
            ),
            duration: Duration(milliseconds: 100),
            child: Text(
              widget.title,
              style: theme.textTheme.headline6?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
