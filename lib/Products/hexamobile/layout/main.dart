// @dart=2.9

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/hexamobile/layout/home.dart';
import 'package:mobile/Products/hexamobile/layout/profile.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/Products/hexamobile/layout/history.dart';
import 'package:mobile/screen/kasir/main.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';

class PakaiAjaHome extends StatefulWidget {
  @override
  _PakaiAjaHomeState createState() => _PakaiAjaHomeState();
}

class _PakaiAjaHomeState extends State<PakaiAjaHome> {
  Color mainColor = Colors.white;
  Color mainTextColor = Colors.blue;

  List<Widget> halaman = [
    PakeAjaHome(),
    HistoryPage(),
    MainKasir(),
    ProfilePopay()
  ];
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    print('SETELAH MASUKKAN OTP MASUK KE HALAMAN MAIN BAGIAN HOME.');

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
          child: CachedNetworkImage(
            imageUrl: 'https://dokumen.payuni.co.id/logo/payku/qris.png',
            color: Colors.white,
            width: 40.0,
            height: 40.0,
          ),
          elevation: 0.0,
          onPressed: () async {
            var barcode = await BarcodeScanner.scan();
            if (barcode.rawContent.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TransferByQR(barcode.rawContent)));
            }
            // if (configAppBloc.isKasir.valueWrapper?.value) {
            //   Navigator.of(context).pushNamed('/kasir');
            // } else {
            //   var barcode = await BarcodeScanner.scan();
            //   if (barcode.rawContent.isNotEmpty) {
            //     Navigator.of(context).push(MaterialPageRoute(
            //         builder: (_) => TransferByQR(barcode.rawContent)));
            //   }
            // }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: AppBar(
          title: CachedNetworkImage(
              imageUrl:
                  'https://dokumen.payuni.co.id/logo/hexapay/rebrand/hexamobile.png',
              width: 100.0),
          backgroundColor: Colors.white,
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.chat, color: Theme.of(context).primaryColor),
                onPressed: () {
                  if (configAppBloc.liveChat.valueWrapper?.value != '') {
                    return Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Webview('Live Chat Support',
                            configAppBloc.liveChat.valueWrapper?.value)));
                  } else {
                    return null;
                  }
                }),
            IconButton(
              color: Theme.of(context).primaryColor,
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.of(context).pushNamed('/notifikasi');
              },
            ),
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
                                'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FPakeAja%2Fhistory.png?alt=media&token=6047695d-e0d8-4fdf-b59d-ba7c21c70ab0',
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
                        SvgPicture.asset('assets/img/storefront.svg',
                            color: pageIndex == 2
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                            width: 20.0),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('Kasir', style: TextStyle(fontSize: 10.0))
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
        // bottomNavigationBar: CurvedNavigationBar(
        //   color: Theme.of(context).primaryColor,
        //   backgroundColor: Colors.white.withOpacity(.1),
        //   animationCurve: Curves.fastOutSlowIn,
        //   buttonBackgroundColor: Theme.of(context).primaryColor,
        //   items: <Widget>[
        //     Icon(Icons.apps, size: 30, color: Colors.white),
        //     Icon(Icons.list, size: 30, color: Colors.white),
        //     Icon(Icons.person, size: 30, color: Colors.white),
        //   ],
        //   onTap: (index) {
        //     //Handle button tap
        //     setState(() {
        //       pageIndex = index;
        //     });
        //   },
        // ),
        body: halaman[pageIndex]);
  }
}
