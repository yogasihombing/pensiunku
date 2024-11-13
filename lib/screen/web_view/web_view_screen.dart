import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreenArguments {
  final String initialUrl;

  WebViewScreenArguments({
    required this.initialUrl,
  });
}

class WebViewScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/webview';

  final String initialUrl;

  const WebViewScreen({
    Key? key,
    required this.initialUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: WebView(
        initialUrl: initialUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onPageFinished: (url) {
          // Navigator.of(context).pop(1);
          print('webview already finished: ' + url);
        },
        javascriptChannels: <JavascriptChannel>[
                JavascriptChannel(
                  name: 'Print',
                  onMessageReceived: (JavascriptMessage receiver) {
                    print('==========>>>>>>>>>>>>>> BEGIN');
                    print(receiver.message);
                    if (receiver.message != null || receiver.message != 'undefined') {
                      if (receiver.message == 'close') {
                        Navigator.pop(context);
                      } else {
                        _handleResponse(receiver.message);
                      }
                    }
                    print('==========>>>>>>>>>>>>>> END');
                  },
                ),
                // JavascriptChannel(
                //   name: 'Android',
                //   onMessageReceived: (JavascriptMessage receiver) {
                //     print('==========>>>>>>>>>>>>>> BEGIN');
                //     print(receiver.message);
                //     if (Platform.isAndroid) {
                //       if (receiver.message != null || receiver.message != 'undefined') {
                //         if (receiver.message == 'close') {
                //           Navigator.pop(context);
                //         } else {
                //           _handleResponse(receiver.message);
                //         }
                //       }
                //     }
                //     print('==========>>>>>>>>>>>>>> END');
                //   },
                // ),
              ].toSet(),
      ),
    );
  }

  _handleResponse(message) {
    try {
      print('respnse:'+message);
    } catch (e) {
      // utils.toast(e.toString());
    }
  }
}
