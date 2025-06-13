// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../../app_config.dart';
import 'config.dart';
import 'color.dart';
import 'resource.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  var configApp = AppConfig(
    appDisplayName: namaApp,
    appInternalId: sigVendor,
    theme: colors,
    resource: StringResource(),
    child: MyApp(),
  );

  runApp(configApp);
}
