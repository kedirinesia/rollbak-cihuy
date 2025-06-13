// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/config.dart';

enum DisableType { merchant, member }

class DisablePage extends StatelessWidget {
  final DisableType type;
  DisablePage(this.type);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(configAppBloc.namaApp.valueWrapper?.value),
          centerTitle: true,
          elevation: 0,
          backgroundColor: packageName == 'com.lariz.mobile'
              ? Theme.of(context).secondaryHeaderColor
              : Theme.of(context).primaryColor,
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            color: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            padding: EdgeInsets.all(20),
            child: Column(children: <Widget>[
              Spacer(),
              Text(
                  'Maaf, ${this.type == DisableType.merchant ? 'aplikasi' : 'user'} saat ini dalam status tidak aktif',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.clip),
              SizedBox(height: 5),
              Text('Silahkan hubungi Customer Service',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.clip),
              Spacer(),
              this.type == DisableType.member
                  ? ButtonTheme(
                      minWidth: double.infinity,
                      buttonColor: Theme.of(context).canvasColor,
                      textTheme: ButtonTextTheme.primary,
                      child: MaterialButton(
                          child: Text('Keluar'.toUpperCase()),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.clear();
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => PayuniApp()));
                          }),
                    )
                  : SizedBox()
            ])));
  }
}
