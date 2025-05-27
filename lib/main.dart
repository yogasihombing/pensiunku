import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pensiunku/data/api/pengajuan_anda_api.dart';

import 'package:pensiunku/screen/home/dashboard/article/article_detail_screen.dart';
import 'package:pensiunku/screen/home/dashboard/article/article_screen.dart';
import 'package:pensiunku/screen/common/galery_fullscreen.dart';
import 'package:pensiunku/screen/home/account/TNC/term_and_condition.dart';
import 'package:pensiunku/screen/home/account/account_info/account_info_screen.dart';
import 'package:pensiunku/screen/home/account/customer_support/customer_support_screen.dart';
import 'package:pensiunku/screen/home/account/faq/faq_detail_screen.dart';
import 'package:pensiunku/screen/home/account/faq/faq_screen.dart';
import 'package:pensiunku/screen/home/account/privacy_policy/privacy_policy.dart';
// import 'package:pensiunku/screen/home/account/referral/confirm_ktp_referral_screen.dart';
// import 'package:pensiunku/screen/home/account/referral/referral_screen.dart';
// import 'package:pensiunku/screen/home/account/referral/referral_success_screen.dart';
import 'package:pensiunku/screen/home/dashboard/ajukan/pengajuan_anda_screen.dart';
import 'package:pensiunku/screen/home/dashboard/dashboard_screen.dart';
import 'package:pensiunku/screen/home/dashboard/event/event_screen.dart';
import 'package:pensiunku/screen/home/dashboard/forum/forum_screen.dart';
import 'package:pensiunku/screen/home/dashboard/franchise/franchise_screen.dart';
import 'package:pensiunku/screen/home/dashboard/halopensiun/halopensiun_screen.dart';
import 'package:pensiunku/screen/home/dashboard/karir/karir_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/daftarkan_pin_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/camera_ktp_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/prepare_ktp_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/preview_ktp_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/pensiunkuplus_success_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/selfie/preview_selfie_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/e_wallet_bank_tujuan.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/e_wallet_histori.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/e_wallet_info_akun.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/e_wallet_pencairan.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/e_wallet_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/add_shipping_address_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/barang_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/checkout_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/expedition_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/history_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/kategori_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/keranjang_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/shipping_address_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/toko_screen.dart';
import 'package:pensiunku/screen/home/dashboard/usaha/usaha_detail_screen.dart';
import 'package:pensiunku/screen/home/home_screen.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan_orang_lain.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan_anda.dart';
import 'package:pensiunku/screen/init/init_screen.dart';
import 'package:pensiunku/screen/notification/notification_screen.dart';
import 'package:pensiunku/screen/otp/otp_code_screen.dart';
import 'package:pensiunku/screen/otp/otp_screen.dart';
import 'package:pensiunku/screen/permission/permission_screen.dart';
import 'package:pensiunku/screen/register/prepare_register_screen.dart';
import 'package:pensiunku/screen/register/register_screen.dart';
import 'package:pensiunku/screen/register/register_success_screen.dart';
import 'package:pensiunku/screen/web_view/web_view_screen.dart';
import 'package:pensiunku/screen/welcome/welcome_screen.dart';
import 'screen/common/gallery_youtube_fullscreen.dart';
import 'screen/home/dashboard/event/event_detail_screen.dart';
import 'screen/home/dashboard/pensiunku_plus/aktifkan_pensiunku_plus_screen.dart';
import 'screen/home/dashboard/usaha/usaha_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientation
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Initialize Firebase first
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}
// void main() async {
//   // add these lines
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setPreferredOrientations(
//       [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

//   await Firebase.initializeApp();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Color primaryColor = Color.fromARGB(255, 116, 130, 43);
    // Color primaryColor = Color.fromARGB(255, 155, 169, 32);
    Color primaryColor = Color(0xff16826e);
    Color secondaryColor = Color(0xfff29724);
    return MaterialApp(
      title: 'Pensiunku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: primaryColor,
        primarySwatch: MaterialColor(
          0xff16826e,
          {
            50: primaryColor,
            100: primaryColor,
            200: primaryColor,
            300: primaryColor,
            400: primaryColor,
            500: primaryColor,
            600: primaryColor,
            700: primaryColor,
            800: primaryColor,
            900: primaryColor,
          },
        ),
        // accentColor: secondaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
        ),
        cardTheme: CardTheme(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(secondaryColor),
            elevation: MaterialStateProperty.all(0.0),
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 24.0,
              ),
            ),
            textStyle: MaterialStateProperty.all(
              TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(36.0),
              ),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            foregroundColor: MaterialStateProperty.all(secondaryColor),
            elevation: MaterialStateProperty.all(0.0),
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 24.0,
              ),
            ),
            textStyle: MaterialStateProperty.all(
              TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(36.0),
              ),
            ),
            side: MaterialStateProperty.all(
              BorderSide(
                color: secondaryColor,
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
      initialRoute: InitScreen.ROUTE_NAME,
      onGenerateRoute: (RouteSettings settings) {
        Widget page;
        switch (settings.name) {
          case InitScreen.ROUTE_NAME:
            page = InitScreen();
            break;
          case NotificationScreen.ROUTE_NAME:
            final args = settings.arguments as NotificationScreenArguments;
            page = NotificationScreen(
              currentIndex: args.currentIndex,
            );

            break;
          case FaqScreen.ROUTE_NAME:
            page = FaqScreen();
            break;
          case FaqDetailScreen.ROUTE_NAME:
            final args = settings.arguments as FaqDetailScreenArguments;
            page = FaqDetailScreen(
              faqCategoryModel: args.faqCategoryModel,
            );
            break;
          case CustomerSupportScreen.ROUTE_NAME:
            page = CustomerSupportScreen();
            break;
          case TokoScreen.ROUTE_NAME:
            final args = settings.arguments as TokoScreenArguments;
            page = TokoScreen(
              categoryId: args.categoryId,
            );
            break;
          case BarangScreen.ROUTE_NAME:
            final args = settings.arguments as BarangScreenArguments;
            page = BarangScreen(
              barangId: args.barangId,
              barang: args.barang,
            );
            break;
          case FranchiseScreen.ROUTE_NAME:
            page = FranchiseScreen();
            break;
          case KeranjangScreen.ROUTE_NAME:
            page = KeranjangScreen();
            break;
          case CheckoutScreen.ROUTE_NAME:
            page = CheckoutScreen();
            break;
          case ShippingAddressScreen.ROUTE_NAME:
            page = ShippingAddressScreen();
            break;
          case CategoryScreen.ROUTE_NAME:
            page = CategoryScreen();
            break;
          case AddShippingAddressScreen.ROUTE_NAME:
            final args = settings.arguments as AddShippingAddressArguments;
            page = AddShippingAddressScreen(
              shippingAddressId: args.shippingAddressId,
            );
            break;
          case HistoryScreen.ROUTE_NAME:
            page = HistoryScreen();
            break;
          case ExpeditionScreen.ROUTE_NAME:
            final args = settings.arguments as ExpeditionScreenArguments;
            page = ExpeditionScreen(
              destination: args.destination,
              origin: args.origin,
              weight: args.weight,
            );
            break;
          // case ReferralScreen.ROUTE_NAME:
          //   // page = ReferralScreen();
          //   // log(ReferralScreenArguments.retype<num>());

          //   final args = settings.arguments as ReferralScreenArguments;
          //   page = ReferralScreen(
          //     referralModel: args.referralModel,
          //     onSuccess: args.onSuccess,
          //   );
          //   break;

          case TermAndConditionScreen.ROUTE_NAME:
            page = TermAndConditionScreen();
            break;
          case PrivacyPolicyScreen.ROUTE_NAME:
            page = PrivacyPolicyScreen();
            break;
          // case PrepareSelfieScreen.ROUTE_NAME:
          //   final args = settings.arguments as PrepareSelfieScreenArguments;
          //   page = PrepareSelfieScreen(
          //     submissionModel: args.submissionModel,
          //     onSuccess: args.onSuccess,
          //   );
          //   break;
          case AccountInfoScreen.ROUTE_NAME:
            page = AccountInfoScreen();
            break;
          case AktifkanPensiunkuPlusScreen.ROUTE_NAME:
            page = AktifkanPensiunkuPlusScreen();
            break;
          case RiwayatPengajuanAndaScreen.ROUTE_NAME:
            page = RiwayatPengajuanAndaScreen(
              onChangeBottomNavIndex: (int index) {},
            );
            break;
          case RiwayatPengajuanOrangLainScreen.ROUTE_NAME:
            page = RiwayatPengajuanOrangLainScreen(
              onChangeBottomNavIndex: (int index) {},
            );
            break;
          case PengajuanAndaScreen.ROUTE_NAME:
            page = PengajuanAndaScreen();
            break;
          case WelcomeScreen.ROUTE_NAME:
            page = WelcomeScreen();
            break;
          case OtpScreen.ROUTE_NAME:
            page = OtpScreen();
            break;
          case OtpCodeScreen.ROUTE_NAME:
            var args = settings.arguments as OtpCodeScreenArgs;
            page = OtpCodeScreen(
              phone: args.phone,
            );
            break;
          case PermissionScreen.ROUTE_NAME:
            page = PermissionScreen();
            break;
          case CameraKtpScreen.ROUTE_NAME:
            final args = settings.arguments as CameraKtpScreenArgs;
            page = CameraKtpScreen(
              cameraFilter: args.cameraFilter,
              onProcessImage: args.onProcessImage,
              onPreviewImage: args.onPreviewImage,
              buildFilter: args.buildFilter,
            );
            break;
          case PreviewSelfieScreen.ROUTE_NAME:
            var args = settings.arguments as PreviewSelfieScreenArgs;
            page = PreviewSelfieScreen(
              selfieModel: args.selfieModel,
              submissionModel: args.submissionModel,
            );
            break;
          // case ConfirmKtpReferalScreen.ROUTE_NAME:
          //   var args = settings.arguments as ConfirmKtpReferalScreenArgs;
          //   page = ConfirmKtpReferalScreen(
          //     referralModel: args.referralModel,
          //     ktpModel: args.ktpModel,
          //     onSuccess: args.onSuccess,
          //   );
          //   break;
          // ini tambahan baru
          case PrepareKtpScreen.ROUTE_NAME:
            final args = settings.arguments as PrepareKtpScreenArguments;
            page = PrepareKtpScreen(
              submissionModel: args.submissionModel,
              onSuccess: args.onSuccess,
            );
            break;

          // case ReferralSuccessScreen.ROUTE_NAME:
          //   var args = settings.arguments as ReferralSuccessScreenArgs;
          //   page = ReferralSuccessScreen(
          //     referralModel: args.referralModel,
          //   );
          //   break;
          case PrepareRegisterScreen.ROUTE_NAME:
            page = PrepareRegisterScreen();
            break;
          case RegisterScreen.ROUTE_NAME:
            page = RegisterScreen();
            break;
          case RegisterSuccessScreen.ROUTE_NAME:
            page = RegisterSuccessScreen();
            break;
          case WebViewScreen.ROUTE_NAME:
            final args = settings.arguments as WebViewScreenArguments;
            page = WebViewScreen(
              initialUrl: args.initialUrl,
            );
            break;
          case UsahaScreen.ROUTE_NAME:
            page = UsahaScreen();
            break;
          case UsahaDetailScreen.ROUTE_NAME:
            final args = settings.arguments as UsahaDetailScreenArguments;
            page = UsahaDetailScreen(
              usahaDetailModel: args.usahaDetailModel,
            );
            break;

          case HomeScreen.ROUTE_NAME:
            page = HomeScreen(
              title: 'Pensiunku',
            );
            break;
          case EventScreen.ROUTE_NAME:
            page = EventScreen();
            break;
          case EventDetailScreen.ROUTE_NAME:
            final args = settings.arguments as EventDetailScreenArguments;
            page = EventDetailScreen(
              eventId: args.eventId,
            );
            break;
          case GalleryFullScreen.ROUTE_NAME:
            final args = settings.arguments as GalleryFullScreenArguments;
            page = GalleryFullScreen(
              images: args.images,
              indexPage: args.indexPage,
            );
            break;
          case GalleryYoutubeFullscreen.ROUTE_NAME:
            final args =
                settings.arguments as GalleryYoutubeFullscreenArguments;
            page = GalleryYoutubeFullscreen(
              videos: args.videos,
              indexPage: args.indexPage,
            );
            break;
          case HalopensiunScreen.ROUTE_NAME:
            page = HalopensiunScreen();
            break;
          case ForumScreen.ROUTE_NAME:
            page = ForumScreen();
            break;
          case ArticleScreen.ROUTE_NAME:
            final args = settings.arguments as ArticleScreenArguments;
            page = ArticleScreen(
              articleCategories: args.articleCategories,
            );
            break;
          case ArticleDetailScreen.ROUTE_NAME:
            final args = settings.arguments as ArticleDetailScreenArguments;
            page = ArticleDetailScreen(
              articleId: args.articleId,
            );
            break;
          case PensiunkuPlusSuccessScreen.ROUTE_NAME:
            page = PensiunkuPlusSuccessScreen();
            break;
          case PreviewKtpScreen.ROUTE_NAME:
            var args = settings.arguments as PreviewKtpScreenArgs;
            page = PreviewKtpScreen(
              ktpModel: args.ktpModel,
            );
            break;

          case DaftarkanPinPensiunkuPlusScreen.ROUTE_NAME:
            page = DaftarkanPinPensiunkuPlusScreen();
            break;
          case DashboardScreen.ROUTE_NAME:
            print('DashboardScreen route detected');
            final args = settings.arguments as Map<String, dynamic>?;

            if (args != null) {
              print('Arguments received: $args');
              page = DashboardScreen(
                onApplySubmission: args['onApplySubmission'],
                onChangeBottomNavIndex: args['onChangeBottomNavIndex'],
                scrollController: args['scrollController'],
              );
            } else {
              print('Arguments are null, using default values');
              page = DashboardScreen(
                onApplySubmission: (context) {},
                onChangeBottomNavIndex: (index) {},
                scrollController: ScrollController(),
              );
            }
            break;
          case EWalletScreen.ROUTE_NAME:
            page = EWalletScreen();
            break;
          case EWalletPencairan.ROUTE_NAME:
            page = EWalletPencairan();
            break;
          case EWalletHistori.ROUTE_NAME:
            page = EWalletHistori();
            break;
          case EWalletBankTujuan.ROUTE_NAME:
            page = EWalletBankTujuan();
            break;
          case EWalletInfoAkun.ROUTE_NAME:
            page = EWalletInfoAkun();
            break;
          case KarirScreen.ROUTE_NAME:
            page = KarirScreen();
            break;
          default:
            page = Container();
            break;
        }
        return MaterialPageRoute(builder: (BuildContext context) {
          return page;
        });
      },
    );
  }
}
