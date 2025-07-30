import 'package:flutter/material.dart';
import 'package:mobile/config.dart';
import 'package:mobile/screen/kyc/verification1.dart';

class NotVerifiedPage extends StatefulWidget {
  @override
  _NotVerifiedPageState createState() => _NotVerifiedPageState();
}

class _NotVerifiedPageState extends State<NotVerifiedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Belum Verifikasi'), centerTitle: true, elevation: 0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(children: <Widget>[
          Spacer(),
          Text(
              'Maaf anda tidak dapat melakukan transaksi ini karena belum melakukan verifikasi. Silahkan lakukan verifikasi akun terlebih dahulu agar dapat melakukan transaksi ini.',
              textAlign: TextAlign.justify),
          Spacer(),
          ButtonTheme(
            minWidth: double.infinity,
            buttonColor: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            textTheme: ButtonTextTheme.primary,
            child: MaterialButton(
                child: Text('Verifikasi Sekarang'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => SubmitKyc1()));
                }),
          )
        ]),
      ),
    );
  }
}
