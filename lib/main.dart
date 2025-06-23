// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/app_config.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:permission_handler/permission_handler.dart';
import './index.dart';

void mainCommon() {}

class MyApp extends StatelessWidget {
  void _requestPermissions() async {
    await [
      Permission.camera,
      Permission.contacts,
      Permission.storage,
      Permission.bluetooth,
      Permission.notification,
      Permission.location,
      Permission.locationWhenInUse,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    var config = AppConfig.of(context);

    apiBloc.sigVendor.add(config.resource.sig);
    apiBloc.apiUrl.add(config.resource.apiUrl);
    apiBloc.apiUrlKasir.add(config.resource.apiUrlKasir);
    configAppBloc.namaApp.add(config.appDisplayName);
    configAppBloc.labelSaldo.add(config.resource.labelSaldo);
    configAppBloc.packagename.add(config.resource.packagename);
    configAppBloc.brandId.add(config.resource.brandId);
    configAppBloc.labelPoint.add(config.resource.labelPoint);
    configAppBloc.copyRight.add(config.resource.copyRight);
    configAppBloc.gaId.add(config.resource.gaId);
    configAppBloc.templateCode.add(config.resource.templateCode);
    configAppBloc.iconApp.add(config.resource.iconApp);
    configAppBloc.pinCount.add(config.resource.pinCount);
    configAppBloc.otpCount.add(config.resource.otpCount);
    configAppBloc.liveChat.add(config.resource.liveChat);
    configAppBloc.limitPinLogin.add(config.resource.limitPinLogin);
    configAppBloc.autoReload.add(config.resource.autoReload);
    configAppBloc.displayGangguan.add(config.resource.gangguanDisplay);
    configAppBloc.dynamicFooterStruk.add(config.resource.dynamicFooterStruk);
    configAppBloc.isKasir.add(config.resource.isKasir);
    configAppBloc.isMarketplace.add(config.resource.isMarketplace);
    configAppBloc.realtimePrepaid.add(config.resource.realtimePrepaid);
    configAppBloc.enableMultiChannel.add(config.resource.enableMultiChannel);
    configAppBloc.boldNomorTujuan.add(config.resource.boldNomorTujuan);
    configAppBloc.layoutApp.add(config.resource.layoutApp);
    configAppBloc.qrisStaticOnTopup.add(config.resource.qrisStaticOnTopup);

    // if (config.resource.packagename == 'id.paymobileku.app' || config.resource.packagename == 'com.hexamobile.androidapp') {
    //   _requestPermissions();
    // }
    _requestPermissions();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: config.appDisplayName,
      theme: config.theme,
      home: PayuniApp(),
    );
  }
}

// void main() => runApp(PayuniApp());
