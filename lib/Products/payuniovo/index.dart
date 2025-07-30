import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

// Import halaman dan config
import '../../main.dart';
import '../../app_config.dart';
import 'config.dart';
import 'color.dart';
import 'resource.dart';
import 'layout/wizard/wizard.dart';
import 'package:mobile/Products/payuniovo/layout/register.dart';
import '../../index.dart';

void main() {
  runApp(AppConfig(
    appDisplayName: namaApp,
    appInternalId: sigVendor,
    theme: colors,
    resource: StringResource(),
    child: DeeplinkWrapper(child: MyApp()),
  ));
}

class DeeplinkWrapper extends StatefulWidget {
  final Widget child;
  DeeplinkWrapper({required this.child});

  @override
  _DeeplinkWrapperState createState() => _DeeplinkWrapperState();
}

class _DeeplinkWrapperState extends State<DeeplinkWrapper> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeeplink(initialLink);
      }
    } catch (e) {
      print("Error initialLink: $e");
    }

    _sub = linkStream.listen((String? link) {
      if (link != null) {
        _handleDeeplink(link);  
      }
    }, onError: (err) {
      print("Error listening linkStream: $err");
    });
  }

  void _handleDeeplink(String link) {
    if (link.contains('login')) {
      PayuniApp.navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => IntroScreen()),
      );

      // Tampilkan snackbar "Silakan Login"
      Future.delayed(Duration(milliseconds: 300), () {
        final context = PayuniApp.navigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verifikasi berhasil')),
          );
        }
      });
    } else if (link.contains('register')) {
      PayuniApp.navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => RegisterUser()),
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
