import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config.dart';

class CustomerServicePage extends StatefulWidget {
  @override
  _CustomerServicePageState createState() => _CustomerServicePageState();
}

class _CustomerServicePageState extends State<CustomerServicePage> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('TalentaPay Live Chat',
                style: TextStyle(color: Colors.white)),
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white)),
        body: WebView(
            initialUrl: liveChat,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              _controller.complete(controller);
            }));
  }
}
