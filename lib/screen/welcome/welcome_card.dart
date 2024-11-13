import 'package:flutter/material.dart';
import 'package:pensiunku/screen/welcome/welcome_screen.dart';

/// Card displayed in the [WelcomeScreen].
///
class WelcomeCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  const WelcomeCard({
    Key? key,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Column(
      children: [
        SizedBox(height: 24.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(5, 5),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              width: screenWidth * 0.75,
              height: screenHeight * 0.65,
              decoration: BoxDecoration(
                color: Colors.grey,
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 36.0),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headline5?.copyWith(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
