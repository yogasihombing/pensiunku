import 'package:flutter/material.dart';
import 'package:pensiunku/model/toko/promo_model.dart';
import 'package:pensiunku/screen/web_view/web_view_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ItemPromo extends StatelessWidget {
  final PromoModel promo;

  const ItemPromo({
    Key? key,
    required this.promo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4.0,
        vertical: 8.0,
      ),
      child: InkWell(
        onTap: promo.url != null
            ? () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed(
                  WebViewScreen.ROUTE_NAME,
                  arguments: WebViewScreenArguments(
                    initialUrl: promo.url!,
                  ),
                );
              }
            : null,
        child: Card(
          elevation: 4.0,
          child: Ink(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.5),
              image: DecorationImage(
                image: CachedNetworkImageProvider(promo.imageUrl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ),
    );
  }
}
