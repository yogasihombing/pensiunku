import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SliverAppBarSheetTop extends StatefulWidget {
  Key? key;
  Color? colorx;

  SliverAppBarSheetTop({this.key, this.colorx}) : super(key: key);

  @override
  _SliverAppBarSheetTopState createState() => new _SliverAppBarSheetTopState();
}

class _SliverAppBarSheetTopState extends State<SliverAppBarSheetTop> {
  ScrollPosition? _position;
  double _borderRadius = 20.0;
  double _height = 12.0;
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
      double appBarHeight = MediaQuery.of(context).size.height * 0.4;
      double maxExtentBottom = settings.maxExtent;
      double minExtentBottom = settings.minExtent;
      double currentExtentBottom = settings.currentExtent;
      double opacityBottom = (currentExtentBottom - minExtentBottom) /
          (maxExtentBottom - minExtentBottom);
      if (opacityBottom < 0) opacityBottom = 0;

      double height = 40.0 + ((appBarHeight - 104) * (1 - opacityBottom));
      setState(() {
        _height = height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -4.0,
      left: 0.0,
      right: 0.0,
      child: Container(
        height: _height,
        decoration: BoxDecoration(
          // color: Color(0xfff2f2f2),
          color: widget.colorx,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_borderRadius),
            topRight: Radius.circular(_borderRadius),
          ),
          // boxShadow: [
          //   BoxShadow(
          //     offset: Offset(0, -5),
          //     color: Colors.black.withOpacity(0.25),
          //     blurRadius: 10.0,
          //   ),
          // ],
        ),
      ),
    );
  }
}
