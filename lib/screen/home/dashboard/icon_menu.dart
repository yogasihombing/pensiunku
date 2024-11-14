import 'package:flutter/material.dart';

// ignore: must_be_immutable
class IconMenu extends StatelessWidget {
  final String title;
  final String image;
  final double size;
  final String routeNamed;
  Object? arguments;

  IconMenu(
      {Key? key,
      required this.title,
      required this.image,
      this.size = 51,
      required this.routeNamed,
      this.arguments})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(routeNamed, arguments: arguments);
      },
      child: Column(children: [
        Stack(children: [
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              color: Color.fromRGBO(237, 237, 237, 1.0),
            ),
          ),
          Image(
            height: size,
            image: AssetImage(image),
          ),
        ]),
        SizedBox(height: 5),
        Text(title,
            style: theme.textTheme.subtitle1
                ?.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}