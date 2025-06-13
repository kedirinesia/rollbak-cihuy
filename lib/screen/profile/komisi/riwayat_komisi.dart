// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/provider/user.dart';
import 'package:mobile/screen/profile/komisi/riwayat_komisi_controller.dart';

class RiwayatKomisi extends StatefulWidget {
  @override
  _RiwayatKomisiState createState() => _RiwayatKomisiState();
}

class _RiwayatKomisiState extends RiwayattKomisiController {
  @override
  void initState() {
    UserProvider().getProfile().whenComplete(() => getData());
    super.initState();
    void initState() {
      analitycs.pageView('/riwayat/komisi', {
        'userId': bloc.userId.valueWrapper?.value,
        'title': 'Riwayat Komisi',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Komisi'),
        centerTitle: true,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
      ),
      body: loading ? loadingWidget() : listWidget(),
      bottomNavigationBar: loading ? null : bottomWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: loading ? null : fab(),
    );
  }
}
