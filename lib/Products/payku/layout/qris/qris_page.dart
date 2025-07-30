// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/Products/payku/layout/qris.dart';
import 'package:mobile/Products/payku/layout/qris/my_qr.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/kyc/reject.dart';
import 'package:mobile/screen/kyc/verification1.dart';
import 'package:mobile/screen/kyc/waiting.dart';

// ignore: must_be_immutable
class QrisPage extends StatefulWidget {
  int initIndex;

  QrisPage({this.initIndex = 0});

  @override
  _QrisPageState createState() => _QrisPageState();
}

class _QrisPageState extends State<QrisPage>
    with SingleTickerProviderStateMixin {
  Future<int> _kycStatusFuture;
  @override
  void initState() {
    super.initState();
    _kycStatusFuture = _getKycStatus();
  }

  // void showLoading(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         backgroundColor: Colors.transparent,
  //         elevation: 0,
  //         child: Center(
  //           child: SizedBox(
  //             width: 60,
  //             height: 60,
  //             child: CircularProgressIndicator(
  //               strokeWidth: 5,
  //               color: Colors.green,
  //               valueColor: AlwaysStoppedAnimation<Color>(
  //                   Theme.of(context).primaryColor),
  //               backgroundColor: Colors.grey[200],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // void hideLoading(BuildContext context) {
  //   Navigator.of(context, rootNavigator: true).pop();
  // }

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

  // membuat Future untuk dipanggil dalam FutureBuilder
  Future<int> _getKycStatus() async {
    // Tempatkan logika untuk mendapatkan status KYC di sini. Kode berikut hanyalah contoh.
    Map<String, dynamic> userInfo = await getUserInfo();
    Map<String, dynamic> kyc = userInfo['data']['kyc'];
    return kyc == null ? null : kyc['status'];
    // return kyc['status'];
  }

  Widget _getKycPage(int status) {
    if (status == null) {
      return SubmitKyc1();
    }
    switch (status) {
      case 0:
        return WaitingKycPage();
      case 1:
        return MyQrisPage();
      case 2:
        return KycRejectPage();
      default:
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
                    Theme.of(context).primaryColor),
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
        ); // Kembali ke widget loading jika status tidak dikenal
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initIndex,
      child: FutureBuilder<int>(
          future: _kycStatusFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Tampilkan indikator loading ketika data masih dimuat
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
                          Theme.of(context).primaryColor),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              // Tampilkan pesan error jika terjadi kesalahan saat memuat data
              return Text('Error: ${snapshot.error}');
            } else {
              // Jika data telah selesai dimuat, tampilkan TabBarView dengan halaman yang sesuai
              return Scaffold(
                // appBar: AppBar(
                //   automaticallyImplyLeading: false,
                //   backgroundColor: Theme.of(context).primaryColor,
                //   elevation: 0,
                // ),
                body: Column(
                  children: <Widget>[
                    Container(
                      height: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                    Container(
                      color: Theme.of(context).primaryColor,
                      child: Row(
                        children: [
                          Expanded(
                            child: TabBar(
                              indicatorColor:
                                  Theme.of(context).appBarTheme.iconTheme.color,
                              labelColor:
                                  Theme.of(context).appBarTheme.iconTheme.color,
                              unselectedLabelColor: Theme.of(context)
                                  .appBarTheme
                                  .iconTheme
                                  .color
                                  .withOpacity(.7),
                              tabs: [
                                Tab(
                                  child: Text('QRCode'),
                                  icon: Icon(Icons.qr_code_scanner_outlined),
                                ),
                                Tab(
                                  child: Text('QRIS Static'),
                                  icon: Icon(Icons.qr_code),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(physics: ScrollPhysics(), children: [
                        MyQR(),
                        _getKycPage(snapshot.data),
                      ]),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
