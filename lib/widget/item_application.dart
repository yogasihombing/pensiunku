import 'package:flutter/material.dart';

class ItemApplication extends StatelessWidget {
  final String title;
  final String assetName;
  final VoidCallback onTap;

  const ItemApplication({
    Key? key,
    required this.title,
    required this.assetName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1,
          color: Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 6.0,
        horizontal: 24.0,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 12.0,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 75,
                height: 75,
                child: Image.asset(assetName),
              ),
              SizedBox(width: 24.0),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.headline6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
