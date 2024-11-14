import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pensiunku/screen/article/article_detail_screen.dart';
import 'package:pensiunku/screen/article/article_screen.dart';
import 'package:pensiunku/screen/common/galery_fullscreen.dart';
import 'package:pensiunku/screen/home/account/account_info/account_info_screen.dart';
import 'package:pensiunku/screen/home/account/customer_support/customer_support_screen.dart';
import 'package:pensiunku/screen/home/account/faq/faq_detail_screen.dart';
import 'package:pensiunku/screen/home/account/faq/faq_screen.dart';
import 'package:pensiunku/screen/home/account/referral/confirm_ktp_referral_screen.dart';
import 'package:pensiunku/screen/home/account/referral/referral_screen.dart';
import 'package:pensiunku/screen/home/account/referral/referral_success_screen.dart';
import 'package:pensiunku/screen/home/dashboard/event/event_screen.dart';
import 'package:pensiunku/screen/home/dashboard/forum/forum_screen.dart';
import 'package:pensiunku/screen/home/dashboard/halopensiun/halopensiun_screen.dart';
import 'package:pensiunku/screen/home/home_screen.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan.dart';
import 'package:pensiunku/screen/init/init_screen.dart';
import 'package:pensiunku/screen/notification/notification_screen.dart';
import 'package:pensiunku/screen/otp/otp_code_screen.dart';
import 'package:pensiunku/screen/otp/otp_screen.dart';
import 'package:pensiunku/screen/permission/permission_screen.dart';
import 'package:pensiunku/screen/register/prepare_register_screen.dart';
import 'package:pensiunku/screen/register/register_screen.dart';
import 'package:pensiunku/screen/selfie/prepare_selfie_screen.dart';
import 'package:pensiunku/screen/selfie/preview_selfie_screen.dart';
import 'package:pensiunku/screen/toko/add_shipping_address_screen.dart';
import 'package:pensiunku/screen/toko/barang_screen.dart';
import 'package:pensiunku/screen/toko/checkout_screen.dart';
import 'package:pensiunku/screen/toko/expedition_screen.dart';
import 'package:pensiunku/screen/toko/history_screen.dart';
import 'package:pensiunku/screen/toko/kategori_screen.dart';
import 'package:pensiunku/screen/toko/keranjang_screen.dart';
import 'package:pensiunku/screen/toko/shipping_address_screen.dart';
import 'package:pensiunku/screen/toko/toko_screen.dart';
import 'package:pensiunku/screen/web_view/web_view_screen.dart';
import 'package:pensiunku/screen/welcome/welcome_screen.dart';
import 'screen/common/gallery_youtube_fullscreen.dart';
import 'screen/home/dashboard/event/event_detail_screen.dart';
import 'screen/home/dashboard/usaha_detail_screen.dart';
import 'screen/home/dashboard/usaha_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  // add these lines
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

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
        fontFamily: 'San Fransisco',
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
          case ReferralScreen.ROUTE_NAME:
            // page = ReferralScreen();
            // log(ReferralScreenArguments.retype<num>());

            final args = settings.arguments as ReferralScreenArguments;
            page = ReferralScreen(
              referralModel: args.referralModel,
              onSuccess: args.onSuccess,
            );

            break;
          case PrepareSelfieScreen.ROUTE_NAME:
            final args = settings.arguments as PrepareSelfieScreenArguments;
            page = PrepareSelfieScreen(
              submissionModel: args.submissionModel,
              onSuccess: args.onSuccess,
            );
            break;
          case AccountInfoScreen.ROUTE_NAME:
            page = AccountInfoScreen();
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
          case PreviewSelfieScreen.ROUTE_NAME:
            var args = settings.arguments as PreviewSelfieScreenArgs;
            page = PreviewSelfieScreen(
              selfieModel: args.selfieModel,
              submissionModel: args.submissionModel,
            );
            break;
          case ConfirmKtpReferalScreen.ROUTE_NAME:
            var args = settings.arguments as ConfirmKtpReferalScreenArgs;
            page = ConfirmKtpReferalScreen(
              referralModel: args.referralModel,
              ktpModel: args.ktpModel,
              onSuccess: args.onSuccess,
            );
            break;
          case ReferralSuccessScreen.ROUTE_NAME:
            var args = settings.arguments as ReferralSuccessScreenArgs;
            page = ReferralSuccessScreen(
              referralModel: args.referralModel,
            );
            break;
          case PrepareRegisterScreen.ROUTE_NAME:
            page = PrepareRegisterScreen();
            break;
          case RegisterScreen.ROUTE_NAME:
            page = RegisterScreen();
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
          case KeranjangScreen.ROUTE_NAME:
            page = KeranjangScreen();
            break;
          case CheckoutScreen.ROUTE_NAME:
            page = CheckoutScreen();
            break;
          case ShippingAddressScreen.ROUTE_NAME:
            page = ShippingAddressScreen();
            break;
          case ForumScreen.ROUTE_NAME:
            page = ForumScreen();
            break;
          case AddShippingAddressScreen.ROUTE_NAME:
            final args = settings.arguments as AddShippingAddressArguments;
            page = AddShippingAddressScreen(
              shippingAddressId: args.shippingAddressId,
            );
            break;
          case ExpeditionScreen.ROUTE_NAME:
            final args = settings.arguments as ExpeditionScreenArguments;
            page = ExpeditionScreen(
              destination: args.destination,
              origin: args.origin,
              weight: args.weight,
            );
            break;
          case CategoryScreen.ROUTE_NAME:
            page = CategoryScreen();
            break;
          case HistoryScreen.ROUTE_NAME:
            page = HistoryScreen();
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