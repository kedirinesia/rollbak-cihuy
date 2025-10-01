import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Webview extends StatefulWidget {
  final String title;
  final String url;
  final bool footer;

    Webview(this.title, this.url, {this.footer = true});

  @override
  State<Webview> createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  late WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
      ),
      persistentFooterButtons: widget.footer
          ? <Widget>[
              IconButton(
                  icon: Icon(Icons.navigate_before),
                  onPressed: () async {
                    if (await _controller.canGoBack()) {
                      await _controller.goBack();
                    }
                  }),
              IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => _controller.reload()),
              IconButton(
                  icon: Icon(Icons.navigate_next),
                  onPressed: () async {
                    if (await _controller.canGoForward()) {
                      await _controller.goForward();
                    }
                  }),
            ]
          : null,
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
          ),
          if (isLoading)
            Center(
              child: SpinKitThreeBounce(
                color: Theme.of(context).primaryColor,
                size: 35,
              ),
            ),
        ],
      ),
    );
  }
}
