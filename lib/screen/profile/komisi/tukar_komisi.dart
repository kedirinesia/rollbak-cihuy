// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/profile/komisi/tukar_komisi_controller.dart';

class TukarKomisi extends StatefulWidget {
  final int nominal;

  TukarKomisi(this.nominal);

  @override
  _TukarKomisiState createState() => _TukarKomisiState();
}

class _TukarKomisiState extends TukarKomisiController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/tukar/komisi', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Tukar Komisi',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tukar Komisi'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
      ),
      body: Column(children: <Widget>[
        Container(
          width: double.infinity,
          height: 200,
          color: packageName == 'com.lariz.mobile'
              ? Theme.of(context).secondaryHeaderColor
              : Theme.of(context).primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text('Tukar komisi menjadi saldo aktif',
                  style: TextStyle(color: Colors.white)),
              SizedBox(height: 15)
            ],
          ),
        ),
        loading
            ? loadingWidget()
            : Container(
                width: double.infinity,
                margin: EdgeInsets.all(15),
                child: packageName == 'com.eralink.mobileapk'
                    ? TextFormField(
                        controller: nominal,
                        cursorColor: Theme.of(context).primaryColor,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            labelText: 'Nominal',
                            labelStyle: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor),
                            prefixText: 'Rp ',
                            prefixStyle: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor)),
                      )
                    : TextFormField(
                        controller: nominal,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nominal',
                            prefixText: 'Rp '),
                      ),
              )
      ]),
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              icon: Icon(Icons.navigate_next),
              label: Text('Tukar'),
              backgroundColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
              onPressed: () => tukar(),
            ),
    );
  }
}
