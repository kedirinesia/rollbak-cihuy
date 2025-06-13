// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/Products/ayoba/layout/komisi/tukar_komisi_controller.dart';

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
      ),
      body: Column(children: <Widget>[
        Container(
          width: double.infinity,
          height: 200,
          color: Theme.of(context).primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Jumlah Komisi', style: TextStyle(color: Colors.white)),
              SizedBox(height: 10),
              Text(
                formatRupiah(bloc.user.valueWrapper?.value.komisi),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
              )
            ],
          ),
        ),
        SizedBox(height: 15),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Tukar Komisi Menjadi Saldo Aktif",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        loading
            ? loadingWidget()
            : Container(
                width: double.infinity,
                margin: EdgeInsets.all(15),
                child: TextFormField(
                  controller: nominal,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nominal',
                      prefixText: 'Rp '),
                ))
      ]),
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              icon: Icon(Icons.navigate_next),
              label: Text('Tukar'),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () => tukar(),
            ),
    );
  }
}
