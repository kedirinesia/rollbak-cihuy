// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/profile/downline/downline_controller.dart';
import 'package:mobile/screen/profile/downline/tambah_downline.dart';

class Downline extends StatefulWidget {
  final String id;
  final String name;
  Downline({this.id = '', this.name = ''});
  @override
  _DownlineState createState() => _DownlineState();
}

class _DownlineState extends DownlineController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/downline/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Halaman Downline',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Downline'),
        centerTitle: true,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
      ),
      body: loading ? loadingWidget() : listWidget(),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: packageName == 'com.lariz.mobile'
              ? Theme.of(context).secondaryHeaderColor
              : Theme.of(context).primaryColor,
          onPressed: () async {
            dynamic response = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TambahDownline()));

            if (response != null) {
              getData();
            }
          }),
    );
  }
}
