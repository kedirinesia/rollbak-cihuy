import 'package:flutter/material.dart';
import 'app_config.dart';
import 'main.dart';
import 'Products/payuniovo/index.dart';
import 'Products/payuniovo/config.dart';
import 'Products/payuniovo/color.dart';
import 'Products/payuniovo/resource.dart';
import 'package:mobile/utils/debug_helper.dart';

void main() {
  runApp(AppConfig(
    appDisplayName: namaApp,
    appInternalId: sigVendor,
    theme: colors,
    resource: StringResource(),
    child: DeeplinkWrapper(child: MyApp()),
  ));
} 