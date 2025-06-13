// @dart=2.9

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/xenaja/layout/qris/qris_page.dart';
import 'package:mobile/Products/xenaja/layout/transfer.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';

class MenuToolPopay extends StatefulWidget {
  @override
  _MenuToolPopayState createState() => _MenuToolPopayState();
}

class _MenuToolPopayState extends State<MenuToolPopay> {
  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      children: <Widget>[
        InkWell(
          onTap: () async {
            var barcode = await BarcodeScanner.scan();
            if (barcode.rawContent.isNotEmpty) {
              return Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TransferByQR(barcode.rawContent)));
            }
          },
          child: Container(
            child: Column(
              children: <Widget>[
                MenuGrid(
                  imageUrl:
                      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fqr-code-scan%20(1).png?alt=media&token=9c6c8655-238f-4c93-9b1e-f5176a7d1dcb',
                  label: 'QRIS',
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/topup');
          },
          child: Container(
            child: Column(
              children: <Widget>[
                MenuGrid(
                  imageUrl:
                      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fadd-circle.png?alt=media&token=d3e90f2e-b4cb-4833-9d47-5f19d5884a49',
                  label: 'Deposit',
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => TransferPagePopay()));
          },
          child: Container(
            child: Column(
              children: <Widget>[
                MenuGrid(
                  imageUrl:
                      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fsend.png?alt=media&token=2e13bce4-488c-42d3-86ec-7dfa265d3487',
                  label: 'Transfer',
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => QrisPage()));
          },
          child: Container(
            child: Column(
              children: <Widget>[
                MenuGrid(
                  imageUrl:
                      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2FReceive.png?alt=media&token=aa730aa8-0380-4d66-bf55-89b8d422d20b',
                  label: 'Mutasi',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MenuGrid extends StatelessWidget {
  final String imageUrl;
  final String label;

  MenuGrid({this.imageUrl, this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(top: 15),
        // color: Colors.amber,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 30,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10.0),
            Align(
              alignment: Alignment.center,
              child: Text(label ?? '-',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.0, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
