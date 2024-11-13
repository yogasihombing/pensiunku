import 'package:flutter/material.dart';
import 'package:pensiunku/model/event_model.dart';
import 'package:pensiunku/repository/event_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/screen/home/dashboard/event/event_item_screen.dart';
import 'package:pensiunku/screen/home/dashboard/event/latest_event_screen.dart';
import 'package:pensiunku/screen/home/dashboard/event/no_event_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class EventScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/event';
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late Future<ResultModel<List<EventModel>>> _futureData;
  late Future<ResultModel<List<EventModel>>> _futureDataWithoutSearchString;
  int _currentCarouselIndex = 0;
  int _filterIndex = 0;
  String? _searchText;
  final TextEditingController editingController = TextEditingController();
  List<String> images = [];
  List<int> idArticles = [];

  @override
  void initState() {
    super.initState();

    _currentCarouselIndex = 0;
    _filterIndex = 0;
    _searchText = null;
    _refreshData();
  }

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    return _futureData = EventRepository()
        .getEvents(token!, _filterIndex, _searchText)
        .then((value) {
      if (value.error != null) {
        // showDialog(
        //     context: context,
        //     builder: (_) => AlertDialog(
        //           content: Text(value.error.toString(),
        //               style: TextStyle(color: Colors.white)),
        //           backgroundColor: Colors.red,
        //           elevation: 24.0,
        //         ));
      }
      _futureDataWithoutSearchString =
          EventRepository().getEvents(token, _filterIndex, '');
      setState(() {});
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
          ),
          title: Text(
            "Event",
            style: theme.textTheme.headline6?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          )),
      body: RefreshIndicator(
        onRefresh: () {
          return _refreshData();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height * 1.2,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 36.0,
                      child: TextField(
                        onSubmitted: (value) {
                          _searchText = value;
                          _refreshData();
                        },
                        controller: editingController,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Color.fromRGBO(228, 228, 228, 1.0),
                            suffixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(36.0)))),
                      ),
                    ),
                  ),
                  FutureBuilder(
                      future: _futureData,
                      builder: (BuildContext context,
                          AsyncSnapshot<ResultModel<List<EventModel>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data?.data != null) {
                            List<EventModel> data = snapshot.data!.data!;
                            if (data.isEmpty) {
                              return Container();
                            } else {
                              images = [];
                              idArticles = [];
                              data.asMap().forEach((index, value) {
                                if (index < 3) {
                                  images.add(value.foto);
                                  idArticles.add(value.id);
                                }
                              });
                              return Column(
                                children: [
                                  LatestEvent(
                                      images: images, idArticles: idArticles),
                                ],
                              );
                            }
                          } else {
                            //check without search
                            return FutureBuilder(
                                future: _futureDataWithoutSearchString,
                                builder: ((context,
                                    AsyncSnapshot<ResultModel<List<EventModel>>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data?.data != null) {
                                      List<EventModel> data =
                                          snapshot.data!.data!;
                                      if (data.isEmpty) {
                                        return Container();
                                      } else {
                                        images = [];
                                        idArticles = [];
                                        data.asMap().forEach((index, value) {
                                          if (index < 3) {
                                            images.add(value.foto);
                                            idArticles.add(value.id);
                                          }
                                        });
                                        return Column(
                                          children: [
                                            LatestEvent(
                                                images: images,
                                                idArticles: idArticles),
                                          ],
                                        );
                                      }
                                    } else {
                                      return Container();
                                    }
                                  } else {
                                    return Container(
                                      height:
                                          (screenSize.height) * 0.5 + 36 + 16.0,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    );
                                  }
                                }));
                          }
                        } else {
                          return Column(
                            children: [
                              SizedBox(height: 16),
                              Center(
                                child: CircularProgressIndicator(
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                      filter(context),
                  FutureBuilder(
                      future: _futureData,
                      builder: (BuildContext context,
                          AsyncSnapshot<ResultModel<List<EventModel>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data?.data != null) {
                            List<EventModel> data = snapshot.data!.data!;
                            if (data.isEmpty) {
                              return NoEvent();
                            } else {
                              images = [];
                              idArticles = [];
                              data.asMap().forEach((index, value) {
                                if (index < 3) {
                                  images.add(value.foto);
                                  idArticles.add(value.id);
                                }
                              });
                              return Column(
                                children: [
                                  ...data.map((event) {
                                    return EventItemScreen(
                                      event: event,
                                      status: _filterIndex,
                                    );
                                  })
                                ],
                              );
                            }
                          } else {
                            //check without search
                            return FutureBuilder(
                                future: _futureDataWithoutSearchString,
                                builder: ((context,
                                    AsyncSnapshot<ResultModel<List<EventModel>>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data?.data != null) {
                                      List<EventModel> data =
                                          snapshot.data!.data!;
                                      if (data.isEmpty) {
                                        return NoEvent();
                                      } else {
                                        images = [];
                                        idArticles = [];
                                        data.asMap().forEach((index, value) {
                                          if (index < 3) {
                                            images.add(value.foto);
                                            idArticles.add(value.id);
                                          }
                                        });
                                        return Column(
                                          children: [
                                            Container(
                                              width: screenSize.width - 16.0,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              child: Card(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 8.0),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                          'Hasil pencarian : 0 event'),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    } else {
                                      return NoEvent();
                                    }
                                  } else {
                                    return Container(
                                      height:
                                          (screenSize.height) * 0.5 + 36 + 16.0,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    );
                                  }
                                }));
                          }
                        } else {
                          return Column(
                            children: [
                              SizedBox(height: 16),
                              Center(
                                child: CircularProgressIndicator(
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget filter(BuildContext context) {
    return Container(
        height: 36.0,
        margin: EdgeInsets.symmetric(horizontal: 45.0, vertical: 18.0),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(195, 195, 195, 1.0)),
          // color: Color.fromRGBO(195, 195, 195, 1.0),
          borderRadius: BorderRadius.all(Radius.circular(36)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _filterIndex = 0;
                    _refreshData();
                  });
                },
                child: Container(
                    alignment: Alignment.center,
                    height: 36.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36),
                          bottomLeft: Radius.circular(36)),
                      color: _filterIndex == 0
                          ? Color.fromRGBO(1, 169, 159, 1.0)
                          : Colors.white,
                    ),
                    child: Text(
                      "Akan Berlangsung",
                      style: TextStyle(
                        color: _filterIndex == 0
                            ? Colors.white
                            : Color.fromRGBO(149, 149, 149, 1.0),
                      ),
                    )),
              ),
            ),
            Expanded(
                child: GestureDetector(
              onTap: () {
                setState(() {
                  _filterIndex = 1;
                  _refreshData();
                });
              },
              child: Container(
                  alignment: Alignment.center,
                  height: 36.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(36),
                        bottomRight: Radius.circular(36)),
                    color: _filterIndex == 1
                        ? Color.fromRGBO(1, 169, 159, 1.0)
                        : Colors.white,
                  ),
                  child: Text(
                    "Telah Berlangsung",
                    style: TextStyle(
                        color: _filterIndex == 0
                            ? Color.fromRGBO(149, 149, 149, 1.0)
                            : Colors.white),
                  )),
            ))
          ],
        ));
  }
}
