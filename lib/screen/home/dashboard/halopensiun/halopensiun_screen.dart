import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/halopensiun_model.dart';
import 'package:pensiunku/repository/halopensiun_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/chip_tab.dart';
import 'package:pensiunku/widget/sliver_app_bar_sheet_top.dart';
import 'package:pensiunku/widget/sliver_app_bar_title.dart';

class HalopensiunScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/halopensiun';

  const HalopensiunScreen({
    Key? key,
  }) : super(key: key);

  @override
  _HalopensiunScreenState createState() => _HalopensiunScreenState();
}

class _HalopensiunScreenState extends State<HalopensiunScreen> {
  ScrollController scrollController = new ScrollController();
  late Future<ResultModel<HalopensiunModel>> _futureData;
  late String _searchText;
  final TextEditingController editingController = TextEditingController();
  late List<Categories> _categories = [];
  late List<ListHalopensiun> _listHalopensiun = [];
  late int _selectedCategoryId;

  // bool _isLoading = false;
  final dataKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = 1;
    _searchText = '';
    _refreshData();
  }

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    return _futureData =
        HalopensiunRepository().getAllHalopensiuns(token!).then((value) {
      if (value.error != null) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(value.error.toString(),
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
      } else {
        setState(() {
          _categories = [];
          _listHalopensiun = [];
          //categories
          value.data!.categories.asMap().forEach((key, value) {
            _categories.add(value);
          });

          //listhalopensiun
          value.data!.list.asMap().forEach((key, value) {
            if (value.idKategori == _selectedCategoryId &&
                value.judul.toLowerCase().contains(_searchText)) {
              _listHalopensiun.add(value);
            }
          });
        });
      }
      setState(() {});
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // Widget Dimensions
    Size screenSize = MediaQuery.of(context).size;
    double sliverAppBarExpandedHeight = screenSize.height * 0.24;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1) Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white,
                Colors.white,
                Color(0xFFDCE293),
              ],
              stops: [0.25, 0.5, 0.75, 1.0],
            ),
          ),
        ),

        // 2) Scaffold transparan
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: RefreshIndicator(
            onRefresh: () => _refreshData(),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: sliverAppBarExpandedHeight,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: SliverAppBarTitle(
                      child: SizedBox(
                        height: AppBar().preferredSize.height * 0.4,
                        child: Text('Halo Pensiun'),
                      ),
                    ),
                    titlePadding: const EdgeInsets.only(
                      left: 46.0,
                      bottom: 16.0,
                    ),
                    background: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(110, 184, 179, 1),
                                  Color.fromRGBO(119, 189, 185, 1),
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: InkWell(
                                    child: Stack(
                                      fit: StackFit.loose,
                                      children: [
                                        Image.asset(
                                          'assets/halopensiun/banner.png',
                                          fit: BoxFit.cover,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              9 /
                                              16, // Rasio 16:9
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverAppBarSheetTop(),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                    child: FutureBuilder(
                  future: _futureData,
                  builder: (BuildContext context,
                      AsyncSnapshot<ResultModel<HalopensiunModel>> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data?.data?.categories.isNotEmpty == true) {
                        HalopensiunModel data = snapshot.data!.data!;
                        return Container(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                                bottom: 12.0,
                                top: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 36.0,
                                  child: TextField(
                                    onSubmitted: (value) {
                                      _searchText = value;
                                      _refreshData();
                                    },
                                    controller: editingController,
                                    decoration: InputDecoration(
                                        hintText: 'Search',
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                        ),
                                        filled: true,
                                        fillColor:
                                            Color.fromRGBO(228, 228, 228, 1.0),
                                        suffixIcon: Icon(Icons.search),
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(36.0)))),
                                  ),
                                ),
                                SizedBox(
                                  height: 12.0,
                                ),
                                Container(
                                  height: 28.0,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      ...data.categories
                                          .asMap()
                                          .map((index, halopensiunCategory) {
                                            return MapEntry(
                                              index,
                                              ChipTab(
                                                text: halopensiunCategory.nama,
                                                isActive: _selectedCategoryId ==
                                                    index + 1,
                                                onTap: () {
                                                  setState(() {
                                                    _selectedCategoryId =
                                                        index + 1;
                                                  });
                                                  _refreshData();
                                                },
                                                backgroundColor:
                                                    const Color(0xFFFEC842),
                                              ),
                                            );
                                          })
                                          .values
                                          .toList(),
                                      SizedBox(width: 24.0),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return noData();
                      }
                    } else {
                      return Container(
                        height: (screenSize.height) * 0.5 + 36 + 16.0,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.primaryColor,
                          ),
                        ),
                      );
                    }
                  },
                )),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: ExpansionTile(
                              title: Text(_listHalopensiun[index].judul),
                              children: [
                                CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  imageUrl: _listHalopensiun[index].infografis,
                                  fit: BoxFit.fitWidth,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _listHalopensiun.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget noData() {
    ThemeData theme = Theme.of(context);
    return Padding(
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
            'Tidak ada info Halo Pensiun',
            textAlign: TextAlign.center,
            style: theme.textTheme.headline5?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Jika ada info Halo Pensiun, maka informasinya akan muncul disini',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyText1?.copyWith(
              color: theme.textTheme.caption?.color,
            ),
          ),
        ],
      ),
    );
  }
}
