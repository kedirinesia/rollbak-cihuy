// @dart=2.9

import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  AppConfig(
      {this.appDisplayName,
      this.appInternalId,
      this.theme,
      this.resource,
      Widget child})
      : super(child: child);

  final String appDisplayName;
  final String appInternalId;
  final ThemeData theme;
  final Resource resource;

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

abstract class Resource {
  String sig;
  String packagename;
  String brandId;
  String labelPoint;
  String labelSaldo;
  String gaId;
  int templateCode;
  String copyRight;
  String liveChat;
  String apiUrl;
  String apiUrlKasir;
  int pinCount;
  int otpCount;
  bool limitPinLogin;
  bool autoReload;
  bool gangguanDisplay;
  bool boldNomorTujuan;
  bool qrisStaticOnTopup;
  bool dynamicFooterStruk;
  bool isKasir;
  bool isMarketplace;
  bool realtimePrepaid;
  bool enableMultiChannel;
  Map<String, String> iconApp;
  Map<String, dynamic> layoutApp;
}
