// @dart=2.9

import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQR extends StatefulWidget {
  @override
  _MyQRState createState() => _MyQRState();
}

class _MyQRState extends State<MyQR> {
  bool isScan = false;

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/myqr', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'My QRCode',
    });

    List<String> pkgNameScanQRList = [
      'com.esaldoku.app',
    ];

    pkgNameScanQRList.forEach((element) {
      if (element == packageName) {
        isScan = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('My QRCode')),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: isScan
              ? Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          'Ajak Teman Kamu untuk Scan QR di bawah ini untuk menerima saldo dari mereka',
                          textAlign: TextAlign.center),
                      SizedBox(height: 20.0),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            QrImageView(
                              data: bloc.user.valueWrapper?.value.phone
                                  .toString(),
                              version: QrVersions.auto,
                              size: MediaQuery.of(context).size.width * .75,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              bloc.username.valueWrapper?.value,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            'Ajak Teman Kamu untuk Scan QR di bawah ini untuk menerima saldo dari mereka',
                            textAlign: TextAlign.center),
                        SizedBox(height: 20.0),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              QrImageView(
                                data: bloc.user.valueWrapper?.value.phone
                                    .toString(),
                                version: QrVersions.auto,
                                size: MediaQuery.of(context).size.width * .75,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                              SizedBox(height: 20.0),
                              Text(
                                bloc.username.valueWrapper?.value,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      floatingActionButton: isScan
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () async {
                var barcode = await BarcodeScanner.scan();
                if (barcode.rawContent.isNotEmpty) {
                  return Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => TransferByQR(barcode.rawContent)));
                }
              },
              child: SvgPicture.asset(
                "assets/img/payuni2/scan.svg",
                color: Colors.white,
                height: 33.0,
                width: 33.0,
              ),
            )
          : Container(),
    );
  }
}
