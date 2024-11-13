import 'package:flutter/material.dart';

class ButtonTextField extends StatelessWidget {
  final String title;
  final String labelText;
  final bool isFilled;
  final void Function()? onTap;
  final double borderRadius;
  final Color color;
  final bool useIcon;

  const ButtonTextField({
    Key? key,
    required this.title,
    required this.labelText,
    required this.isFilled,
    this.onTap,
    this.borderRadius = 4.0,
    this.color = const Color.fromARGB(255, 226, 226, 226),
    this.useIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8.0),
          child: InkWell(
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
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: isFilled
                            ? theme.textTheme.subtitle1?.copyWith(
                                color: Colors.black87,
                              )
                            : theme.textTheme.subtitle1?.copyWith(
                                color: Colors.black54,
                              ),
                      ),
                    ),
                    if (useIcon)
                      Icon(
                        Icons.chevron_right,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 24.0,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 100),
            opacity: isFilled ? 1.0 : 0.0,
            child: Text(
              labelText,
              style: theme.textTheme.caption,
            ),
          ),
        ),
      ],
    );
  }
}
