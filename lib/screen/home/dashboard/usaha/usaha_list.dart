import 'package:flutter/material.dart';
import 'package:pensiunku/model/usaha_model.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/usaha_repository.dart';
import 'package:pensiunku/screen/home/dashboard/usaha/usaha_detail_screen.dart';
import 'package:pensiunku/widget/error_card.dart';


class UsahaList extends StatefulWidget {
  final Categories usahaModelCategory;
  final double carouselHeight;
   final String searchQuery;

  const UsahaList({
    Key? key,
    required this.usahaModelCategory,
    required this.carouselHeight,
   required this.searchQuery,
  }) : super(key: key);
  @override
  State<UsahaList> createState() => _UsahaListState();
}

class _UsahaListState extends State<UsahaList> {
  late Future<ResultModel<UsahaModel>> _futureData;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  _refreshData() {
    return _futureData =
        UsahaRepository().getAll(widget.usahaModelCategory.id).then((value) {
          // if (value.error != null) {
          //   WidgetUtil.showSnackbar(
          //     context,
          //     value.error.toString(),
          //   );
          // }
          setState(() {});
          return value;
        });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    double cardWidth = screenSize.width * 0.37;

    return FutureBuilder(
      future: _futureData,
      builder: (BuildContext context,
          AsyncSnapshot<ResultModel<UsahaModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data?.data?.categories.isNotEmpty == true) {
            UsahaModel data = snapshot.data!.data!;
            return Container(
              height: widget.carouselHeight,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(width: 24.0),
                  ...data.list.map((franchise) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _onSelectFranchise(franchise.id);
                            },
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              width: cardWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: cardWidth,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: Image.network(
                                            franchise.logo,
                                            fit: BoxFit.fill
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                      right: 8.0,
                                      left: 8.0,
                                      bottom: 16.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          franchise.nama,
                                          style: theme.textTheme.bodyText1?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  SizedBox(width: 24.0),
                ],
              ),
            );
          } else {
            String errorTitle = 'Tidak dapat menampilkan artikel';
            String? errorSubtitle = snapshot.data?.error;
            return Container(
              child: ErrorCard(
                title: errorTitle,
                subtitle: errorSubtitle,
                iconData: Icons.warning_rounded,
              ),
            );
          }
        } else {
          return Container(
            height: widget.carouselHeight,
            child: Center(
              child: CircularProgressIndicator(
                color: theme.primaryColor,
              ),
            ),
          );
        }
      },
    );
  }
  void _onSelectFranchise(int usahaId) {
    UsahaRepository()
        .getDetail(usahaId)
        .then((result) {
      if (result.isSuccess) {
        Navigator.of(context)
            .pushNamed(
          UsahaDetailScreen.ROUTE_NAME,
          arguments: UsahaDetailScreenArguments(
            usahaDetailModel: result.data!,
          ),
        )
            .then(
              (newIndex) {
            if (newIndex is int) {
              Navigator.of(context).pop(newIndex);
            }
          },
        );
      } else {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
              content: Text(
                  result.error ?? 'Gagal mengirimkan informasi lengkap franchise',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              elevation: 24.0,
            ));
      }
    });
  }
}


// class UsahaList extends StatefulWidget {
//   final Categories usahaModelCategory;
//   final double carouselHeight;

//   const UsahaList({
//     Key? key,
//     required this.usahaModelCategory,
//     required this.carouselHeight, required String searchQuery,
//   }) : super(key: key);
//   @override
//   State<UsahaList> createState() => _UsahaListState();
// }

// class _UsahaListState extends State<UsahaList> {
//   late Future<ResultModel<UsahaModel>> _futureData;

//   @override
//   void initState() {
//     super.initState();
//     _refreshData();
//   }

//   _refreshData() {
//     return _futureData =
//         UsahaRepository().getAll(widget.usahaModelCategory.id).then((value) {
//           // if (value.error != null) {
//           //   WidgetUtil.showSnackbar(
//           //     context,
//           //     value.error.toString(),
//           //   );
//           // }
//           setState(() {});
//           return value;
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     Size screenSize = MediaQuery.of(context).size;
//     double cardWidth = screenSize.width * 0.37;

//     return FutureBuilder(
//       future: _futureData,
//       builder: (BuildContext context,
//           AsyncSnapshot<ResultModel<UsahaModel>> snapshot) {
//         if (snapshot.hasData) {
//           if (snapshot.data?.data?.categories.isNotEmpty == true) {
//             UsahaModel data = snapshot.data!.data!;
//             return Container(
//               height: widget.carouselHeight,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: [
//                   SizedBox(width: 24.0),
//                   ...data.list.map((franchise) {
//                     return Builder(
//                       builder: (BuildContext context) {
//                         return Material(
//                           color: Colors.transparent,
//                           child: InkWell(
//                             onTap: () {
//                               _onSelectFranchise(franchise.id);
//                             },
//                             borderRadius: BorderRadius.circular(8.0),
//                             child: Container(
//                               margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                               width: cardWidth,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     height: cardWidth,
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(8.0),
//                                       child: Container(
//                                         width: MediaQuery.of(context).size.width,
//                                         child: Image.network(
//                                             franchise.logo,
//                                             fit: BoxFit.fill
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.only(
//                                       top: 8.0,
//                                       right: 8.0,
//                                       left: 8.0,
//                                       bottom: 16.0,
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           franchise.nama,
//                                           style: theme.textTheme.bodyText1?.copyWith(
//                                             fontWeight: FontWeight.w700,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   }).toList(),
//                   SizedBox(width: 24.0),
//                 ],
//               ),
//             );
//           } else {
//             String errorTitle = 'Tidak dapat menampilkan artikel';
//             String? errorSubtitle = snapshot.data?.error;
//             return Container(
//               child: ErrorCard(
//                 title: errorTitle,
//                 subtitle: errorSubtitle,
//                 iconData: Icons.warning_rounded,
//               ),
//             );
//           }
//         } else {
//           return Container(
//             height: widget.carouselHeight,
//             child: Center(
//               child: CircularProgressIndicator(
//                 color: theme.primaryColor,
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }
//   void _onSelectFranchise(int usahaId) {
//     UsahaRepository()
//         .getDetail(usahaId)
//         .then((result) {
//       if (result.isSuccess) {
//         Navigator.of(context)
//             .pushNamed(
//           UsahaDetailScreen.ROUTE_NAME,
//           arguments: UsahaDetailScreenArguments(
//             usahaDetailModel: result.data!,
//           ),
//         )
//             .then(
//               (newIndex) {
//             if (newIndex is int) {
//               Navigator.of(context).pop(newIndex);
//             }
//           },
//         );
//       } else {
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//               content: Text(
//                   result.error ?? 'Gagal mengirimkan informasi lengkap franchise',
//                   style: TextStyle(color: Colors.white)),
//               backgroundColor: Colors.red,
//               elevation: 24.0,
//             ));
//       }
//     });
//   }
// }
