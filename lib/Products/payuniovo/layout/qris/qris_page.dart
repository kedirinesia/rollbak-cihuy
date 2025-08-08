// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/Products/payuniovo/layout/qris.dart';
import 'package:mobile/Products/payuniovo/layout/qris/my_qr.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/kyc/reject.dart';
import 'package:mobile/screen/kyc/verification1.dart';
import 'package:mobile/screen/kyc/waiting.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    print('[DEBUG] Payuniovo QRIS Page: Getting user info...');
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/user/info'),
        headers: {'Authorization': bloc.token.valueWrapper?.value},
      );

      print('[DEBUG] Payuniovo QRIS Page: HTTP status: ${response.statusCode}');
      print('[DEBUG] Payuniovo QRIS Page: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[DEBUG] Payuniovo QRIS Page: User info data: $data');
        return data;
      } else {
        print('[DEBUG] Payuniovo QRIS Page: Failed to load user info, status: ${response.statusCode}');
        throw Exception('Failed to load user info');
      }
    } catch (e) {
      print('[DEBUG] Payuniovo QRIS Page: Exception getting user info: $e');
      throw e;
    }
  }

  // membuat Future untuk dipanggil dalam FutureBuilder
  Future<int> _getKycStatus() async {
    print('[DEBUG] Payuniovo QRIS Page: Getting KYC status...');
    try {
      // Tempatkan logika untuk mendapatkan status KYC di sini. Kode berikut hanyalah contoh.
      Map<String, dynamic> userInfo = await getUserInfo();
      Map<String, dynamic> kyc = userInfo['data']['kyc'];
      int status = kyc == null ? null : kyc['status'];
      print('[DEBUG] Payuniovo QRIS Page: KYC status: $status');
      return status;
    } catch (e) {
      print('[DEBUG] Payuniovo QRIS Page: Exception getting KYC status: $e');
      return null;
    }
    // return kyc['status'];
  }

  Widget _getKycPage(int status) {
    print('[DEBUG] Payuniovo QRIS Page: Getting KYC page for status: $status');
    if (status == null) {
      print('[DEBUG] Payuniovo QRIS Page: Status null, showing text only');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                FaIcon(FontAwesomeIcons.idCard, color: Colors.orange, size: 130),
                const SizedBox(height: 16),
              Text(
                "Butuh Verifikasi KYC",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Untuk pendaftaran qris akun anda harus melakukan verifikasi kyc terlebih dahulu pada menu \n profile -> profile detail -> verifikasi",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    switch (status) {
      case 0:
        print('[DEBUG] Payuniovo QRIS Page: Status 0, showing WaitingKycPage');
        return WaitingKycPage();
      case 1:
        print('[DEBUG] Payuniovo QRIS Page: Status 1, showing MyQrisPage');
        return MyQrisPage();
      case 2:
        print('[DEBUG] Payuniovo QRIS Page: Status 2, showing text only');
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.idCard, color: Colors.orange, size: 60),
                const SizedBox(height: 16),
                Text(
                  "Butuh Verifikasi KYC",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Untuk pendaftaran qris akun anda harus melakukan verifikasi kyc terlebih dahulu pada menu \n profile -> profile detail -> verifikasi",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        );
      default:
        print('[DEBUG] Payuniovo QRIS Page: Unknown status $status, showing loading dialog');
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
    print('[DEBUG] Payuniovo QRIS Page: Building QRIS page with initIndex: ${widget.initIndex}');
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initIndex,
      child: FutureBuilder<int>(
          future: _kycStatusFuture,
          builder: (context, snapshot) {
            print('[DEBUG] Payuniovo QRIS Page: Connection state: ${snapshot.connectionState}');
            print('[DEBUG] Payuniovo QRIS Page: Has error: ${snapshot.hasError}');
            print('[DEBUG] Payuniovo QRIS Page: Has data: ${snapshot.hasData}');
            if (snapshot.hasData) {
              print('[DEBUG] Payuniovo QRIS Page: KYC status data: ${snapshot.data}');
            }
            if (snapshot.hasError) {
              print('[DEBUG] Payuniovo QRIS Page: Error: ${snapshot.error}');
            }
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Tampilkan indikator loading ketika data masih dimuat
              print('[DEBUG] Payuniovo QRIS Page: Showing loading dialog');
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
              print('[DEBUG] Payuniovo QRIS Page: Showing error message');
              return Text('Error: ${snapshot.error}');
            } else {
              // Jika data telah selesai dimuat, tampilkan TabBarView dengan halaman yang sesuai
              print('[DEBUG] Payuniovo QRIS Page: Showing main QRIS interface');
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
