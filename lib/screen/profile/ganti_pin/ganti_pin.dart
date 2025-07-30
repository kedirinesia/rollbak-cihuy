// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/profile/ganti_pin/ganti_pin_controller.dart';

class GantiPin extends StatefulWidget {
  @override
  _GantiPinState createState() => _GantiPinState();
}

class _GantiPinState extends GantiPinController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/ganti/pin', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Ganti PIN',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            iconTheme: IconThemeData(color: Colors.white),
            expandedHeight: 200.0,
            backgroundColor: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            pinned: true,
            flexibleSpace:
                FlexibleSpaceBar(title: Text('Ganti PIN'), centerTitle: true),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            loading
                ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    child: Center(
                        child: SpinKitThreeBounce(
                            color: packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                            size: 35)))
                : Container(
                    padding: EdgeInsets.all(15),
                    child: Column(children: <Widget>[
                      packageName == 'com.eralink.mobileapk'
                          ? TextFormField(
                              controller: pinLama,
                              cursorColor: Theme.of(context).primaryColor,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                labelText: 'PIN Lama',
                                labelStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              maxLength:
                                  configAppBloc.pinCount.valueWrapper?.value,
                              keyboardType: TextInputType.number,
                            )
                          : TextFormField(
                              controller: pinLama,
                              decoration: InputDecoration(
                                labelText: 'PIN Lama',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              maxLength:
                                  configAppBloc.pinCount.valueWrapper?.value,
                              keyboardType: TextInputType.number,
                            ),
                      SizedBox(height: 15),
                      packageName == 'com.eralink.mobileapk'
                          ? TextFormField(
                              controller: pinBaru,
                              cursorColor: Theme.of(context).primaryColor,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                labelText: 'PIN Baru',
                                labelStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              maxLength:
                                  configAppBloc.pinCount.valueWrapper?.value,
                              keyboardType: TextInputType.number,
                            )
                          : TextFormField(
                              controller: pinBaru,
                              decoration: InputDecoration(
                                labelText: 'PIN Baru',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              maxLength:
                                  configAppBloc.pinCount.valueWrapper?.value,
                              keyboardType: TextInputType.number,
                            ),
                      SizedBox(height: 15),
                      packageName == 'com.eralink.mobileapk'
                          ? TextFormField(
                              controller: pinConfirm,
                              cursorColor: Theme.of(context).primaryColor,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                labelText: 'Ulangi PIN Baru',
                                labelStyle: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              maxLength:
                                  configAppBloc.pinCount.valueWrapper?.value,
                              keyboardType: TextInputType.number,
                            )
                          : TextFormField(
                              controller: pinConfirm,
                              decoration: InputDecoration(
                                labelText: 'Ulangi PIN Baru',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              maxLength:
                                  configAppBloc.pinCount.valueWrapper?.value,
                              keyboardType: TextInputType.number,
                            )
                    ]))
          ]))
        ],
      ),
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
              label: Text('Simpan'),
              icon: Icon(Icons.save),
              onPressed: () => ganti(),
            ),
    );
  }
}
