import 'package:flutter/material.dart';

class GreySelectButton extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final double borderRadius;
  final bool showIcon;
  final Color color;
  final IconData? iconData;
  final TextAlign? textAlign;
   final TextStyle? textStyle;

  const GreySelectButton({
    Key? key,
    required this.title,
    this.onTap,
    this.borderRadius = 4.0,
    this.showIcon = true,
    this.color = const Color.fromARGB(255, 226, 226, 226),
    this.iconData = Icons.chevron_right,
    this.textAlign = TextAlign.start,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  textAlign: textAlign,
                  style: theme.textTheme.bodyText1?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ),
              showIcon
                  ? Icon(
                      iconData,
                      color: Colors.black54,
                    )
                  : SizedBox(
                      height: 24,
                    )
            ],
          ),
        ),
      ),
    );
  }
}
