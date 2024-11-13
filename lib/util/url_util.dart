import 'package:url_launcher/url_launcher.dart';

/// URL utility class
///
class UrlUtil {
  static void launchURL(String url) async =>
      await canLaunchUrl(Uri.parse(url)) ? await launchUrl(Uri.parse(url),mode: LaunchMode.externalApplication) : throw 'Could not launch $url';
}
