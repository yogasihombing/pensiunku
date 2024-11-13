import 'package:flutter/material.dart';

class ExpandedButton extends StatefulWidget {
  final String text;
  final Color color1;
  final Color color2;
  final String image1;
  final String image2;
  final String image3;
  final bool isActive;

  const ExpandedButton(
      {Key? key,
      required this.text,
      required this.color1,
      required this.color2,
      required this.image1,
      required this.image2,
      required this.image3,
      required this.isActive})
      : super(key: key);

  @override
  State<ExpandedButton> createState() => _ExpandedButtonState();
}

class _ExpandedButtonState extends State<ExpandedButton> {
  // bool isActive = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);

    return AnimatedContainer(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      height:
          !widget.isActive ? (screenSize.height / 7) : (screenSize.height / 3),
      duration: Duration(milliseconds: 500),
      child: Container(
        alignment: Alignment.center,
        width: screenSize.width - 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          gradient: LinearGradient(
            colors: [
              widget.color1,
              widget.color2,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Stack(children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              widget.text,
              style: theme.textTheme.headline5?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            width: screenSize.width / 1.7,
            height: screenSize.height / 8,
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 500),
              firstChild: Container(),
              secondChild: Image.asset(widget.image1,
                  width: screenSize.width / 5, height: screenSize.width / 5),
              secondCurve: Curves.slowMiddle,
              crossFadeState: !widget.isActive
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            width: screenSize.width / 4,
            height: screenSize.height / 4,
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 500),
              firstChild: Container(),
              secondChild: Image.asset(widget.image2,
                  width: screenSize.width / 5, height: screenSize.width / 5),
              crossFadeState: !widget.isActive
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            width: screenSize.width / 1.2,
            height: screenSize.height / 3.5,
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 500),
              firstChild: Container(),
              secondChild: Image.asset(widget.image3,
                  width: screenSize.width / 5, height: screenSize.width / 5),
              crossFadeState: !widget.isActive
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
            ),
          )
        ]),
      ),
    );
  }
}
