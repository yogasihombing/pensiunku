import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/event_model.dart';
import 'package:pensiunku/screen/home/dashboard/event/event_detail_screen.dart';

class EventItemScreen extends StatelessWidget {
  final EventModel event;
  final int status;

  const EventItemScreen({
    Key? key,
    required this.event,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(EventDetailScreen.ROUTE_NAME,
            arguments: EventDetailScreenArguments(eventId: event.id));
      },
      child: Container(
        width: screenSize.width - 16.0,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    height: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        color: Color.fromRGBO(1, 169, 159, 1.0),
                        image: DecorationImage(
                            image: NetworkImage(event.foto.toString()),
                            fit: BoxFit.fitHeight)),
                    // child: Image.network(event.foto, fit: BoxFit.fitHeight,),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.nama.toString(),
                        style: theme.textTheme.subtitle1
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        event.tempat,
                        style: theme.textTheme.subtitle1
                            ?.copyWith(color: Colors.grey),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                    flex: 1,
                    child: status == 0
                        ? Container(
                            width: 72.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                color: Color.fromRGBO(232, 232, 232, 1.0)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat("dd")
                                      .format(DateTime.parse(event.tanggal)),
                                  style: theme.textTheme.headline2?.copyWith(
                                      color: Color.fromRGBO(112, 112, 112, 1.0),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  DateFormat("MMM")
                                      .format(DateTime.parse(event.tanggal)),
                                  style: theme.textTheme.subtitle1?.copyWith(
                                      color: Color.fromRGBO(112, 112, 112, 1.0),
                                      fontSize: 11.0),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            width: 72.0,
                            height: 36.0,
                          )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
