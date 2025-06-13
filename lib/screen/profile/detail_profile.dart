// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/kyc/reject.dart';
import 'package:mobile/screen/kyc/waiting.dart';
import 'package:mobile/screen/profile/kyc/verification.dart';
import 'package:mobile/screen/kyc/verification1.dart';
import 'package:mobile/screen/profile/my_qris.dart';

class DetailProfile extends StatefulWidget {
  @override
  _DetailProfileState createState() => _DetailProfileState();
}

class _DetailProfileState extends State<DetailProfile> {
  bool loading = true;
  UserModel user;

  @override
  void initState() {
    getData();
    super.initState();
    void initState() {
      analitycs.pageView('/detail/profile', {
        'userId': bloc.userId.valueWrapper?.value,
        'title': 'Detail Profile',
      });
    }
  }

  void getData() async {
    http.Response response = await http.get(Uri.parse('$apiUrl/user/info'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      user = UserModel.fromJson(json.decode(response.body)['data']);
      setState(() {
        loading = false;
      });
    }
  }

  void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: Colors.green,
                valueColor: AlwaysStoppedAnimation<Color>(
                  packageName == 'com.lariz.mobile'
                      ? Theme.of(context).secondaryHeaderColor
                      : Theme.of(context).primaryColor,
                ),
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
        );
      },
    );
  }

  void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await http.get(
      Uri.parse('$apiUrl/user/info'),
      headers: {'Authorization': bloc.token.valueWrapper?.value},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user info');
    }
  }

  void _onVerificationButtonPressed(BuildContext context) async {
    // Menampilkan CircularProgressIndicator yang disesuaikan
    showLoading(context);

    try {
      // Memanggil API dan mendapatkan informasi pengguna
      Map<String, dynamic> userInfo = await getUserInfo();
      Map<String, dynamic> kyc = userInfo['data']['kyc'];

      // Menyembunyikan CircularProgressIndicator yang disesuaikan
      hideLoading(context);

      if (kyc == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SubmitKyc1()),
        );
      } else {
        switch (kyc['status']) {
          case 0: // Dalam Proses
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WaitingKycPage()),
            );
            break;
          case 1: // Sukses
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyQrisPage()),
            );
            break;
          case 2: // Di Tolak
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => KycRejectPage()),
            );
            break;
          default:
            // Anda dapat menangani kondisi default di sini jika diperlukan
            break;
        }
      }
    } catch (error) {
      // Menyembunyikan CircularProgressIndicator yang disesuaikan
      hideLoading(context);

      // Tampilkan pesan kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Profil'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .2,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  packageName == 'com.lariz.mobile'
                      ? Theme.of(context).secondaryHeaderColor
                      : Theme.of(context).primaryColor,
                  Theme.of(context).canvasColor
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                child: Center(
                    child: Icon(Icons.person_outline,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.height * .15))),
            Flexible(
              flex: 1,
              child: loading
                  ? Center(
                      child: SpinKitThreeBounce(
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                          size: 35))
                  : ListView(
                      padding: EdgeInsets.all(15),
                      children: <Widget>[
                        bloc.user.valueWrapper?.value.kyc_verification
                            ? SizedBox()
                            : ButtonTheme(
                                minWidth: double.infinity,
                                // buttonColor: Theme.of(context).primaryColor,
                                height: 40.0,
                                // textTheme: ButtonTextTheme.normal,
                                child: MaterialButton(
                                    color: packageName == 'com.lariz.mobile'
                                        ? Theme.of(context).secondaryHeaderColor
                                        : Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(
                                      'Verifikasi Identitas'.toUpperCase(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () =>
                                        _onVerificationButtonPressed(context))),
                        SizedBox(height: 10),
                        Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(.1),
                                      offset: Offset(5, 10.0),
                                      blurRadius: 20)
                                ]),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('Informasi Pengguna',
                                            style: TextStyle(
                                                color: packageName ==
                                                        'com.lariz.mobile'
                                                    ? Theme.of(context)
                                                        .secondaryHeaderColor
                                                    : Theme.of(context)
                                                        .primaryColor,
                                                fontWeight: FontWeight.bold)),
                                        Icon(
                                          Icons.person,
                                          color: packageName ==
                                                  'com.lariz.mobile'
                                              ? Theme.of(context)
                                                  .secondaryHeaderColor
                                              : Theme.of(context).primaryColor,
                                        )
                                      ]),
                                  Divider(),
                                  SizedBox(height: 15),
                                  Text('ID Pengguna',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                  SizedBox(height: 3),
                                  Text(user.id.toUpperCase(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Text('Nama',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                  SizedBox(height: 3),
                                  Row(
                                    children: <Widget>[
                                      Text(user.nama,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(width: 5),
                                      user.kyc_verification
                                          ? Icon(Icons.verified_user,
                                              color: Colors.green, size: 18)
                                          : SizedBox()
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text('Nomor Telepon',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                  SizedBox(height: 3),
                                  Text(user.phone,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Text(
                                      configAppBloc
                                          .labelSaldo.valueWrapper?.value,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                  SizedBox(height: 3),
                                  Text(formatRupiah(user.saldo),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Text('Komisi',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                  SizedBox(height: 3),
                                  Text(formatRupiah(user.komisi),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Text(
                                      configAppBloc
                                          .labelPoint.valueWrapper?.value,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                  SizedBox(height: 3),
                                  Text(formatNumber(user.poin),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Text('Alamat',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                  SizedBox(height: 3),
                                  Text(user.alamat,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Text('Kecamatan',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                  SizedBox(height: 3),
                                  Text(user.idKecamatan,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Text('Kota',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                  SizedBox(height: 3),
                                  Text(user.idKota,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Text('Provinsi',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                  SizedBox(height: 3),
                                  Text(user.idProvinsi,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ])),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}
