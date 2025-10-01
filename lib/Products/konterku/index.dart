import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../main.dart';
import 'color.dart';
import 'config.dart';
import 'resource.dart';

void main() {
  var configApp = AppConfig(
    appDisplayName: namaApp,
    appInternalId: sigVendor,
    theme: colors,
    resource: StringResource(),
    child: MyApp(),
  );

  runApp(configApp);
}
