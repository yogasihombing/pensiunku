import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LiveChat extends StatefulWidget {
  @override
  _LiveChatState createState() => _LiveChatState();
}

class _LiveChatState extends State<LiveChat> {
  final String title = "Live Chat";
  final String SelectedUrl = "";

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  int position = 1;

  final key = UniqueKey();

  doneLoading(String A) {
    setState(() {
      position = 0;
    });
  }

  startLoading(String A) {
    setState(() {
      position = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Chat',
      home: new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          title: new Text(
            'Live Chat',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20.0,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                splashColor: Colors.blue,
                highlightColor: Colors.blue.withOpacity(0.5),
                onTap: () {
                  print("Back");
                  Navigator.pop(context, true);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.red,
                  size: 30.0,
                ),
              ),
            )
          ],
        ),
        body: IndexedStack(
          index: position,
          children: <Widget>[
            WebView(
              initialUrl:
                  'https://tawk.to/chat/622eb99aa34c2456412ae25f/1fu38a1e5',
              javascriptMode: JavascriptMode.unrestricted,
              key: key,
              onPageFinished: doneLoading,
              onPageStarted: startLoading,
            ),
            Container(
              color: Colors.white,
              child: Center(child: CircularProgressIndicator()),
            )
          ],
        ),
      ),
    );
  }
}
