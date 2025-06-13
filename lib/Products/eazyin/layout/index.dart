// @dart=2.9

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/Products/eazyin/layout/home.dart';
import 'package:mobile/Products/eazyin/layout/history.dart';
import 'package:mobile/Products/eazyin/layout/profile.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/screen/kasir/main.dart';
import 'package:mobile/screen/profile/downline/downline.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';

class EpulsaHome extends StatefulWidget {
  @override
  _EpulsaHomeState createState() => _EpulsaHomeState();
}

class _EpulsaHomeState extends State<EpulsaHome> {
  Color mainColor = Colors.white;
  Color mainTextColor = Colors.blue;

  List<Widget> halaman = [
    Home4App(),
    HistoryPage(),
    DownlinePage(),
    ProfilePage()
  ];

  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    bloc.mainColor
      ..listen((Color color) {
        setState(() {
          mainColor = color;
        });
      });
    bloc.mainTextColor
      ..listen((Color color) {
        setState(() {
          mainTextColor = color;
        });
      });

    changePrimaryColor();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changePrimaryColor() {
    if (mounted) {
      setState(() {
        mainTextColor = Colors.purple;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: configAppBloc.isKasir.valueWrapper?.value
            ? InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('/kasir');
                },
                child: SvgPicture.asset('assets/img/storefront.svg',
                    width: 28.0, color: Colors.white),
              )
            : CachedNetworkImage(
                imageUrl:
                    'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fqr-code-scan%20(1).png?alt=media&token=9c6c8655-238f-4c93-9b1e-f5176a7d1dcb'),
        elevation: 0.0,
        onPressed: () async {
          if (configAppBloc.isKasir.valueWrapper?.value) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => MainKasir()));
          } else {
            var barcode = await BarcodeScanner.scan();
            if (barcode.rawContent.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TransferByQR(barcode.rawContent)));
            }
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Theme.of(context).primaryColor,
      //   child: CachedNetworkImage(
      //       imageUrl:
      //           'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fqr-code-scan%20(1).png?alt=media&token=9c6c8655-238f-4c93-9b1e-f5176a7d1dcb',
      //       width: 32.0,
      //       color: Colors.white),
      //   elevation: 0.0,
      //   onPressed: () async {
      //     String barcode = (await BarcodeScanner.scan()).toString();
      //     print(barcode);
      //     if (barcode.isNotEmpty) {
      //       return Navigator.of(context)
      //           .push(MaterialPageRoute(builder: (_) => TransferByQR(barcode)));
      //     }
      //   },
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: configAppBloc.iconApp.valueWrapper?.value['logoLogin'] != null
            ? CachedNetworkImage(
                imageUrl:
                    'https://dokumen.payuni.co.id/logo/eazyin/logohomeapk.png',
                width: 75.0)
            : Text(configAppBloc.namaApp.valueWrapper?.value),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
        actions: <Widget>[
          configAppBloc.liveChat.valueWrapper?.value != ''
              ? IconButton(
                  icon: Icon(Icons.chat, color: Colors.white),
                  onPressed: () {
                    if (configAppBloc.liveChat.valueWrapper?.value != '') {
                      return Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Webview('Live Chat Support',
                              configAppBloc.liveChat.valueWrapper?.value)));
                    } else {
                      return null;
                    }
                  })
              : Container(),
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamed('/notifikasi');
            },
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5.0,
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
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FPakeAja%2Fdashboard.png?alt=media&token=0794cc0a-16ef-48f8-8625-17d450c61680',
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
              SizedBox(width: 20.0),
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
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fepulsa%2Fhistory_inactive.png?alt=media&token=2b5c6539-d5e2-41d1-8915-a010e012b94a',
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
              SizedBox(width: 80.0),
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
                          imageUrl:
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FPakeAja%2Ffriendship.png?alt=media&token=f8d24fd1-7e7b-4cbd-8dbf-5b382fc2a825',
                          color: pageIndex == 2
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 20.0),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text('Keagenan', style: TextStyle(fontSize: 10.0))
                    ],
                  ),
                ),
              ),
              SizedBox(width: 20.0),
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
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FPakeAja%2Fyoung.png?alt=media&token=1c94548d-8480-4530-add4-58b90522e4a8',
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
      body: halaman[pageIndex],
    );
  }
}

class DownlinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<bool> _onBackPressed() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              configAppBloc.layoutApp?.valueWrapper?.value['home'] ??
              templateConfig[configAppBloc.templateCode.valueWrapper?.value],
        ),
      );
      return Future.value(true);
    }

    return WillPopScope(onWillPop: _onBackPressed, child: Downline());
  }
}
