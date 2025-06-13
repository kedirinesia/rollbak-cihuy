// @dart=2.9

import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/Products/oneshop/layout/cs.dart';
import 'package:mobile/Products/oneshop/layout/home1.dart';
import 'package:mobile/Products/oneshop/layout/profile.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/Products/oneshop/layout/history.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';

class HomePopay extends StatefulWidget {
  @override
  _HomePopayState createState() => _HomePopayState();
}

class _HomePopayState extends State<HomePopay> {
  int pageIndex = 0;
  List<Widget> halaman = [
    PayuniHome(),
    HistoryPage(),
    CustomerServicePage(),
    ProfilePopay()
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: configAppBloc.isMarketplace.valueWrapper?.value
            ? Icon(Icons.qr_code_scanner_rounded)
            : CachedNetworkImage(
                imageUrl:
                    'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fqr-code-scan%20(1).png?alt=media&token=9c6c8655-238f-4c93-9b1e-f5176a7d1dcb'),
        elevation: 0.0,
        onPressed: () async {
          var barcode = await BarcodeScanner.scan();
          if (barcode.rawContent.isNotEmpty) {
            return Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TransferByQR(barcode.rawContent),
              ),
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: halaman[pageIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
          padding: EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      pageIndex = 0;
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      CachedNetworkImage(
                          imageUrl:
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fcombined_shape.png?alt=media&token=2d78122e-51a2-4a0b-9e6e-ed699b8a5758',
                          color: pageIndex == 0
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 20.0),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text('Home', style: TextStyle(fontSize: 10.0))
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      pageIndex = 1;
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      CachedNetworkImage(
                          imageUrl:
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fhistory_inactive.png?alt=media&token=04704026-de7b-4dca-838f-ab5fdd6802be',
                          color: pageIndex == 1
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 20.0),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text('History', style: TextStyle(fontSize: 10.0))
                    ],
                  ),
                ),
              ),
              SizedBox(width: 40.0),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      pageIndex = 2;
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      CachedNetworkImage(
                          imageUrl: 'https://www.payuni.co.id/img/lc.png',
                          color: pageIndex == 2
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 20.0),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text('Livechat', style: TextStyle(fontSize: 10.0))
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      pageIndex = 3;
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      CachedNetworkImage(
                          imageUrl:
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fprofile-home.png?alt=media&token=65f46061-2ae6-48ba-8e61-dfddec73706f',
                          color: pageIndex == 3
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 20.0),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text('Profile', style: TextStyle(fontSize: 10.0))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
