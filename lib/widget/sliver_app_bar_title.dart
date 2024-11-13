import 'package:flutter/material.dart';

class SliverAppBarTitle extends StatefulWidget {
  final Widget child;
  const SliverAppBarTitle({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _SliverAppBarTitleState createState() => new _SliverAppBarTitleState();
}

class _SliverAppBarTitleState extends State<SliverAppBarTitle> {
  ScrollPosition? _position;
  bool? _visible;

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
    bool visible =
        settings == null || settings.currentExtent <= settings.minExtent + 10;
    if (_visible != visible) {
      setState(() {
        _visible = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 100),
      opacity: _visible == true ? 1 : 0,
      child: widget.child,
    );
  }
}
