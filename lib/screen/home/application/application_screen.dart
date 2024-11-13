// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:kredit_pensiun_app/model/simulation_form_model.dart';
// import 'package:kredit_pensiun_app/model/simulation_model.dart';
// import 'package:kredit_pensiun_app/model/user_model.dart';
// import 'package:kredit_pensiun_app/screen/home/application/simulation_form_screen.dart';
// import 'package:kredit_pensiun_app/screen/home/application/simulation_result_screen.dart';
// import 'package:kredit_pensiun_app/util/widget_util.dart';
// import 'package:kredit_pensiun_app/widget/carousel_indicator.dart';

// class ApplicationScreen extends StatefulWidget {
//   final void Function(BuildContext) onApplySubmission;
//   final void Function(int index) onChangeBottomNavIndex;

//   const ApplicationScreen({
//     Key? key,
//     required this.onApplySubmission,
//     required this.onChangeBottomNavIndex,
//   }) : super(key: key);

//   @override
//   _ApplicationScreenState createState() => _ApplicationScreenState();
// }

// class _ApplicationScreenState extends State<ApplicationScreen>
//     with TickerProviderStateMixin {
//   int _currentCarouselIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     double carouselWidth = MediaQuery.of(context).size.width * 0.8;
//     double carouselHeight = carouselWidth * 2223 / 1652;

//     return WillPopScope(
//       onWillPop: () async {
//         widget.onChangeBottomNavIndex(0);
//         return false;
//       },
//       child: Scaffold(
//         appBar: WidgetUtil.getNewAppBar(
//           context,
//           'Produk Kami',
//           1,
//           (newIndex) {
//             widget.onChangeBottomNavIndex(newIndex);
//           },
//           () {
//             widget.onChangeBottomNavIndex(0);
//           },
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 16.0),
//               Text(
//                 'PRODUK KAMI',
//                 style: theme.textTheme.headline5?.copyWith(
//                   color: theme.primaryColor,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 16.0),
//               CarouselSlider(
//                 options: CarouselOptions(
//                   height: carouselHeight,
//                   viewportFraction: 0.8,
//                   enableInfiniteScroll: false,
//                   // autoPlay: true,
//                   // autoPlayInterval: Duration(seconds: 5),
//                   onPageChanged: (index, reason) {
//                     setState(() {
//                       _currentCarouselIndex = index;
//                     });
//                   },
//                 ),
//                 items: [
//                   'assets/application_screen/image_1.png',
//                   'assets/application_screen/image_2.png',
//                   // 'assets/application_screen/image_3.png',
//                   'assets/application_screen/image_4.png',
//                 ]
//                     .asMap()
//                     .map((index, assetName) {
//                       return MapEntry(
//                         index,
//                         Builder(
//                           builder: (BuildContext context) {
//                             return AnimatedOpacity(
//                               opacity:
//                                   index == _currentCarouselIndex ? 1.0 : 0.7,
//                               duration: Duration(milliseconds: 300),
//                               child: Container(
//                                 margin: const EdgeInsets.all(16.0),
//                                 decoration: BoxDecoration(
//                                   boxShadow: [
//                                     BoxShadow(
//                                       offset: Offset(0, 0),
//                                       color: Colors.black.withOpacity(0.2),
//                                       blurRadius: 16.0,
//                                     ),
//                                   ],
//                                 ),
//                                 child: InkWell(
//                                   borderRadius: BorderRadius.circular(16.0),
//                                   onTap: () {
//                                     String simulationFormTitle;
//                                     SimulationFormType simulationFormType;
//                                     if (index == 0) {
//                                       simulationFormTitle = 'Kredit Pensiun';
//                                       simulationFormType =
//                                           SimulationFormType.Pensiun;
//                                     } else if (index == 1) {
//                                       simulationFormTitle =
//                                           'Kredit Pra-Pensiun';
//                                       simulationFormType =
//                                           SimulationFormType.PraPensiun;
//                                       // } else if (index == 2) {
//                                       //   simulationFormTitle = 'Kredit Aktif';
//                                       //   simulationFormType =
//                                       //       SimulationFormType.PegawaiAktif;
//                                     } else {
//                                       simulationFormTitle = 'Kredit Platinum';
//                                       simulationFormType =
//                                           SimulationFormType.Platinum;
//                                     }
//                                     Navigator.of(context)
//                                         .pushNamed(
//                                       SimulationFormScreen.ROUTE_NAME,
//                                       arguments: SimulationFormScreenArguments(
//                                         simulationFormType: simulationFormType,
//                                         onSubmit: (context, simulationFormModel,
//                                                 simulationModel) =>
//                                             _onSubmitCreditScreen(
//                                           context,
//                                           simulationFormTitle,
//                                           simulationFormType,
//                                           simulationModel,
//                                           simulationFormModel,
//                                         ),
//                                       ),
//                                     )
//                                         .then((newIndex) {
//                                       if (newIndex is int) {
//                                         widget.onChangeBottomNavIndex(newIndex);
//                                       }
//                                     });
//                                   },
//                                   child: Image.asset(assetName),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     })
//                     .values
//                     .toList(),
//               ),
//               CarouselIndicator(
//                 length: 3,
//                 currentIndex: _currentCarouselIndex,
//                 vsync: this,
//                 mainAxisAlignment: MainAxisAlignment.center,
//               ),
//               SizedBox(height: 80.0),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _onSubmitCreditScreen(
//     BuildContext context,
//     String title,
//     SimulationFormType simulationFormType,
//     SimulationModel simulationModel,
//     SimulationFormModel simulationFormModel,
//   ) {
//     Navigator.of(context)
//         .pushNamed(
//       SimulationResultScreen.ROUTE_NAME,
//       arguments: SimulationResultScreenArguments(
//         title: title,
//         onSubmit: widget.onApplySubmission,
//         simulationFormType: simulationFormType,
//         simulationModel: simulationModel,
//         simulationFormModel: simulationFormModel,
//       ),
//     )
//         .then((newIndex) {
//       if (newIndex is int) {
//         Navigator.of(context).pop(newIndex);
//       }
//     });
//   }
// }
