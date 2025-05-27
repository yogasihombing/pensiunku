import 'package:flutter/material.dart';

class NoArticle extends StatelessWidget {
  const NoArticle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height -
          AppBar().preferredSize.height * 2,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 90.0,
              horizontal: 60.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 160,
                  child: Image.asset('assets/notification_screen/empty.png'),
                ),
                SizedBox(height: 24.0),
                Text(
                  'Tidak ada artikel',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headline5?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Jika ada artikel, maka informasinya akan muncul disini',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText1?.copyWith(
                    color: theme.textTheme.caption?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
