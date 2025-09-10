import 'package:flutter/cupertino.dart';

import '../../app_config.dart';
import '../../main.dart';
import '../SEEPAYS/config.dart';
import '../seepays/color.dart';
import '../seepays/resource.dart';
import 'package:mobile/utils/debug_helper.dart';

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
