
import 'package:flutter/material.dart';
// import 'package:mobile/utils/debug_helper.dart'; // Unused import

class AppConfig extends InheritedWidget {
  AppConfig(
      {this.appDisplayName = '',
      this.appInternalId = '',
      ThemeData? theme,
      Resource? resource,
      required Widget child})
      : theme = theme ?? ThemeData(),
        resource = resource ?? DefaultResource(),
        super(child: child);

  final String appDisplayName;
  final String appInternalId;
  final ThemeData theme;
  final Resource resource;

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>()!;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

abstract class Resource {
  String sig = '';
  String packagename = '';
  String brandId = '';
  String labelPoint = '';
  String labelSaldo = '';
  String gaId = '';
  int templateCode = 0;
  String copyRight = '';
  String liveChat = '';
  String apiUrl = '';
  String apiUrlKasir = '';
  int pinCount = 0;
  int otpCount = 0;
  bool limitPinLogin = false;
  bool autoReload = false;
  bool gangguanDisplay = false;
  bool boldNomorTujuan = false;
  bool qrisStaticOnTopup = false;
  bool dynamicFooterStruk = false;
  bool isKasir = false;
  bool isMarketplace = false;
  bool realtimePrepaid = false;
  bool enableMultiChannel = false;
  Map<String, String> iconApp = {};
  Map<String, dynamic> layoutApp = {};
}

class DefaultResource extends Resource {
  DefaultResource() {
    // Initialize with default values if needed
    sig = '';
    packagename = '';
    brandId = '';
    labelPoint = '';
    labelSaldo = '';
    gaId = '';
    templateCode = 0;
    copyRight = '';
    liveChat = '';
    apiUrl = '';
    apiUrlKasir = '';
    pinCount = 0;
    otpCount = 0;
    limitPinLogin = false;
    autoReload = false;
    gangguanDisplay = false;
    boldNomorTujuan = false;
    qrisStaticOnTopup = false;
    dynamicFooterStruk = false;
    isKasir = false;
    isMarketplace = false;
    realtimePrepaid = false;
    enableMultiChannel = false;
    iconApp = {};
    layoutApp = {};
  }
}
