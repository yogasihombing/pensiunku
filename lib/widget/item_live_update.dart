import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/live_update_model.dart';

class ItemLiveUpdate extends StatelessWidget {
  final LiveUpdateModel liveUpdate;

  const ItemLiveUpdate({
    Key? key,
    required this.liveUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.only(
        left: 4.0,
        right: 4.0,
        top: 4.0,
        bottom: 16.0,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.5),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(liveUpdate.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
