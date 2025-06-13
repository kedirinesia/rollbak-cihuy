// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/Products/lariz/layout/notifikasi/notifikasi_controller.dart';

class Notifikasi extends StatefulWidget {
  @override
  _NotifikasiState createState() => _NotifikasiState();
}

class _NotifikasiState extends NotifikasiController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi'),
        centerTitle: true,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        leading: GestureDetector(
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      configAppBloc.layoutApp?.valueWrapper?.value['home'] ??
                      templateConfig[
                          configAppBloc.templateCode.valueWrapper?.value],
                ),
                (route) => false),
            child: Icon(Icons.arrow_back_outlined)),
      ),
      body: loading ? loadingWidget() : listWidget(),
    );
  }
}
