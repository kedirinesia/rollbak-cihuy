import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TelePage extends StatefulWidget {
  @override
  _TelePageState createState() => _TelePageState();
}

class _TelePageState extends State<TelePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // themeMode: ThemeMode.light,
      theme: ThemeData.dark(),
      // darkTheme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            WebView(
              initialUrl: 'https://t.me/s/centralbayarid',
              javascriptMode: JavascriptMode.unrestricted,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                title: Text('Informasi'),
                centerTitle: true,
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
