// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/Products/talentapay/layout/history.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/history/history.dart';
import 'package:mobile/screen/transaksi/trx_wait.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/Bloc.dart' show bloc;
import 'package:mobile/bloc/Api.dart';

class VerifikasiPin extends StatefulWidget {
  @override
  _VerifikasiPinState createState() => _VerifikasiPinState();
}

class _VerifikasiPinState extends VerifikasiPinController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/verification/pin',
        {'userId': bloc.userId.valueWrapper?.value, 'title': 'Verifikasi PIN'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: packageName == 'com.lariz.mobile'
              ? Theme.of(context).secondaryHeaderColor
              : Theme.of(context).primaryColor,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Verifikasi PIN',
            style: TextStyle(
              color: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
            )),
        centerTitle: true,
      ),
      body: loading
          ? Container(
              child: Center(
                  child: SpinKitFadingCircle(
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      size: 35)))
          : Container(
              padding: EdgeInsets.all(20),
              child: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SvgPicture.asset('assets/img/unlock.svg',
                      width: MediaQuery.of(context).size.width * .45),
                  SizedBox(height: 15),
                  PinInputTextField(
                      controller: pin,
                      pinLength: configAppBloc.pinCount.valueWrapper?.value,
                      decoration: BoxLooseDecoration(
                          obscureStyle: ObscureStyle(
                              isTextObscure: true, obscureText: '*'),
                          strokeColorBuilder: PinListenColorBuilder(
                            packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                            packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                          ),
                          radius: Radius.circular(5)),
                      keyboardType: TextInputType.number,
                      autoFocus: true,
                      onChanged: (value) {
                        if (value.length ==
                            configAppBloc.pinCount.valueWrapper?.value) {
                          verifikasi();
                        }
                      }),
                ],
              )),
            ),
    );
  }
}

abstract class VerifikasiPinController extends State<VerifikasiPin>
    with TickerProviderStateMixin {
  TextEditingController pin = TextEditingController();
  bool loading = false;

  verifikasi() async {
    if (realtimePrepaid) {
      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        loading = true;
      });
    }
    try {
      http.Response response =
          await http.post(Uri.parse('$apiUrl/user/pin/validate'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': bloc.token.valueWrapper?.value
              },
              body: json.encode({'pin': pin.text}));

      var responseJson = json.decode(response.body);

      if (response.statusCode == 200) {
        await getUserInfo();
        Navigator.of(context).pop(pin.text);
      } else {
        pin.clear();

        return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: Text('Gagal'),
                  content: Text(responseJson['message']),
                  actions: <Widget>[
                    TextButton(
                        child: Text(
                          'TUTUP',
                          style: TextStyle(
                            color: packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop())
                  ]);
            });
      }
    } catch (err) {
      print(err);
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('Terjadi Masalah'),
                content: Text(err.toString()),
                actions: <Widget>[
                  TextButton(
                      child: Text(
                        'TUTUP',
                        style: TextStyle(
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop())
                ]);
          });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> getUserInfo() async {
    http.Response response = await http.get(Uri.parse('$apiUrl/user/info'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});
    if (response.statusCode == 200) {
      UserModel profile =
          UserModel.fromJson(json.decode(response.body)['data']);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('id', profile.id);
      prefs.setString('nama', profile.nama);
      prefs.setInt('saldo', profile.saldo);
      prefs.setInt('poin', profile.poin);
      prefs.setInt('komisi', profile.komisi);
      bloc.userId.add(profile.id);
      bloc.username.add(profile.nama);
      bloc.saldo.add(profile.saldo);
      bloc.poin.add(profile.poin);
      bloc.komisi.add(profile.komisi);
    }
  }
}
